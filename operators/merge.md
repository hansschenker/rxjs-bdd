# `merge`

Deprecated pipeable form of `mergeWith`: subscribes to the source and the supplied inputs concurrently and forwards values from all of them as they arrive.

*Note:* Deprecated pipeable form.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source and then to the supplied inputs in order, up to the concurrency limit
     queue the remaining inputs
```

## State-conditioned rule

```text
Given multiple inputs active
When a subscription lifecycle event occurs
Then allow concurrent subscriptions up to configured concurrency
```

## Event-triggered rule

```text
Given the operator is active
When any active input emits
Then forward immediately; an input completes: admit pending input if capacity exists
```

## Inner rule

```text
Given inputs are active
When any input emits a value
Then forward the value immediately
```

## Concurrency rules

```text
Given fewer than concurrent inputs are active
When an input is pending
Then admit it: subscribe immediately

Given concurrent inputs are active
When an input is pending
Then queue it
     admit it when an active input completes
```

## Completion rules

```text
Given other inputs are still active
When an input completes
Then keep mirroring the remaining inputs
     admit a pending input if concurrency capacity opens

Given every other input has completed
When the last active input completes
Then complete
```

## Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
```

## Unsubscription rule

```text
Given inputs are active
When the downstream subscriber unsubscribes
Then unsubscribe every active input
     never subscribe to inputs still waiting for concurrency capacity
```

## Cancellation rule

```text
Given inputs are active
When any source value or lifecycle event arrives
Then cancel no active work
     every input runs until it terminates on its own
```
