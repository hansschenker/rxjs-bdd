# `first`

Emits the first source value (or the first one satisfying the predicate) and completes; if the source completes first, emits the default value or errors with `EmptyError`.

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
When the next relevant operator event occurs
Then wait for first value satisfying predicate (or simply first value)
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first qualifying value arrives
Then emit and complete; source completes first: emit default or error
```

## Completion rules

```text
Given no value has matched and no default value is configured
When the source completes
Then error with EmptyError

Given no value has matched and a default value is configured
When the source completes
Then emit the default value
     complete
```

## Error rule

```text
Given no value has matched
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
Then emit it
     complete
     unsubscribe from the source
```
