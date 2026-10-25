# `distinctUntilChanged`

Forwards a source value only when it differs from the previously forwarded value according to the comparator (default: strict equality), suppressing consecutive duplicates.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no previous value; the first value always passes
```

## State-conditioned rule

```text
Given source active after first value
When the next relevant source event occurs
Then remember the last emitted value/key
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives or comparator says current differs from previous
Then emit and replace remembered value/key
```

## Completion rule

```text
Given a previous value or key is retained
When the source completes
Then complete
```

## Error rule

```text
Given a previous value or key is retained
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given a previous value or key is retained
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
