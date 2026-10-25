# `sequenceEqual`

Compares the source with another observable value by value using the optional comparator, queuing whichever side is ahead; emits `true` and completes if both sequences end with every pair equal, `false` on the first mismatch or length difference.

## Subscription rule

```text
Given no subscription is active
When a downstream subscriber subscribes
Then subscribe to the source first
     then subscribe to the comparison sequence
     start with both queues empty
```

## State-conditioned rule

```text
Given two sequences active
When the relevant input event occurs
Then queue unmatched values from each side and compare in order
```

## Event-triggered rule

```text
Given the operator is active
When both sides provide the next pair
Then compare them; mismatch emits false and completes; matched completion emits true
```

## Inner rule

```text
Given both sequences are active
When the comparison sequence emits a value
Then if the source queue holds a value, compare it with the oldest queued source value and emit false and complete on mismatch
     otherwise enqueue the value, or emit false and complete if the source has already completed
```

## Concurrency rule

```text
Given values are being compared
When a value arrives on one side without a counterpart
Then queue it without limit
     it is compared when the other side emits
```

## Completion rules

```text
Given the other sequence is still active
When one sequence completes
Then mark that sequence as completed
     keep comparing arriving values from the other sequence against the completed sequence's queue
     emit false and complete if a value arrives while the completed sequence's queue is empty

Given the other sequence has already completed
When the remaining sequence completes
Then emit true if both queues are empty, otherwise false
     complete
```

## Error rule

```text
Given any state
When either sequence errors
Then discard both queues
     error immediately
```

## Unsubscription rule

```text
Given both sequences are active
When the downstream subscriber unsubscribes
Then unsubscribe both sequences
     discard both queues
```

## Cancellation rule

```text
Given both sequences are active
When a compared pair does not match
Then emit false
     complete
     unsubscribe both sequences
```
