# `sample`

Keeps the latest source value pending and emits it each time the notifier emits, provided a new value has arrived since the last sample; a pending value is discarded when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source first
     then subscribe to the notifier
     start with no pending value
```

## State-conditioned rule

```text
Given source active
When a source value arrives
Then remember latest source value and whether a new value exists since last sample
```

## Event-triggered rule

```text
Given the operator is active
When sampler emits
Then emit remembered latest value if one is pending, then clear pending flag
```

## Notifier rules

```text
Given a pending value exists
When the notifier emits
Then emit the pending latest value
     clear the pending flag

Given no pending value exists
When the notifier emits
Then emit nothing
```

## Concurrency rule

```text
Given the next sample has not occurred
When a source value arrives
Then replace the pending value
     only the latest value per sample period is admitted
```

## Completion rules

```text
Given a pending sampled value exists
When the source completes
Then discard the pending value without emitting it
     complete

Given the source subscription is active
When the notifier completes
Then ignore the completion
     keep sampling state until the source completes
```

## Error rule

```text
Given any state
When the source or the notifier errors
Then discard the pending value
     error immediately
```

## Unsubscription rule

```text
Given a pending sampled value may exist
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the notifier
     discard the pending value
```

## Cancellation rule

```text
Given the notifier is active
When the source terminates
Then unsubscribe the notifier as part of termination teardown
```
