// Parser and semantic checker for the Mealy DSL (spec/mealy.ebnf).
//
// The Mealy DSL is the machine-oriented sibling of Convertible BDD: it makes state, input,
// output, action, and transition explicit, with a declaration section the Convertible BDD layer
// does not have. This module parses it and uses those declarations to check the semantic
// constraints that `scripts/convertible-bdd.mjs` cannot (symbol resolution and arity, constraints
// 1 to 4 of docs/formal-language.md).
//
// The sub-expression language (Predicate, Expression, Event, Assignment) is shared with
// Convertible BDD, so this parser reuses that grammar's BodyParser rather than duplicating it.
//
// Exports:
//   parseMachine(text)    -> machine AST (throws MealyError on a syntax error)
//   checkMachine(ast)     -> string[] of semantic problems
//   toSemanticModel(ast)  -> object matching spec/machine-semantic-model.schema.json
//   generateMealy(model)  -> Mealy DSL text for a Machine Semantic Model (inverse of parse + project)
//   serializeExpr / serializePredicate -> canonical source text for an expression / predicate

import { readFileSync } from "node:fs";
import { pathToFileURL } from "node:url";
import { BodyParser, ConvertibleBddError } from "./convertible-bdd.mjs";

export class MealyError extends Error {
  constructor(message, line) {
    super(line ? `line ${line}: ${message}` : message);
    this.name = "MealyError";
    this.line = line;
  }
}

const PATH = /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*$/;
const TYPE_REF = /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*(<.+>)?$/;
const MACHINE_OPEN = /^machine\s+([A-Za-z][A-Za-z0-9_]*)\s*\{$/;
const BLOCK_OPEN = /^(state|initial|input|output|action)\s*\{$/;
const TRANSITION_OPEN = /^transition\s+([A-Za-z][A-Za-z0-9_]*)\s*\{$/;
const CLOSE = /^\}$/;

// Parse one shared sub-body (predicate / expression / event / assignment) and rewrap any
// Convertible BDD syntax error as a MealyError carrying the Mealy line number.
function sub(text, line, method) {
  const parser = new BodyParser(text, line);
  try {
    const node = parser[method]();
    parser.expectEnd();
    return node;
  } catch (error) {
    if (error instanceof ConvertibleBddError) throw new MealyError(error.message.replace(/^line \d+: /, ""), line);
    throw error;
  }
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------
export function parseMachine(text) {
  const lines = text.split(/\r?\n/);
  let i = 0;
  const trimmed = () => (lines[i] ?? "").trim();
  const lineNo = () => i + 1;
  const fail = (message) => {
    throw new MealyError(message, lineNo());
  };
  const skipBlanks = () => {
    while (i < lines.length && trimmed() === "") i += 1;
  };

  function splitParameters(inner) {
    const parts = [];
    let depth = 0;
    let current = "";
    for (const ch of inner) {
      if (ch === "<") depth += 1;
      else if (ch === ">") depth -= 1;
      if (ch === "," && depth === 0) {
        parts.push(current);
        current = "";
      } else {
        current += ch;
      }
    }
    parts.push(current);
    return parts;
  }

  function parseStateField(body) {
    const colon = body.indexOf(":");
    if (colon < 0) fail(`expected "<path>: <Type>" in state field "${body}"`);
    const path = body.slice(0, colon).trim();
    const type = body.slice(colon + 1).trim();
    if (!PATH.test(path)) fail(`invalid state path "${path}"`);
    if (!TYPE_REF.test(type)) fail(`invalid type "${type}" for "${path}"`);
    return { path, type };
  }

  function parseSignature(body) {
    const match = /^([A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)*)\((.*)\)$/.exec(body);
    if (!match) fail(`expected "<name>(<parameters>)" in signature "${body}"`);
    const name = match[1];
    const inner = match[2].trim();
    const parameters = [];
    if (inner !== "") {
      for (const part of splitParameters(inner)) {
        const parameter = /^([A-Za-z][A-Za-z0-9_]*)\s*:\s*(.+)$/.exec(part.trim());
        if (!parameter) fail(`invalid parameter "${part.trim()}" in "${body}"`);
        if (!TYPE_REF.test(parameter[2].trim())) fail(`invalid type "${parameter[2].trim()}" in "${body}"`);
        parameters.push({ name: parameter[1], type: parameter[2].trim() });
      }
    }
    return { name, parameters };
  }

  function collectUntilClose(handle) {
    for (;;) {
      skipBlanks();
      if (i >= lines.length) fail('expected "}" to close the block');
      const text_ = trimmed();
      if (CLOSE.test(text_)) {
        i += 1;
        return;
      }
      handle(text_);
      i += 1;
    }
  }

  function statement(raw) {
    if (!raw.endsWith(";")) fail(`expected ";" at the end of "${raw}"`);
    return raw.slice(0, -1).trim();
  }

  function parseBlock(kind, machine) {
    collectUntilClose((raw) => {
      const body = statement(raw);
      if (kind === "state") machine.state.push(parseStateField(body));
      else if (kind === "initial") machine.initial.push(sub(body, lineNo(), "parseAssignment"));
      else machine[kind === "input" ? "inputs" : kind === "output" ? "outputs" : "actions"].push(parseSignature(body));
    });
  }

  function parseTransitionStatement(transition, body) {
    if (body === "complete") {
      transition.actions.push({ kind: "complete" });
    } else if (body.startsWith("then ")) {
      transition.updates.push(sub(body.slice(5), lineNo(), "parseAssignment"));
    } else if (body.startsWith("error ")) {
      transition.actions.push({ kind: "error", value: sub(body.slice(6), lineNo(), "parseExpression") });
    } else if (body.startsWith("do ")) {
      transition.actions.push({ kind: "do", call: sub(body.slice(3), lineNo(), "parseEvent") });
    } else if (body === "emit nothing") {
      transition.actions.push({ kind: "nothing" });
    } else if (body.startsWith("emit ")) {
      transition.actions.push({ kind: "emit", value: sub(body.slice(5), lineNo(), "parseExpression") });
    } else {
      fail(`unknown transition statement "${body}"`);
    }
  }

  function parseTransition(name, machine) {
    const transition = { name, guard: null, input: null, updates: [], actions: [] };
    let stage = 0; // 0 = expect given, 1 = expect when, 2 = body
    collectUntilClose((raw) => {
      const body = statement(raw);
      if (stage === 0) {
        if (!body.startsWith("given ")) fail('a transition must start with "given <predicate>;"');
        transition.guard = sub(body.slice(6), lineNo(), "parsePredicate");
        stage = 1;
      } else if (stage === 1) {
        if (!body.startsWith("when ")) fail('"given" must be followed by "when <event>;"');
        transition.input = sub(body.slice(5), lineNo(), "parseEvent");
        stage = 2;
      } else {
        parseTransitionStatement(transition, body);
      }
    });
    if (stage < 2) fail(`transition ${name} needs both a "given" and a "when"`);
    machine.transitions.push(transition);
  }

  skipBlanks();
  const open = MACHINE_OPEN.exec(trimmed());
  if (!open) fail('expected "machine <Name> {"');
  const machine = { name: open[1], state: [], initial: [], inputs: [], outputs: [], actions: [], transitions: [] };
  i += 1;

  const seen = new Set();
  for (;;) {
    skipBlanks();
    if (i >= lines.length) fail('expected "}" to close the machine');
    const text_ = trimmed();
    if (CLOSE.test(text_)) {
      i += 1;
      break;
    }
    const block = BLOCK_OPEN.exec(text_);
    const transition = TRANSITION_OPEN.exec(text_);
    if (block) {
      if (seen.has(block[1])) fail(`duplicate "${block[1]}" block`);
      seen.add(block[1]);
      i += 1;
      parseBlock(block[1], machine);
    } else if (transition) {
      i += 1;
      parseTransition(transition[1], machine);
    } else {
      fail(`expected a declaration block or a transition, got "${text_}"`);
    }
  }
  skipBlanks();
  if (i < lines.length) fail(`unexpected content after the machine: "${trimmed()}"`);
  return machine;
}

// ---------------------------------------------------------------------------
// Semantic checks (use the declarations)
// ---------------------------------------------------------------------------
function collectExprRefs(node, out) {
  switch (node.type) {
    case "path": out.push(node.name); break;
    case "paren": collectExprRefs(node.inner, out); break;
    case "binary": collectExprRefs(node.left, out); collectExprRefs(node.right, out); break;
    case "call": for (const arg of node.args) collectExprRefs(arg, out); break;
    default: break; // literals reference nothing
  }
  return out;
}

function collectPredicateRefs(node, out) {
  switch (node.type) {
    case "and":
    case "or": collectPredicateRefs(node.left, out); collectPredicateRefs(node.right, out); break;
    case "not": collectPredicateRefs(node.operand, out); break;
    case "group": collectPredicateRefs(node.inner, out); break;
    case "compare": collectExprRefs(node.left, out); collectExprRefs(node.right, out); break;
    default: break;
  }
  return out;
}

export function checkMachine(machine) {
  const problems = [];
  const add = (message) => problems.push(message);

  const statePaths = new Set();
  for (const field of machine.state) {
    if (statePaths.has(field.path)) add(`duplicate state field "${field.path}"`);
    statePaths.add(field.path);
  }
  const signatures = (list, label) => {
    const arity = new Map();
    for (const signature of list) {
      if (arity.has(signature.name)) add(`duplicate ${label} "${signature.name}"`);
      arity.set(signature.name, signature.parameters.length);
    }
    return arity;
  };
  const inputs = signatures(machine.inputs, "input");
  const outputs = signatures(machine.outputs, "output");
  const actions = signatures(machine.actions, "action");

  for (const assignment of machine.initial) {
    if (!statePaths.has(assignment.target)) add(`initial value assigns undeclared state "${assignment.target}"`);
  }

  const names = new Set();
  const keys = new Map();
  for (const transition of machine.transitions) {
    const where = transition.name;
    if (names.has(where)) add(`duplicate transition name "${where}"`);
    names.add(where);

    // constraint 2 / 6: the input event is declared and used with its declared arity.
    const inputArity = inputs.get(transition.input.name);
    if (inputArity === undefined) add(`${where}: input "${transition.input.name}" is not declared`);
    else if (inputArity !== transition.input.args.length) {
      add(`${where}: input "${transition.input.name}" takes ${inputArity} argument(s), used with ${transition.input.args.length}`);
    }
    const params = new Set(transition.input.args.filter((arg) => arg.type === "path").map((arg) => arg.name));
    const resolvable = (name) => statePaths.has(name) || params.has(name);

    // constraint 1: guards and update right-hand sides reference declared state or input parameters.
    for (const ref of collectPredicateRefs(transition.guard, [])) {
      if (!resolvable(ref)) add(`${where}: guard references undeclared symbol "${ref}"`);
    }
    for (const update of transition.updates) {
      if (params.has(update.target)) add(`${where}: assignment to "${update.target}" mutates an input parameter`); // constraint 7
      if (!statePaths.has(update.target)) add(`${where}: assignment to undeclared state "${update.target}"`);
      for (const ref of collectExprRefs(update.value, [])) {
        if (!resolvable(ref)) add(`${where}: update references undeclared symbol "${ref}"`);
      }
    }

    // constraints 3 / 4 / 10 / 11: declared outputs and actions, and no output after a terminal.
    let terminated = false;
    for (const action of transition.actions) {
      if (terminated && action.kind !== "complete" && action.kind !== "error") {
        add(`${where}: output after a terminal (complete / error)`);
      }
      if (action.kind === "emit") {
        if (action.value?.type === "call") {
          const outputArity = outputs.get(action.value.name);
          if (outputArity === undefined) add(`${where}: emits undeclared output "${action.value.name}"`);
          else if (outputArity !== action.value.args.length) {
            add(`${where}: output "${action.value.name}" takes ${outputArity} argument(s), used with ${action.value.args.length}`);
          }
        } else {
          add(`${where}: emit must name a declared output`);
        }
      } else if (action.kind === "do") {
        const actionArity = actions.get(action.call.name);
        if (actionArity === undefined) add(`${where}: calls undeclared action "${action.call.name}"`);
        else if (actionArity !== action.call.args.length) {
          add(`${where}: action "${action.call.name}" takes ${actionArity} argument(s), used with ${action.call.args.length}`);
        }
      } else if (action.kind === "complete" || action.kind === "error") {
        if (terminated) add(`${where}: more than one terminal action`);
        terminated = true;
      }
    }

    // constraint 12: two transitions with the same input and guard are non-deterministic.
    const key = `${transition.input.name}|${serializePredicate(transition.guard)}`;
    if (keys.has(key)) add(`${where}: same input and guard as ${keys.get(key)} (non-deterministic)`);
    else keys.set(key, where);
  }
  return problems;
}

// ---------------------------------------------------------------------------
// Serialization and the Machine Semantic Model projection
// ---------------------------------------------------------------------------
export function serializeExpr(node) {
  switch (node.type) {
    case "number": return String(node.value);
    case "string": return `"${node.value}"`;
    case "boolean": return String(node.value);
    case "null": return "null";
    case "path": return node.name;
    case "paren": return `(${serializeExpr(node.inner)})`;
    case "binary": return `${serializeExpr(node.left)} ${node.op} ${serializeExpr(node.right)}`;
    case "call": return `${node.name}(${node.args.map(serializeExpr).join(", ")})`;
    default: throw new MealyError(`cannot serialize expression node "${node.type}"`);
  }
}

export function serializePredicate(node) {
  switch (node.type) {
    case "and": return `${serializePredicate(node.left)} and ${serializePredicate(node.right)}`;
    case "or": return `${serializePredicate(node.left)} or ${serializePredicate(node.right)}`;
    case "not": return `not ${serializePredicate(node.operand)}`;
    case "group": return `(${serializePredicate(node.inner)})`;
    case "compare": return `${serializeExpr(node.left)} ${node.op} ${serializeExpr(node.right)}`;
    default: throw new MealyError(`cannot serialize predicate node "${node.type}"`);
  }
}

function actionToModel(action) {
  switch (action.kind) {
    case "nothing": return { kind: "nothing" };
    case "complete": return { kind: "complete" };
    case "error": return { kind: "error", expression: serializeExpr(action.value) };
    case "emit": return { kind: "emit", event: { name: action.value.name, arguments: action.value.args.map(serializeExpr) } };
    case "do": return { kind: "do", call: { name: action.call.name, arguments: action.call.args.map(serializeExpr) } };
    default: throw new MealyError(`cannot project action "${action.kind}"`);
  }
}

// ---------------------------------------------------------------------------
// Generation: Machine Semantic Model -> Mealy DSL text
// ---------------------------------------------------------------------------
// The inverse of parseMachine + toSemanticModel. The model already stores guards and expressions
// as canonical source strings (as produced by serializePredicate / serializeExpr), so generation
// is layout assembly. For a canonical model the round-trip holds both ways:
//   parseMachine(generateMealy(M))  projects back to  M        (parse . generate = id)
//   generateMealy(toSemanticModel(parseMachine(text)))  ==  text  (for canonical text)
export function generateMealy(model) {
  const blocks = [];

  if (model.state.length) {
    blocks.push(["  state {", ...model.state.map((f) => `    ${f.path}: ${f.type};`), "  }"].join("\n"));
  }
  if (model.initial.length) {
    blocks.push(["  initial {", ...model.initial.map((a) => `    ${a.target} = ${a.expression};`), "  }"].join("\n"));
  }
  const signatureBlock = (keyword, list) =>
    [`  ${keyword} {`, ...list.map((s) => `    ${s.name}(${s.parameters.map((p) => `${p.name}: ${p.type}`).join(", ")});`), "  }"].join("\n");
  if (model.inputs.length) blocks.push(signatureBlock("input", model.inputs));
  if (model.outputs.length) blocks.push(signatureBlock("output", model.outputs));
  if (model.actions.length) blocks.push(signatureBlock("action", model.actions));

  for (const transition of model.transitions) {
    const lines = [
      `  transition ${transition.name} {`,
      `    given ${transition.guard};`,
      `    when ${transition.input.name}(${transition.input.arguments.join(", ")});`,
    ];
    for (const update of transition.updates) lines.push(`    then ${update.target} = ${update.expression};`);
    for (const action of transition.actions) {
      if (action.kind === "nothing") lines.push("    emit nothing;");
      else if (action.kind === "complete") lines.push("    complete;");
      else if (action.kind === "error") lines.push(`    error ${action.expression};`);
      else if (action.kind === "emit") lines.push(`    emit ${action.event.name}(${action.event.arguments.join(", ")});`);
      else if (action.kind === "do") lines.push(`    do ${action.call.name}(${action.call.arguments.join(", ")});`);
    }
    lines.push("  }");
    blocks.push(lines.join("\n"));
  }

  return `machine ${model.machine} {\n${blocks.join("\n\n")}\n}\n`;
}

// Project a parsed Mealy machine onto the syntax-independent Machine Semantic Model, so it can be
// compared against (or validated like) spec/machine-semantic-model.schema.json.
export function toSemanticModel(machine) {
  const signature = (s) => ({ name: s.name, parameters: s.parameters.map((p) => ({ name: p.name, type: p.type })) });
  return {
    version: "0.1",
    machine: machine.name,
    state: machine.state.map((field) => ({ path: field.path, type: field.type })),
    initial: machine.initial.map((assignment) => ({ target: assignment.target, expression: serializeExpr(assignment.value) })),
    inputs: machine.inputs.map(signature),
    outputs: machine.outputs.map(signature),
    actions: machine.actions.map(signature),
    transitions: machine.transitions.map((transition) => ({
      name: transition.name,
      guard: serializePredicate(transition.guard),
      input: { name: transition.input.name, arguments: transition.input.args.map(serializeExpr) },
      updates: transition.updates.map((update) => ({ target: update.target, expression: serializeExpr(update.value) })),
      actions: transition.actions.map(actionToModel),
    })),
  };
}

// ---------------------------------------------------------------------------
// CLI: node scripts/mealy.mjs <machine-model.json>  ->  prints the Mealy DSL text
// ---------------------------------------------------------------------------
if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) {
  const path = process.argv[2];
  if (!path) {
    console.error("usage: node scripts/mealy.mjs <machine-model.json>");
    process.exit(2);
  }
  process.stdout.write(generateMealy(JSON.parse(readFileSync(path, "utf8"))));
}
