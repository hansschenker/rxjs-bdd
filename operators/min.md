# `min`

Reduces the source to its smallest value, using the optional comparer, and emits that single value when the source completes; an empty source completes without emitting.

*Note:* Implemented via reduction.

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
Then retain the least value seen according to comparer
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained minimum (or follow empty-reduction behavior)
```

## Completion rules

```text
Given at least one value has been compared
When the source completes
Then emit the retained minimum
     complete

Given no value has arrived
When the source completes
Then complete without emitting
```

## Error rule

```text
Given any state
When the source errors
Then discard the retained minimum
     error immediately
```

## Unsubscription rule

```text
Given a minimum may be retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the retained minimum
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
