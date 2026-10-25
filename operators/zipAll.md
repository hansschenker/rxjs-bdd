# `zipAll`

Collects the inner observables of a higher-order source until it completes, then zips them: values are queued per inner and a tuple is emitted whenever every inner has an unconsumed value.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately and collect inner observables
     defer subscribing to the inners until the outer completes
```

## State-conditioned rule

```text
Given collected inner inputs active
When the relevant input event occurs
Then maintain one FIFO queue per inner
```

## Event-triggered rule

```text
Given the relevant inner state exists
When every inner queue has a value
Then dequeue one from each and emit tuple; terminate when further full tuples become impossible
```

## Inner rule

```text
Given inners are active
When a inner emits a value
Then enqueue the value on that inner's FIFO queue
     when every queue is non-empty, dequeue one value from each and emit the tuple, or its projection
```

## Concurrency rule

```text
Given inners are active
When a inner emits faster than the others
Then queue its values without limit
     no value is dropped or replaced
```

## Completion rules

```text
Given inner observables are being collected
When the outer source completes
Then stop collecting
     subscribe to every collected inner with zip semantics
     complete immediately if no inners were collected

Given the zipped inners are active and the completing inner's queue is empty
When an inner completes
Then complete, because no further tuple is possible

Given the zipped inners are active and the completing inner's queue still holds values
When an inner completes
Then mark that inner as completed
     complete as soon as its queue is empty
```

## Error rule

```text
Given any state
When the outer source or any inner errors
Then discard all queues
     error immediately
```

## Unsubscription rule

```text
Given inners are being collected or zipped
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source if still collecting
     unsubscribe every inner
     discard all queues
```

## Cancellation rule

```text
Given other inners are still active
When an inner completes with an empty queue
Then complete
     unsubscribe the remaining inners
```
