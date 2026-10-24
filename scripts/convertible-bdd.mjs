// Parser and semantic checker for Convertible BDD (spec/convertible-bdd.ebnf).
//
// The grammar is line oriented: a Feature line, then Scenario blocks, each made of one Given
// clause (with optional And predicates), exactly one When clause, one Then clause, and optional
// And effects. Clause bodies are parsed by a small recursive-descent parser that follows the EBNF
// productions for Predicate, Expression, Event, and Effect, including its single-space rules.
//
// Exports:
//   parseFeature(text)  -> AST  (throws ConvertibleBddError on a syntax error)
//   checkFeature(ast)   -> string[] of semantic problems that need no type declarations
//   vocabulary(ast)     -> { inputs, actions, states, emits } summary of the symbols used

export class ConvertibleBddError extends Error {
  constructor(message, line) {
    super(line ? `line ${line}: ${message}` : message);
    this.name = "ConvertibleBddError";
    this.line = line;
  }
}

const IDENTIFIER = /^[A-Za-z][A-Za-z0-9_]*$/;
const RESERVED = new Set(["not", "and", "or", "emit", "complete", "error", "nothing", "true", "false", "null"]);
const COMPARE_OPS = ["==", "!=", ">=", "<=", ">", "<"];
const BINARY_OPS = new Set(["+", "-", "*", "/", "%"]);

// ---------------------------------------------------------------------------
// Clause-body parser
// ---------------------------------------------------------------------------
class BodyParser {
  constructor(text, line) {
    this.text = text;
    this.line = line;
    this.pos = 0;
  }

  fail(message) {
    throw new ConvertibleBddError(`${message} at column ${this.pos + 1} in "${this.text}"`, this.line);
  }

  peek(n = 1) {
    return this.text.slice(this.pos, this.pos + n);
  }

  startsWith(literal) {
    return this.text.startsWith(literal, this.pos);
  }

  consume(literal) {
    if (!this.startsWith(literal)) this.fail(`expected "${literal}"`);
    this.pos += literal.length;
  }

  optionalSpace() {
    if (this.peek() === " ") {
      this.pos += 1;
      if (this.peek() === " ") this.fail("only a single space is allowed here");
    }
  }

  atEnd() {
    return this.pos >= this.text.length;
  }

  expectEnd() {
    if (!this.atEnd()) this.fail("unexpected trailing input");
  }

  // Predicate = Comparison | "not" Predicate | "(" Predicate ")" | Predicate "and" Predicate | Predicate "or" Predicate
  parsePredicate() {
    let left = this.parseAndPredicate();
    while (this.startsWith(" or ")) {
      this.pos += 4;
      const right = this.parseAndPredicate();
      left = { type: "or", left, right };
    }
    return left;
  }

  parseAndPredicate() {
    let left = this.parseUnaryPredicate();
    while (this.startsWith(" and ")) {
      this.pos += 5;
      const right = this.parseUnaryPredicate();
      left = { type: "and", left, right };
    }
    return left;
  }

  parseUnaryPredicate() {
    if (this.startsWith("not ")) {
      this.pos += 4;
      return { type: "not", operand: this.parseUnaryPredicate() };
    }
    if (this.peek() === "(") {
      const saved = this.pos;
      try {
        this.pos += 1;
        const inner = this.parsePredicate();
        this.consume(")");
        return { type: "group", inner };
      } catch (error) {
        if (!(error instanceof ConvertibleBddError)) throw error;
        this.pos = saved; // a parenthesised expression, not a predicate
      }
    }
    return this.parseComparison();
  }

  parseComparison() {
    const left = this.parseExpression();
    this.optionalSpace();
    const op = COMPARE_OPS.find((candidate) => this.startsWith(candidate));
    if (!op) this.fail("expected a comparison operator (==, !=, >=, <=, >, <)");
    this.pos += op.length;
    this.optionalSpace();
    const right = this.parseExpression();
    return { type: "compare", op, left, right };
  }

  // Expression = Primary { Space? BinaryOp Space? Primary }
  parseExpression() {
    let left = this.parsePrimary();
    for (;;) {
      const saved = this.pos;
      this.optionalSpace();
      const op = this.peek();
      if (!BINARY_OPS.has(op) || this.startsWith("==") ) {
        this.pos = saved;
        break;
      }
      this.pos += 1;
      this.optionalSpace();
      const right = this.parsePrimary();
      left = { type: "binary", op, left, right };
    }
    return left;
  }

  // Primary = Literal | Identifier | StatePath | Event | "(" Expression ")"
  parsePrimary() {
    const ch = this.peek();
    if (ch === '"') return this.parseString();
    if (/[0-9]/.test(ch) || (ch === "-" && /[0-9]/.test(this.peek(2)[1] ?? ""))) return this.parseNumber();
    if (ch === "(") {
      this.pos += 1;
      const inner = this.parseExpression();
      this.consume(")");
      return { type: "paren", inner };
    }
    if (/[A-Za-z]/.test(ch)) return this.parseNameOrCall();
    this.fail("expected a literal, identifier, state path, event, or parenthesised expression");
  }

  parseString() {
    this.consume('"');
    let value = "";
    while (!this.atEnd() && this.peek() !== '"') {
      if (this.peek() === "\\") {
        value += this.peek(2);
        this.pos += 2;
      } else {
        value += this.peek();
        this.pos += 1;
      }
    }
    this.consume('"');
    return { type: "string", value };
  }

  parseNumber() {
    const match = /^-?[0-9]+(\.[0-9]+)?/.exec(this.text.slice(this.pos));
    this.pos += match[0].length;
    return { type: "number", value: Number(match[0]) };
  }

  parseQualifiedIdentifier() {
    const match = /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*/.exec(this.text.slice(this.pos));
    if (!match) this.fail("expected an identifier");
    this.pos += match[0].length;
    return match[0];
  }

  parseNameOrCall() {
    const name = this.parseQualifiedIdentifier();
    if (this.peek() === "(") {
      if (RESERVED.has(name)) this.fail(`"${name}" is reserved`);
      return { type: "call", name, args: this.parseArguments() };
    }
    if (name === "true" || name === "false") return { type: "boolean", value: name === "true" };
    if (name === "null") return { type: "null" };
    if (RESERVED.has(name)) this.fail(`"${name}" is reserved`);
    return { type: "path", name };
  }

  // ArgumentList = Expression { "," Space? Expression }
  parseArguments() {
    this.consume("(");
    const args = [];
    if (this.peek() === ")") {
      this.pos += 1;
      return args;
    }
    args.push(this.parseExpression());
    while (this.peek() === ",") {
      this.pos += 1;
      this.optionalSpace();
      args.push(this.parseExpression());
    }
    this.consume(")");
    return args;
  }

  // Event = QualifiedIdentifier "(" [ ArgumentList ] ")"
  parseEvent() {
    const name = this.parseQualifiedIdentifier();
    if (RESERVED.has(name)) this.fail(`"${name}" is reserved`);
    if (this.peek() !== "(") this.fail("an event must be a call with parentheses");
    return { type: "call", name, args: this.parseArguments() };
  }

  // Effect = Assignment | EmitEffect | ActionCall | "complete" | "error" Expression | "nothing"
  parseEffect() {
    if (this.text === "complete") {
      this.pos = this.text.length;
      return { type: "complete" };
    }
    if (this.text === "nothing") {
      this.pos = this.text.length;
      return { type: "nothing" };
    }
    if (this.startsWith("emit ")) {
      this.pos += 5;
      if (this.text.slice(this.pos) === "nothing") {
        this.pos = this.text.length;
        return { type: "emit", value: null };
      }
      return { type: "emit", value: this.parseExpression() };
    }
    if (this.startsWith("error ")) {
      this.pos += 6;
      return { type: "error", value: this.parseExpression() };
    }
    const name = this.parseQualifiedIdentifier();
    if (RESERVED.has(name)) this.fail(`"${name}" is reserved`);
    if (this.peek() === "(") return { type: "action", call: { type: "call", name, args: this.parseArguments() } };
    this.optionalSpace();
    if (this.startsWith("==")) this.fail('an assignment uses a single "="');
    this.consume("=");
    this.optionalSpace();
    return { type: "assign", target: name, value: this.parseExpression() };
  }
}

function parseBody(text, line, method) {
  const parser = new BodyParser(text, line);
  const node = parser[method]();
  parser.expectEnd();
  return node;
}

// ---------------------------------------------------------------------------
// Document parser
// ---------------------------------------------------------------------------
const CLAUSE = /^(?: {2}| {4}|\t)(Given|And|When|Then) (.+)$/;
const FEATURE = /^Feature: ?([A-Za-z][A-Za-z0-9_]*)$/;
const SCENARIO = /^Scenario: ?([A-Za-z][A-Za-z0-9_]*)$/;

export function parseFeature(text) {
  const lines = text.split(/\r?\n/);
  if (lines.length && lines[lines.length - 1] === "") lines.pop(); // final Newline
  const featureMatch = FEATURE.exec(lines[0] ?? "");
  if (!featureMatch) throw new ConvertibleBddError('expected "Feature: <Identifier>"', 1);
  const feature = { name: featureMatch[1], scenarios: [] };

  let i = 1;
  const clauseAt = (index, expected) => {
    const line = lines[index];
    const match = line === undefined ? null : CLAUSE.exec(line);
    if (!match || (expected && !expected.includes(match[1]))) {
      throw new ConvertibleBddError(
        `expected ${expected ? expected.map((k) => `"${k}"`).join(" or ") : "a clause"} clause`,
        index + 1,
      );
    }
    return { keyword: match[1], body: match[2] };
  };

  while (i < lines.length) {
    const line = lines[i];
    if (line === "") {
      i += 1;
      continue;
    }
    const scenarioMatch = SCENARIO.exec(line);
    if (!scenarioMatch) throw new ConvertibleBddError('expected "Scenario: <Identifier>" or a blank line', i + 1);
    const scenario = { name: scenarioMatch[1], line: i + 1, given: [], givenText: [], when: null, whenText: "", then: [], thenText: [] };
    i += 1;

    const given = clauseAt(i, ["Given"]);
    scenario.given.push(parseBody(given.body, i + 1, "parsePredicate"));
    scenario.givenText.push(given.body);
    i += 1;
    while (lines[i] !== undefined && CLAUSE.exec(lines[i])?.[1] === "And") {
      const and = clauseAt(i, ["And"]);
      scenario.given.push(parseBody(and.body, i + 1, "parsePredicate"));
      scenario.givenText.push(and.body);
      i += 1;
    }

    const when = clauseAt(i, ["When"]);
    scenario.when = parseBody(when.body, i + 1, "parseEvent");
    scenario.whenText = when.body;
    i += 1;

    const then = clauseAt(i, ["Then"]);
    scenario.then.push(parseBody(then.body, i + 1, "parseEffect"));
    scenario.thenText.push(then.body);
    i += 1;
    while (lines[i] !== undefined && CLAUSE.exec(lines[i])?.[1] === "And") {
      const and = clauseAt(i, ["And"]);
      scenario.then.push(parseBody(and.body, i + 1, "parseEffect"));
      scenario.thenText.push(and.body);
      i += 1;
    }

    feature.scenarios.push(scenario);
  }
  return feature;
}

// ---------------------------------------------------------------------------
// Semantic checks that need no declarations
// ---------------------------------------------------------------------------
export function checkFeature(feature) {
  const problems = [];
  const names = new Set();
  const eventArity = new Map();
  const actionArity = new Map();
  const transitions = new Map();

  for (const scenario of feature.scenarios) {
    const where = `${feature.name}/${scenario.name} (line ${scenario.line})`;

    if (names.has(scenario.name)) problems.push(`${where}: duplicate scenario name`);
    names.add(scenario.name);

    const eventName = scenario.when.name;
    const arity = scenario.when.args.length;
    if (eventArity.has(eventName) && eventArity.get(eventName) !== arity) {
      problems.push(`${where}: event ${eventName} used with ${arity} arguments, elsewhere with ${eventArity.get(eventName)}`);
    }
    eventArity.set(eventName, arity);

    const inputs = new Set(scenario.when.args.filter((arg) => arg.type === "path").map((arg) => arg.name.split(".")[0]));
    let terminated = false;
    for (const effect of scenario.then) {
      if (effect.type === "assign") {
        const root = effect.target.split(".")[0];
        if (inputs.has(root)) problems.push(`${where}: assignment to "${effect.target}" mutates an input of ${eventName}`);
      }
      if (effect.type === "action") {
        const callArity = effect.call.args.length;
        if (actionArity.has(effect.call.name) && actionArity.get(effect.call.name) !== callArity) {
          problems.push(`${where}: action ${effect.call.name} called with ${callArity} arguments, elsewhere with ${actionArity.get(effect.call.name)}`);
        }
        actionArity.set(effect.call.name, callArity);
      }
      if (effect.type === "emit" && terminated) problems.push(`${where}: emit after complete or error`);
      if (effect.type === "complete" || effect.type === "error") {
        if (terminated) problems.push(`${where}: more than one terminal effect`);
        terminated = true;
      }
    }
    if (scenario.then.some((effect) => effect.type === "nothing") && scenario.then.length > 1) {
      problems.push(`${where}: "nothing" combined with other effects`);
    }

    const key = `${eventName}|${scenario.givenText.join(" and ")}`;
    if (transitions.has(key)) {
      problems.push(`${where}: same event and guard as scenario ${transitions.get(key)} (non-deterministic)`);
    } else {
      transitions.set(key, scenario.name);
    }
  }
  return problems;
}

// ---------------------------------------------------------------------------
// Vocabulary extraction
// ---------------------------------------------------------------------------
export function vocabulary(feature) {
  const inputs = new Map();
  const actions = new Map();
  const states = new Set();
  let emits = 0;
  for (const scenario of feature.scenarios) {
    inputs.set(scenario.when.name, scenario.when.args.length);
    for (const effect of scenario.then) {
      if (effect.type === "assign") states.add(effect.target);
      if (effect.type === "action") actions.set(effect.call.name, effect.call.args.length);
      if (effect.type === "emit" && effect.value) emits += 1;
    }
  }
  return { inputs, actions, states, emits };
}
