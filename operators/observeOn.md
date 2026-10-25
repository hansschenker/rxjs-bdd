# `observeOn`

Reschedules the delivery of every source notification onto the given scheduler, optionally after a delay, without changing when or how the source produces them.

*Note:* Changes notification delivery context, not source production.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     deliveries are scheduled as notifications arrive
```

## State-conditioned rule

```text
Given notifications pending on a scheduler
When the relevant scheduled event occurs
Then retain scheduled delivery tasks
```

## Event-triggered rule

```text
Given the operator is active
When scheduled action executes
Then deliver the corresponding next/error/complete downstream
```

## Timer rule

```text
Given a notification has been scheduled
When its scheduled action runs
Then deliver that next, error, or complete notification downstream in scheduling order
```

## Concurrency rule

```text
Given scheduled deliveries are pending
When a notification arrives
Then schedule it behind the pending deliveries
     delivery order equals arrival order
```

## Completion rule

```text
Given scheduled notifications may be pending
When the source completes
Then schedule the completion on the scheduler
     complete after previously scheduled notifications have been delivered
```

## Error rule

```text
Given scheduled notifications may be pending
When the source errors
Then schedule the error on the scheduler
     error after previously scheduled notifications have been delivered
```

## Unsubscription rule

```text
Given scheduled deliveries may be pending
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel every pending scheduled delivery
```

## Cancellation rule

```text
Given scheduled deliveries may be pending
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
