# `skip`

Drops the first `count` source values and forwards every later value unchanged.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start the skip counter at zero
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count seen values
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives after the first `count` values
Then emit it; earlier values emit nothing
```

## Completion rule

```text
Given values are being counted
When the source completes
Then complete
```

## Error rule

```text
Given values are being counted
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given values are being counted
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
