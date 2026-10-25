# `distinct`

Forwards a source value only if its key (the value itself, or the result of the key selector) has not been seen before; an optional flushes observable clears the set of remembered keys.

*Note:* Optional flush Observable clears remembered keys.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then create an empty set of seen keys
     subscribe to the source
     then subscribe to the flushes observable when one is configured
```

## State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep a set of previously seen keys
```

## Event-triggered rule

```text
Given the operator is active
When a value's key has not been seen
Then remember the key and emit the value; otherwise emit nothing
```

## Notifier rule

```text
Given seen keys are retained
When the flushes observable emits
Then clear the set of seen keys
     later values with previously seen keys pass again
```

## Completion rules

```text
Given seen keys are retained
When the source completes
Then clear the set of seen keys
     complete

Given seen keys are retained
When the flushes observable completes
Then ignore the completion
     keep the current set of seen keys
```

## Error rule

```text
Given any state
When the source or the flushes observable errors
Then clear the set of seen keys
     error immediately
```

## Unsubscription rule

```text
Given seen keys are retained
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the flushes observable
     clear the set of seen keys
```

## Cancellation rule

```text
Given the flushes observable is active
When the source terminates
Then unsubscribe the flushes observable as part of termination teardown
```
