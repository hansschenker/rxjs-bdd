# `concatMap`

Projects each source value to an inner observable and subscribes to the inners one at a time in arrival order; projections made while an inner is active are queued (concurrency policy: queue).

*Note:* Concurrency policy: queue.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active projected inner and an empty queue
```

## State-conditioned rule

```text
Given one projected inner active
When an outer value arrives
Then queue the outer value
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then project and subscribe to the next queued outer value
```

## Inner rule

```text
Given the active projected inner is running
When the active projected inner emits a value
Then forward the value immediately
     values from queued projected inners are never interleaved with it
```

## Concurrency rules

```text
Given no inner is active
When an outer value arrives
Then admit it immediately

Given an inner is active
When an outer value arrives
Then queue the outer value behind the active inner
     admit queued items one at a time in arrival order
```

## Completion rules

```text
Given no projected inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given a projected inner is active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued outer values in order, one projected inner at a time
     complete after the last projected inner completes
```

## Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then discard queued outer values
     unsubscribe the active projected inner
     error immediately
```

## Unsubscription rule

```text
Given a projected inner is active or outer values are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active projected inner
     discard queued outer values
```

## Cancellation rule

```text
Given a projected inner is active
When any source value or lifecycle event arrives
Then cancel no active work
     the active inner always runs to completion; queued outer values are never cancelled by the operator
```
