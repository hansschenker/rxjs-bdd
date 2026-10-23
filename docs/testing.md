# From Given / When / Then to RxJS Tests

The purpose of the BDD notation is not only documentation. Each rule can become a transition-oriented test.

## Core mapping

```text
Given <state S>
When  <event E>
Then  <next state S'>
      <output O>
```

maps to:

```text
Arrange S
Act with E
Assert S' and O
```

For externally observable RxJS behavior, the test normally asserts the output protocol and subscription behavior. Internal state may be inferred through subsequent events or exposed by a dedicated model test.

## Test layers

### 1. Observable behavior test

Use `TestScheduler` marble tests to verify emitted values, completion, errors, and subscription timing.

### 2. Transition-model test

Test the pure machine rule directly when the operator behavior has been modeled as:

```ts
type Step<S, E, O> = (state: S, event: E) => {
  state: S;
  output: O[];
};
```

### 3. Conformance test

Feed the same event trace into:

- the pure transition model;
- the real RxJS operator;

then compare observable outputs and termination behavior.

This is the strongest use of the repository: the readable BDD rule becomes an executable semantic oracle.

## Example: debounceTime

Rule:

```text
Given silence timer active
When source value arrives
Then replace pending value
     restart timer
     emit nothing
```

Observable test idea:

```text
source:      a 100ms b 199ms -
output:      -----------------
```

At the arrival of `b`, no output is produced and the silence deadline is restarted.

Boundary rule:

```text
Given pending value exists
When configured silence interval elapses
Then emit pending latest value
```

Observable test idea:

```text
source:      a ---------
output:      --200ms-- a
```

Completion rule:

```text
Given pending value exists
When source completes
Then emit pending latest value
     complete
```

Error rule:

```text
Given any state
When source errors
Then discard pending value
     error immediately
```

## Coverage criterion

A test suite is stronger when every meaningful BDD transition rule has at least one corresponding test.

The desired relation is:

```text
Operator specification
      ↓
Given / When / Then rules
      ↓
transition coverage matrix
      ↓
RxJS tests
```

This does not mean one test per line mechanically. One test may cover several transitions, but the coverage matrix should make that explicit.

## Why this matters

Traditional marble tests often demonstrate representative traces. The Given / When / Then model asks a stricter question:

> Have we exercised every meaningful state/event combination?

That moves operator testing from example coverage toward **state-transition coverage**.
