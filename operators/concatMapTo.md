# `concatMapTo`

Deprecated specialization of `concatMap` that maps every source value to the same inner observable, subscribing to it once per source value in sequence.

*Note:* Deprecated specialization.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active configured inner and an empty queue
```

## State-conditioned rule

```text
Given one fixed inner active
When an outer value arrives
Then queue the outer value
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then subscribe to another instance of the configured inner for the next queued outer value
```

## Inner rule

```text
Given the active configured inner is running
When the active configured inner emits a value
Then forward the value immediately
     values from queued configured inners are never interleaved with it
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
Given no configured inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given a configured inner is active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued outer values in order, one configured inner at a time
     complete after the last configured inner completes
```

## Error rule

```text
Given any state
When the outer source or the active configured inner errors
Then discard queued outer values
     unsubscribe the active configured inner
     error immediately
```

## Unsubscription rule

```text
Given a configured inner is active or outer values are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active configured inner
     discard queued outer values
```

## Cancellation rule

```text
Given a configured inner is active
When any source value or lifecycle event arrives
Then cancel no active work
     the active inner always runs to completion; queued outer values are never cancelled by the operator
```
