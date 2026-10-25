# `combineAll`

Deprecated alias of `combineLatestAll`: collects the inner observables of a higher-order source until it completes, then combines their latest values.

*Note:* Deprecated alias behavior built on `combineLatestAll`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately and collect inner observables
     defer subscribing to the inners until the outer completes
```

## State-conditioned rule

```text
Given outer active
When an inner event arrives
Then collect inner Observables until the outer completes
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When outer completes
Then subscribe/combine inners and emit whenever all have values and any inner updates
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
