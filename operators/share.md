# `share`

Multicasts the source through a connector Subject shared by all subscribers, connecting on the first subscriber and, by default, disconnecting when the last one leaves; the `resetOnError`, `resetOnComplete`, and `resetOnRefCountZero` options control when the connection is reset.

## Subscription rules

```text
Given no connection exists
When a downstream subscriber subscribes
Then create the subject with the connector
     set the reference count to one
     subscribe the subscriber to the subject
     then connect the source

Given a connection exists
When a downstream subscriber subscribes
Then increment the reference count
     attach the subscriber to the existing subject
     cancel a pending reset if one is scheduled
```

## State-conditioned rule

```text
Given shared subscription state active
When a subscription lifecycle event occurs
Then retain connector, subscriber count, and reset state
```

## Event-triggered rule

```text
Given the operator is active
When first subscriber needs source
Then connect; reset conditions occur: reset connector/connection according to configuration
```

## Notifier rule

```text
Given a reset notifier factory is configured for resetOnRefCountZero, resetOnComplete, or resetOnError, and that condition has occurred
When the reset notifier emits
Then reset the subject and connection
     later subscribers resubscribe to the source
```

## Completion rule

```text
Given the source is connected
When the source completes
Then complete every current subscriber
     reset the connection and subject when resetOnComplete is set (default true), so later subscribers resubscribe to the source
```

## Error rule

```text
Given the source is connected
When the source errors
Then error every current subscriber
     reset the connection and subject when resetOnError is set (default true), so later subscribers resubscribe to the source
```

## Unsubscription rules

```text
Given more than one subscriber is attached
When a subscriber unsubscribes
Then decrement the reference count
     keep the connection

Given exactly one subscriber is attached
When that subscriber unsubscribes
Then decrement the reference count to zero
     when resetOnRefCountZero is set (default true), unsubscribe the source connection and reset the subject, after the reset notifier emits if one is configured
```

## Cancellation rule

```text
Given the reference count dropped to zero and a reset notifier is pending
When a new subscriber arrives before the notifier emits
Then cancel the pending reset
     keep the existing connection and subject
```
