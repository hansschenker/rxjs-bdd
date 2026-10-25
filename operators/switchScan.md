# `switchScan`

Projects each source value together with the current accumulator to an inner observable, unsubscribing the previously active inner; every value of the current inner replaces the accumulator and is emitted.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     initialise the accumulator with the seed
     start with no active inner
```

## State-conditioned rule

```text
Given one projected accumulator inner active
When the next relevant source event occurs
Then retain accumulator and current inner
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner and start projection from current accumulator; inner emissions replace and emit accumulator
```

## Inner rule

```text
Given the current accumulator inner is active
When it emits a value
Then replace the accumulator with the value
     emit the new accumulator
     values from a replaced inner are never applied
```

## Concurrency rule

```text
Given an inner is active
When a new outer value arrives
Then replace: unsubscribe the active inner and admit the new one immediately
     nothing is queued
```

## Completion rules

```text
Given no accumulator inner is active
When the source completes
Then complete immediately

Given an accumulator inner is active
When the source completes
Then mark the source as completed
     complete when the active inner completes
```

## Error rule

```text
Given any state
When the source or the active accumulator inner errors
Then discard the accumulator
     unsubscribe the active inner
     error immediately
```

## Unsubscription rule

```text
Given a accumulator inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active accumulator inner
     discard the accumulator
```

## Cancellation rule

```text
Given an accumulator inner is active
When a new outer value arrives
Then unsubscribe the active accumulator inner
     project and subscribe to a new inner from the current accumulator
```
