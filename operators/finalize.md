# `finalize`

Forwards every notification unchanged and runs the callback once when the subscription ends, whether by completion, error, or unsubscription.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source
     then register the finalizer on the subscription
```

## State-conditioned rule

```text
Given subscription active
When the next relevant source event occurs
Then retain the finalizer for teardown
```

## Event-triggered rule

```text
Given the operator is active
When source terminates or subscriber explicitly unsubscribes
Then invoke the finalizer exactly as teardown requires
```

## Completion rule

```text
Given the finalizer is registered
When the source completes
Then complete
     invoke the finalizer during teardown
```

## Error rule

```text
Given the finalizer is registered
When the source errors
Then error immediately
     invoke the finalizer during teardown
```

## Unsubscription rule

```text
Given the finalizer is registered
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     invoke the finalizer
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
