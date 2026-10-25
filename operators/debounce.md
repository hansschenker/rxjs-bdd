# `debounce`

Starts a duration observable for each source value, discarding the previous pending value's duration; when the duration emits, the pending latest value is emitted. A pending value is still emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending value and no active duration
```

## State-conditioned rule

```text
Given duration active for pending value
When a source value arrives
Then replace pending value and cancel/restart its duration for the source value
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current duration emits/completes before another source value
Then emit the pending latest value
```

## Notifier rules

```text
Given a duration is active for a pending value
When the duration observable emits
Then unsubscribe the duration
     emit the pending value

Given a duration is active for a pending value
When the duration observable completes without emitting
Then keep the pending value
     it is emitted on source completion or replaced by the next source value
```

## Concurrency rule

```text
Given a duration is active
When a source value arrives
Then replace the pending value
     restart the silence window from this value
```

## Completion rules

```text
Given a pending value exists
When the source completes
Then unsubscribe the active duration
     emit the pending latest value
     complete

Given no pending value exists
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source or the active duration observable errors
Then discard the pending value
     unsubscribe the active duration
     error immediately
```

## Unsubscription rule

```text
Given a pending value may exist with an active duration
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the active duration
     discard the pending value without emitting it
```

## Cancellation rules

```text
Given a duration is active for a pending value
When a new source value arrives
Then unsubscribe the current duration observable
     start a new duration for the new value

Given a duration is active
When the duration observable emits
Then unsubscribe the duration after its first emission
     emit the pending value
```
