# `skipWhile`

Drops source values while the predicate holds; from the first value for which it returns false onward, every value is forwarded regardless of the predicate.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start in the skipping state
```

## State-conditioned rule

```text
Given skipping state active
When a source value arrives
Then evaluate predicate for the source value
```

## Event-triggered rule

```text
Given the operator is active
When predicate first becomes false
Then stop skipping permanently and emit that value plus all subsequent values
```

## Completion rule

```text
Given skipping or forwarding state is active
When the source completes
Then complete
```

## Error rule

```text
Given skipping or forwarding state is active
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given skipping or forwarding state is active
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
