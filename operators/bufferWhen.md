# `bufferWhen`

Collects source values into a buffer whose lifetime is governed by a closing observable obtained from the closing selector; when it emits, the buffer is emitted and a fresh buffer with a new closing observable is started.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then open an empty buffer and subscribe to its closing observable
     then subscribe to the source
```

## State-conditioned rule

```text
Given current buffer open
When a source value arrives
Then append the source value
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When closing selector's notifier emits
Then emit current buffer and immediately open the next buffer
```

## Notifier rule

```text
Given a buffer is open
When the closing observable emits
Then emit the current buffer
     open a fresh buffer
     subscribe to a new closing observable from the closing selector
```

## Concurrency rule

```text
Given a buffer is open
When the closing observable emits
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
When the closing observable completes without emitting
Then ignore the completion
     keep the buffer open until the source completes
```

## Error rule

```text
Given any state
When the source or the closing observable errors
Then discard the current buffer
     error immediately
```

## Unsubscription rule

```text
Given a buffer is open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the current closing observable
     discard the current buffer
```

## Cancellation rule

```text
Given a closing observable is active
When the closing observable emits
Then unsubscribe the previous closing observable
     subscribe to a fresh closing observable for the next buffer
```
