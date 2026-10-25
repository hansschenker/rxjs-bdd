# `mergeAll`

Flattens a higher-order source by subscribing to inner observables as they arrive, up to the optional concurrency limit, with excess inners queued; completes when the source and every inner have completed.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with zero active inners and an empty queue
```

## State-conditioned rule

```text
Given inners active
When the relevant input event occurs
Then track active count and queue excess inners beyond concurrency limit
```

## Event-triggered rule

```text
Given the relevant inner state exists
When an inner emits
Then forward immediately; capacity opens: subscribe to queued inner
```

## Inner rule

```text
Given inners are active
When a inner emits a value
Then forward the value immediately
     values from different active inners interleave in arrival order
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When an inner observable arrives
Then admit it: subscribe immediately
     increment the active count

Given concurrent inners are already active
When an inner observable arrives
Then queue the inner
     admit the oldest queued item when an active inner completes
```

## Completion rules

```text
Given no inner is active and no inners are queued
When the outer source completes
Then complete immediately

Given inners are active or inners are queued
When the outer source completes
Then mark the outer as completed
     keep running active inners and admit queued inners as concurrency capacity opens
     complete when the last inner completes and the queue is empty
```

## Error rule

```text
Given any state
When the outer source or any active inner errors
Then discard queued inners
     unsubscribe all active inners
     error immediately
```

## Unsubscription rule

```text
Given inners are active or inners are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe every active inner
     discard queued inners
```

## Cancellation rule

```text
Given inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     inners always run to completion; excess inners are queued, never cancelled
```
