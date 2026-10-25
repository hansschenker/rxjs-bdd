# `window`

Splits the source into consecutive non-overlapping windows, each a `Subject`-backed observable that receives source values until the boundary notifier emits, at which point the window completes and a new one is emitted.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then create the first window and emit it downstream
     subscribe to the source
     then subscribe to the boundary notifier
```

## State-conditioned rule

```text
Given current window open
When a source value arrives
Then forward the source value into current window Subject
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When boundary Observable emits
Then close current window, emit/open a new window
```

## Notifier rule

```text
Given a window is open
When the boundary notifier emits
Then complete the current window
     open a new window and emit it downstream
```

## Concurrency rule

```text
Given a window is open
When the boundary notifier emits
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
When the boundary notifier completes
Then ignore the completion
     keep the current window open until the source completes
```

## Error rule

```text
Given a window is open
When the source or the boundary notifier errors
Then error the current window
     error immediately
```

## Unsubscription rule

```text
Given a window is open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe the boundary notifier
     unsubscribe the current window subject
```

## Cancellation rule

```text
Given the boundary notifier is active
When the source terminates
Then unsubscribe the boundary notifier as part of termination teardown
```
