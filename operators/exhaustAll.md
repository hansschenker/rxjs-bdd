# `exhaustAll`

Flattens a higher-order source by subscribing to an inner observable only when no inner is active; inners that arrive while one is active are dropped (concurrency policy: ignore while busy).

*Note:* Alias-style specialization of exhaust semantics.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active inner
```

## State-conditioned rule

```text
Given one inner active
When an inner event arrives
Then ignore newly arriving inner Observables
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then become idle and allow the next inner
```

## Inner rule

```text
Given the active inner is running
When the active inner emits a value
Then forward the value immediately
```

## Concurrency rules

```text
Given an inner is active
When a new inner observable arrives
Then ignore it
     it is dropped, not queued

Given no inner is active
When a new inner observable arrives
Then admit it immediately
```

## Completion rules

```text
Given no inner is active
When the outer source completes
Then complete immediately

Given a inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active inner completes
```

## Error rule

```text
Given any state
When the outer source or the active inner errors
Then unsubscribe the active inner
     error immediately
```

## Unsubscription rule

```text
Given a inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active inner
```

## Cancellation rule

```text
Given an inner is active
When any source value or lifecycle event arrives
Then cancel no active work
     newly arriving inners are ignored, not cancelled; the active inner always runs to completion
```
