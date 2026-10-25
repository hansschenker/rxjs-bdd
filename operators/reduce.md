# `reduce`

Applies the accumulator to each source value, starting from the optional seed, and emits only the final accumulated value when the source completes; without a seed, an empty source completes without emitting.

*Note:* Unlike `scan`, no intermediate accumulator emissions.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     initialise the accumulator with the seed when one is provided
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain accumulator and whether accumulation has begun
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the final accumulator exactly once, then complete
```

## Completion rules

```text
Given a seed was provided or at least one value has been accumulated
When the source completes
Then emit the accumulated value
     complete

Given no seed was provided and no value has arrived
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
Given an accumulator may be retained
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
