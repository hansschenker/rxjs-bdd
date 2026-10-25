# `materialize`

Wraps each `next`, `error`, and `complete` notification from the source in an `ObservableNotification` object emitted as a value; after a terminal notification has been emitted as a value, the output completes normally.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
```

## State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then convert protocol events into `Notification` values
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When next/error/complete occurs
Then emit the corresponding notification object; after terminal notification value, complete normally
```

## Completion rule

```text
Given the source subscription is active
When the source completes
Then emit a complete Notification
     complete
```

## Error rule

```text
Given the source subscription is active
When the source errors
Then emit an error Notification wrapping the error
     complete
     the error itself is not forwarded
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
