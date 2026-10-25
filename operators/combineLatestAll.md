# `combineLatestAll`

Collects the inner observables emitted by a higher-order source until the source completes, then subscribes to all of them and emits a tuple of latest values whenever any inner emits, once every inner has emitted at least once.

*Note:* Starts combining after the higher-order source supplies/collects inners per implementation.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately and collect inner observables
     defer subscribing to the inners until the outer completes
```

## State-conditioned rule

```text
Given combined inners active
When the next relevant source event occurs
Then retain each inner's latest value and readiness
```

## Event-triggered rule

```text
Given the relevant inner state exists
When all active inners are ready and any inner emits
Then emit the latest-value tuple
```

## Inner rule

```text
Given inners are active
When a inner emits a value
Then replace that inner's retained latest value
     emit the combined tuple, or its projection, once every inner has emitted at least once
     emit nothing before that
```

## Concurrency rule

```text
Given inners are active
When a inner emits again before the others
Then replace its retained latest value
     nothing is queued
```

## Completion rules

```text
Given inner observables are being collected
When the outer source completes
Then stop collecting
     subscribe to every collected inner with combineLatest semantics
     complete immediately if no inners were collected

Given the combined inners are active
When an inner completes
Then retain its latest value
     complete when every inner has completed
```

## Error rule

```text
Given any state
When the outer source or any inner observable errors
Then unsubscribe all inners
     error immediately
```

## Unsubscription rule

```text
Given inners are being collected or combined
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source if still collecting
     unsubscribe every inner
     discard retained latest values
```

## Cancellation rule

```text
Given the combined inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     every inner runs until it terminates on its own
```
