# `tap`

Runs the given side-effect callbacks for `next`, `error`, `complete`, `subscribe`, `unsubscribe`, and `finalize` without altering the forwarded notifications.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then invoke the subscribe callback
     then subscribe to the source
```

## State-conditioned rule

```text
Given source active
When a source value arrives
Then preserve source values while invoking side-effect observers
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When next/error/complete/subscription/finalize events occur
Then invoke configured side effect and otherwise mirror source protocol
```

## Completion rule

```text
Given the source subscription is active
When the source completes
Then invoke the complete callback
     complete
     invoke the finalize callback during teardown
```

## Error rule

```text
Given the source subscription is active
When the source errors
Then invoke the error callback
     error immediately
     invoke the finalize callback during teardown
```

## Unsubscription rule

```text
Given the source subscription is active
When the downstream subscriber unsubscribes
Then invoke the unsubscribe callback
     unsubscribe from the source
     invoke the finalize callback
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
