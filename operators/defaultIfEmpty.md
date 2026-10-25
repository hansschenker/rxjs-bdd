# `defaultIfEmpty`

Forwards source values unchanged; if the source completes without having emitted any value, emits the default value before completing.

*Note:* If values were seen, they were forwarded normally.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no value seen
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then remember whether any value has been seen
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes with no value seen
Then emit the default value, then complete
```

## Completion rules

```text
Given no value has been emitted
When the source completes
Then emit the default value
     complete

Given at least one value has been emitted
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source errors
Then error immediately
     the default value is not emitted
```

## Unsubscription rule

```text
Given the source subscription is active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
