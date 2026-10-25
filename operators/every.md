# `every`

Tests each source value against the predicate; emits `false` and completes as soon as a value fails, otherwise emits `true` when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start in the all-passed state
```

## State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then remain in 'all passed' state while predicate is true
```

## Event-triggered rule

```text
Given the operator is active
When a value fails predicate
Then emit false and complete; source completes without failure: emit true
```

## Completion rule

```text
Given no value has failed the predicate
When the source completes
Then emit true
     complete
```

## Error rule

```text
Given no value has failed the predicate
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given no value has failed the predicate
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given no value has failed the predicate
When a value fails the predicate
Then emit false
     complete
     unsubscribe from the source
```
