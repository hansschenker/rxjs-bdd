# `count`

Counts the source values that satisfy the optional predicate (or all values) and emits the total as a single value when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start the count at zero
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then increment count for the value satisfying the predicate (or every value without one)
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the final count and complete
```

## Completion rule

```text
Given a running count exists, possibly zero
When the source completes
Then emit the final count
     complete
```

## Error rule

```text
Given a running count exists
When the source errors
Then discard the count
     error immediately
```

## Unsubscription rule

```text
Given a running count exists
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the count
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
