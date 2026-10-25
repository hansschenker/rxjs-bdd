# `zip`

Deprecated pipeable form of `zipWith`: queues values from the source and the supplied inputs and emits a tuple each time every input has an unconsumed value.

*Note:* Deprecated pipeable form.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source and then to each supplied input, in order
     start with an empty queue per input
```

## State-conditioned rule

```text
Given inputs active
When the relevant input event occurs
Then maintain one FIFO queue per input
```

## Event-triggered rule

```text
Given the operator is active
When every queue has at least one value
Then dequeue one from each and emit the tuple/projected result
```

## Inner rule

```text
Given inputs are active
When a input emits a value
Then enqueue the value on that input's FIFO queue
     when every queue is non-empty, dequeue one value from each and emit the tuple, or its projection
```

## Concurrency rule

```text
Given inputs are active
When a input emits faster than the others
Then queue its values without limit
     no value is dropped or replaced
```

## Completion rules

```text
Given the completing input's queue is empty
When an input completes
Then complete, because no further tuple is possible

Given the completing input's queue still holds values
When an input completes
Then mark that input as completed
     keep emitting tuples while its queue drains
     complete as soon as its queue is empty
```

## Error rule

```text
Given any state
When any input errors
Then discard all queues
     error immediately
```

## Unsubscription rule

```text
Given inputs are active
When the downstream subscriber unsubscribes
Then unsubscribe every input
     discard all queues
```

## Cancellation rule

```text
Given other inputs are still active
When an input completes with an empty queue
Then complete
     unsubscribe the remaining inputs
```
