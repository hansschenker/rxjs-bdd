# `connect`

Multicasts the source through a connector Subject, applies the selector to the shared observable, and subscribes the downstream subscriber to the selector output before connecting the source, so one source subscription feeds every branch inside the selector.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then create the shared subject with the connector
     subscribe the downstream subscriber to the selector output
     then connect the source to the subject
```

## State-conditioned rule

```text
Given shared connector active inside the selector scope
When the next relevant operator event occurs
Then multicast one source execution
```

## Event-triggered rule

```text
Given the operator is active
When selector output is subscribed
Then connect the shared source and route it through the selector result
```

## Completion rule

```text
Given the source is connected to the shared subject
When the source completes
Then complete the subject
     the output completes as the selector pipeline propagates the subject's completion
```

## Error rule

```text
Given the source is connected to the shared subject
When the source errors
Then error the subject
     the output errors as the selector pipeline propagates the subject's error
```

## Unsubscription rule

```text
Given the selector output is subscribed
When the downstream subscriber unsubscribes
Then unsubscribe from the selector output
     unsubscribe the source from the shared subject
```

## Cancellation rule

```text
Given the source is connected to the shared subject
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
