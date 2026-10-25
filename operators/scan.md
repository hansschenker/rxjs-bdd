# `scan`

Applies the accumulator to each source value and emits every intermediate accumulated value; with a seed the first emission is the accumulator applied to the seed and the first value, otherwise the first value itself is emitted as the initial accumulator.

*Note:* State is emitted on every reduction step.

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
Then retain accumulator
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then update accumulator with reducer and emit the updated accumulator
```

## Completion rule

```text
Given an accumulator is retained
When the source completes
Then complete without emitting the accumulator again
```

## Error rule

```text
Given an accumulator is retained
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
