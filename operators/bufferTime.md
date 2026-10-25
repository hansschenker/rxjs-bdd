# `bufferTime`

Collects source values into a buffer that is emitted when its time span elapses; an optional creation interval opens overlapping buffers, and an optional maximum size closes a buffer early. Open buffers are emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then open the first buffer and schedule its close timer
     schedule periodic buffer creation when bufferCreationInterval is configured
     then subscribe to the source
```

## State-conditioned rule

```text
Given time-span buffer(s) open
When a source value arrives
Then append source values to every active buffer
```

## Event-triggered rule

```text
Given the operator is active
When a buffer times out or reaches `maxBufferSize`
Then emit it and open replacements according to configuration
```

## Timer rules

```text
Given a buffer is open with its close timer running
When the close timer fires after bufferTimeSpan
Then emit that buffer
     open a new buffer immediately when no bufferCreationInterval is configured

Given bufferCreationInterval is configured
When the creation interval fires
Then open an additional buffer with its own close timer
```

## Concurrency rules

```text
Given bufferCreationInterval is configured and shorter than bufferTimeSpan
When the creation interval fires
Then open an additional buffer alongside the open ones
     each value is admitted to every open buffer

Given no bufferCreationInterval is configured
When a buffer closes
Then open exactly one replacement buffer
     buffers never overlap
```

## Completion rule

```text
Given one or more time-span buffers are open
When the source completes
Then emit every open buffer in opening order, including an empty one
     cancel pending buffer timers
     complete
```

## Error rule

```text
Given any state
When the source errors
Then discard all open buffers
     cancel pending buffer timers
     error immediately
```

## Unsubscription rule

```text
Given one or more buffers are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel every buffer creation and close timer
     discard all open buffers
```

## Cancellation rule

```text
Given a buffer is open with a close timer pending
When the buffer reaches maxBufferSize
Then cancel that buffer's close timer
     emit the buffer early
```
