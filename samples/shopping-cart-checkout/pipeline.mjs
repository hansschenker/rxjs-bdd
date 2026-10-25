// Shopping-cart checkout — the RxJS pipeline (the final stage of the rxjs-bdd workflow).
//
// This file is the "RxJS generator" and the generated pipeline in one place. It compiles the
// parsed Convertible BDD feature (2-checkout.feature) into a Mealy step function
//
//     step : (State, Event) -> { state: State, outputs: Output[], terminal }
//
// and exposes that machine as a pipeable RxJS operator: a stream of input events in, a stream of
// output values out, with the machine's `complete` / `error` mapped onto the Observable's own
// completion and error. The initial state is read from the Machine Semantic Model
// (3-checkout.machine.json), so the pipeline is driven by the upstream artifacts rather than by
// hand-written behaviour.

import { Observable } from "rxjs";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseFeature } from "../../scripts/convertible-bdd.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const read = (name) => readFileSync(resolve(here, name), "utf8");

// ---------------------------------------------------------------------------
// Expression / predicate evaluation over the Convertible BDD AST
// ---------------------------------------------------------------------------
// `env` is { state: { "<dotted.path>": value }, args: { "<param>": value } }. A bare identifier or
// dotted path resolves against the event arguments first, then the machine state.
function resolvePath(name, env) {
  if (Object.prototype.hasOwnProperty.call(env.args, name)) return env.args[name];
  if (Object.prototype.hasOwnProperty.call(env.state, name)) return env.state[name];
  throw new Error(`unbound symbol "${name}"`);
}

function evalExpr(node, env) {
  switch (node.type) {
    case "number":
    case "string":
    case "boolean":
      return node.value;
    case "null":
      return null;
    case "path":
      return resolvePath(node.name, env);
    case "paren":
      return evalExpr(node.inner, env);
    case "binary": {
      const l = evalExpr(node.left, env);
      const r = evalExpr(node.right, env);
      switch (node.op) {
        case "+": return l + r;
        case "-": return l - r;
        case "*": return l * r;
        case "/": return l / r;
        case "%": return l % r;
        default: throw new Error(`unknown binary operator "${node.op}"`);
      }
    }
    default:
      throw new Error(`cannot evaluate expression node "${node.type}"`);
  }
}

function evalPredicate(node, env) {
  switch (node.type) {
    case "and": return evalPredicate(node.left, env) && evalPredicate(node.right, env);
    case "or": return evalPredicate(node.left, env) || evalPredicate(node.right, env);
    case "not": return !evalPredicate(node.operand, env);
    case "group": return evalPredicate(node.inner, env);
    case "compare": {
      const l = evalExpr(node.left, env);
      const r = evalExpr(node.right, env);
      switch (node.op) {
        case "==": return l === r;
        case "!=": return l !== r;
        case ">": return l > r;
        case "<": return l < r;
        case ">=": return l >= r;
        case "<=": return l <= r;
        default: throw new Error(`unknown comparison operator "${node.op}"`);
      }
    }
    default:
      throw new Error(`cannot evaluate predicate node "${node.type}"`);
  }
}

// ---------------------------------------------------------------------------
// Compile a parsed feature into a Mealy step function
// ---------------------------------------------------------------------------
export function compile(feature) {
  const compiled = feature.scenarios.map((scenario) => {
    const formals = scenario.when.args.map((arg) => {
      if (arg.type !== "path") throw new Error(`${scenario.name}: event arguments must be plain parameter names`);
      return arg.name;
    });
    const guard = (env) => scenario.given.every((predicate) => evalPredicate(predicate, env));
    const updates = [];
    const actions = [];
    for (const effect of scenario.then) {
      switch (effect.type) {
        case "assign":
          updates.push({ target: effect.target, evaluate: (env) => evalExpr(effect.value, env) });
          break;
        case "emit":
          if (effect.value === null) break; // "emit nothing": no output
          if (effect.value.type !== "call") throw new Error(`${scenario.name}: this sample only emits named outputs`);
          actions.push({
            kind: "emit",
            name: effect.value.name,
            args: effect.value.args.map((arg) => (env) => evalExpr(arg, env)),
          });
          break;
        case "complete":
          actions.push({ kind: "complete" });
          break;
        case "error":
          // "error PaymentFailed": a bare identifier is the error symbol, not a state lookup.
          actions.push({
            kind: "error",
            evaluate: effect.value.type === "path" ? () => effect.value.name : (env) => evalExpr(effect.value, env),
          });
          break;
        case "nothing":
          break;
        default:
          throw new Error(`${scenario.name}: unsupported effect "${effect.type}"`);
      }
    }
    return { name: scenario.name, when: scenario.when.name, formals, guard, updates, actions };
  });

  function step(state, event) {
    for (const transition of compiled) {
      if (transition.when !== event.name) continue;
      const args = {};
      transition.formals.forEach((name, index) => (args[name] = event.args[index]));
      const env = { state, args };
      if (!transition.guard(env)) continue;

      // Mealy semantics: every update reads the pre-transition state, then all are applied.
      const assigned = transition.updates.map((update) => [update.target, update.evaluate(env)]);
      const nextState = { ...state };
      for (const [target, value] of assigned) nextState[target] = value;

      const outputs = [];
      let terminal = null;
      for (const action of transition.actions) {
        if (action.kind === "emit") outputs.push({ name: action.name, args: action.args.map((fn) => fn(env)) });
        else if (action.kind === "complete") terminal = { type: "complete" };
        else if (action.kind === "error") terminal = { type: "error", error: action.evaluate(env) };
      }
      return { state: nextState, outputs, terminal, transition: transition.name };
    }
    return null; // no transition matches this event in this state: the machine ignores it
  }

  return { step, transitions: compiled };
}

// ---------------------------------------------------------------------------
// Initial state, read from the Machine Semantic Model
// ---------------------------------------------------------------------------
export function initialStateFromMachine(machine) {
  const state = {};
  for (const { target, expression } of machine.initial) {
    state[target] = /^".*"$/.test(expression) ? expression.slice(1, -1) : Number(expression);
  }
  return state;
}

// ---------------------------------------------------------------------------
// The pipeable RxJS operator
// ---------------------------------------------------------------------------
// events$ : Observable<{ name, args: unknown[] }>  ->  Observable<{ name, args: unknown[] }>
export function checkoutMachine({ step, initialState }) {
  return (events$) =>
    new Observable((subscriber) => {
      let state = { ...initialState };
      let done = false;
      const inner = events$.subscribe({
        next: (event) => {
          if (done) return;
          let result;
          try {
            result = step(state, event);
          } catch (error) {
            done = true;
            subscriber.error(error);
            return;
          }
          if (!result) return; // ignored event
          state = result.state;
          for (const output of result.outputs) subscriber.next(output);
          if (result.terminal?.type === "complete") {
            done = true;
            subscriber.complete();
          } else if (result.terminal?.type === "error") {
            done = true;
            subscriber.error(result.terminal.error);
          }
        },
        error: (error) => subscriber.error(error),
        complete: () => subscriber.complete(),
      });
      return () => inner.unsubscribe();
    });
}

// ---------------------------------------------------------------------------
// Convenience loader: wires the feature, the machine model, and the operator together
// ---------------------------------------------------------------------------
export function loadCheckout() {
  const feature = parseFeature(read("2-checkout.feature"));
  const machine = JSON.parse(read("3-checkout.machine.json"));
  const { step, transitions } = compile(feature);
  const initialState = initialStateFromMachine(machine);
  return { feature, machine, transitions, step, initialState, operator: checkoutMachine({ step, initialState }) };
}
