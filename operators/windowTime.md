# `windowTime`

Splits the source into windows that close after a fixed time span; an optional creation interval opens overlapping windows and an optional maximum size closes a window early. Open windows complete with the source.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then open the first window, emit it, and schedule its close timer
     schedule periodic window creation when windowCreationInterval is configured
     then subscribe to the source
```

## State-conditioned rule

```text
Given time-based windows open
When the relevant input event occurs
Then route values into all active windows and track age/count
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When time span, creation interval, or max size boundary occurs
Then close/open windows according to configuration
```

## Timer rules

```text
Given a window is open with its close timer running
When the close timer fires after windowTimeSpan
Then complete that window
     open and emit a new window immediately when no windowCreationInterval is configured

Given windowCreationInterval is configured
When the creation interval fires
Then open and emit an additional window with its own close timer
```

## Concurrency rules

```text
Given windowCreationInterval is configured and shorter than windowTimeSpan
When the creation interval fires
Then open an additional window alongside the open ones
     each value is admitted to every open window

Given no windowCreationInterval is configured
When a window closes
Then open exactly one replacement window
     windows never overlap
```

## Completion rule

```text
Given one or more windows are open
When the source completes
Then complete every open window
     cancel pending window timers
     complete
```

## Error rule

```text
Given one or more windows are open
When the source errors
Then error every open window
     cancel pending window timers
     error immediately
```

## Unsubscription rule

```text
Given one or more windows are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     cancel every window creation and close timer
     release the open window subjects
```

## Cancellation rule

```text
Given a window is open with a close timer pending
When the window reaches maxWindowSize
Then cancel that window's close timer
     complete the window early
```
