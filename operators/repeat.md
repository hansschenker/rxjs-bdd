# `repeat`

Resubscribes to the source each time it completes, up to the given count and optionally after a delay given as a duration or as a notifier factory; errors are forwarded immediately and are never repeated.

*Note:* Does not repeat on error.

## Subscription rules

```text
Given count is greater than zero
When a downstream subscriber subscribes
Then subscribe to the source for the first execution

Given count is zero or less
When a downstream subscriber subscribes
Then complete immediately without subscribing to the source
```

## State-conditioned rule

```text
Given source execution active
When the next relevant source event occurs
Then track repeat count/delay state
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes and repeats remain
Then resubscribe; otherwise forward completion
```

## Timer rule

```text
Given the source completed and delay is a number
When the delay timer fires
Then unsubscribe the timer
     resubscribe to the source
```

## Notifier rules

```text
Given the source completed and delay is a function
When the notifier returned by delay emits
Then unsubscribe the notifier
     resubscribe to the source

Given the source completed and delay is a function
When the notifier completes without emitting
Then complete
```

## Concurrency rule

```text
Given an execution is active
When the execution completes
Then start the next execution only after the current one has completes
     executions never overlap
```

## Completion rules

```text
Given the repeat count is not exhausted
When the source completes
Then unsubscribe the completed source execution
     resubscribe to the source, after the configured delay if any

Given the repeat count is exhausted
When the source completes
Then complete
```

## Error rule

```text
Given any repetition is active
When the source errors
Then error immediately
     no further repetitions are started
```

## Unsubscription rule

```text
Given a repetition is active or a repeat delay is pending
When the downstream subscriber unsubscribes
Then unsubscribe the active source execution
     unsubscribe a pending delay notifier
```

## Cancellation rules

```text
Given a repetition is active
When the source completes with repetitions remaining
Then unsubscribe the completed execution before resubscribing

Given a repeat delay notifier is pending
When the delay notifier emits
Then unsubscribe the delay notifier after its first emission
     resubscribe to the source
```
