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

Every operator also carries explicit lifecycle rules. **Completion rules** describe what happens to pending state and output when the source, an input, an inner Observable, or a notifier completes. **Error rules** describe what is discarded, propagated, recovered, or swallowed when one of them errors. Where the outcome depends on the state at that moment, the alternatives are listed as separate rules.


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

### Completion rules

```text
Given no pending value exists or no duration is active
When the source completes
Then complete immediately

Given a pending value exists and a duration is active
When the source completes
Then defer completion until the duration ends
     emit the pending latest value when the duration ends
     complete
```

### Error rule

```text
Given any state
When the source or the active duration observable errors
Then discard the pending value
     unsubscribe the active duration
     error immediately
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

### Completion rules

```text
Given no pending value exists or no interval timer is active
When the source completes
Then complete immediately

Given a pending value exists and an interval timer is active
When the source completes
Then defer completion until the interval ends
     emit the pending latest value when the interval ends
     complete
```

### Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the interval timer
     error immediately
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

### Completion rules

```text
Given a buffer is open
When the source completes
Then emit the current buffer, even if it is empty
     complete

Given a buffer is open
When the closing notifier completes
Then ignore the completion
     keep buffering until the source completes
```

### Error rule

```text
Given any state
When the source or the closing notifier errors
Then discard the current buffer
     error immediately
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

### Completion rules

```text
Given one or more partial buffers are open
When the source completes
Then emit every open partial buffer in opening order
     complete

Given no buffer is open
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source errors
Then discard all open buffers
     error immediately
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

### Completion rule

```text
Given one or more time-span buffers are open
When the source completes
Then emit every open buffer in opening order, including an empty one
     cancel pending buffer timers
     complete
```

### Error rule

```text
Given any state
When the source errors
Then discard all open buffers
     cancel pending buffer timers
     error immediately
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

### Completion rules

```text
Given zero or more toggled buffers are open
When the source completes
Then emit every open buffer in opening order
     complete

Given the operator is active
When the openings observable completes
Then ignore the completion
     already open buffers stay open until their closing notifier emits or the source completes

Given a buffer is open
When its closing notifier completes without emitting
Then ignore the completion
     keep that buffer open until the source completes
```

### Error rule

```text
Given any state
When the source, the openings observable, or a closing notifier errors
Then discard all open buffers
     error immediately
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

### Completion rules

```text
Given a buffer is open
When the source completes
Then emit the current buffer, even if it is empty
     complete

Given a buffer is open
When the closing observable completes without emitting
Then ignore the completion
     keep the buffer open until the source completes
```

### Error rule

```text
Given any state
When the source or the closing observable errors
Then discard the current buffer
     error immediately
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

### Completion rules

```text
Given the source is active and no error has been caught
When the source completes
Then complete

Given a replacement observable is active
When the replacement observable completes
Then complete
```

### Error rules

```text
Given the source is active
When the source errors
Then unsubscribe from the source
     invoke the selector with the error and the caught observable
     subscribe to the returned observable and mirror its notifications
     error with the thrown error if the selector throws

Given a replacement observable is active
When the replacement observable errors
Then error immediately
     the selector is not invoked again
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

### Completion rules

```text
Given inner observables are being collected
When the outer source completes
Then stop collecting
     subscribe to every collected inner with combineLatest semantics
     complete immediately if no inners were collected

Given the combined inners are active
When an inner completes
Then retain its latest value
     complete when every inner has completed
```

### Error rule

```text
Given any state
When the outer source or any inner observable errors
Then unsubscribe all inners
     error immediately
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

### Completion rules

```text
Given other inputs are still active
When an input completes
Then retain its latest value
     keep combining with the remaining inputs
     no combination is ever emitted if that input never emitted

Given every other input has completed
When the last active input completes
Then complete
```

### Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
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

### Completion rules

```text
Given inner observables are being collected
When the outer source completes
Then stop collecting
     subscribe to every collected inner with combineLatest semantics
     complete immediately if no inners were collected

Given the combined inners are active
When an inner completes
Then retain its latest value
     complete when every inner has completed
```

### Error rule

```text
Given any state
When the outer source or any inner observable errors
Then unsubscribe all inners
     error immediately
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

### Completion rules

```text
Given other inputs are still active
When an input completes
Then retain its latest value
     keep combining with the remaining inputs
     no combination is ever emitted if that input never emitted

Given every other input has completed
When the last active input completes
Then complete
```

### Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
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

### Completion rules

```text
Given an input is active and further inputs remain
When the active input completes
Then subscribe to the next input

Given the last input is active
When the last input completes
Then complete
```

### Error rule

```text
Given any input is active
When the active input errors
Then error immediately
     never subscribe to the remaining inputs
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

### Completion rules

```text
Given no inner is active and no inners are queued
When the outer source completes
Then complete immediately

Given a inner is active or inners are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued inners in order, one inner at a time
     complete after the last inner completes
```

### Error rule

```text
Given any state
When the outer source or the active inner errors
Then discard queued inners
     unsubscribe the active inner
     error immediately
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

### Completion rules

```text
Given no projected inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given a projected inner is active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued outer values in order, one projected inner at a time
     complete after the last projected inner completes
```

### Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then discard queued outer values
     unsubscribe the active projected inner
     error immediately
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

### Completion rules

```text
Given no configured inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given a configured inner is active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep draining queued outer values in order, one configured inner at a time
     complete after the last configured inner completes
```

### Error rule

```text
Given any state
When the outer source or the active configured inner errors
Then discard queued outer values
     unsubscribe the active configured inner
     error immediately
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

### Completion rules

```text
Given an input is active and further inputs remain
When the active input completes
Then subscribe to the next input

Given the last input is active
When the last input completes
Then complete
```

### Error rule

```text
Given any input is active
When the active input errors
Then error immediately
     never subscribe to the remaining inputs
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

### Completion rule

```text
Given the source is connected to the shared subject
When the source completes
Then complete the subject
     the output completes as the selector pipeline propagates the subject's completion
```

### Error rule

```text
Given the source is connected to the shared subject
When the source errors
Then error the subject
     the output errors as the selector pipeline propagates the subject's error
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

### Completion rule

```text
Given a running count exists, possibly zero
When the source completes
Then emit the final count
     complete
```

### Error rule

```text
Given a running count exists
When the source errors
Then discard the count
     error immediately
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

### Completion rules

```text
Given a pending value exists
When the source completes
Then unsubscribe the active duration
     emit the pending latest value
     complete

Given no pending value exists
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source or the active duration observable errors
Then discard the pending value
     unsubscribe the active duration
     error immediately
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

### Completion rules

```text
Given a pending value exists
When the source completes
Then cancel the silence timer
     emit the pending latest value
     complete

Given no pending value exists
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the silence timer
     error immediately
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

### Completion rules

```text
Given no value has been emitted
When the source completes
Then emit the default value
     complete

Given at least one value has been emitted
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source errors
Then error immediately
     the default value is not emitted
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

### Completion rules

```text
Given delayed values are pending
When the source completes
Then keep the pending timers running
     emit each pending value when its delay elapses
     complete after the last pending value is emitted

Given no delayed values are pending
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source errors
Then cancel pending timers and discard their values
     error immediately
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

### Completion rules

```text
Given durations are active for pending values
When the source completes
Then keep waiting on each active duration
     emit each value when its duration first emits
     complete after the last pending duration resolves

Given no values are pending
When the source completes
Then complete

Given a value is pending on its duration
When its duration completes without emitting
Then drop the pending value without emitting it
```

### Error rule

```text
Given any state
When the source or any active duration observable errors
Then discard pending values
     unsubscribe active durations
     error immediately
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

### Completion rules

```text
Given notification objects are being interpreted
When a complete notification arrives as a value
Then complete
     unsubscribe from the source

Given notification objects are being interpreted
When the source completes
Then complete
```

### Error rules

```text
Given notification objects are being interpreted
When an error notification arrives as a value
Then error with the wrapped error
     unsubscribe from the source

Given notification objects are being interpreted
When the source errors
Then error immediately
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

### Completion rules

```text
Given seen keys are retained
When the source completes
Then clear the set of seen keys
     complete

Given seen keys are retained
When the flushes observable completes
Then ignore the completion
     keep the current set of seen keys
```

### Error rule

```text
Given any state
When the source or the flushes observable errors
Then clear the set of seen keys
     error immediately
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

### Completion rule

```text
Given a previous value or key is retained
When the source completes
Then complete
```

### Error rule

```text
Given a previous value or key is retained
When the source errors
Then error immediately
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

### Completion rule

```text
Given a previous key is retained
When the source completes
Then complete
```

### Error rule

```text
Given a previous key is retained
When the source errors
Then error immediately
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

### Completion rules

```text
Given fewer than index + 1 values have arrived and no default value is configured
When the source completes
Then error with ArgumentOutOfRangeError

Given fewer than index + 1 values have arrived and a default value is configured
When the source completes
Then emit the default value
     complete
```

### Error rule

```text
Given the configured index has not been reached
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then emit each appended value in order
     complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
     the appended values are never emitted
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

### Completion rule

```text
Given no value has failed the predicate
When the source completes
Then emit true
     complete
```

### Error rule

```text
Given no value has failed the predicate
When the source errors
Then error immediately
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

### Completion rules

```text
Given no inner is active
When the outer source completes
Then complete immediately

Given a inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active inner completes
```

### Error rule

```text
Given any state
When the outer source or the active inner errors
Then unsubscribe the active inner
     error immediately
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

### Completion rules

```text
Given no inner is active
When the outer source completes
Then complete immediately

Given a inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active inner completes
```

### Error rule

```text
Given any state
When the outer source or the active inner errors
Then unsubscribe the active inner
     error immediately
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

### Completion rules

```text
Given no projected inner is active
When the outer source completes
Then complete immediately

Given a projected inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active projected inner completes
```

### Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then unsubscribe the active projected inner
     error immediately
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

### Completion rules

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

### Error rule

```text
Given any state
When the source or any recursive inner errors
Then discard buffered values
     unsubscribe active inners
     error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the finalizer is registered
When the source completes
Then complete
     invoke the finalizer during teardown
```

### Error rule

```text
Given the finalizer is registered
When the source errors
Then error immediately
     invoke the finalizer during teardown
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

### Completion rule

```text
Given no value has matched the predicate
When the source completes
Then emit undefined
     complete
```

### Error rule

```text
Given no value has matched the predicate
When the source errors
Then error immediately
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

### Completion rule

```text
Given no value has matched the predicate
When the source completes
Then emit -1
     complete
```

### Error rule

```text
Given no value has matched the predicate
When the source errors
Then error immediately
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

### Completion rules

```text
Given no value has matched and no default value is configured
When the source completes
Then error with EmptyError

Given no value has matched and a default value is configured
When the source completes
Then emit the default value
     complete
```

### Error rule

```text
Given no value has matched
When the source errors
Then error immediately
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

### Completion rules

```text
Given no projected inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given projected inners are active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep running active projected inners and admit queued outer values as concurrency capacity opens
     complete when the last projected inner completes and the queue is empty
```

### Error rule

```text
Given any state
When the outer source or any active projected inner errors
Then discard queued outer values
     unsubscribe all active projected inners
     error immediately
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

### Completion rule

```text
Given groups are active
When the source completes
Then complete every active group
     complete
```

### Error rule

```text
Given groups are active
When the source or a group duration observable errors
Then error every active group
     error immediately
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

### Completion rule

```text
Given values are being ignored
When the source completes
Then complete
```

### Error rule

```text
Given values are being ignored
When the source errors
Then error immediately
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

### Completion rule

```text
Given no value has arrived
When the source completes
Then emit true
     complete
```

### Error rule

```text
Given no value has arrived
When the source errors
Then error immediately
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

### Completion rule

```text
Given inner observables are being collected
When the outer source completes
Then pass the collected inners to the join function
     subscribe to the joined observable
     apply the optional projection to its values
     complete when the joined observable completes
```

### Error rule

```text
Given any state
When the outer source or the joined observable errors
Then error immediately
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

### Completion rules

```text
Given at least one value has matched
When the source completes
Then emit the retained last matching value
     complete

Given no value has matched and no default value is configured
When the source completes
Then error with EmptyError

Given no value has matched and a default value is configured
When the source completes
Then emit the default value
     complete
```

### Error rule

```text
Given any state
When the source errors
Then discard the retained value
     error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then emit a complete Notification
     complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then emit an error Notification wrapping the error
     complete
     the error itself is not forwarded
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

### Completion rules

```text
Given at least one value has been compared
When the source completes
Then emit the retained maximum
     complete

Given no value has arrived
When the source completes
Then complete without emitting
```

### Error rule

```text
Given any state
When the source errors
Then discard the retained maximum
     error immediately
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

### Completion rules

```text
Given other inputs are still active
When an input completes
Then keep mirroring the remaining inputs
     admit a pending input if concurrency capacity opens

Given every other input has completed
When the last active input completes
Then complete
```

### Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
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

### Completion rules

```text
Given no inner is active and no inners are queued
When the outer source completes
Then complete immediately

Given inners are active or inners are queued
When the outer source completes
Then mark the outer as completed
     keep running active inners and admit queued inners as concurrency capacity opens
     complete when the last inner completes and the queue is empty
```

### Error rule

```text
Given any state
When the outer source or any active inner errors
Then discard queued inners
     unsubscribe all active inners
     error immediately
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

### Completion rules

```text
Given no inner is active and the buffer is empty
When the outer source completes
Then complete immediately

Given inners are active or values are buffered
When the outer source completes
Then set the completed flag
     complete only once the active count reaches zero and the buffer is empty
```

### Error rule

```text
Given any state
When the outer source or any inner errors
Then error through the operator subscriber
     release the buffer during teardown
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

### Completion rules

```text
Given no projected inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given projected inners are active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep running active projected inners and admit queued outer values as concurrency capacity opens
     complete when the last projected inner completes and the queue is empty
```

### Error rule

```text
Given any state
When the outer source or any active projected inner errors
Then discard queued outer values
     unsubscribe all active projected inners
     error immediately
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

### Completion rules

```text
Given no configured inner is active and no outer values are queued
When the outer source completes
Then complete immediately

Given configured inners are active or outer values are queued
When the outer source completes
Then mark the outer as completed
     keep running active configured inners and admit queued outer values as concurrency capacity opens
     complete when the last configured inner completes and the queue is empty
```

### Error rule

```text
Given any state
When the outer source or any active configured inner errors
Then discard queued outer values
     unsubscribe all active configured inners
     error immediately
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

### Completion rules

```text
Given no accumulator inner is active and no outer values are queued
When the source completes
Then complete immediately

Given accumulator inners are active or outer values are queued
When the source completes
Then mark the source as completed
     keep running active accumulator inners and admit queued values as capacity opens
     complete when the last inner completes and the queue is empty
```

### Error rule

```text
Given any state
When the source or any active accumulator inner errors
Then discard the accumulator and queued values
     unsubscribe all active inners
     error immediately
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

### Completion rules

```text
Given other inputs are still active
When an input completes
Then keep mirroring the remaining inputs
     admit a pending input if concurrency capacity opens

Given every other input has completed
When the last active input completes
Then complete
```

### Error rule

```text
Given any state
When the source or any supplied input errors
Then unsubscribe all inputs
     error immediately
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

### Completion rules

```text
Given at least one value has been compared
When the source completes
Then emit the retained minimum
     complete

Given no value has arrived
When the source completes
Then complete without emitting
```

### Error rule

```text
Given any state
When the source errors
Then discard the retained minimum
     error immediately
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

### Completion rule

```text
Given the source is connected to the subject
When the source completes
Then complete the subject
     complete every current subscriber
     with a selector, the output completes as the selector pipeline propagates completion
```

### Error rule

```text
Given the source is connected to the subject
When the source errors
Then error the subject
     error every current subscriber
     with a selector, the output errors as the selector pipeline propagates the error
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

### Completion rule

```text
Given scheduled notifications may be pending
When the source completes
Then schedule the completion on the scheduler
     complete after previously scheduled notifications have been delivered
```

### Error rule

```text
Given scheduled notifications may be pending
When the source errors
Then schedule the error on the scheduler
     error after previously scheduled notifications have been delivered
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

### Completion rules

```text
Given further fallback sources remain
When the active source completes
Then subscribe to the next source

Given no further sources remain
When the active source completes
Then complete
```

### Error rules

```text
Given further fallback sources remain
When the active source errors
Then swallow the error
     subscribe to the next source

Given no further sources remain
When the active source errors
Then swallow the error
     complete
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

### Completion rule

```text
Given a previous value is retained
When the source completes
Then discard the retained value
     complete
```

### Error rule

```text
Given a previous value is retained
When the source errors
Then error immediately
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

### Completion rule

```text
Given both partition outputs are subscribed
When the source completes
Then complete both outputs
```

### Error rule

```text
Given both partition outputs are subscribed
When the source errors
Then error both outputs
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source is connected to the Subject
When the source completes
Then complete every current subscriber
     late subscribers complete immediately
```

### Error rule

```text
Given the source is connected to the Subject
When the source errors
Then error every current subscriber
     late subscribers error immediately
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

### Completion rule

```text
Given the source is connected to the BehaviorSubject
When the source completes
Then complete every current subscriber
     late subscribers complete immediately without receiving the retained value
```

### Error rule

```text
Given the source is connected to the BehaviorSubject
When the source errors
Then error every current subscriber
     late subscribers error immediately
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

### Completion rule

```text
Given the source is connected to the AsyncSubject
When the source completes
Then emit the retained last value, if any, to every current subscriber
     complete every current subscriber
     late subscribers receive the last value and complete
```

### Error rule

```text
Given the source is connected to the AsyncSubject
When the source errors
Then error every current subscriber
     late subscribers error immediately
     the retained last value is never emitted
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

### Completion rule

```text
Given the source is connected to the ReplaySubject
When the source completes
Then complete every current subscriber
     late subscribers replay the buffered values and then complete
```

### Error rule

```text
Given the source is connected to the ReplaySubject
When the source errors
Then error every current subscriber
     late subscribers replay the buffered values and then error
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

### Completion rules

```text
Given no competitor has emitted yet
When any competitor completes
Then complete
     unsubscribe the other competitors

Given a winner has been selected
When the winner completes
Then complete
```

### Error rules

```text
Given no competitor has emitted yet
When any competitor errors
Then error immediately
     unsubscribe the other competitors

Given a winner has been selected
When the winner errors
Then error immediately
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

### Completion rules

```text
Given no competitor has emitted yet
When any competitor completes
Then complete
     unsubscribe the other competitors

Given a winner has been selected
When the winner completes
Then complete
```

### Error rules

```text
Given no competitor has emitted yet
When any competitor errors
Then error immediately
     unsubscribe the other competitors

Given a winner has been selected
When the winner errors
Then error immediately
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

### Completion rules

```text
Given a seed was provided or at least one value has been accumulated
When the source completes
Then emit the accumulated value
     complete

Given no seed was provided and no value has arrived
When the source completes
Then complete without emitting
```

### Error rule

```text
Given any state
When the source errors
Then discard the accumulator
     error immediately
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

### Completion rule

```text
Given the connection is active with subscribers
When the connectable source completes
Then complete every subscriber through the shared subject
```

### Error rule

```text
Given the connection is active with subscribers
When the connectable source errors
Then error every subscriber through the shared subject
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

### Completion rules

```text
Given the repeat count is not exhausted
When the source completes
Then unsubscribe the completed source execution
     resubscribe to the source, after the configured delay if any

Given the repeat count is exhausted
When the source completes
Then complete
```

### Error rule

```text
Given any repetition is active
When the source errors
Then error immediately
     no further repetitions are started
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

### Completion rules

```text
Given the notifier has not completed
When the source completes
Then push a completion signal to the notifications subject
     resubscribe to the source when the notifier emits

Given the source has completed and is waiting on the notifier
When the notifier completes
Then complete

Given the notifier has completed
When the source completes
Then complete
```

### Error rules

```text
Given any state
When the source errors
Then error immediately

Given any state
When the notifier errors
Then error immediately
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

### Completion rule

```text
Given any attempt is active
When the source completes
Then complete
```

### Error rules

```text
Given the retry count is not exhausted
When the source errors
Then unsubscribe the failed source execution
     resubscribe to the source, after the configured delay if any
     reset the attempt counter on the next value if resetOnSuccess is set

Given the retry count is exhausted
When the source errors
Then error immediately
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

### Completion rules

```text
Given any attempt is active
When the source completes
Then complete

Given the source has errored and is waiting on the notifier
When the notifier completes
Then complete
```

### Error rules

```text
Given the notifier is active
When the source errors
Then push the error to the errors subject
     resubscribe to the source when the notifier emits

Given any state
When the notifier errors
Then error immediately
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

### Completion rules

```text
Given a pending sampled value exists
When the source completes
Then discard the pending value without emitting it
     complete

Given the source subscription is active
When the notifier completes
Then ignore the completion
     keep sampling state until the source completes
```

### Error rule

```text
Given any state
When the source or the notifier errors
Then discard the pending value
     error immediately
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

### Completion rule

```text
Given a pending sampled value exists
When the source completes
Then discard the pending value without emitting it
     cancel the sampling interval
     complete
```

### Error rule

```text
Given any state
When the source errors
Then discard the pending value
     cancel the sampling interval
     error immediately
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

### Completion rule

```text
Given an accumulator is retained
When the source completes
Then complete without emitting the accumulator again
```

### Error rule

```text
Given an accumulator is retained
When the source errors
Then discard the accumulator
     error immediately
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

### Completion rules

```text
Given emitOnComplete is set and accumulated state exists
When the source completes
Then emit the accumulated state
     complete

Given emitOnComplete is not set, or no state has been accumulated
When the source completes
Then complete without emitting
```

### Error rule

```text
Given any state
When the source errors
Then discard the accumulator
     error immediately
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

### Completion rules

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

### Error rule

```text
Given any state
When either sequence errors
Then discard both queues
     error immediately
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

### Completion rule

```text
Given the source is connected
When the source completes
Then complete every current subscriber
     reset the connection and subject when resetOnComplete is set (default true), so later subscribers resubscribe to the source
```

### Error rule

```text
Given the source is connected
When the source errors
Then error every current subscriber
     reset the connection and subject when resetOnError is set (default true), so later subscribers resubscribe to the source
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

### Completion rule

```text
Given the source is connected
When the source completes
Then complete every current subscriber
     keep the ReplaySubject because resetOnComplete is false; late subscribers replay the buffer and then complete
```

### Error rule

```text
Given the source is connected
When the source errors
Then error every current subscriber
     reset the connection because resetOnError is true; the next subscriber resubscribes to the source
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

### Completion rules

```text
Given exactly one value has matched
When the source completes
Then emit the matched value
     complete

Given values have arrived but none matched
When the source completes
Then error with NotFoundError

Given no value has arrived
When the source completes
Then error with EmptyError
```

### Error rule

```text
Given any state
When the source errors
Then discard the retained match
     error immediately
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

### Completion rule

```text
Given values are being counted
When the source completes
Then complete
```

### Error rule

```text
Given values are being counted
When the source errors
Then error immediately
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

### Completion rule

```text
Given the last count values are buffered
When the source completes
Then discard the buffered values without emitting them
     complete
```

### Error rule

```text
Given the last count values are buffered
When the source errors
Then discard the buffered values
     error immediately
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

### Completion rules

```text
Given the gate is open or closed
When the source completes
Then complete, whether or not the notifier has emitted

Given the gate is closed
When the notifier completes without emitting
Then ignore the completion
     keep skipping source values permanently
```

### Error rule

```text
Given any state
When the source or the notifier errors
Then error immediately
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

### Completion rule

```text
Given skipping or forwarding state is active
When the source completes
Then complete
```

### Error rule

```text
Given skipping or forwarding state is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the prefix values have been emitted and the source is active
When the source completes
Then complete
```

### Error rule

```text
Given the prefix values have been emitted and the source is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source subscription has been scheduled or established
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription has been scheduled or established
When the source errors
Then error immediately
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

### Completion rules

```text
Given no inner is active
When the outer source completes
Then complete immediately

Given a inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active inner completes
```

### Error rule

```text
Given any state
When the outer source or the active inner errors
Then unsubscribe the active inner
     error immediately
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

### Completion rules

```text
Given no projected inner is active
When the outer source completes
Then complete immediately

Given a projected inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active projected inner completes
```

### Error rule

```text
Given any state
When the outer source or the active projected inner errors
Then unsubscribe the active projected inner
     error immediately
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

### Completion rules

```text
Given no configured inner is active
When the outer source completes
Then complete immediately

Given a configured inner is active
When the outer source completes
Then mark the outer as completed
     complete when the active configured inner completes
```

### Error rule

```text
Given any state
When the outer source or the active configured inner errors
Then unsubscribe the active configured inner
     error immediately
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

### Completion rules

```text
Given no accumulator inner is active
When the source completes
Then complete immediately

Given an accumulator inner is active
When the source completes
Then mark the source as completed
     complete when the active inner completes
```

### Error rule

```text
Given any state
When the source or the active accumulator inner errors
Then discard the accumulator
     unsubscribe the active inner
     error immediately
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

### Completion rule

```text
Given fewer than count values have been taken
When the source completes
Then complete
```

### Error rule

```text
Given fewer than count values have been taken
When the source errors
Then error immediately
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

### Completion rule

```text
Given up to count trailing values are buffered
When the source completes
Then emit the buffered values in arrival order
     complete
```

### Error rule

```text
Given up to count trailing values are buffered
When the source errors
Then discard the buffered values
     error immediately
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

### Completion rules

```text
Given the notifier has not emitted
When the source completes
Then complete
     unsubscribe the notifier

Given the notifier has not emitted
When the notifier completes without emitting
Then ignore the completion
     keep mirroring the source
```

### Error rule

```text
Given the notifier has not emitted
When the source or the notifier errors
Then error immediately
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

### Completion rule

```text
Given the predicate has not yet failed
When the source completes
Then complete
```

### Error rule

```text
Given the predicate has not yet failed
When the source errors
Then error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then invoke the complete callback
     complete
     invoke the finalize callback during teardown
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then invoke the error callback
     error immediately
     invoke the finalize callback during teardown
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

### Completion rules

```text
Given trailing is enabled, a trailing value is pending, and the duration is active
When the source completes
Then defer completion until the duration ends
     emit the trailing value
     complete

Given no trailing value is pending, or trailing is disabled
When the source completes
Then discard any suppressed value
     complete immediately
```

### Error rule

```text
Given any state
When the source or the active duration observable errors
Then discard any pending value
     cancel the duration
     error immediately
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

### Completion rules

```text
Given trailing is enabled, a trailing value is pending, and the interval timer is active
When the source completes
Then defer completion until the interval timer ends
     emit the trailing value
     complete

Given no trailing value is pending, or trailing is disabled
When the source completes
Then discard any suppressed value
     complete immediately
```

### Error rule

```text
Given any state
When the source errors
Then discard any pending value
     cancel the interval timer
     error immediately
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

### Completion rules

```text
Given no value has arrived
When the source completes
Then error with the result of the error factory (EmptyError by default)

Given at least one value has arrived
When the source completes
Then complete
```

### Error rule

```text
Given any state
When the source errors
Then error immediately
     the error factory is not invoked
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

### Completion rule

```text
Given a previous timestamp is retained
When the source completes
Then complete
```

### Error rule

```text
Given a previous timestamp is retained
When the source errors
Then error immediately
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

### Completion rule

```text
Given a timeout deadline is pending
When the source completes
Then cancel the pending timeout timer
     complete
```

### Error rule

```text
Given a timeout deadline is pending
When the source errors
Then cancel the pending timeout timer
     error immediately
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

### Completion rule

```text
Given a timeout deadline is pending
When the source completes
Then cancel the pending timeout timer
     complete
```

### Error rule

```text
Given a timeout deadline is pending
When the source errors
Then cancel the pending timeout timer
     error immediately
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

### Completion rule

```text
Given the source subscription is active
When the source completes
Then complete
```

### Error rule

```text
Given the source subscription is active
When the source errors
Then error immediately
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

### Completion rule

```text
Given values are being collected
When the source completes
Then emit the collected array, empty if no values arrived
     complete
```

### Error rule

```text
Given values are being collected
When the source errors
Then discard the collected array
     error immediately
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

### Completion rules

```text
Given a window is open
When the source completes
Then complete the current window
     complete

Given a window is open
When the boundary notifier completes
Then ignore the completion
     keep the current window open until the source completes
```

### Error rule

```text
Given a window is open
When the source or the boundary notifier errors
Then error the current window
     error immediately
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

### Completion rule

```text
Given one or more windows are open
When the source completes
Then complete every open window
     complete
```

### Error rule

```text
Given one or more windows are open
When the source errors
Then error every open window
     error immediately
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

### Completion rule

```text
Given one or more windows are open
When the source completes
Then complete every open window
     cancel pending window timers
     complete
```

### Error rule

```text
Given one or more windows are open
When the source errors
Then error every open window
     cancel pending window timers
     error immediately
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

### Completion rules

```text
Given zero or more windows are open
When the source completes
Then complete every open window
     complete

Given the operator is active
When the openings observable completes
Then ignore the completion
     open windows stay open until their closing notifier emits or the source completes
```

### Error rule

```text
Given any state
When the source, the openings observable, or a closing notifier errors
Then error every open window
     error immediately
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

### Completion rule

```text
Given a window is open
When the source completes
Then complete the current window
     complete
```

### Error rule

```text
Given a window is open
When the source or the closing notifier errors
Then error the current window
     error immediately
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

### Completion rules

```text
Given latest values from secondary inputs may be retained
When the source completes
Then complete

Given the source subscription is active
When a secondary input completes
Then ignore the completion
     keep its latest value for later combinations
```

### Error rule

```text
Given any state
When the source or any secondary input errors
Then error immediately
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

### Completion rules

```text
Given the completing input's queue is empty
When an input completes
Then complete, because no further tuple is possible

Given the completing input's queue still holds values
When an input completes
Then mark that input as completed
     keep emitting tuples while its queue drains
     complete as soon as its queue is empty
```

### Error rule

```text
Given any state
When any input errors
Then discard all queues
     error immediately
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

### Completion rules

```text
Given inner observables are being collected
When the outer source completes
Then stop collecting
     subscribe to every collected inner with zip semantics
     complete immediately if no inners were collected

Given the zipped inners are active and the completing inner's queue is empty
When an inner completes
Then complete, because no further tuple is possible

Given the zipped inners are active and the completing inner's queue still holds values
When an inner completes
Then mark that inner as completed
     complete as soon as its queue is empty
```

### Error rule

```text
Given any state
When the outer source or any inner errors
Then discard all queues
     error immediately
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

### Completion rules

```text
Given the completing input's queue is empty
When an input completes
Then complete, because no further tuple is possible

Given the completing input's queue still holds values
When an input completes
Then mark that input as completed
     keep emitting tuples while its queue drains
     complete as soon as its queue is empty
```

### Error rule

```text
Given any state
When any input errors
Then discard all queues
     error immediately
```


---

## Coverage

This document contains **116 operator modules**, matching the source catalog used for the conversion.
