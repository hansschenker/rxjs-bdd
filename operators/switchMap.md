# `switchMap`

Projects each source value to an inner observable, subscribes to it, and unsubscribes the previously active inner, so only values from the latest inner are forwarded (concurrency policy: only latest).

*Note:* Concurrency policy: only latest.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active projected inner
```

## State-conditioned rule

```text
Given one projected inner active
When a subscription lifecycle event occurs
Then remember only the latest inner subscription
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner, project, and subscribe to the new inner
```

## Inner rule

```text
Given the current projected inner is active
When the current projected inner emits a value
Then forward the value immediately
     values from a replaced projected inner are never forwarded
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
Given no projected inner is active
When the outer source completes
Then complete immediately

Given a projected inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active projected inner completes
```

## Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then unsubscribe the active projected inner
     error immediately
```

## Unsubscription rule

```text
Given a projected inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active projected inner
```

## Cancellation rule

```text
Given a projected inner is active
When a new outer value arrives
Then unsubscribe the active projected inner
     project and subscribe to the new inner
```
