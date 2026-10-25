# `combineLatestWith`

Subscribes to the source and the supplied inputs, waits until every input has emitted at least once, and from then on emits a tuple of latest values each time any input emits. Completes when every input has completed.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source and then to each supplied input, in order
     start with no latest value for any input
```

## State-conditioned rule

```text
Given inputs active
When the next relevant source event occurs
Then retain the latest value from source and each supplied Observable
```

## Event-triggered rule

```text
Given the operator is active
When all inputs have emitted and any input emits
Then emit the latest-value tuple
```

## Inner rule

```text
Given inputs are active
When a input emits a value
Then replace that input's retained latest value
     emit the combined tuple, or its projection, once every input has emitted at least once
     emit nothing before that
```

## Concurrency rule

```text
Given inputs are active
When a input emits again before the others
Then replace its retained latest value
     nothing is queued
```

## Completion rules

```text
Given other inputs are still active
When an input completes
Then retain its latest value
     keep combining with the remaining inputs
     no combination is ever emitted if that input never emitted

Given every other input has completed
When the last active input completes
Then complete
```

## Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
```

## Unsubscription rule

```text
Given inputs are active
When the downstream subscriber unsubscribes
Then unsubscribe every input
     discard retained latest values
```

## Cancellation rule

```text
Given inputs are active
When any source value or lifecycle event arrives
Then cancel no active work
     every input runs until it terminates on its own
```
