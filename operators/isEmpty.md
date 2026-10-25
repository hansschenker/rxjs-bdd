# `isEmpty`

Emits `false` and completes as soon as the source emits a value; emits `true` if the source completes without emitting.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start in the possibly-empty state
```

## State-conditioned rule

```text
Given source active before first value
When the next relevant operator event occurs
Then remain 'possibly empty'
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives
Then emit false and complete; source completes first: emit true
```

## Completion rule

```text
Given no value has arrived
When the source completes
Then emit true
     complete
```

## Error rule

```text
Given no value has arrived
When the source errors
Then error immediately
```

## Unsubscription rule

```text
Given no value has arrived
When the downstream subscriber unsubscribes
Then unsubscribe from the source
```

## Cancellation rule

```text
Given no value has arrived
When the first value arrives
Then emit false
     complete
     unsubscribe from the source
```
