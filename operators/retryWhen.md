# `retryWhen`

Resubscribes to the source whenever the notifier observable, built from a subject that receives each error, emits; completes when the notifier completes and errors when the notifier errors.

*Note:* Deprecated-style notifier API.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     create the notifier only on the first error
```

## State-conditioned rule

```text
Given source execution active
When the relevant notifier event occurs
Then route error signals to notifier workflow
```

## Event-triggered rule

```text
Given the operator is active
When notifier emits after an error
Then resubscribe; notifier completes/errors: terminate accordingly
```

## Notifier rule

```text
Given the source has errored
When the notifier emits
Then resubscribe to the source
```

## Concurrency rule

```text
Given an attempt is active
When the attempt errors
Then start the next attempt only after the current one has errors
     attempts never overlap
```

## Completion rules

```text
Given any attempt is active
When the source completes
Then complete

Given the source has errored and is waiting on the notifier
When the notifier completes
Then complete
```

## Error rules

```text
Given the notifier is active
When the source errors
Then push the error to the errors subject
     resubscribe to the source when the notifier emits

Given any state
When the notifier errors
Then error immediately
```

## Unsubscription rule

```text
Given an attempt is active or the notifier is waiting
When the downstream subscriber unsubscribes
Then unsubscribe the active source execution
     unsubscribe the notifier
```

## Cancellation rule

```text
Given an attempt is active
When any source value or lifecycle event arrives
Then cancel no active work
     a failed execution is torn down by its own error; the notifier is never cancelled by the operator
```
