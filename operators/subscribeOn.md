# `subscribeOn`

Defers the subscription to the source onto the given scheduler, optionally after a delay, so the source's subscription side effects run in that scheduler's context; notifications themselves are not rescheduled.

*Note:* Moves subscription side effect in time/context.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then schedule the source subscription on the scheduler
     the source is not subscribed until the scheduled action runs
```

## State-conditioned rule

```text
Given source subscription is pending on a scheduler
When a subscription lifecycle event occurs
Then keep the source subscription deferred
```

## Event-triggered rule

```text
Given the operator is active
When scheduled subscription action executes
Then subscribe to the source
```

## Timer rule

```text
Given the source subscription is scheduled
When the scheduled action runs
Then subscribe to the source
     deliver source notifications without further scheduling
```

## Completion rule

```text
Given the source subscription has been scheduled or established
When the source completes
Then complete
```

## Error rule

```text
Given the source subscription has been scheduled or established
When the source errors
Then error immediately
```

## Unsubscription rules

```text
Given the source subscription is still scheduled
When the downstream subscriber unsubscribes
Then cancel the scheduled subscription action
     the source is never subscribed

Given the source has been subscribed
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given the source has been subscribed
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
