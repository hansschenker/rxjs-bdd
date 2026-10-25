# `concatWith`

Forwards the source until it completes, then subscribes to each supplied input in turn, forwarding values in order; an error from any input propagates immediately.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     keep the supplied inputs pending until the source completes
```

## State-conditioned rule

```text
Given current Observable active
When the next relevant operator event occurs
Then keep following Observables pending
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current Observable completes
Then subscribe to the next and continue forwarding
```

## Inner rule

```text
Given an input is active
When the active input emits a value
Then forward the value immediately
     pending inputs are not yet subscribed and cannot emit
```

## Concurrency rule

```text
Given an input is active
When later inputs are pending
Then queue them
     admit the next input only when the active input completes
```

## Completion rules

```text
Given an input is active and further inputs remain
When the active input completes
Then subscribe to the next input

Given the last input is active
When the last input completes
Then complete
```

## Error rule

```text
Given any input is active
When the active input errors
Then error immediately
     never subscribe to the remaining inputs
```

## Unsubscription rule

```text
Given an input is active and later inputs are pending
When the downstream subscriber unsubscribes
Then unsubscribe the active input
     never subscribe to the pending inputs
```

## Cancellation rule

```text
Given an input is active
When any source value or lifecycle event arrives
Then cancel no active work
     each input runs to completion; pending inputs are never cancelled by the operator
```
