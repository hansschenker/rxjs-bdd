# `elementAt`

Emits only the source value at the given zero-based index and then completes; if the source completes earlier, emits the default value or errors with `ArgumentOutOfRangeError`.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start counting positions at zero
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count source positions
```

## Event-triggered rule

```text
Given the operator is active
When configured index arrives
Then emit that value and complete; source completes too early: emit default or error
```

## Completion rules

```text
Given fewer than index + 1 values have arrived and no default value is configured
When the source completes
Then error with ArgumentOutOfRangeError

Given fewer than index + 1 values have arrived and a default value is configured
When the source completes
Then emit the default value
     complete
```

## Error rule

```text
Given the configured index has not been reached
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given the configured index has not been reached
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard the position count
```

## Cancellation rule

```text
Given the configured index has not been reached
When the value at the configured index arrives
Then emit it
     complete
     unsubscribe from the source
```
