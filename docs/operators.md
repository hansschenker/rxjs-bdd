# RxJS 7.x Operator Given / When / Then Catalog

This catalog converts the complete RxJS 7.x operator behavior catalog from
[rxjs-operators-state-and-policy-patterns](https://github.com/hansschenker/rxjs-operators-state-and-policy-patterns)
into explicit **Given / When / Then** rules.

The mapping is:

```text
Given  -> current state / state predicate
When   -> input, timer, notifier, lifecycle, or subscription event
Then   -> state transition + Action Policy
```

Formally:

```text
(State, Event) -> (Next State, Output)
```

The conversion deliberately keeps state-maintenance rules and event-triggered action rules separate. This prevents a common error: combining a state such as "duration active" with a mutually exclusive event such as "duration ends" in the same transition.


---

## `audit`

### State-conditioned rule

```text
Given duration active
When a source value arrives
Then replace the pending value using the new source value
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When duration ends
Then emit the pending latest value and return to idle
```

*Note:* The first source value starts the duration.

---

## `auditTime`

### State-conditioned rule

```text
Given fixed audit interval active
When a source value arrives
Then replace the pending value using the new source value
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When interval ends
Then emit the pending latest value and return to idle
```

*Note:* Time-based specialization of `audit`.

---

## `buffer`

### State-conditioned rule

```text
Given buffer open
When a source value arrives
Then append the source value to the current array
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When closing notifier emits
Then emit the current array and start a fresh buffer
```


---

## `bufferCount`

### State-conditioned rule

```text
Given buffer(s) open
When a source value arrives
Then append source values and track size/start positions
```

### Event-triggered rule

```text
Given the operator is active
When a buffer reaches its configured size
Then emit that buffer; open later buffers according to `startBufferEvery`
```


---

## `bufferTime`

### State-conditioned rule

```text
Given time-span buffer(s) open
When a source value arrives
Then append source values to every active buffer
```

### Event-triggered rule

```text
Given the operator is active
When a buffer times out or reaches `maxBufferSize`
Then emit it and open replacements according to configuration
```


---

## `bufferToggle`

### State-conditioned rule

```text
Given one or more buffers open
When a source value arrives
Then route the source value into every active buffer
```

### Event-triggered rule

```text
Given the operator is active
When an opening arrives
Then open a buffer; its closing notifier fires: emit and close that buffer
```


---

## `bufferWhen`

### State-conditioned rule

```text
Given current buffer open
When a source value arrives
Then append the source value
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When closing selector's notifier emits
Then emit current buffer and immediately open the next buffer
```


---

## `catchError`

### State-conditioned rule

```text
Given source active normally
When the next relevant source event occurs
Then forward values without recovery state
```

### Event-triggered rule

```text
Given the operator is active
When source errors
Then invoke selector and subscribe to the replacement Observable instead of forwarding the error
```


---

## `combineAll`

### State-conditioned rule

```text
Given outer active
When an inner event arrives
Then collect inner Observables until the outer completes
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When outer completes
Then subscribe/combine inners and emit whenever all have values and any inner updates
```

*Note:* Deprecated alias behavior built on `combineLatestAll`.

---

## `combineLatest`

### State-conditioned rule

```text
Given source plus supplied inputs active
When the next relevant source event occurs
Then retain the latest value from each input and a readiness mask
```

### Event-triggered rule

```text
Given the operator is active
When every input has emitted at least once and any input emits
Then emit the tuple/projected latest combination
```

*Note:* Deprecated pipeable form.

---

## `combineLatestAll`

### State-conditioned rule

```text
Given combined inners active
When the next relevant source event occurs
Then retain each inner's latest value and readiness
```

### Event-triggered rule

```text
Given the relevant inner state exists
When all active inners are ready and any inner emits
Then emit the latest-value tuple
```

*Note:* Starts combining after the higher-order source supplies/collects inners per implementation.

---

## `combineLatestWith`

### State-conditioned rule

```text
Given inputs active
When the next relevant source event occurs
Then retain the latest value from source and each supplied Observable
```

### Event-triggered rule

```text
Given the operator is active
When all inputs have emitted and any input emits
Then emit the latest-value tuple
```


---

## `concat`

### State-conditioned rule

```text
Given current input Observable active
When the next relevant operator event occurs
Then keep later supplied Observables pending
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current input completes
Then subscribe to the next; forward values from only the current input
```

*Note:* Deprecated pipeable form.

---

## `concatAll`

### State-conditioned rule

```text
Given one inner active
When an inner event arrives
Then queue later inner Observables
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then subscribe to the next queued inner; forward inner values in order
```


---

## `concatMap`

### State-conditioned rule

```text
Given one projected inner active
When an outer value arrives
Then queue the outer value
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then project and subscribe to the next queued outer value
```

*Note:* Concurrency policy: queue.

---

## `concatMapTo`

### State-conditioned rule

```text
Given one fixed inner active
When an outer value arrives
Then queue the outer value
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then subscribe to another instance of the configured inner for the next queued outer value
```

*Note:* Deprecated specialization.

---

## `concatWith`

### State-conditioned rule

```text
Given current Observable active
When the next relevant operator event occurs
Then keep following Observables pending
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current Observable completes
Then subscribe to the next and continue forwarding
```


---

## `connect`

### State-conditioned rule

```text
Given shared connector active inside the selector scope
When the next relevant operator event occurs
Then multicast one source execution
```

### Event-triggered rule

```text
Given the operator is active
When selector output is subscribed
Then connect the shared source and route it through the selector result
```


---

## `count`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then increment count for the value satisfying the predicate (or every value without one)
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the final count and complete
```


---

## `debounce`

### State-conditioned rule

```text
Given duration active for pending value
When a source value arrives
Then replace pending value and cancel/restart its duration for the source value
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current duration emits/completes before another source value
Then emit the pending latest value
```


---

## `debounceTime`

### State-conditioned rule

```text
Given silence timer active
When a source value arrives
Then replace pending value and restart the timer for the source value
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When configured silence interval elapses
Then emit the pending latest value
```


---

## `defaultIfEmpty`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then remember whether any value has been seen
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes with no value seen
Then emit the default value, then complete
```

*Note:* If values were seen, they were forwarded normally.

---

## `delay`

### State-conditioned rule

```text
Given notifications pending
When the next relevant operator event occurs
Then schedule each source notification for later delivery
```

### Event-triggered rule

```text
Given the operator is active
When its scheduled due time arrives
Then forward that notification
```

*Note:* Implemented via `delayWhen`/timer semantics in RxJS 7.x.

---

## `delayWhen`

### State-conditioned rule

```text
Given source values pending
When the relevant scheduled event occurs
Then associate each value with a duration Observable
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When that value's duration emits
Then release/emit the corresponding source value
```

*Note:* Subscription delay may also defer source subscription.

---

## `dematerialize`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then treat each incoming `Notification` object as protocol data
```

### Event-triggered rule

```text
Given the operator is active
When a notification object arrives
Then execute it as next/error/complete on the destination
```


---

## `distinct`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep a set of previously seen keys
```

### Event-triggered rule

```text
Given the operator is active
When a value's key has not been seen
Then remember the key and emit the value; otherwise emit nothing
```

*Note:* Optional flush Observable clears remembered keys.

---

## `distinctUntilChanged`

### State-conditioned rule

```text
Given source active after first value
When the next relevant source event occurs
Then remember the last emitted value/key
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives or comparator says current differs from previous
Then emit and replace remembered value/key
```


---

## `distinctUntilKeyChanged`

### State-conditioned rule

```text
Given source active after first value
When the next relevant source event occurs
Then remember the selected key of the last emitted object
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives or selected key differs
Then emit the object and replace remembered key
```


---

## `elementAt`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count source positions
```

### Event-triggered rule

```text
Given the operator is active
When configured index arrives
Then emit that value and complete; source completes too early: emit default or error
```


---

## `endWith`

### State-conditioned rule

```text
Given source active
When a source value arrives
Then forward source values
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit configured trailing values in order, then complete
```


---

## `every`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then remain in 'all passed' state while predicate is true
```

### Event-triggered rule

```text
Given the operator is active
When a value fails predicate
Then emit false and complete; source completes without failure: emit true
```


---

## `exhaust`

### State-conditioned rule

```text
Given one inner active
When an inner event arrives
Then ignore newly arriving inner Observables
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then become idle and allow the next outer inner Observable to be subscribed
```


---

## `exhaustAll`

### State-conditioned rule

```text
Given one inner active
When an inner event arrives
Then ignore newly arriving inner Observables
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then become idle and allow the next inner
```

*Note:* Alias-style specialization of exhaust semantics.

---

## `exhaustMap`

### State-conditioned rule

```text
Given one projected inner active
When an outer value arrives
Then ignore the outer value
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current inner completes
Then become idle; next outer value may start a new inner
```

*Note:* Concurrency policy: ignore while busy.

---

## `expand`

### State-conditioned rule

```text
Given expansion active
When the next relevant operator event occurs
Then feed emitted values back through the projection while respecting concurrency
```

### Event-triggered rule

```text
Given the operator is active
When a value is accepted for expansion
Then emit it and subscribe to its projected Observable recursively
```


---

## `filter`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no operator-specific state except index
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a source value arrives
Then emit it only if predicate(value, index) is true
```


---

## `finalize`

### State-conditioned rule

```text
Given subscription active
When the next relevant source event occurs
Then retain the finalizer for teardown
```

### Event-triggered rule

```text
Given the operator is active
When source terminates or subscriber explicitly unsubscribes
Then invoke the finalizer exactly as teardown requires
```


---

## `find`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then scan values until predicate matches
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first matching value arrives
Then emit it and complete; source completes without match: emit `undefined`
```


---

## `findIndex`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then track index while scanning for first predicate match
```

### Event-triggered rule

```text
Given the operator is active
When first match arrives
Then emit its index and complete; source completes without match: emit `-1`
```


---

## `first`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then wait for first value satisfying predicate (or simply first value)
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first qualifying value arrives
Then emit and complete; source completes first: emit default or error
```


---

## `flatMap`

### State-conditioned rule

```text
Given projected inners active
When the next relevant operator event occurs
Then use merge-style concurrency
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives
Then project and subscribe according to `mergeMap` concurrency policy
```

*Note:* Deprecated alias of `mergeMap`.

---

## `groupBy`

### State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then maintain a map from keys to live grouped Subjects
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives
Then create group if needed and emit value into its group; emit each new group once to downstream
```

*Note:* Duration/connector options can close or customize groups.

---

## `ignoreElements`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then maintain no value state
```

### Event-triggered rule

```text
Given the operator is active
When source next arrives
Then emit nothing; source error/complete arrives: forward the terminal notification
```


---

## `isEmpty`

### State-conditioned rule

```text
Given source active before first value
When the next relevant operator event occurs
Then remain 'possibly empty'
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When first value arrives
Then emit false and complete; source completes first: emit true
```


---

## `joinAllInternals`

### State-conditioned rule

```text
Given inner collection/combine operation active
When the next relevant operator event occurs
Then delegate state to chosen join strategy
```

### Event-triggered rule

```text
Given the relevant inner state exists
When join strategy has enough inner values
Then emit projected joined result
```

*Note:* Internal helper used by higher-order join operators.

---

## `last`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain latest value satisfying predicate (or latest value)
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained last value; if none, emit default or error
```


---

## `map`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no operator-specific value state except index
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit project(value, index)
```


---

## `mapTo`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no operator-specific value state
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit the configured constant
```

*Note:* Deprecated specialization of `map`.

---

## `materialize`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then convert protocol events into `Notification` values
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When next/error/complete occurs
Then emit the corresponding notification object; after terminal notification value, complete normally
```


---

## `max`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain the greatest value seen according to comparer
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained maximum (or follow empty-reduction behavior)
```

*Note:* Implemented via reduction.

---

## `merge`

### State-conditioned rule

```text
Given multiple inputs active
When a subscription lifecycle event occurs
Then allow concurrent subscriptions up to configured concurrency
```

### Event-triggered rule

```text
Given the operator is active
When any active input emits
Then forward immediately; an input completes: admit pending input if capacity exists
```

*Note:* Deprecated pipeable form.

---

## `mergeAll`

### State-conditioned rule

```text
Given inners active
When the relevant input event occurs
Then track active count and queue excess inners beyond concurrency limit
```

### Event-triggered rule

```text
Given the relevant inner state exists
When an inner emits
Then forward immediately; capacity opens: subscribe to queued inner
```


---

## `mergeInternals`

### State-conditioned rule

```text
Given inners active
When the relevant input event occurs
Then track active count, queue, completion state, and optional expansion
```

### Event-triggered rule

```text
Given the relevant inner state exists
When outer/inner events occur
Then apply merge concurrency admission, forwarding, drain, and completion policy
```

*Note:* Internal engine behind several flattening operators.

---

## `mergeMap`

### State-conditioned rule

```text
Given projected inners active
When an outer value arrives
Then allow overlap up to concurrency limit and queue excess outer values
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives with capacity
Then start projected inner; inner emits: forward immediately
```

*Note:* Concurrency policy: allow overlap.

---

## `mergeMapTo`

### State-conditioned rule

```text
Given fixed inners active
When the next relevant operator event occurs
Then allow overlap up to concurrency limit
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives with capacity
Then subscribe to configured inner and forward its values
```

*Note:* Deprecated specialization.

---

## `mergeScan`

### State-conditioned rule

```text
Given projected accumulator inners active
When the next relevant source event occurs
Then retain accumulator and merge-style concurrency state
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When outer value arrives
Then project `(acc, value)` to inner; inner emits: replace accumulator and emit it
```


---

## `mergeWith`

### State-conditioned rule

```text
Given source and supplied Observables are active
When a subscription lifecycle event occurs
Then retain their concurrent subscriptions
```

### Event-triggered rule

```text
Given the operator is active
When any input emits
Then forward immediately; complete after all inputs complete
```


---

## `min`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain the least value seen according to comparer
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained minimum (or follow empty-reduction behavior)
```

*Note:* Implemented via reduction.

---

## `multicast`

### State-conditioned rule

```text
Given connectable state active
When the next relevant operator event occurs
Then route source through a Subject/Subject factory
```

### Event-triggered rule

```text
Given the operator is active
When connection is established
Then subscribe subject to source; subscribers observe the shared subject
```

*Note:* Deprecated multicasting API.

---

## `observeOn`

### State-conditioned rule

```text
Given notifications pending on a scheduler
When the relevant scheduled event occurs
Then retain scheduled delivery tasks
```

### Event-triggered rule

```text
Given the operator is active
When scheduled action executes
Then deliver the corresponding next/error/complete downstream
```

*Note:* Changes notification delivery context, not source production.

---

## `onErrorResumeNextWith`

### State-conditioned rule

```text
Given current Observable active
When the next relevant operator event occurs
Then keep fallback Observables pending
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When current source errors or completes
Then suppress the distinction and subscribe to the next fallback; complete after all finish
```


---

## `pairwise`

### State-conditioned rule

```text
Given source active after first value
When a source value arrives
Then remember previous source value
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When next value arrives and previous exists
Then emit `[previous, current]`, then remember current
```


---

## `partition`

### State-conditioned rule

```text
Given each partition subscription active
When the next relevant operator event occurs
Then apply complementary predicates independently
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then one output forwards if predicate true, the other if false
```

*Note:* Deprecated pipeable partition form.

---

## `pluck`

### State-conditioned rule

```text
Given source active
When the next relevant operator event occurs
Then keep no evolving operator state
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then read configured property path and emit the result
```

*Note:* Deprecated; equivalent to `map` property access.

---

## `publish`

### State-conditioned rule

```text
Given connectable state active
When the next relevant operator event occurs
Then multicast through a plain Subject
```

### Event-triggered rule

```text
Given the operator is active
When connection starts
Then subscribe Subject to source and share that execution
```

*Note:* Deprecated wrapper around connectable/multicast semantics.

---

## `publishBehavior`

### State-conditioned rule

```text
Given connectable state active
When the next relevant source event occurs
Then multicast through BehaviorSubject retaining current value
```

### Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then receive current retained value; connection forwards source into shared BehaviorSubject
```

*Note:* Deprecated.

---

## `publishLast`

### State-conditioned rule

```text
Given connectable state active
When the next relevant source event occurs
Then multicast through AsyncSubject retaining only final value
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit retained last value to subscribers and complete
```

*Note:* Deprecated.

---

## `publishReplay`

### State-conditioned rule

```text
Given connectable state active
When the relevant input event occurs
Then retain configured replay buffer/window in ReplaySubject
```

### Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then replay retained notifications then receive live shared values
```

*Note:* Deprecated.

---

## `race`

### State-conditioned rule

```text
Given competitors pending before winner
When the next relevant operator event occurs
Then subscribe to competing Observables
```

### Event-triggered rule

```text
Given the operator is active
When first competitor emits
Then choose it as winner, unsubscribe losers, and forward only winner thereafter
```

*Note:* Deprecated pipeable form.

---

## `raceWith`

### State-conditioned rule

```text
Given competitors pending before winner
When the next relevant operator event occurs
Then subscribe to source and supplied Observables
```

### Event-triggered rule

```text
Given the operator is active
When first competitor emits
Then choose it, unsubscribe losers, forward winner only
```


---

## `reduce`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain accumulator and whether accumulation has begun
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the final accumulator exactly once, then complete
```

*Note:* Unlike `scan`, no intermediate accumulator emissions.

---

## `refCount`

### State-conditioned rule

```text
Given shared connectable subscriber count > 0
When the next relevant source event occurs
Then retain count and active connection
```

### Event-triggered rule

```text
Given the operator is active
When first subscriber arrives
Then connect; last subscriber leaves: disconnect shared connection
```


---

## `repeat`

### State-conditioned rule

```text
Given source execution active
When the next relevant source event occurs
Then track repeat count/delay state
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes and repeats remain
Then resubscribe; otherwise forward completion
```

*Note:* Does not repeat on error.

---

## `repeatWhen`

### State-conditioned rule

```text
Given source execution active
When the relevant notifier event occurs
Then route completion signals to notifier workflow
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits after a source completion
Then resubscribe to source; notifier completes/errors: terminate accordingly
```

*Note:* Deprecated-style notifier API.

---

## `retry`

### State-conditioned rule

```text
Given source execution active
When the next relevant source event occurs
Then track retry count/delay/reset configuration
```

### Event-triggered rule

```text
Given the operator is active
When source errors and retry policy permits
Then resubscribe; otherwise forward final error
```

*Note:* Does not retry on normal completion.

---

## `retryWhen`

### State-conditioned rule

```text
Given source execution active
When the relevant notifier event occurs
Then route error signals to notifier workflow
```

### Event-triggered rule

```text
Given the operator is active
When notifier emits after an error
Then resubscribe; notifier completes/errors: terminate accordingly
```

*Note:* Deprecated-style notifier API.

---

## `sample`

### State-conditioned rule

```text
Given source active
When a source value arrives
Then remember latest source value and whether a new value exists since last sample
```

### Event-triggered rule

```text
Given the operator is active
When sampler emits
Then emit remembered latest value if one is pending, then clear pending flag
```


---

## `sampleTime`

### State-conditioned rule

```text
Given source active
When a source value arrives
Then remember latest source value and pending flag between periodic sample ticks
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When sampling interval ticks
Then emit remembered latest value if one is pending
```


---

## `scan`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain accumulator
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then update accumulator with reducer and emit the updated accumulator
```

*Note:* State is emitted on every reduction step.

---

## `scanInternals`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain accumulator, index, and seed-state flag
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then initialize/update accumulator and optionally emit according to helper configuration
```

*Note:* Internal helper behind `scan`/`reduce`.

---

## `sequenceEqual`

### State-conditioned rule

```text
Given two sequences active
When the relevant input event occurs
Then queue unmatched values from each side and compare in order
```

### Event-triggered rule

```text
Given the operator is active
When both sides provide the next pair
Then compare them; mismatch emits false and completes; matched completion emits true
```


---

## `share`

### State-conditioned rule

```text
Given shared subscription state active
When a subscription lifecycle event occurs
Then retain connector, subscriber count, and reset state
```

### Event-triggered rule

```text
Given the operator is active
When first subscriber needs source
Then connect; reset conditions occur: reset connector/connection according to configuration
```


---

## `shareReplay`

### State-conditioned rule

```text
Given shared replay state active
When the relevant input event occurs
Then retain ReplaySubject buffer and shared connection state
```

### Event-triggered rule

```text
Given the operator is active
When subscriber arrives
Then replay buffered values then receive live values; connection/reset follows `refCount` and terminal policy
```


---

## `single`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain whether one matching value has been found and that value
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a second matching value arrives
Then error; source completes with exactly one match: emit it; otherwise empty/not-found error semantics apply
```


---

## `skip`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count seen values
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives after the first `count` values
Then emit it; earlier values emit nothing
```


---

## `skipLast`

### State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then maintain a queue/ring of the last `count` values
```

### Event-triggered rule

```text
Given the operator is active
When a new value makes the buffer exceed `count`
Then emit the oldest buffered value
```

*Note:* Trailing `count` values are discarded on completion.

---

## `skipUntil`

### State-conditioned rule

```text
Given gate closed
When a source value arrives
Then ignore source values while waiting for notifier
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits
Then open gate permanently; subsequent source values are forwarded
```

*Note:* Notifier completion alone does not open the gate.

---

## `skipWhile`

### State-conditioned rule

```text
Given skipping state active
When a source value arrives
Then evaluate predicate for the source value
```

### Event-triggered rule

```text
Given the operator is active
When predicate first becomes false
Then stop skipping permanently and emit that value plus all subsequent values
```


---

## `startWith`

### State-conditioned rule

```text
Given subscription begins
When the next relevant operator event occurs
Then configured prefix values are pending before source
```

### Event-triggered rule

```text
Given the operator is active
When output is subscribed
Then emit prefix values first, then subscribe/forward source
```


---

## `subscribeOn`

### State-conditioned rule

```text
Given source subscription is pending on a scheduler
When a subscription lifecycle event occurs
Then keep the source subscription deferred
```

### Event-triggered rule

```text
Given the operator is active
When scheduled subscription action executes
Then subscribe to the source
```

*Note:* Moves subscription side effect in time/context.

---

## `switchAll`

### State-conditioned rule

```text
Given one current inner active
When a subscription lifecycle event occurs
Then remember only the latest inner subscription
```

### Event-triggered rule

```text
Given the relevant inner state exists
When new inner Observable arrives
Then cancel previous inner and subscribe to the new one; forward only current inner
```


---

## `switchMap`

### State-conditioned rule

```text
Given one projected inner active
When a subscription lifecycle event occurs
Then remember only the latest inner subscription
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner, project, and subscribe to the new inner
```

*Note:* Concurrency policy: only latest.

---

## `switchMapTo`

### State-conditioned rule

```text
Given one fixed inner active
When a subscription lifecycle event occurs
Then remember only latest inner subscription instance
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner and subscribe to the configured inner again
```

*Note:* Deprecated specialization.

---

## `switchScan`

### State-conditioned rule

```text
Given one projected accumulator inner active
When the next relevant source event occurs
Then retain accumulator and current inner
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When new outer value arrives
Then cancel current inner and start projection from current accumulator; inner emissions replace and emit accumulator
```


---

## `take`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then count forwarded values up to limit
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When a value arrives within limit
Then emit it; configured count is reached: complete and unsubscribe upstream
```


---

## `takeLast`

### State-conditioned rule

```text
Given source active
When the relevant input event occurs
Then retain a bounded buffer of the last `count` values
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit buffered trailing values in order, then complete
```


---

## `takeUntil`

### State-conditioned rule

```text
Given source active
When the relevant notifier event occurs
Then forward values while notifier has not emitted
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When notifier emits
Then complete output immediately and unsubscribe source
```


---

## `takeWhile`

### State-conditioned rule

```text
Given taking state active
When the next relevant operator event occurs
Then evaluate predicate for each value
```

### Event-triggered rule

```text
Given the operator is active
When predicate becomes false
Then optionally emit boundary value if `inclusive`, then complete; otherwise emit qualifying values
```


---

## `tap`

### State-conditioned rule

```text
Given source active
When a source value arrives
Then preserve source values while invoking side-effect observers
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When next/error/complete/subscription/finalize events occur
Then invoke configured side effect and otherwise mirror source protocol
```


---

## `throttle`

### State-conditioned rule

```text
Given duration active
When a source value arrives
Then suppress new source values, optionally retaining a trailing value depending on config
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When leading/trailing boundary occurs
Then emit according to `{leading, trailing}` policy and manage the duration
```

*Note:* Default is leading `true`, trailing `false`.

---

## `throttleTime`

### State-conditioned rule

```text
Given fixed throttle interval active
When a source value arrives
Then suppress new source values, optionally retain trailing value
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When interval boundary occurs
Then emit according to leading/trailing configuration and reopen as required
```


---

## `throwIfEmpty`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then remember whether any value has been seen
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes empty
Then error using configured error factory; otherwise complete normally after forwarding values
```


---

## `timeInterval`

### State-conditioned rule

```text
Given source active
When a subscription lifecycle event occurs
Then remember scheduler timestamp of previous emission/subscription baseline
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit `{value, interval}` using elapsed scheduler time and update timestamp
```


---

## `timeout`

### State-conditioned rule

```text
Given waiting state active
When the relevant scheduled event occurs
Then track deadline for first/each value using scheduler
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When deadline expires before required source emission
Then unsubscribe source and switch to configured fallback or throw TimeoutError
```


---

## `timeoutWith`

### State-conditioned rule

```text
Given waiting state active
When the relevant scheduled event occurs
Then track timeout deadline
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When deadline expires
Then unsubscribe source and subscribe to configured fallback Observable
```

*Note:* Deprecated wrapper around `timeout`.

---

## `timestamp`

### State-conditioned rule

```text
Given source active
When the relevant scheduled event occurs
Then keep no evolving value state beyond scheduler access
```

### Event-triggered rule

```text
Given the operator is subscribed and ready to process input
When source value arrives
Then emit `{value, timestamp: scheduler.now()}`
```


---

## `toArray`

### State-conditioned rule

```text
Given source active
When a source value arrives
Then append every source value to one array
```

### Event-triggered rule

```text
Given the operator is active and completion has not yet been forwarded
When source completes
Then emit the accumulated array once, then complete
```


---

## `window`

### State-conditioned rule

```text
Given current window open
When a source value arrives
Then forward the source value into current window Subject
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When boundary Observable emits
Then close current window, emit/open a new window
```


---

## `windowCount`

### State-conditioned rule

```text
Given one or more count-based windows open
When a source value arrives
Then route source values into active windows and track counts
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When start/size boundary is reached
Then open or close windows according to `windowSize` and `startWindowEvery`
```


---

## `windowTime`

### State-conditioned rule

```text
Given time-based windows open
When the relevant input event occurs
Then route values into all active windows and track age/count
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When time span, creation interval, or max size boundary occurs
Then close/open windows according to configuration
```


---

## `windowToggle`

### State-conditioned rule

```text
Given one or more windows open
When a source value arrives
Then route the source value into all active windows
```

### Event-triggered rule

```text
Given the operator is active
When opening emits
Then create/emit a new window; its closing notifier fires: close that window
```


---

## `windowWhen`

### State-conditioned rule

```text
Given current window open
When a source value arrives
Then route source values into it
```

### Event-triggered rule

```text
Given the corresponding pending state exists
When closing notifier fires
Then close current window and immediately create/emit the next window
```


---

## `withLatestFrom`

### State-conditioned rule

```text
Given source active
When the next relevant source event occurs
Then retain latest values/readiness from all secondary Observables
```

### Event-triggered rule

```text
Given the operator is active
When source emits and every secondary has emitted at least once
Then emit source value combined with latest secondary values
```

*Note:* Only the source triggers output.

---

## `zip`

### State-conditioned rule

```text
Given inputs active
When the relevant input event occurs
Then maintain one FIFO queue per input
```

### Event-triggered rule

```text
Given the operator is active
When every queue has at least one value
Then dequeue one from each and emit the tuple/projected result
```

*Note:* Deprecated pipeable form.

---

## `zipAll`

### State-conditioned rule

```text
Given collected inner inputs active
When the relevant input event occurs
Then maintain one FIFO queue per inner
```

### Event-triggered rule

```text
Given the relevant inner state exists
When every inner queue has a value
Then dequeue one from each and emit tuple; terminate when further full tuples become impossible
```


---

## `zipWith`

### State-conditioned rule

```text
Given source and supplied inputs active
When the relevant input event occurs
Then maintain one FIFO queue per input
```

### Event-triggered rule

```text
Given the operator is active
When every queue has at least one value
Then dequeue one from each and emit the tuple
```


---

## Coverage

This document contains **116 operator modules**, matching the source catalog used for the conversion.
