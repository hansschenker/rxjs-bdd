# `pairwise`

Emits each source value together with its predecessor as a two-element array, starting from the second source value.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no previous value
```

## State-conditioned rule

```text
Given source active after first value
When a source value arrives
Then remember previous source value
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When next value arrives and previous exists
Then emit `[previous, current]`, then remember current
```

## Completion rule

```text
Given a previous value is retained
When the source completes
Then discard the retained value
     complete
```

## Error rule

```text
Given a previous value is retained
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given a previous value is retained
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
