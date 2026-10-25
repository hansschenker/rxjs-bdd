# `delayWhen`

Delays each source value until the duration observable created for that value emits, so values may be reordered; an optional subscription delay observable defers the source subscription itself.

*Note:* Subscription delay may also defer source subscription.

## Subscription rules

```text
Given no subscription delay is configured
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending values

Given a subscription delay is configured
When a downstream subscriber subscribes
Then subscribe to the subscription delay first
     subscribe to the source once the subscription delay emits once or completes
```

## State-conditioned rule

```text
Given source values pending
When the relevant scheduled event occurs
Then associate each value with a duration Observable
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When that value's duration emits
Then release/emit the corresponding source value
```

## Notifier rules

```text
Given a duration is active for a pending value
When the duration observable emits
Then unsubscribe the duration
     emit the pending value

Given a duration is active for a pending value
When the duration observable completes without emitting
Then drop the pending value

Given a subscription delay is configured and pending
When the subscription delay emits or completes
Then unsubscribe the subscription delay
     subscribe to the source
```

## Concurrency rule

```text
Given durations are active
When a source value arrives
Then admit it: start its own duration without limit
     emission order follows duration order, not arrival order
```

## Completion rules

```text
Given durations are active for pending values
When the source completes
Then keep waiting on each active duration
     emit each value when its duration first emits
     complete after the last pending duration resolves

Given no values are pending
When the source completes
Then complete

Given a value is pending on its duration
When its duration completes without emitting
Then drop the pending value without emitting it
```

## Error rule

```text
Given any state
When the source or any active duration observable errors
Then discard pending values
     unsubscribe active durations
     error immediately
```

## Unsubscription rule

```text
Given durations are active for pending values
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe every active duration
     unsubscribe a pending subscription delay
     discard pending values
```

## Cancellation rules

```text
Given a duration is active for a pending value
When the duration emits its first value
Then unsubscribe that duration
     emit the pending value

Given the subscription delay is pending
When the subscription delay emits
Then unsubscribe the subscription delay
     subscribe to the source
```
