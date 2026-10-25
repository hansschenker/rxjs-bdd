# `publishReplay`

Deprecated: multicasts the source through a `ReplaySubject` with the given buffer size and window time, replaying buffered values to late subscribers.

*Note:* Deprecated.

## Subscription rules

```text
Given no selector is configured
When a downstream subscriber subscribes
Then attach the subscriber to the ReplaySubject
     replay buffered values immediately
     do not subscribe to the source until connect() is called on the ConnectableObservable

Given a selector is configured
When a downstream subscriber subscribes
Then subscribe the subscriber to the selector output
     then connect the source to the ReplaySubject
```

## State-conditioned rule

```text
Given connectable state active
When the relevant input event occurs
Then retain configured replay buffer/window in ReplaySubject
```

## Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then replay retained notifications then receive live shared values
```

## Completion rule

```text
Given the source is connected to the ReplaySubject
When the source completes
Then complete every current subscriber
     late subscribers replay the buffered values and then complete
```

## Error rule

```text
Given the source is connected to the ReplaySubject
When the source errors
Then error every current subscriber
     late subscribers replay the buffered values and then error
```

## Unsubscription rule

```text
Given a subscriber is attached to the ReplaySubject
When the downstream subscriber unsubscribes
Then detach that subscriber from the ReplaySubject
     keep the source connection alive until the connection itself is unsubscribed, or until refCount drops to zero when refCount is applied
```

## Cancellation rule

```text
Given the source is connected to the ReplaySubject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
