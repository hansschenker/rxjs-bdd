# `takeWhile`

Forwards source values while the predicate holds and completes at the first value that fails it; with `inclusive: true` that failing value is emitted before completing.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start in the taking state
```

## State-conditioned rule

```text
Given taking state active
When the next relevant operator event occurs
Then evaluate predicate for each value
```

## Event-triggered rule

```text
Given the operator is active
When predicate becomes false
Then optionally emit boundary value if `inclusive`, then complete; otherwise emit qualifying values
```

## Completion rule

```text
Given the predicate has not yet failed
When the source completes
Then complete
```

## Error rule

```text
Given the predicate has not yet failed
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given the predicate has not yet failed
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given the predicate has not yet failed
When a value fails the predicate
Then emit it only if inclusive is set
     complete
     unsubscribe from the source
```
