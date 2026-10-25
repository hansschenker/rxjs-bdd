# `throwIfEmpty`

Forwards source values unchanged, but if the source completes without having emitted, errors with the result of the error factory (default `EmptyError`).

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no value seen
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then remember whether any value has been seen
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes empty
Then error using configured error factory; otherwise complete normally after forwarding values
```

## Completion rules

```text
Given no value has arrived
When the source completes
Then error with the result of the error factory (EmptyError by default)

Given at least one value has arrived
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source errors
Then error immediately
     the error factory is not invoked
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
