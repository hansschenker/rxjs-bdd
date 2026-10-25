# `retry`

Resubscribes to the source when it errors, up to the given count and optionally after a delay; once the budget is exhausted the error is forwarded, and `resetOnSuccess` restarts the budget after a value. Completion is never retried.

*Note:* Does not retry on normal completion.

## Subscription rules

```text
Given count is greater than zero
When a downstream subscriber subscribes
Then subscribe to the source for the first attempt

Given count is zero or less
When a downstream subscriber subscribes
Then subscribe to the source as a plain pass-through; errors are never retried
```

## State-conditioned rule

```text
Given source execution active
When the next relevant source event occurs
Then track retry count/delay/reset configuration
```

## Event-triggered rule

```text
Given the operator is active
When source errors and retry policy permits
Then resubscribe; otherwise forward final error
```

## Timer rule

```text
Given the source errored and delay is a number
When the delay timer fires
Then unsubscribe the timer
     resubscribe to the source
```

## Notifier rules

```text
Given the source errored and delay is a function
When the notifier returned by delay emits
Then unsubscribe the notifier
     resubscribe to the source

Given the source errored and delay is a function
When the notifier completes without emitting
Then complete without re-raising the error
```

## Concurrency rule

```text
Given an attempt is active
When the attempt errors
Then start the next attempt only after the current one has errors
     attempts never overlap
```

## Completion rule

```text
Given any attempt is active
When the source completes
Then complete
```

## Error rules

```text
Given the retry count is not exhausted
When the source errors
Then unsubscribe the failed source execution
     resubscribe to the source, after the configured delay if any
     reset the attempt counter on the next value if resetOnSuccess is set

Given the retry count is exhausted
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given an attempt is active or a retry delay is pending
When the downstream subscriber unsubscribes
Then unsubscribe the active source execution
     unsubscribe a pending delay notifier
```

## Cancellation rules

```text
Given an attempt is active
When the source errors with retries remaining
Then unsubscribe the failed execution before resubscribing

Given a retry delay notifier is pending
When the delay notifier emits
Then unsubscribe the delay notifier after its first emission
     resubscribe to the source
```
