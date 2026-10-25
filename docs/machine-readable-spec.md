# Machine-readable specification

The human-readable catalog in `operators/<operator>.md` (indexed by `docs/operators.md`) is mirrored by `spec/operators.json`.

Each operator contains one or more rules:

```json
{
  "operator": "debounceTime",
  "rules": [
    {
      "kind": "state",
      "given": "silence timer active",
      "when": "a source value arrives",
      "then": [
        "replace pending value and restart the timer for the source value"
      ]
    }
  ]
}
```

## Rule semantics

- `given` is the current state or state predicate.
- `when` is the input/event.
- `then` is an ordered list of transition and Action Policy statements.
- `kind: subscription` identifies the initial transition taken when a downstream subscriber subscribes: whether the source is subscribed immediately, deferred, or shared, the order in which inputs and notifiers are subscribed, and the initial state.
- `kind: state` identifies a rule derived from persistent state behavior.
- `kind: event` identifies a rule centered on a discrete trigger or boundary.
- `kind: timer` identifies a rule triggered by a scheduled action firing: an interval tick, a due-time or absolute-date timer, or a scheduler-dispatched delivery or subscription.
- `kind: notifier` identifies a rule triggered by a secondary notifier observable emitting (or, where that matters, completing): a closing or opening notifier, a window boundary, a duration selector result, a flush, a repeat or retry notifier, or a reset notifier.
- `kind: inner` identifies a rule describing how a value emitted by an active inner observable or secondary input is handled: forwarded, interleaved, combined, queued, retained, or fed back.
- `kind: concurrency` identifies an admission rule: when new work arrives while work is active, is it allowed (and up to what limit), queued, replaced, or ignored.
- `kind: completion` identifies a lifecycle rule triggered by the completion of the source, an input, an inner Observable, or a notifier.
- `kind: error` identifies a lifecycle rule triggered by an error from the source, an input, an inner Observable, or a notifier.
- `kind: unsubscription` identifies a teardown rule triggered by the downstream subscriber unsubscribing, or, for multicast operators, by a subscriber detaching from the shared subject.
- `kind: cancellation` identifies a rule describing which active work the operator itself cancels (inner subscriptions, timers, notifiers, or the source) in response to an event, or stating explicitly that the operator cancels nothing on its own.

Every operator carries at least one rule of each of the `subscription`, `completion`, `error`, `unsubscription`, and `cancellation` kinds. `timer`, `notifier`, `inner`, and `concurrency` rules exist only where they apply: operators that schedule work (13), consume a notifier observable (20), subscribe to inner observables or secondary inputs whose values matter (37), or hold work that can overlap or be superseded (60). The absence of such a rule means that coverage-matrix row does not apply to the operator. Where the outcome depends on the state at that moment (a pending value or none, a retry budget left or exhausted, one subscriber left or several), each case is a separate rule with its own `given`. This makes every row of the transition coverage matrix except *Source next* derivable from the catalog by filtering on `kind`; *Source next* remains the domain of the original `state` and `event` rules.

The schema is in `spec/operator-catalog.schema.json`. Run `npm run validate` (after `npm install`) to check the catalog against it. The script also enforces the invariants below, checks that operators are unique and alphabetical, that every operator carries each lifecycle rule kind in lifecycle order, and that the `operators/<operator>.md` files mirror the JSON rule for rule and are all listed, with their summaries, in `docs/operators.md`. GitHub Actions runs the same script on every push.

## Validation invariants

A valid rule must have:

1. a non-empty operator name;
2. at least one rule;
3. a non-empty `Given`;
4. a non-empty `When`;
5. at least one `Then` action;
6. a rule kind of `subscription`, `state`, `event`, `timer`, `notifier`, `inner`, `concurrency`, `completion`, `error`, `unsubscription`, or `cancellation`.

This structural validation does not by itself prove semantic completeness. Semantic review still asks whether all meaningful source, timer, notifier, inner, completion, error, and teardown transitions are represented.


## Formal syntax and semantic model

The original operator catalog remains the human-readable behavioral corpus. Deterministic conversion uses the stricter language layer:

```text
spec/convertible-bdd.ebnf
        ↓ parse
BDD AST
        ↓ analyze
spec/machine-semantic-model.schema.json
        ↓ generate
spec/mealy.ebnf
```

The conversion has been carried out for all 116 operators: see `spec/convertible/` and `docs/convertible-catalog.md`.

The grammar validates syntactic form. The semantic analyzer must separately enforce declaration, typing, lifecycle, transition, and ambiguity constraints described in `docs/formal-language.md`.

This separation is intentional: JSON Schema and EBNF can prove structural validity, but they do not by themselves prove that a transition is behaviorally complete or semantically correct.

### LLM contract

When an LLM participates in conversion, it should produce or transform structures that are subsequently checked by the grammar and semantic validator. Free-form model output is not itself the source of truth.

Preferred flow:

```text
prose
  ↓ LLM normalization
Convertible BDD
  ↓ deterministic parser
AST
  ↓ semantic checks
Machine Model
  ↓ deterministic generator
Mealy DSL / RxJS
```

A model may suggest missing transitions or classifications, but ambiguity must be surfaced as an error or review item rather than silently resolved.
