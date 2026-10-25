# `timeout`

Errors with `TimeoutError`, or switches to the fallback observable given by `with`, if the first value does not arrive within `first`, or if any later value does not arrive within `each` of the previous one.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source
     if no value arrived synchronously, start the first-value timer from the first option (duration or absolute date), or else from each
```

## State-conditioned rule

```text
Given waiting state active
When the relevant scheduled event occurs
Then track deadline for first/each value using scheduler
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When deadline expires before required source emission
Then unsubscribe source and switch to configured fallback or throw TimeoutError
```

## Timer rule

```text
Given a timeout timer is pending
When the timer fires before the awaited value
Then unsubscribe from the source
     subscribe to the observable returned by with, when configured
     otherwise error with a TimeoutError carrying meta, lastValue, and seen
```

## Inner rule

```text
Given the fallback observable is active
When the fallback observable emits a value
Then forward the value unchanged
     no further timeout is applied
```

## Completion rule

```text
Given a timeout deadline is pending
When the source completes
Then cancel the pending timeout timer
     complete
```

## Error rule

```text
Given a timeout deadline is pending
When the source errors
Then cancel the pending timeout timer
     error immediately
```

## Unsubscription rule

```text
Given a timeout timer is pending
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel the pending timeout timer
```

## Cancellation rules

```text
Given a timeout timer is pending
When a source value arrives
Then cancel the pending timer
     schedule a new timer when an each timeout is configured

Given a timeout timer is pending
When the timer fires
Then unsubscribe from the source
     subscribe to the fallback observable, or error with TimeoutError when none is configured
```
