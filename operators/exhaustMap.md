# `exhaustMap`

Projects each source value to an inner observable but subscribes only when no inner is active; source values that arrive while an inner is active are dropped.

*Note:* Concurrency policy: ignore while busy.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active projected inner
```

## State-conditioned rule

```text
Given one projected inner active
When an outer value arrives
Then ignore the outer value
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then become idle; next outer value may start a new inner
```

## Inner rule

```text
Given the active projected inner is running
When the active projected inner emits a value
Then forward the value immediately
```

## Concurrency rules

```text
Given an inner is active
When a new outer value arrives
Then ignore it
     it is dropped, not queued

Given no inner is active
When a new outer value arrives
Then admit it immediately
```

## Completion rules

```text
Given no projected inner is active
When the outer source completes
Then complete immediately

Given a projected inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active projected inner completes
```

## Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then unsubscribe the active projected inner
     error immediately
```

## Unsubscription rule

```text
Given a projected inner is active
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active projected inner
```

## Cancellation rule

```text
Given a projected inner is active
When any source value or lifecycle event arrives
Then cancel no active work
     outer values arriving while busy are ignored, not cancelled; the active inner always runs to completion
```
