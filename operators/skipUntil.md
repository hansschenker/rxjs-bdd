# `skipUntil`

Drops source values until the notifier emits, then forwards every later value; the notifier is subscribed first and unsubscribed once it has opened the gate. Notifier completion alone never opens the gate.

*Note:* Notifier completion alone does not open the gate.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the notifier first
     then subscribe to the source
     start with the gate closed
```

## State-conditioned rule

```text
Given gate closed
When a source value arrives
Then ignore source values while waiting for notifier
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits
Then open gate permanently; subsequent source values are forwarded
```

## Notifier rule

```text
Given the gate is closed
When the notifier emits
Then open the gate permanently
     unsubscribe the notifier
```

## Completion rules

```text
Given the gate is open or closed
When the source completes
Then complete, whether or not the notifier has emitted

Given the gate is closed
When the notifier completes without emitting
Then ignore the completion
     keep skipping source values permanently
```

## Error rule

```text
Given any state
When the source or the notifier errors
Then error immediately
```

## Unsubscription rule

```text
Given the notifier may still be active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the notifier
```

## Cancellation rule

```text
Given the gate is closed and the notifier is active
When the notifier emits
Then unsubscribe the notifier after its first emission
     open the gate
```
