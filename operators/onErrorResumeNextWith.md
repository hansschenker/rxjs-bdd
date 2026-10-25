# `onErrorResumeNextWith`

Forwards the source and, whenever the active source errors or completes, moves on to the next supplied input; errors are swallowed, and the output completes only after the last input terminates.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     keep the fallback sources pending
```

## State-conditioned rule

```text
Given current Observable active
When the next relevant operator event occurs
Then keep fallback Observables pending
```

## Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current source errors or completes
Then suppress the distinction and subscribe to the next fallback; complete after all finish
```

## Inner rule

```text
Given a fallback source is active
When a fallback source emits a value
Then forward the value unchanged
```

## Concurrency rule

```text
Given a source is active
When the active source terminates
Then admit the next source
     sources never overlap
```

## Completion rules

```text
Given further fallback sources remain
When the active source completes
Then subscribe to the next source

Given no further sources remain
When the active source completes
Then complete
```

## Error rules

```text
Given further fallback sources remain
When the active source errors
Then swallow the error
     subscribe to the next source

Given no further sources remain
When the active source errors
Then swallow the error
     complete
```

## Unsubscription rule

```text
Given a source in the sequence is active
When the downstream subscriber unsubscribes
Then unsubscribe the active source
     never subscribe to the remaining sources
```

## Cancellation rule

```text
Given a source in the sequence is active
When any source value or lifecycle event arrives
Then cancel no active work
     each source runs until it terminates on its own
```
