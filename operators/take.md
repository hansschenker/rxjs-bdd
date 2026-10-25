# `take`

Forwards the first `count` source values and then completes, unsubscribing from the source; `take(0)` completes immediately without subscribing.

## Subscription rules

```text
Given count is greater than zero
When a downstream subscriber subscribes
Then subscribe to the source immediately

Given count is zero or less
When a downstream subscriber subscribes
Then complete immediately without subscribing to the source
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count forwarded values up to limit
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives within limit
Then emit it; configured count is reached: complete and unsubscribe upstream
```

## Completion rule

```text
Given fewer than count values have been taken
When the source completes
Then complete
```

## Error rule

```text
Given fewer than count values have been taken
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given fewer than count values have been taken
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given count - 1 values have been taken
When the count-th value arrives
Then emit it
     complete
     unsubscribe from the source
```
