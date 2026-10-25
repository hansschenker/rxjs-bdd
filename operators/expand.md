# `expand`

Emits each source value and projects it to an inner observable; every inner value is likewise emitted and fed back through the projection recursively, with active inners limited by the optional concurrency and excess values buffered.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source immediately
     start with no active recursive inner and an empty buffer
```

## State-conditioned rule

```text
Given expansion active
When the next relevant operator event occurs
Then feed emitted values back through the projection while respecting concurrency
```

## Event-triggered rule

```text
Given the operator is active
When a value is accepted for expansion
Then emit it and subscribe to its projected Observable recursively
```

## Inner rule

```text
Given a recursive inner is active
When it emits a value
Then forward the value downstream
     feed it back through the projection as a new expansion, subject to the concurrency limit
```

## Concurrency rules

```text
Given fewer than concurrent inners are active
When a value is accepted for expansion
Then admit it: project and subscribe immediately

Given concurrent inners are already active
When a value is accepted for expansion
Then buffer it
     expand it when an active inner completes
```

## Completion rules

```text
Given no recursive inner is active and the buffer is empty
When the source completes
Then complete immediately

Given recursive inners are active or values are buffered
When the source completes
Then mark the source as completed
     keep expanding buffered and emitted values
     complete when every recursive inner has completed and the buffer is empty
```

## Error rule

```text
Given any state
When the source or any recursive inner errors
Then discard buffered values
     unsubscribe active inners
     error immediately
```

## Unsubscription rule

```text
Given recursive inners are active
When the downstream subscriber unsubscribes
Then unsubscribe from the source
     unsubscribe every active recursive inner
     discard buffered values
```

## Cancellation rule

```text
Given recursive inners are active
When any source value or lifecycle event arrives
Then cancel no active work
     recursive inners always run to completion
```
