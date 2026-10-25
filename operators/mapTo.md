# `mapTo`

Deprecated specialization of `map` that replaces every source value with the same constant.

*Note:* Deprecated specialization of `map`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
```

## State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no operator-specific value state
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit the configured constant
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
