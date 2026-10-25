# `catchError`

Forwards source values unchanged until the source errors, then subscribes to the observable returned by the selector and forwards its notifications in place of the error. The selector may rethrow, or return the source itself to retry.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     track the source subscription so a synchronous error can be replaced
```

## State-conditioned rule

```text
Given source active normally
When the next relevant source event occurs
Then forward values without recovery state
```

## Event-triggered rule

```text
Given the operator is active
When source errors
Then invoke selector and subscribe to the replacement Observable instead of forwarding the error
```

## Inner rule

```text
Given the replacement observable is active
When the replacement observable emits a value
Then forward the value unchanged
```

## Completion rules

```text
Given the source is active and no error has been caught
When the source completes
Then complete

Given a replacement observable is active
When the replacement observable completes
Then complete
```

## Error rules

```text
Given the source is active
When the source errors
Then unsubscribe from the source
     invoke the selector with the error and the caught observable
     subscribe to the returned observable and mirror its notifications
     error with the thrown error if the selector throws

Given a replacement observable is active
When the replacement observable errors
Then error immediately
     the selector is not invoked again
```

## Unsubscription rule

```text
Given the source or a replacement observable is active
When the downstream subscriber unsubscribes
Then unsubscribe from whichever observable is currently active
```

## Cancellation rule

```text
Given the source is active
When the source errors
Then unsubscribe from the errored source before subscribing to the replacement
```
