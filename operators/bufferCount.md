# `bufferCount`

Collects source values into arrays of `bufferSize` values, emitting each buffer when it is full; with a `startBufferEvery` offset a new buffer opens every that many values, so buffers may overlap. Partial buffers are emitted when the source completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no open buffer; the first buffer opens on the first source value
```

## State-conditioned rule

```text
Given buffer(s) open
When a source value arrives
Then append source values and track size/start positions
```

## Event-triggered rule

```text
Given the operator is active
When a buffer reaches its configured size
Then emit that buffer; open later buffers according to `startBufferEvery`
```

## Concurrency rules

```text
Given startBufferEvery is less than bufferSize
When a source value arrives at a start boundary
Then open an additional buffer alongside the open ones
     each value is admitted to every open buffer, so buffers overlap

Given startBufferEvery is omitted or at least bufferSize
When a buffer reaches bufferSize
Then emit it
     the next buffer opens at the next start boundary, so buffers never overlap
```

## Completion rules

```text
Given one or more partial buffers are open
When the source completes
Then emit every open partial buffer in opening order
     complete

Given no buffer is open
When the source completes
Then complete
```

## Error rule

```text
Given any state
When the source errors
Then discard all open buffers
     error immediately
```

## Unsubscription rule

```text
Given one or more buffers are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     discard all open buffers
```

## Cancellation rule

```text
Given one or more buffers are open
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
