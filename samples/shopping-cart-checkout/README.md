# Sample: shopping-cart checkout

A full run of the rxjs-bdd workflow on a business use case rather than an RxJS operator.
It takes one checkout process from readable Given / When / Then prose all the way to a
running, tested RxJS pipeline, producing one artifact per stage of the formal pipeline in
[`docs/formal-language.md`](../../docs/formal-language.md):

```text
Readable BDD            1-readable-bdd.md        prose Given / When / Then
      |
Convertible BDD         2-checkout.feature       parses under spec/convertible-bdd.ebnf
      |  parse (scripts/convertible-bdd.mjs)
Machine Semantic Model  3-checkout.machine.json  validates against spec/machine-semantic-model.schema.json
      |
Mealy DSL               4-checkout.mealy         conforms to spec/mealy.ebnf
      |  generate
RxJS pipeline           pipeline.mjs             a pipeable operator, events in -> outputs out
```

## The use case

A checkout is a Mealy machine reacting to customer and payment-gateway events over time. It
moves through three live stages (`shopping`, `review`, `awaitingPayment`) and two terminal
stages (`confirmed`, `cancelled`). A declined payment is retried up to `maxRetries` times
before the checkout fails.

| | |
|---|---|
| **Inputs** | `cart.addItem` · `cart.removeItem` · `customer.checkout` · `customer.confirm` · `customer.cancel` · `payment.authorized` · `payment.declined` |
| **Outputs** | `checkout.review` · `checkout.rejected` · `payment.request` · `order.placed` · `order.cancelled` |
| **Terminal** | `complete` on a placed or cancelled order, `error PaymentFailed` when retries are exhausted |

## The RxJS pipeline

`pipeline.mjs` is both the generator and the generated pipeline. It compiles the parsed
Convertible BDD feature into a Mealy step function

```text
step : (State, Event) -> { state, outputs, terminal }
```

and exposes it as a pipeable operator. A stream of input events goes in, a stream of output
values comes out, and the machine's `complete` / `error` become the Observable's own
completion and error. The initial state is read from the Machine Semantic Model, so the
pipeline is driven by the upstream artifacts rather than by hand-written behaviour.

```js
import { from } from "rxjs";
import { loadCheckout } from "./pipeline.mjs";

const { operator } = loadCheckout();

from([
  { name: "cart.addItem", args: [10] },
  { name: "cart.addItem", args: [5] },
  { name: "customer.checkout", args: [] },
  { name: "customer.confirm", args: [] },
  { name: "payment.authorized", args: ["PAY-123"] },
]).pipe(operator).subscribe({
  next: (output) => console.log(output), // checkout.review(15), payment.request(15), order.placed("PAY-123")
  complete: () => console.log("done"),
});
```

## Running the test

`verify.mjs` exercises every stage and is wired as an npm script:

```sh
npm install            # brings in rxjs (a devDependency) and ajv
npm run sample:checkout
```

It checks, in order:

1. **Convertible BDD** — `2-checkout.feature` parses under the grammar and passes the
   declaration-free semantic checks in `scripts/convertible-bdd.mjs`.
2. **Machine Semantic Model** — `3-checkout.machine.json` validates against
   `spec/machine-semantic-model.schema.json`.
3. **Feature ↔ model** — every transition matches its scenario name, event, arguments, and guard.
4. **RxJS pipeline** — the generated operator reproduces hand-computed golden outputs for six
   event traces, and those traces fire all ten transitions.

## Notes and limitations

- The Mealy file `4-checkout.mealy` is the DSL artifact for the machine. The repository ships
  the Mealy grammar but no Mealy parser yet, so this file is verified by eye against
  `spec/mealy.ebnf`, not mechanically. Generating it from the machine model, and parsing it
  back, is future work.
- The executable path runs through the parsed Convertible BDD feature, with the machine model
  used for the initial state and as the agreement oracle in step 3. The machine model and the
  Mealy DSL are the same machine in two other notations.
- `emit nothing` in the feature is modelled as a `nothing` action in the machine JSON: a
  transition that deliberately produces no output.
- An event with no matching transition in the current state is ignored, which is the usual
  default for a business workflow.
