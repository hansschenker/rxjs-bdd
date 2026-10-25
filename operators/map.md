# `map`

Applies the projection function to each source value, with its index, and forwards the result; completion and errors pass through unchanged.

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
Then keep no operator-specific value state except index
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit project(value, index)
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
