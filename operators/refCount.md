# `refCount`

Connects a `ConnectableObservable` when its first subscriber arrives and disconnects it when the subscriber count drops to zero, so the shared source is active only while subscribers exist.

## Subscription rules

```text
Given the reference count is zero
When a downstream subscriber subscribes
Then attach the subscriber to the connectable's subject
     increment the reference count to one
     connect the source

Given the reference count is above zero
When a downstream subscriber subscribes
Then attach the subscriber to the connectable's subject
     increment the reference count
     reuse the existing connection
```

## State-conditioned rule

```text
Given shared connectable subscriber count > 0
When the next relevant source event occurs
Then retain count and active connection
```

## Event-triggered rule

```text
Given the operator is active
When first subscriber arrives
Then connect; last subscriber leaves: disconnect shared connection
```

## Completion rule

```text
Given the connection is active with subscribers
When the connectable source completes
Then complete every subscriber through the shared subject
```

## Error rule

```text
Given the connection is active with subscribers
When the connectable source errors
Then error every subscriber through the shared subject
```

## Unsubscription rules

```text
Given more than one subscriber is attached
When a subscriber unsubscribes
Then decrement the reference count
     keep the shared connection

Given exactly one subscriber is attached
When that subscriber unsubscribes
Then decrement the reference count to zero
     unsubscribe the shared connection
```

## Cancellation rule

```text
Given the shared connection is active
When the reference count reaches zero
Then cancel the shared source execution by unsubscribing the connection
```
