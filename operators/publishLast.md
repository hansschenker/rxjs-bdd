# `publishLast`

Deprecated: multicasts the source through an `AsyncSubject`, so every subscriber receives only the final source value, delivered when the source completes.

*Note:* Deprecated.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then attach the subscriber to the AsyncSubject
     deliver nothing until the source completes
     do not subscribe to the source until connect() is called on the ConnectableObservable
```

## State-conditioned rule

```text
Given connectable state active
When the next relevant source event occurs
Then multicast through AsyncSubject retaining only final value
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained last value to subscribers and complete
```

## Completion rule

```text
Given the source is connected to the AsyncSubject
When the source completes
Then emit the retained last value, if any, to every current subscriber
     complete every current subscriber
     late subscribers receive the last value and complete
```

## Error rule

```text
Given the source is connected to the AsyncSubject
When the source errors
Then error every current subscriber
     late subscribers error immediately
     the retained last value is never emitted
```

## Unsubscription rule

```text
Given a subscriber is attached to the AsyncSubject
When the downstream subscriber unsubscribes
Then detach that subscriber from the AsyncSubject
     keep the source connection alive until the connection itself is unsubscribed, or until refCount drops to zero when refCount is applied
```

## Cancellation rule

```text
Given the source is connected to the AsyncSubject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
