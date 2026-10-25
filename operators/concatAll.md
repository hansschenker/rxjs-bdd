# `concatAll`

Flattens a higher-order source by subscribing to one inner observable at a time; inners that arrive while another is active are queued and subscribed in order after it completes.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the outer source immediately
     start with no active inner and an empty queue
```

## State-conditioned rule

```text
Given one inner active
When an inner event arrives
Then queue later inner Observables
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then subscribe to the next queued inner; forward inner values in order
```

## Inner rule

```text
Given the active inner is running
When the active inner emits a value
Then forward the value immediately
     values from queued inners are never interleaved with it
```

## Concurrency rules

```text
Given no inner is active
When an inner observable arrives
Then admit it immediately

Given an inner is active
When an inner observable arrives
Then queue the inner behind the active inner
     admit queued items one at a time in arrival order
```

## Completion rules

```text
Given no inner is active and no inners are queued
When the outer source completes
Then complete immediately

Given a inner is active or inners are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued inners in order, one inner at a time
     complete after the last inner completes
```

## Error rule

```text
Given any state
When the outer source or the active inner errors
Then discard queued inners
     unsubscribe the active inner
     error immediately
```

## Unsubscription rule

```text
Given a inner is active or inners are queued
When the downstream subscriber unsubscribes
Then unsubscribe from the outer source
     unsubscribe the active inner
     discard queued inners
```

## Cancellation rule

```text
Given an inner is active
When any source value or lifecycle event arrives
Then cancel no active work
     the active inner always runs to completion; queued inners are never cancelled by the operator
```
