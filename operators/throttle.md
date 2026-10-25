# `throttle`

Emits the leading source value and starts a duration observable from it, ignoring further values while the duration is active; with `trailing: true` the latest suppressed value is emitted when the duration ends. Defaults to leading only.

*Note:* Default is leading `true`, trailing `false`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no active duration and no pending value
```

## State-conditioned rule

```text
Given duration active
When a source value arrives
Then suppress new source values, optionally retaining a trailing value depending on config
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When leading/trailing boundary occurs
Then emit according to `{leading, trailing}` policy and manage the duration
```

## Notifier rules

```text
Given a duration is active
When the duration observable emits
Then unsubscribe the duration
     emit the pending trailing value when trailing is enabled and one exists, which starts a new duration
     otherwise return to idle
     complete if the source has already completed and nothing is pending

Given a duration is active
When the duration observable completes without emitting
Then return to idle without emitting
     complete, dropping any pending trailing value, if the source has already completed
```

## Concurrency rules

```text
Given the duration is active
When a source value arrives
Then ignore the value when trailing is false
     retain it as the trailing value, replacing any earlier one, when trailing is true

Given the operator is idle
When a source value arrives
Then emit it immediately when leading is true, otherwise retain it as the trailing value
     start the duration
```

## Completion rules

```text
Given trailing is enabled, a trailing value is pending, and the duration is active
When the source completes
Then defer completion until the duration ends
     emit the trailing value
     complete

Given no trailing value is pending, or trailing is disabled
When the source completes
Then discard any suppressed value
     complete immediately
```

## Error rule

```text
Given any state
When the source or the active duration observable errors
Then discard any pending value
     cancel the duration
     error immediately
```

## Unsubscription rule

```text
Given a duration may be active with a pending trailing value
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the active duration
     discard the pending trailing value
```

## Cancellation rules

```text
Given a duration is active
When the duration observable emits
Then unsubscribe the duration after its first emission
     emit the trailing value if trailing is enabled and one is pending

Given a duration is active
When a source value arrives
Then cancel nothing
     the running duration is not restarted
```
