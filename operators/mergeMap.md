# `mergeMap`

Projects each source value to an inner observable and subscribes to the inners concurrently, up to the optional limit, interleaving their values as they arrive (concurrency policy: allow overlap).

*Note:* Concurrency policy: allow overlap.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with zero active inners and an empty queue
```

## State-conditioned rule

```text
Given projected inners active
When an outer value arrives
Then allow overlap up to concurrency limit and queue excess outer values
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives with capacity
Then start projected inner; inner emits: forward immediately
```

## Inner rule

```text
Given projected inners are active
When a projected inner emits a value
Then forward the value immediately
     values from different active projected inners interleave in arrival order
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When an outer value arrives
Then admit it: project and subscribe immediately
     increment the active count

Given concurrent inners are already active
When an outer value arrives
Then queue the outer value
     admit the oldest queued item when an active inner completes
```

## Completion rules

```text
Given no projected inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given projected inners are active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep running active projected inners and admit queued outer values as concurrency capacity opens
     complete when the last projected inner completes and the queue is empty
```

## Error rule

```text
Given any state
When the outer source or any active projected inner errors
Then discard queued outer values
     unsubscribe all active projected inners
     error immediately
```

## Unsubscription rule

```text
Given projected inners are active or outer values are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe every active projected inner
     discard queued outer values
```

## Cancellation rule

```text
Given projected inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     inners always run to completion; excess outer values are queued, never cancelled
```
