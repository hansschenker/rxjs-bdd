# `bufferToggle`

Opens a new buffer each time the openings observable emits and closes it, emitting its values, when the closing notifier derived from that opening value emits; buffers may overlap. Open buffers are emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the openings observable first
     then subscribe to the source
     start with no open buffer
```

## State-conditioned rule

```text
Given one or more buffers open
When a source value arrives
Then route the source value into every active buffer
```

## Event-triggered rule

```text
Given the operator is active
When an opening arrives
Then open a buffer; its closing notifier fires: emit and close that buffer
```

## Notifier rules

```text
Given the openings observable is active
When the openings observable emits
Then open a new buffer
     subscribe to the closing notifier produced by the closing selector for that opening value

Given a buffer is open with its closing notifier active
When that closing notifier emits
Then emit the buffer
     close it and unsubscribe its closing notifier
```

## Concurrency rule

```text
Given buffers are open
When the openings observable emits
Then open an additional buffer
     any number of buffers may overlap; each value is admitted to every open buffer
```

## Completion rules

```text
Given zero or more toggled buffers are open
When the source completes
Then emit every open buffer in opening order
     complete

Given the operator is active
When the openings observable completes
Then ignore the completion
     already open buffers stay open until their closing notifier emits or the source completes

Given a buffer is open
When its closing notifier completes without emitting
Then ignore the completion
     keep that buffer open until the source completes
```

## Error rule

```text
Given any state
When the source, the openings observable, or a closing notifier errors
Then discard all open buffers
     error immediately
```

## Unsubscription rule

```text
Given zero or more buffers are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the openings observable
     unsubscribe every active closing notifier
     discard all open buffers
```

## Cancellation rule

```text
Given a buffer is open with its closing notifier active
When the closing notifier emits
Then unsubscribe that closing notifier
     emit and close the buffer
```
