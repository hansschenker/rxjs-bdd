# `windowCount`

Splits the source into windows of `windowSize` values; with a `startWindowEvery` offset a new window opens every that many values, so windows may overlap. Open windows complete with the source.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then create the first window and emit it downstream
     subscribe to the source
```

## State-conditioned rule

```text
Given one or more count-based windows open
When a source value arrives
Then route source values into active windows and track counts
```

## Event-triggered rule

```text
Given the corresponding pending state exists
When start/size boundary is reached
Then open or close windows according to `windowSize` and `startWindowEvery`
```

## Concurrency rules

```text
Given startWindowEvery is less than windowSize
When a source value arrives at a start boundary
Then open an additional window alongside the open ones
     each value is admitted to every open window, so windows overlap

Given startWindowEvery is omitted or at least windowSize
When a window reaches windowSize
Then complete it
     the next window opens at the next start boundary, so windows never overlap
```

## Completion rule

```text
Given one or more windows are open
When the source completes
Then complete every open window
     complete
```

## Error rule

```text
Given one or more windows are open
When the source errors
Then error every open window
     error immediately
```

## Unsubscription rule

```text
Given one or more windows are open
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     release the open window subjects without completing them
```

## Cancellation rule

```text
Given one or more windows are open
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
