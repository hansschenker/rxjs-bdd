# `partition`

Deprecated pipeable form: splits the source into two observables, one forwarding the values that satisfy the predicate and one forwarding those that do not; each output holds its own source subscription.

*Note:* Deprecated pipeable partition form.

## Subscription rule

```text
Given a partition output is subscribed
When its subscriber subscribes
Then subscribe to the source independently for that output
     each output holds its own source subscription
```

## State-conditioned rule

```text
Given each partition subscription active
When the next relevant operator event occurs
Then apply complementary predicates independently
```

## Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then one output forwards if predicate true, the other if false
```

## Completion rule

```text
Given both partition outputs are subscribed
When the source completes
Then complete both outputs
```

## Error rule

```text
Given both partition outputs are subscribed
When the source errors
Then error both outputs
```

## Unsubscription rule

```text
Given one partition output is subscribed
When that output's subscriber unsubscribes
Then unsubscribe that output's own source subscription
     the other output is unaffected
```

## Cancellation rule

```text
Given a partition output is subscribed
When any source value or lifecycle event arrives
Then cancel no active work
     the source is released only by its own termination or by downstream unsubscription
```
