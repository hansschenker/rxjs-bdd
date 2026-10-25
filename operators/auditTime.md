# `auditTime`

Time-based specialization of `audit`: the value that arrives when idle starts a fixed-length timer, later values replace the pending value, and the latest value is emitted when the timer fires.

*Note:* Time-based specialization of `audit`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no pending value and no active interval timer
```

## State-conditioned rule

```text
Given fixed audit interval active
When a source value arrives
Then replace the pending value using the new source value
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When interval ends
Then emit the pending latest value and return to idle
```

## Timer rule

```text
Given a pending value exists and the interval timer is running
When the interval timer fires
Then emit the pending latest value
     return to idle so the next source value starts a new interval
     complete if the source has already completed
```

## Concurrency rules

```text
Given a interval timer is active
When a source value arrives
Then replace the pending value
     do not start another interval timer

Given the operator is idle
When a source value arrives
Then admit it as the pending value
     start the interval timer
```

## Completion rules

```text
Given no pending value exists or no interval timer is active
When the source completes
Then complete immediately

Given a pending value exists and an interval timer is active
When the source completes
Then defer completion until the interval ends
     emit the pending latest value when the interval ends
     complete
```

## Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the interval timer
     error immediately
```

## Unsubscription rule

```text
Given an interval timer may be active with a pending value
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel the interval timer
     discard the pending value without emitting it
```

## Cancellation rule

```text
Given an interval timer is active
When a source value arrives
Then cancel nothing
     the running interval is not restarted; the new value only replaces the pending value
```
