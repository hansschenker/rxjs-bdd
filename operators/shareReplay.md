# `shareReplay`

`share` configured with a `ReplaySubject` connector that replays the last `bufferSize` values to late subscribers; by default (`refCount: false`) the source connection is kept alive after the last subscriber leaves, and the buffer survives source completion.

## Subscription rules

```text
Given no connection exists
When a downstream subscriber subscribes
Then create the ReplaySubject
     subscribe the subscriber to it
     then connect the source

Given a connection exists, or the source completed without a reset
When a downstream subscriber subscribes
Then attach the subscriber to the ReplaySubject
     replay buffered values immediately, then deliver live values
```

## State-conditioned rule

```text
Given shared replay state active
When the relevant input event occurs
Then retain ReplaySubject buffer and shared connection state
```

## Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then replay buffered values then receive live values; connection/reset follows `refCount` and terminal policy
```

## Completion rule

```text
Given the source is connected
When the source completes
Then complete every current subscriber
     keep the ReplaySubject because resetOnComplete is false; late subscribers replay the buffer and then complete
```

## Error rule

```text
Given the source is connected
When the source errors
Then error every current subscriber
     reset the connection because resetOnError is true; the next subscriber resubscribes to the source
```

## Unsubscription rules

```text
Given the refCount option is false (default)
When the last subscriber unsubscribes
Then keep the source connection alive
     keep the replay buffer

Given the refCount option is true
When the last subscriber unsubscribes
Then unsubscribe the source connection
     reset the ReplaySubject
```

## Cancellation rule

```text
Given the source is connected
When any source value or lifecycle event arrives
Then cancel no active work
     with the default refCount false nothing is ever cancelled; the source runs to termination
```
