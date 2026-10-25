# `dematerialize`

Converts a source of `ObservableNotification` objects back into the notifications they describe, emitting `next` values and terminating on an `error` or `complete` notification.

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
Then treat each incoming `Notification` object as protocol data
```

## Event-triggered rule

```text
Given the operator is active
When a notification object arrives
Then execute it as next/error/complete on the destination
```

## Completion rules

```text
Given notification objects are being interpreted
When a complete notification arrives as a value
Then complete
     unsubscribe from the source

Given notification objects are being interpreted
When the source completes
Then complete
```

## Error rules

```text
Given notification objects are being interpreted
When an error notification arrives as a value
Then error with the wrapped error
     unsubscribe from the source

Given notification objects are being interpreted
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given notification objects are being interpreted
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given notification objects are being interpreted
When a complete or error notification arrives as a value
Then unsubscribe from the source after forwarding the terminal notification
```
