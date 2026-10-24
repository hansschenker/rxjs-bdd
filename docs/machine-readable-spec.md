# Machine-readable specification

The human-readable catalog in `docs/operators.md` is mirrored by `spec/operators.json`.

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
- `kind: state` identifies a rule derived from persistent state behavior.
- `kind: event` identifies a rule centered on a discrete trigger or boundary.
- `kind: completion` identifies a lifecycle rule triggered by the completion of the source, an input, an inner Observable, or a notifier.
- `kind: error` identifies a lifecycle rule triggered by an error from the source, an input, an inner Observable, or a notifier.
- `kind: unsubscription` identifies a teardown rule triggered by the downstream subscriber unsubscribing, or, for multicast operators, by a subscriber detaching from the shared subject.
- `kind: cancellation` identifies a rule describing which active work the operator itself cancels (inner subscriptions, timers, notifiers, or the source) in response to an event, or stating explicitly that the operator cancels nothing on its own.

Every operator carries at least one rule of each of the `completion`, `error`, `unsubscription`, and `cancellation` kinds. Where the outcome depends on the state at that moment (a pending value or none, a retry budget left or exhausted, one subscriber left or several), each case is a separate rule with its own `given`. This makes the *Source complete*, *Source error*, *Unsubscription*, and *Cancellation* rows of the transition coverage matrix derivable from the catalog by filtering on `kind`.

The schema is in `spec/operator-catalog.schema.json`.

## Validation invariants

A valid rule must have:

1. a non-empty operator name;
2. at least one rule;
3. a non-empty `Given`;
4. a non-empty `When`;
5. at least one `Then` action;
6. a rule kind of `state`, `event`, `completion`, `error`, `unsubscription`, or `cancellation`.

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
