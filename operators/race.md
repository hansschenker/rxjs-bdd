# `race`

Deprecated pipeable form of `raceWith`: subscribes to the source and the supplied competitors and mirrors the first one to emit, unsubscribing the others.

*Note:* Deprecated pipeable form.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source and then to each competitor, in order
     stop subscribing further competitors if one emits synchronously during subscription
```

## State-conditioned rule

```text
Given competitors pending before winner
When the next relevant operator event occurs
Then subscribe to competing Observables
```

## Event-triggered rule

```text
Given the operator is active
When first competitor emits
Then choose it as winner, unsubscribe losers, and forward only winner thereafter
```

## Inner rules

```text
Given no competitor has emitted yet
When a competitor emits a value
Then select it as the winner
     unsubscribe the other competitors
     forward the value

Given a winner has been selected
When the winner emits a value
Then forward the value
```

## Concurrency rule

```text
Given competitors are pending
When the output is subscribed
Then admit every competitor at once
     after the first emission only the winner remains admitted
```

## Completion rules

```text
Given no competitor has emitted yet
When any competitor completes
Then complete
     unsubscribe the other competitors

Given a winner has been selected
When the winner completes
Then complete
```

## Error rules

```text
Given no competitor has emitted yet
When any competitor errors
Then error immediately
     unsubscribe the other competitors

Given a winner has been selected
When the winner errors
Then error immediately
```

## Unsubscription rule

```text
Given competitors are pending or a winner is selected
When the downstream subscriber unsubscribes
Then unsubscribe every still-active competitor
```

## Cancellation rule

```text
Given no competitor has emitted yet
When the first competitor emits
Then unsubscribe every other competitor
     keep only the winner
```
