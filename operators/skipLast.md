# `skipLast`

Holds the last `count` source values in a buffer, forwarding each value only once `count` newer values have arrived; the held values are discarded when the source completes.

*Note:* Trailing `count` values are discarded on completion.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with an empty trailing buffer
```

## State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then maintain a queue/ring of the last `count` values
```

## Event-triggered rule

```text
Given the operator is active
When a new value makes the buffer exceed `count`
Then emit the oldest buffered value
```

## Completion rule

```text
Given the last count values are buffered
When the source completes
Then discard the buffered values without emitting them
     complete
```

## Error rule

```text
Given the last count values are buffered
When the source errors
Then discard the buffered values
     error immediately
```

## Unsubscription rule

```text
Given the last count values are buffered
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the buffered values
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
