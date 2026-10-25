# `delay`

Delays each source value by a fixed duration (or until an absolute date), delivering values in arrival order; completion waits until every pending value has been delivered, while errors propagate immediately.

*Note:* Implemented via `delayWhen`/timer semantics in RxJS 7.x.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending delayed values
```

## State-conditioned rule

```text
Given notifications pending
When the next relevant operator event occurs
Then schedule each source notification for later delivery
```

## Event-triggered rule

```text
Given the operator is active
When its scheduled due time arrives
Then forward that notification
```

## Timer rule

```text
Given a delayed value is pending
When its timer fires after the configured duration or at the configured date
Then emit that value
     complete if the source has completed and no other value is pending
```

## Concurrency rule

```text
Given delayed values are pending
When a source value arrives
Then admit it: schedule its own timer
     pending values are unbounded and preserve arrival order
```

## Completion rules

```text
Given delayed values are pending
When the source completes
Then keep the pending timers running
     emit each pending value when its delay elapses
     complete after the last pending value is emitted

Given no delayed values are pending
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source errors
Then cancel pending timers and discard their values
     error immediately
```

## Unsubscription rule

```text
Given delayed values are pending
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel every pending delay timer
     discard their values
```

## Cancellation rule

```text
Given delayed values are pending
When any source value or lifecycle event arrives
Then cancel no active work
     pending timers are never cancelled by the operator; only downstream unsubscription or a source error cancels them
```
