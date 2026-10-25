# `switchMapTo`

Deprecated specialization of `switchMap` that maps every source value to the same inner observable, resubscribing to it and cancelling the previous subscription on each source value.

*Note:* Deprecated specialization.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active configured inner
```

## State-conditioned rule

```text
Given one fixed inner active
When a subscription lifecycle event occurs
Then remember only latest inner subscription instance
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner and subscribe to the configured inner again
```

## Inner rule

```text
Given the current configured inner is active
When the current configured inner emits a value
Then forward the value immediately
     values from a replaced configured inner are never forwarded
```

## Concurrency rule

```text
Given an inner is active
When a new outer value arrives
Then replace: unsubscribe the active inner and admit the new one immediately
     nothing is queued
```

## Completion rules

```text
Given no configured inner is active
When the outer source completes
Then complete immediately

Given a configured inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active configured inner completes
```

## Error rule

```text
Given any state
When the outer source or the active configured inner errors
Then unsubscribe the active configured inner
     error immediately
```

## Unsubscription rule

```text
Given a configured inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active configured inner
```

## Cancellation rule

```text
Given a configured inner is active
When a new outer value arrives
Then unsubscribe the active inner
     subscribe to the configured inner again
```
