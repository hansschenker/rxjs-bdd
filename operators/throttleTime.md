# `throttleTime`

Time-based specialization of `throttle`: emits a source value, then suppresses values for the given duration; with `trailing: true` the latest suppressed value is emitted when the timer fires.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no running interval and no pending value
```

## State-conditioned rule

```text
Given fixed throttle interval active
When a source value arrives
Then suppress new source values, optionally retain trailing value
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When interval boundary occurs
Then emit according to leading/trailing configuration and reopen as required
```

## Timer rule

```text
Given the interval timer is running
When the interval timer fires
Then end throttling
     emit the pending trailing value when trailing is enabled and one exists, which starts a new interval
     otherwise return to idle
     complete if the source has already completed and nothing is pending
```

## Concurrency rules

```text
Given the interval timer is active
When a source value arrives
Then ignore the value when trailing is false
     retain it as the trailing value, replacing any earlier one, when trailing is true

Given the operator is idle
When a source value arrives
Then emit it immediately when leading is true, otherwise retain it as the trailing value
     start the interval timer
```

## Completion rules

```text
Given trailing is enabled, a trailing value is pending, and the interval timer is active
When the source completes
Then defer completion until the interval timer ends
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
When the source errors
Then discard any pending value
     cancel the interval timer
     error immediately
```

## Unsubscription rule

```text
Given an interval timer may be running with a pending trailing value
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel the interval timer
     discard the pending trailing value
```

## Cancellation rule

```text
Given the interval timer is running
When a source value arrives
Then cancel nothing
     the running interval is not restarted; the value is suppressed or retained as the trailing value
```
