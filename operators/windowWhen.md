# `windowWhen`

Splits the source into consecutive windows whose lifetime is governed by a closing notifier obtained from the closing selector; when it emits or completes, the current window completes and a new window with a new closing notifier is started.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then open the first window, emit it, and subscribe to its closing notifier
     then subscribe to the source
```

## State-conditioned rule

```text
Given current window open
When a source value arrives
Then route source values into it
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When closing notifier fires
Then close current window and immediately create/emit the next window
```

## Notifier rule

```text
Given a window is open
When the closing notifier emits or completes
Then complete the current window
     open a new window and emit it downstream
     subscribe to a new closing notifier from the closing selector
```

## Concurrency rule

```text
Given a window is open
When the closing notifier emits or completes
Then open exactly one replacement window
     windows never overlap
```

## Completion rules

```text
Given a window is open
When the source completes
Then complete the current window
     complete

Given a window is open
When the closing notifier completes without emitting
Then complete the current window
     open and emit the next window with a fresh closing notifier
```

## Error rule

```text
Given a window is open
When the source or the closing notifier errors
Then error the current window
     error immediately
```

## Unsubscription rule

```text
Given a window is open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the closing notifier
     release the current window
```

## Cancellation rule

```text
Given a closing notifier is active
When the closing notifier emits or completes
Then unsubscribe the previous closing notifier
     complete the current window
     open and emit the next window with a fresh closing notifier
```
