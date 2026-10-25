# `mergeWith`

Subscribes to the source and the supplied inputs concurrently and forwards values from all of them as they arrive; completes when every input has completed and errors as soon as any input errors.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source and then to each supplied input, in order
     all inputs run concurrently
```

## State-conditioned rule

```text
Given source and supplied Observables are active
When a subscription lifecycle event occurs
Then retain their concurrent subscriptions
```

## Event-triggered rule

```text
Given the operator is active
When any input emits
Then forward immediately; complete after all inputs complete
```

## Inner rule

```text
Given inputs are active
When any input emits a value
Then forward the value immediately
```

## Concurrency rule

```text
Given inputs are pending
When the output is subscribed
Then admit every input at once
     concurrency is unlimited
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
