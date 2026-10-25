# `repeatWhen`

Resubscribes to the source whenever the notifier observable, built from a subject that receives each completion, emits; completes when the notifier completes and errors when the source or notifier errors.

*Note:* Deprecated-style notifier API.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     create the notifier only on the first completion
```

## State-conditioned rule

```text
Given source execution active
When the relevant notifier event occurs
Then route completion signals to notifier workflow
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits after a source completion
Then resubscribe to source; notifier completes/errors: terminate accordingly
```

## Notifier rule

```text
Given the source has completed
When the notifier emits
Then resubscribe to the source
```

## Concurrency rule

```text
Given an execution is active
When the execution completes
Then start the next execution only after the current one has completes
     executions never overlap
```

## Completion rules

```text
Given the notifier has not completed
When the source completes
Then push a completion signal to the notifications subject
     resubscribe to the source when the notifier emits

Given the source has completed and is waiting on the notifier
When the notifier completes
Then complete

Given the notifier has completed
When the source completes
Then complete
```

## Error rules

```text
Given any state
When the source errors
Then error immediately

Given any state
When the notifier errors
Then error immediately
```

## Unsubscription rule

```text
Given a repetition is active or the notifier is waiting
When the downstream subscriber unsubscribes
Then unsubscribe the active source execution
     unsubscribe the notifier
```

## Cancellation rule

```text
Given a repetition is active
When any source value or lifecycle event arrives
Then cancel no active work
     a completed execution is torn down by its own completion; the notifier is never cancelled by the operator
```
