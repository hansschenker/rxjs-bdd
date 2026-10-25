# `groupBy`

Routes each source value into a `GroupedObservable` chosen by its key, emitting a new group downstream the first time a key is seen; an optional duration selector closes a group, and every group completes or errors with the source.

*Note:* Duration/connector options can close or customize groups.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with an empty group map
```

## State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then maintain a map from keys to live grouped Subjects
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives
Then create group if needed and emit value into its group; emit each new group once to downstream
```

## Notifier rule

```text
Given a group has a duration observable
When the duration observable emits
Then complete that group
     remove it from the group map so the key can start a new group
     unsubscribe the duration
```

## Concurrency rules

```text
Given groups are active
When a value with a new key arrives
Then create a new group
     the number of concurrent groups is unbounded

Given groups are active
When a value with an existing key arrives
Then route it into the existing group
```

## Completion rule

```text
Given groups are active
When the source completes
Then complete every active group
     complete
```

## Error rule

```text
Given groups are active
When the source or a group duration observable errors
Then error every active group
     error immediately
```

## Unsubscription rules

```text
Given group subscriptions are still active
When the outer subscriber unsubscribes
Then keep the source subscription alive while any group subscriber remains
     stop emitting new groups downstream

Given the outer subscriber has already unsubscribed
When the last group subscriber unsubscribes
Then unsubscribe from the source
     clear the group map
```

## Cancellation rule

```text
Given a group has a duration observable
When the duration observable emits
Then complete that group
     remove it from the group map
     unsubscribe the duration observable
```
