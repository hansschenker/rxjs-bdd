# `mergeScan`

Projects each source value together with the current accumulator to an inner observable; every inner value replaces the accumulator and is emitted, and inners are merged up to the concurrency limit.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     initialise the accumulator with the seed
     start with zero active inners
```

## State-conditioned rule

```text
Given projected accumulator inners active
When the next relevant source event occurs
Then retain accumulator and merge-style concurrency state
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives
Then project `(acc, value)` to inner; inner emits: replace accumulator and emit it
```

## Inner rule

```text
Given an accumulator inner is active
When it emits a value
Then replace the accumulator with the value
     emit the new accumulator
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When an outer value arrives
Then admit it: project it with the current accumulator and subscribe immediately
     increment the active count

Given concurrent inners are already active
When an outer value arrives
Then queue the outer value
     admit the oldest queued item when an active inner completes
```

## Completion rules

```text
Given no accumulator inner is active and no outer values are queued
When the source completes
Then complete immediately

Given accumulator inners are active or outer values are queued
When the source completes
Then mark the source as completed
     keep running active accumulator inners and admit queued values as capacity opens
     complete when the last inner completes and the queue is empty
```

## Error rule

```text
Given any state
When the source or any active accumulator inner errors
Then discard the accumulator and queued values
     unsubscribe all active inners
     error immediately
```

## Unsubscription rule

```text
Given accumulator inners are active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe every active accumulator inner
     discard the accumulator and queued values
```

## Cancellation rule

```text
Given accumulator inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     accumulator inners always run to completion
```
