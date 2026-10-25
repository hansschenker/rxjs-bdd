# `find`

Emits the first source value that satisfies the predicate and completes; if the source completes without a match, emits `undefined`.

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
Then scan values until predicate matches
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first matching value arrives
Then emit it and complete; source completes without match: emit `undefined`
```

## Completion rule

```text
Given no value has matched the predicate
When the source completes
Then emit undefined
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
Then emit it
     complete
     unsubscribe from the source
```
