# `publish`

Deprecated wrapper around `multicast` with a plain `Subject`: returns a `ConnectableObservable` that subscribes to the source only when connected, or applies a selector over the shared source.

*Note:* Deprecated wrapper around connectable/multicast semantics.

## Subscription rules

```text
Given no selector is configured
When a downstream subscriber subscribes
Then attach the subscriber to the Subject
     do not subscribe to the source until connect() is called on the ConnectableObservable

Given a selector is configured
When a downstream subscriber subscribes
Then subscribe the subscriber to the selector output
     then connect the source to the Subject
```

## State-conditioned rule

```text
Given connectable state active
When the next relevant operator event occurs
Then multicast through a plain Subject
```

## Event-triggered rule

```text
Given the operator is active
When connection starts
Then subscribe Subject to source and share that execution
```

## Completion rule

```text
Given the source is connected to the Subject
When the source completes
Then complete every current subscriber
     late subscribers complete immediately
```

## Error rule

```text
Given the source is connected to the Subject
When the source errors
Then error every current subscriber
     late subscribers error immediately
```

## Unsubscription rule

```text
Given a subscriber is attached to the Subject
When the downstream subscriber unsubscribes
Then detach that subscriber from the Subject
     keep the source connection alive until the connection itself is unsubscribed, or until refCount drops to zero when refCount is applied
```

## Cancellation rule

```text
Given the source is connected to the Subject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
