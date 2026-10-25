# `startWith`

Emits the given prefix values synchronously (or on the given scheduler) on subscription, and only then subscribes to the source and forwards its values.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then emit the prefix values synchronously, or on the scheduler when one is given
     then subscribe to the source
```

## State-conditioned rule

```text
Given subscription begins
When the next relevant operator event occurs
Then configured prefix values are pending before source
```

## Event-triggered rule

```text
Given the operator is active
When output is subscribed
Then emit prefix values first, then subscribe/forward source
```

## Completion rule

```text
Given the prefix values have been emitted and the source is active
When the source completes
Then complete
```

## Error rule

```text
Given the prefix values have been emitted and the source is active
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given prefix values are being emitted or the source is active
When the downstream subscriber unsubscribes
Then stop emitting prefix values
     unsubscribe from the source
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
