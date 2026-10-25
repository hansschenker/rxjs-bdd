# `last`

Emits the last source value (or the last one satisfying the predicate) when the source completes; if no value qualifies, emits the default value or errors with `EmptyError`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no retained value
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain latest value satisfying predicate (or latest value)
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained last value; if none, emit default or error
```

## Completion rules

```text
Given at least one value has matched
When the source completes
Then emit the retained last matching value
     complete

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
Given any state
When the source errors
Then discard the retained value
     error immediately
```

## Unsubscription rule

```text
Given a last value may be retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the retained value
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
