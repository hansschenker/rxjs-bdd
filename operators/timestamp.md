# `timestamp`

Emits each source value wrapped in an object that pairs it with the current time as reported by the given timestamp provider.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
```

## State-conditioned rule

```text
Given source active
When the relevant scheduled event occurs
Then keep no evolving value state beyond scheduler access
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit `{value, timestamp: scheduler.now()}`
```

## Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

## Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given the source subscription is active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
