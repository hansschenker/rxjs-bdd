# `buffer`

Collects source values into an open buffer and, each time the closing notifier emits, emits the buffer as an array and opens a fresh empty one. The current buffer, even if empty, is emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then open an empty buffer
     subscribe to the source
     then subscribe to the closing notifier
```

## State-conditioned rule

```text
Given buffer open
When a source value arrives
Then append the source value to the current array
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When closing notifier emits
Then emit the current array and start a fresh buffer
```

## Notifier rule

```text
Given a buffer is open
When the closing notifier emits
Then emit the current buffer
     open a fresh empty buffer
```

## Concurrency rule

```text
Given a buffer is open
When the closing notifier emits
Then open exactly one replacement buffer
     buffers never overlap
```

## Completion rules

```text
Given a buffer is open
When the source completes
Then emit the current buffer, even if it is empty
     complete

Given a buffer is open
When the closing notifier completes
Then ignore the completion
     keep buffering until the source completes
```

## Error rule

```text
Given any state
When the source or the closing notifier errors
Then discard the current buffer
     error immediately
```

## Unsubscription rule

```text
Given a buffer is open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the closing notifier
     discard the current buffer
```

## Cancellation rule

```text
Given the closing notifier is active
When the source terminates
Then unsubscribe the closing notifier as part of termination teardown
```
