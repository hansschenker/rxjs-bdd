# `timeInterval`

Emits each source value wrapped in a `TimeInterval` object that records the time elapsed since the previous emission (or since subscription), measured with the given scheduler.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     record the scheduler's current time as the baseline
```

## State-conditioned rule

```text
Given source active
When a subscription lifecycle event occurs
Then remember scheduler timestamp of previous emission/subscription baseline
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit `{value, interval}` using elapsed scheduler time and update timestamp
```

## Completion rule

```text
Given a previous timestamp is retained
When the source completes
Then complete
```

## Error rule

```text
Given a previous timestamp is retained
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given a previous timestamp is retained
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
