# `joinAllInternals`

Internal helper behind `combineLatestAll` and `zipAll`: collects the inner observables of a higher-order source until the source completes, then applies the join function to them and forwards the joined observable's values through the optional projection.

*Note:* Internal helper used by higher-order join operators.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately and collect inner observables
     defer subscribing to the inners until the outer completes
```

## State-conditioned rule

```text
Given inner collection/combine operation active
When the next relevant operator event occurs
Then delegate state to chosen join strategy
```

## Event-triggered rule

```text
Given the relevant inner state exists
When join strategy has enough inner values
Then emit projected joined result
```

## Inner rule

```text
Given the joined observable is active
When it emits a value
Then apply the optional projection
     forward the result
```

## Concurrency rule

```text
Given inner observables are being collected
When an inner observable arrives
Then collect it without limit
     all inners are admitted together once the outer completes
```

## Completion rule

```text
Given inner observables are being collected
When the outer source completes
Then pass the collected inners to the join function
     subscribe to the joined observable
     apply the optional projection to its values
     complete when the joined observable completes
```

## Error rule

```text
Given any state
When the outer source or the joined observable errors
Then error immediately
```

## Unsubscription rule

```text
Given inners are being collected or the joined observable is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source or the joined observable
     discard collected inners
```

## Cancellation rule

```text
Given inners are being collected
When any source value or lifecycle event arrives
Then cancel no active work
     collected inners are subscribed only after the outer completes and are then never cancelled by the helper
```
