# `multicast`

Deprecated: shares one source subscription through a Subject or Subject factory; without a selector it returns a `ConnectableObservable` that subscribes to the source only when connected, with a selector it connects as soon as the selector output is subscribed.

*Note:* Deprecated multicasting API.

## Subscription rules

```text
Given no selector is configured
When a downstream subscriber subscribes
Then attach the subscriber to the subject
     do not subscribe to the source until connect() is called on the ConnectableObservable

Given a selector is configured
When a downstream subscriber subscribes
Then create the subject
     subscribe the subscriber to the selector output
     then connect the source to the subject
```

## State-conditioned rule

```text
Given connectable state active
When the next relevant operator event occurs
Then route source through a Subject/Subject factory
```

## Event-triggered rule

```text
Given the operator is active
When connection is established
Then subscribe subject to source; subscribers observe the shared subject
```

## Completion rule

```text
Given the source is connected to the subject
When the source completes
Then complete the subject
     complete every current subscriber
     with a selector, the output completes as the selector pipeline propagates completion
```

## Error rule

```text
Given the source is connected to the subject
When the source errors
Then error the subject
     error every current subscriber
     with a selector, the output errors as the selector pipeline propagates the error
```

## Unsubscription rule

```text
Given a subscriber is attached to the shared subject
When the downstream subscriber unsubscribes
Then detach that subscriber from the subject
     keep the source connection alive until the connection itself is unsubscribed, or until the selector output is unsubscribed when a selector is used
```

## Cancellation rule

```text
Given the source is connected to the subject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
