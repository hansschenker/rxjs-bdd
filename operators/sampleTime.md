# `sampleTime`

Emits the latest source value at each tick of a fixed interval, but only if a new value arrived since the previous tick; a pending value is discarded when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source first
     then start the periodic sampling interval
     start with no pending value
```

## State-conditioned rule

```text
Given source active
When a source value arrives
Then remember latest source value and pending flag between periodic sample ticks
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When sampling interval ticks
Then emit remembered latest value if one is pending
```

## Timer rules

```text
Given a pending value exists
When the sampling interval ticks
Then emit the pending latest value
     clear the pending flag

Given no pending value exists
When the sampling interval ticks
Then emit nothing
```

## Concurrency rule

```text
Given the next sample has not occurred
When a source value arrives
Then replace the pending value
     only the latest value per sample period is admitted
```

## Completion rule

```text
Given a pending sampled value exists
When the source completes
Then discard the pending value without emitting it
     cancel the sampling interval
     complete
```

## Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the sampling interval
     error immediately
```

## Unsubscription rule

```text
Given a pending sampled value may exist
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel the sampling interval
     discard the pending value
```

## Cancellation rule

```text
Given the sampling interval is active
When the source terminates
Then unsubscribe the sampling interval as part of termination teardown
```
