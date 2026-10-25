# `ignoreElements`

Drops every source value and forwards only the source's completion or error.

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
Then maintain no value state
```

## Event-triggered rule

```text
Given the operator is active
When source next arrives
Then emit nothing; source error/complete arrives: forward the terminal notification
```

## Completion rule

```text
Given values are being ignored
When the source completes
Then complete
```

## Error rule

```text
Given values are being ignored
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given values are being ignored
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
