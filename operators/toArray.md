# `toArray`

Collects every source value into an array and emits that array (empty if no values arrived) as a single value when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with an empty array
```

## State-conditioned rule

```text
Given source active
When a source value arrives
Then append every source value to one array
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the accumulated array once, then complete
```

## Completion rule

```text
Given values are being collected
When the source completes
Then emit the collected array, empty if no values arrived
     complete
```

## Error rule

```text
Given values are being collected
When the source errors
Then discard the collected array
     error immediately
```

## Unsubscription rule

```text
Given values are being collected
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the collected array
```

## Cancellation rule

```text
Given the source subscription is active
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
