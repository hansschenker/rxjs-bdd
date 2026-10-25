# `takeUntil`

Forwards source values until the notifier emits, then completes and unsubscribes from the source; the notifier is subscribed first, and its completion alone does not stop the source.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the notifier first
     subscribe to the source only if the notifier did not complete the output synchronously
```

## State-conditioned rule

```text
Given source active
When the relevant notifier event occurs
Then forward values while notifier has not emitted
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits
Then complete output immediately and unsubscribe source
```

## Notifier rule

```text
Given the notifier has not emitted
When the notifier emits
Then complete
     unsubscribe from the source
```

## Completion rules

```text
Given the notifier has not emitted
When the source completes
Then complete
     unsubscribe the notifier

Given the notifier has not emitted
When the notifier completes without emitting
Then ignore the completion
     keep mirroring the source
```

## Error rule

```text
Given the notifier has not emitted
When the source or the notifier errors
Then error immediately
```

## Unsubscription rule

```text
Given the notifier has not emitted
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the notifier
```

## Cancellation rule

```text
Given the notifier has not emitted
When the notifier emits
Then complete
     unsubscribe from the source and the notifier
```
