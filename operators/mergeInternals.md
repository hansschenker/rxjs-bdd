# `mergeInternals`

Internal engine behind `mergeMap`, `mergeAll`, `mergeScan`, and `expand`: projects values, subscribes to inners up to the concurrency limit, queues the rest, and completes only when the outer source and every inner have completed.

*Note:* Internal engine behind several flattening operators.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with zero active inners and an empty buffer
```

## State-conditioned rule

```text
Given inners active
When the relevant input event occurs
Then track active count, queue, completion state, and optional expansion
```

## Event-triggered rule

```text
Given the relevant inner state exists
When outer/inner events occur
Then apply merge concurrency admission, forwarding, drain, and completion policy
```

## Inner rule

```text
Given inners are active
When an inner emits a value
Then forward the value immediately
     in expand mode, also feed the value back through the projection
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When a value arrives
Then admit it: project and subscribe immediately
     increment the active count

Given concurrent inners are already active
When a value arrives
Then queue the value
     admit the oldest queued item when an active inner completes
```

## Completion rules

```text
Given no inner is active and the buffer is empty
When the outer source completes
Then complete immediately

Given inners are active or values are buffered
When the outer source completes
Then set the completed flag
     complete only once the active count reaches zero and the buffer is empty
```

## Error rule

```text
Given any state
When the outer source or any inner errors
Then error through the operator subscriber
     release the buffer during teardown
```

## Unsubscription rule

```text
Given inners are active or values are buffered
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe every active inner
     release the buffer
```

## Cancellation rule

```text
Given inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     the helper never cancels inners; concurrency is enforced by queueing
```
