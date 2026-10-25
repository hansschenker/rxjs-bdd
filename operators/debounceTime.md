# `debounceTime`

Emits a source value only after a quiet period of `dueTime` with no newer value; each new value replaces the pending value and restarts the silence window. A pending value is still emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending value and no silence timer
```

## State-conditioned rule

```text
Given silence timer active
When a source value arrives
Then replace pending value and restart the timer for the source value
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When configured silence interval elapses
Then emit the pending latest value
```

## Timer rule

```text
Given the silence task is scheduled and a pending value exists
When the scheduled task fires
Then if dueTime has not fully elapsed since the latest value, reschedule the task for the remaining time
     otherwise emit the pending latest value and clear the task
```

## Concurrency rule

```text
Given a silence timer is active
When a source value arrives
Then replace the pending value
     restart the silence window from this value
```

## Completion rules

```text
Given a pending value exists
When the source completes
Then cancel the silence timer
     emit the pending latest value
     complete

Given no pending value exists
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the silence timer
     error immediately
```

## Unsubscription rule

```text
Given a pending value may exist with the silence timer running
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel the silence timer
     discard the pending value without emitting it
```

## Cancellation rule

```text
Given the silence task is scheduled
When a new source value arrives
Then cancel nothing
     record the arrival time of the new value
     the running task re-checks the deadline when it fires and reschedules itself for the remaining time
```
