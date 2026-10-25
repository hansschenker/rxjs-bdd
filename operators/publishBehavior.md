# `publishBehavior`

Deprecated: multicasts the source through a `BehaviorSubject` seeded with the initial value, so each subscriber immediately receives the current value and then live values once connected.

*Note:* Deprecated.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then attach the subscriber to the BehaviorSubject
     deliver the current value immediately
     do not subscribe to the source until connect() is called on the ConnectableObservable
```

## State-conditioned rule

```text
Given connectable state active
When the next relevant source event occurs
Then multicast through BehaviorSubject retaining current value
```

## Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then receive current retained value; connection forwards source into shared BehaviorSubject
```

## Completion rule

```text
Given the source is connected to the BehaviorSubject
When the source completes
Then complete every current subscriber
     late subscribers complete immediately without receiving the retained value
```

## Error rule

```text
Given the source is connected to the BehaviorSubject
When the source errors
Then error every current subscriber
     late subscribers error immediately
```

## Unsubscription rule

```text
Given a subscriber is attached to the BehaviorSubject
When the downstream subscriber unsubscribes
Then detach that subscriber from the BehaviorSubject
     keep the source connection alive until the connection itself is unsubscribed, or until refCount drops to zero when refCount is applied
```

## Cancellation rule

```text
Given the source is connected to the BehaviorSubject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
