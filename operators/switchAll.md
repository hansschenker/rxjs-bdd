# `switchAll`

Flattens a higher-order source by subscribing to each new inner observable and unsubscribing the previously active inner, so only the latest inner's values are forwarded.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active inner
```

## State-conditioned rule

```text
Given one current inner active
When a subscription lifecycle event occurs
Then remember only the latest inner subscription
```

## Event-triggered rule

```text
Given the relevant inner state exists
When new inner Observable arrives
Then cancel previous inner and subscribe to the new one; forward only current inner
```

## Inner rule

```text
Given the current inner is active
When the current inner emits a value
Then forward the value immediately
     values from a replaced inner are never forwarded
```

## Concurrency rule

```text
Given an inner is active
When a new inner observable arrives
Then replace: unsubscribe the active inner and admit the new one immediately
     nothing is queued
```

## Completion rules

```text
Given no inner is active
When the outer source completes
Then complete immediately

Given a inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active inner completes
```

## Error rule

```text
Given any state
When the outer source or the active inner errors
Then unsubscribe the active inner
     error immediately
```

## Unsubscription rule

```text
Given a inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active inner
```

## Cancellation rule

```text
Given an inner is active
When a new inner observable arrives
Then unsubscribe the active inner
     subscribe to the new inner
```
