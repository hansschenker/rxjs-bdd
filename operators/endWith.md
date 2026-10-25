# `endWith`

Forwards every source value and, when the source completes, emits the given values in order before completing.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     keep the appended values pending until the source completes
```

## State-conditioned rule

```text
Given source active
When a source value arrives
Then forward source values
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit configured trailing values in order, then complete
```

## Completion rule

```text
Given the source subscription is active
When the source completes
Then emit each appended value in order
     complete
```

## Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
     the appended values are never emitted
```

## Unsubscription rule

```text
Given the source is active or appended values are being emitted
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     stop emitting appended values
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
