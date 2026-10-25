# `filter`

Forwards only the source values for which the predicate returns true; completion and errors pass through unchanged.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start the index at zero
```

## State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no operator-specific state except index
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a source value arrives
Then emit it only if predicate(value, index) is true
```

## Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

## Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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
