# `scanInternals`

Internal helper behind `scan` and `reduce`: maintains the accumulator and the seed state, and either emits after every step or only the final value on completion, depending on how it is configured.

*Note:* Internal helper behind `scan`/`reduce`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     initialise the accumulator with the seed when one is provided; otherwise the first value becomes the accumulator
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain accumulator, index, and seed-state flag
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then initialize/update accumulator and optionally emit according to helper configuration
```

## Completion rules

```text
Given emitOnComplete is set and accumulated state exists
When the source completes
Then emit the accumulated state
     complete

Given emitOnComplete is not set, or no state has been accumulated
When the source completes
Then complete without emitting
```

## Error rule

```text
Given any state
When the source errors
Then discard the accumulator
     error immediately
```

## Unsubscription rule

```text
Given an accumulator is retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the accumulator
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
