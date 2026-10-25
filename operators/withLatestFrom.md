# `withLatestFrom`

Subscribes to the secondary inputs first and, for each source value, emits a tuple of the source value and the latest value of every secondary; source values are dropped until every secondary has emitted. Only the source triggers output.

*Note:* Only the source triggers output.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to every secondary input first, in order
     then subscribe to the source
```

## State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain latest values/readiness from all secondary Observables
```

## Event-triggered rule

```text
Given the operator is active
When source emits and every secondary has emitted at least once
Then emit source value combined with latest secondary values
```

## Inner rule

```text
Given secondary inputs are active
When a secondary input emits a value
Then replace its retained latest value
     emit nothing; only source values trigger output
```

## Concurrency rules

```text
Given not every secondary input has emitted yet
When a source value arrives
Then ignore the source value
     it is dropped, not queued

Given secondary inputs are active
When a secondary input emits again
Then replace its retained latest value
```

## Completion rules

```text
Given latest values from secondary inputs may be retained
When the source completes
Then complete

Given the source subscription is active
When a secondary input completes
Then ignore the completion
     keep its latest value for later combinations
```

## Error rule

```text
Given any state
When the source or any secondary input errors
Then error immediately
```

## Unsubscription rule

```text
Given secondary inputs are active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe every secondary input
     discard retained latest values
```

## Cancellation rule

```text
Given secondary inputs are active
When the source terminates
Then unsubscribe the secondary inputs as part of termination teardown
```
