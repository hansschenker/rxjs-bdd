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

The schema is in `spec/operator-catalog.schema.json`.

## Validation invariants

A valid rule must have:

1. a non-empty operator name;
2. at least one rule;
3. a non-empty `Given`;
4. a non-empty `When`;
5. at least one `Then` action;
6. a rule kind of `state` or `event`.

This structural validation does not by itself prove semantic completeness. Semantic review still asks whether all meaningful source, timer, notifier, inner, completion, error, and teardown transitions are represented.
