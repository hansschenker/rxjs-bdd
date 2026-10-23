# Given / When / Then for RxJS Operator Behavior

## Canonical form

```text
Given <current state / state predicate>
When  <input event>
Then  <state transition>
      <Action Policy / output>
```

This is a readable form of:

```text
(State, Event) -> (Next State, Output)
```

with:

```text
Given  -> State
When   -> Event
Then   -> Transition + Action Policy
```

## Relation to the While–Then / When–Then notation

Use **While–Then / When–Then** for a compact operator-level summary:

```text
while <state condition> then <ongoing state policy>
when  <event> then <action policy>
```

Use **Given / When / Then** to expand that summary into explicit transition rules.

## debounceTime

```text
Given silence timer active
When source value arrives
Then replace pending value
     restart timer
     emit nothing

Given pending value exists
When silence interval elapses
Then emit pending latest value
     clear pending value

Given pending value exists
When source completes
Then emit pending latest value
     clear pending value
     complete

Given any state
When source errors
Then discard pending value
     error immediately
```

## Compound predicates

```text
Given condition A
And condition B
When event X
Then ...
```

means the rule applies in the state region `A ∧ B`.

## Multiple rules

Several `Given`, `When`, and `Then` rules are normal. The set of rules forms a readable transition specification for the operator.

## Testing interpretation

Each rule can be turned into a transition test:

1. Arrange the machine in the `Given` state.
2. Deliver the `When` event.
3. Assert the `Then` next state and observable output.

This makes the notation useful as a bridge from operator documentation to state-complete testing.
