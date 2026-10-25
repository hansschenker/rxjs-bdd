# `audit`

Holds the latest source value while a duration observable, started by the value that arrives when idle, is active; when the duration emits, the pending latest value is emitted and the operator returns to idle. Values arriving during the duration only replace the pending value.

*Note:* The first source value starts the duration.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending value and no active duration
```

## State-conditioned rule

```text
Given duration active
When a source value arrives
Then replace the pending value using the new source value
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When duration ends
Then emit the pending latest value and return to idle
```

## Notifier rules

```text
Given a duration is active with a pending value
When the duration observable emits
Then unsubscribe the duration
     emit the pending latest value
     return to idle
     complete if the source has already completed

Given a duration is active
When the duration observable completes without emitting
Then clear the duration without emitting the pending value
     the pending value is replaced by the next source value, which starts a new duration
     complete, dropping the pending value, if the source has already completed
```

## Concurrency rules

```text
Given a duration is active
When a source value arrives
Then replace the pending value
     do not start another duration

Given the operator is idle
When a source value arrives
Then admit it as the pending value
     start the duration
```

## Completion rules

```text
Given no pending value exists or no duration is active
When the source completes
Then complete immediately

Given a pending value exists and a duration is active
When the source completes
Then defer completion until the duration ends
     emit the pending latest value when the duration ends
     complete
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
Given a duration may be active with a pending value
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the active duration
     discard the pending value without emitting it
```

## Cancellation rules

```text
Given a duration is active
When a source value arrives
Then cancel nothing
     the running duration continues; the new value only replaces the pending value

Given a duration is active
When the duration observable emits
Then unsubscribe the duration observable after its first emission
```
