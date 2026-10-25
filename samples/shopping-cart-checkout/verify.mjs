// Shopping-cart checkout — end-to-end workflow test.
//
//   node samples/shopping-cart-checkout/verify.mjs   (or: npm run sample:checkout)
//
// Exercises every stage of the rxjs-bdd pipeline on the business use case:
//   1. the Convertible BDD feature parses under the grammar and passes the semantic checks;
//   2. the Machine Semantic Model validates against spec/machine-semantic-model.schema.json;
//   3. the feature and the machine model agree transition for transition;
//   4. the Mealy DSL parses, passes its declaration-aware checks, and round-trips to the model;
//   5. the generated RxJS pipeline reproduces hand-computed golden outputs for six event traces.
//
// Exit code 0 when everything passes, 1 otherwise.

import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import Ajv2020 from "ajv/dist/2020.js";
import { from } from "rxjs";
import { parseFeature, checkFeature } from "../../scripts/convertible-bdd.mjs";
import { parseMachine, checkMachine, toSemanticModel } from "../../scripts/mealy.mjs";
import { loadCheckout } from "./pipeline.mjs";

function deepEqual(a, b) {
  if (a === b) return true;
  if (typeof a !== typeof b || a === null || b === null) return false;
  if (Array.isArray(a) || Array.isArray(b)) {
    if (!Array.isArray(a) || !Array.isArray(b) || a.length !== b.length) return false;
    return a.every((value, index) => deepEqual(value, b[index]));
  }
  if (typeof a === "object") {
    const keys = Object.keys(a);
    if (keys.length !== Object.keys(b).length) return false;
    return keys.every((key) => Object.prototype.hasOwnProperty.call(b, key) && deepEqual(a[key], b[key]));
  }
  return false;
}

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..", "..");
const read = (relative) => readFileSync(resolve(root, relative), "utf8");

const problems = [];
const fail = (message) => problems.push(message);
const section = (title) => console.log(`\n${title}`);

// ---------------------------------------------------------------------------
// 1. Convertible BDD: grammar + semantic checks
// ---------------------------------------------------------------------------
section("1. Convertible BDD");
const feature = parseFeature(read("samples/shopping-cart-checkout/2-checkout.feature"));
console.log(`   feature ${feature.name}, ${feature.scenarios.length} scenarios`);
if (feature.name !== "ShoppingCartCheckout") fail(`feature name is ${feature.name}`);
for (const problem of checkFeature(feature)) fail(`semantic: ${problem}`);
console.log("   grammar + semantic checks: ok");

// ---------------------------------------------------------------------------
// 2. Machine Semantic Model: JSON Schema
// ---------------------------------------------------------------------------
section("2. Machine Semantic Model");
const machine = JSON.parse(read("samples/shopping-cart-checkout/3-checkout.machine.json"));
const ajv = new Ajv2020({ allErrors: true, strict: true });
const validate = ajv.compile(JSON.parse(read("spec/machine-semantic-model.schema.json")));
if (!validate(machine)) for (const error of validate.errors ?? []) fail(`schema: ${error.instancePath || "/"} ${error.message}`);
console.log(`   machine ${machine.machine}: ${machine.transitions.length} transitions, validates against the schema`);

// ---------------------------------------------------------------------------
// 3. Feature and machine model agree
// ---------------------------------------------------------------------------
section("3. Feature <-> machine model");
const scenarioByName = new Map(feature.scenarios.map((s) => [s.name, s]));
const scenarioNames = [...scenarioByName.keys()].sort();
const transitionNames = machine.transitions.map((t) => t.name).sort();
if (JSON.stringify(scenarioNames) !== JSON.stringify(transitionNames)) {
  fail(`transition names differ from scenario names\n    scenarios:   ${scenarioNames.join(", ")}\n    transitions: ${transitionNames.join(", ")}`);
}
for (const transition of machine.transitions) {
  const scenario = scenarioByName.get(transition.name);
  if (!scenario) continue;
  if (transition.input.name !== scenario.when.name) {
    fail(`${transition.name}: input ${transition.input.name} but feature event ${scenario.when.name}`);
  }
  const formals = scenario.when.args.map((arg) => arg.name);
  if (JSON.stringify(transition.input.arguments) !== JSON.stringify(formals)) {
    fail(`${transition.name}: input arguments ${JSON.stringify(transition.input.arguments)} but feature ${JSON.stringify(formals)}`);
  }
  if (transition.guard !== scenario.givenText.join(" and ")) {
    fail(`${transition.name}: guard\n    machine:  ${transition.guard}\n    feature:  ${scenario.givenText.join(" and ")}`);
  }
}
if (!problems.some((p) => p.includes("transition") || p.includes("guard") || p.includes("input"))) {
  console.log("   every transition matches its scenario (name, event, arguments, guard)");
}

// ---------------------------------------------------------------------------
// 4. Mealy DSL: parse, check, and round-trip to the machine model
// ---------------------------------------------------------------------------
section("4. Mealy DSL");
const mealy = parseMachine(read("samples/shopping-cart-checkout/4-checkout.mealy"));
console.log(`   machine ${mealy.name}: parses, ${mealy.transitions.length} transitions`);
for (const problem of checkMachine(mealy)) fail(`mealy: ${problem}`);
const mealyModel = toSemanticModel(mealy);
if (!validate(mealyModel)) for (const error of validate.errors ?? []) fail(`mealy schema: ${error.instancePath || "/"} ${error.message}`);
if (!deepEqual(mealyModel, machine)) {
  fail("mealy: 4-checkout.mealy does not round-trip to 3-checkout.machine.json");
} else {
  console.log("   declaration-aware checks pass; round-trips to the Machine Semantic Model");
}

// ---------------------------------------------------------------------------
// 5. Generated RxJS pipeline vs golden outputs
// ---------------------------------------------------------------------------
section("5. RxJS pipeline conformance");
const { operator, step, initialState } = loadCheckout();

const ev = (name, ...args) => ({ name, args });
const emit = (name, ...args) => ({ name, args });

const traces = [
  {
    title: "happy path: add, add, checkout, confirm, authorized",
    events: [ev("cart.addItem", 10), ev("cart.addItem", 5), ev("customer.checkout"), ev("customer.confirm"), ev("payment.authorized", "PAY-123")],
    expectedOutputs: [emit("checkout.review", 15), emit("payment.request", 15), emit("order.placed", "PAY-123")],
    expectedTerminal: { type: "complete" },
  },
  {
    title: "empty cart rejected, then a successful checkout",
    events: [ev("customer.checkout"), ev("cart.addItem", 20), ev("customer.checkout"), ev("customer.confirm"), ev("payment.authorized", "PAY-9")],
    expectedOutputs: [emit("checkout.rejected", "EmptyCart"), emit("checkout.review", 20), emit("payment.request", 20), emit("order.placed", "PAY-9")],
    expectedTerminal: { type: "complete" },
  },
  {
    title: "two declines retried, third exhausts maxRetries and errors",
    events: [ev("cart.addItem", 100), ev("customer.checkout"), ev("customer.confirm"), ev("payment.declined", "CardExpired"), ev("payment.declined", "CardExpired"), ev("payment.declined", "CardExpired")],
    expectedOutputs: [emit("checkout.review", 100), emit("payment.request", 100), emit("payment.request", 100), emit("payment.request", 100)],
    expectedTerminal: { type: "error", error: "PaymentFailed" },
  },
  {
    title: "cancel from the review stage",
    events: [ev("cart.addItem", 30), ev("customer.checkout"), ev("customer.cancel")],
    expectedOutputs: [emit("checkout.review", 30), emit("order.cancelled", "CustomerCancelled")],
    expectedTerminal: { type: "complete" },
  },
  {
    title: "add then remove empties the cart, so checkout is rejected",
    events: [ev("cart.addItem", 40), ev("cart.removeItem", 40), ev("customer.checkout")],
    expectedOutputs: [emit("checkout.rejected", "EmptyCart")],
    expectedTerminal: { type: "complete" },
  },
  {
    title: "cancel while awaiting payment",
    events: [ev("cart.addItem", 50), ev("customer.checkout"), ev("customer.confirm"), ev("customer.cancel")],
    expectedOutputs: [emit("checkout.review", 50), emit("payment.request", 50), emit("order.cancelled", "CustomerCancelled")],
    expectedTerminal: { type: "complete" },
  },
];

const equal = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const covered = new Set();

for (const trace of traces) {
  const outputs = [];
  let terminal = null;
  from(trace.events)
    .pipe(operator)
    .subscribe({
      next: (output) => outputs.push(output),
      error: (error) => (terminal = { type: "error", error }),
      complete: () => (terminal = { type: "complete" }),
    });

  // Replay the same trace through the pure step to record which transitions fired.
  let state = { ...initialState };
  for (const event of trace.events) {
    const result = step(state, event);
    if (!result) continue;
    covered.add(result.transition);
    state = result.state;
    if (result.terminal) break;
  }

  const outputsOk = equal(outputs, trace.expectedOutputs);
  const terminalOk = equal(terminal, trace.expectedTerminal);
  if (outputsOk && terminalOk) {
    console.log(`   PASS  ${trace.title}`);
  } else {
    console.log(`   FAIL  ${trace.title}`);
    if (!outputsOk) {
      console.log(`         outputs expected ${JSON.stringify(trace.expectedOutputs)}`);
      console.log(`         outputs actual   ${JSON.stringify(outputs)}`);
      fail(`trace "${trace.title}": outputs differ`);
    }
    if (!terminalOk) {
      console.log(`         terminal expected ${JSON.stringify(trace.expectedTerminal)}, actual ${JSON.stringify(terminal)}`);
      fail(`trace "${trace.title}": terminal differs`);
    }
  }
}

const uncovered = machine.transitions.map((t) => t.name).filter((name) => !covered.has(name));
if (uncovered.length) fail(`transition coverage: never fired: ${uncovered.join(", ")}`);
else console.log(`   transition coverage: all ${machine.transitions.length} transitions fired across the traces`);

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------
if (problems.length) {
  console.error(`\n${problems.length} problem${problems.length === 1 ? "" : "s"}:`);
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}
console.log("\nOK: Convertible BDD, machine model, feature/model agreement, Mealy DSL, and RxJS pipeline all pass.");
