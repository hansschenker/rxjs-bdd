# `mergeMapTo`

Deprecated specialization of `mergeMap` that maps every source value to the same inner observable and merges the resulting subscriptions concurrently.

*Note:* Deprecated specialization.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with zero active inners and an empty queue
```

## State-conditioned rule

```text
Given fixed inners active
When the next relevant operator event occurs
Then allow overlap up to concurrency limit
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives with capacity
Then subscribe to configured inner and forward its values
```

## Inner rule

```text
Given configured inners are active
When a configured inner emits a value
Then forward the value immediately
     values from different active configured inners interleave in arrival order
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When an outer value arrives
Then admit it: subscribe to the configured inner immediately
     increment the active count

Given concurrent inners are already active
When an outer value arrives
Then queue the outer value
     admit the oldest queued item when an active inner completes
```

## Completion rules

```text
Given no configured inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given configured inners are active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep running active configured inners and admit queued outer values as concurrency capacity opens
     complete when the last configured inner completes and the queue is empty
```

## Error rule

```text
Given any state
When the outer source or any active configured inner errors
Then discard queued outer values
     unsubscribe all active configured inners
     error immediately
```

## Unsubscription rule

```text
Given configured inners are active or outer values are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe every active configured inner
     discard queued outer values
```

## Cancellation rule

```text
Given configured inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     inners always run to completion; excess outer values are queued, never cancelled
```
