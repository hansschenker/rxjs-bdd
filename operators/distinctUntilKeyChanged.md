# `distinctUntilKeyChanged`

Specialization of `distinctUntilChanged` that compares consecutive values by the given property key, optionally with a custom comparator for that property.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no previous key; the first value always passes
```

## State-conditioned rule

```text
Given source active after first value
When the next relevant source event occurs
Then remember the selected key of the last emitted object
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives or selected key differs
Then emit the object and replace remembered key
```

## Completion rule

```text
Given a previous key is retained
When the source completes
Then complete
```

## Error rule

```text
Given a previous key is retained
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given a previous key is retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the retained key
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
