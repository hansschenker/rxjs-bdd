# `timeoutWith`

Deprecated wrapper around `timeout`: switches to the given fallback observable when the source does not emit within the due time, forwarding the fallback's notifications.

*Note:* Deprecated wrapper around `timeout`.

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
Then track timeout deadline
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When deadline expires
Then unsubscribe source and subscribe to configured fallback Observable
```

## Timer rule

```text
Given a timeout timer is pending
When the timer fires before the awaited value
Then unsubscribe from the source
     subscribe to the configured fallback observable
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
     schedule a new timer for the next value

Given a timeout timer is pending
When the timer fires
Then unsubscribe from the source
     subscribe to the configured fallback observable
```
