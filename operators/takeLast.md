# `takeLast`

Holds the last `count` source values in a buffer and emits them in order when the source completes; `takeLast(0)` completes immediately without subscribing.

## Subscription rules

```text
Given count is greater than zero
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with an empty trailing buffer

Given count is zero or less
When a downstream subscriber subscribes
Then complete immediately without subscribing to the source
```

## State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then retain a bounded buffer of the last `count` values
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit buffered trailing values in order, then complete
```

## Completion rule

```text
Given up to count trailing values are buffered
When the source completes
Then emit the buffered values in arrival order
     complete
```

## Error rule

```text
Given up to count trailing values are buffered
When the source errors
Then discard the buffered values
     error immediately
```

## Unsubscription rule

```text
Given trailing values are buffered
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the buffered values
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
