# `single`

Emits the one source value that satisfies the predicate (or the only value) when the source completes; errors with `SequenceError` if a second value matches, `NotFoundError` if values arrived but none matched, or `EmptyError` if the source was empty.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no value seen and no match
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain whether one matching value has been found and that value
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a second matching value arrives
Then error; source completes with exactly one match: emit it; otherwise empty/not-found error semantics apply
```

## Completion rules

```text
Given exactly one value has matched
When the source completes
Then emit the matched value
     complete

Given values have arrived but none matched
When the source completes
Then error with NotFoundError

Given no value has arrived
When the source completes
Then error with EmptyError
```

## Error rule

```text
Given any state
When the source errors
Then discard the retained match
     error immediately
```

## Unsubscription rule

```text
Given a matching value may be retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the retained match
```

## Cancellation rule

```text
Given one matching value is retained
When a second matching value arrives
Then error with SequenceError
     unsubscribe from the source
```
