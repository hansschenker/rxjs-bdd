# `findIndex`

Emits the zero-based index of the first source value that satisfies the predicate and completes; emits `-1` if the source completes without a match.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no match
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then track index while scanning for first predicate match
```

## Event-triggered rule

```text
Given the operator is active
When first match arrives
Then emit its index and complete; source completes without match: emit `-1`
```

## Completion rule

```text
Given no value has matched the predicate
When the source completes
Then emit -1
     complete
```

## Error rule

```text
Given no value has matched the predicate
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given no value has matched
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given no value has matched
When the first matching value arrives
Then emit its index
     complete
     unsubscribe from the source
```
