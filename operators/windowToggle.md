# `windowToggle`

Opens a new window each time the openings observable emits and completes it when the closing notifier derived from that opening value emits or completes; windows may overlap, and open windows complete with the source.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the openings observable first
     then subscribe to the source
     start with no open window
```

## State-conditioned rule

```text
Given one or more windows open
When a source value arrives
Then route the source value into all active windows
```

## Event-triggered rule

```text
Given the operator is active
When opening emits
Then create/emit a new window; its closing notifier fires: close that window
```

## Notifier rules

```text
Given the openings observable is active
When the openings observable emits
Then open a new window and emit it downstream
     subscribe to the closing notifier produced by the closing selector for that opening value

Given a window is open with its closing notifier active
When that closing notifier emits or completes
Then complete that window
     unsubscribe its closing notifier
```

## Concurrency rule

```text
Given windows are open
When the openings observable emits
Then open an additional window
     any number of windows may overlap; each value is admitted to every open window
```

## Completion rules

```text
Given zero or more windows are open
When the source completes
Then complete every open window
     complete

Given the operator is active
When the openings observable completes
Then ignore the completion
     open windows stay open until their closing notifier emits or completes, or the source completes

Given a window is open
When its closing notifier completes without emitting
Then complete and remove that window
     the source and other windows are unaffected
```

## Error rule

```text
Given any state
When the source, the openings observable, or a closing notifier errors
Then error every open window
     error immediately
```

## Unsubscription rule

```text
Given zero or more windows are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the openings observable
     unsubscribe every active closing notifier
     unsubscribe every open window subject
```

## Cancellation rule

```text
Given a window is open with its closing notifier active
When the closing notifier emits or completes
Then unsubscribe that closing notifier
     complete and remove the window
```
