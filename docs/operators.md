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

Every operator also carries explicit lifecycle rules. **Subscription rules** come first and describe what is established when a downstream subscriber subscribes: whether the source is subscribed immediately, deferred, or shared, the order in which inputs and notifiers are subscribed, and the initial state. **Timer rules** (only for operators that schedule work) describe what happens when an interval, due-time timer, or scheduler action fires. **Notifier rules** (only for operators that consume a secondary observable) describe what a closing, opening, boundary, duration, flush, repeat, retry, or reset notifier does when it emits. **Inner rules** (only for operators with inner observables or secondary inputs) describe how a value from such an observable is handled. **Concurrency rules** (only for operators whose work can overlap or be superseded) state whether new work is allowed, queued, replaced, or ignored. **Completion rules** describe what happens to pending state and output when the source, an input, an inner Observable, or a notifier completes. **Error rules** describe what is discarded, propagated, recovered, or swallowed when one of them errors. **Unsubscription rules** describe what is torn down when the downstream subscriber unsubscribes. **Cancellation rules** describe which active work the operator itself cancels in response to an event, or state explicitly that it cancels nothing on its own. Where the outcome depends on the state at that moment, the alternatives are listed as separate rules.

Each operator has its own file under [`operators/`](../operators/), named after the RxJS 7.x source module (`operators/audit.md` for `audit`). Every file opens with a short summary of the operator's behaviour, followed by its rules in lifecycle order under one heading per rule kind (`## Subscription rule`, `## Timer rules`, ...). The table below lists every operator with that summary.

---

## Operators

| Operator | Summary |
|---|---|
| [`audit`](../operators/audit.md) | Holds the latest source value while a duration observable, started by the value that arrives when idle, is active; when the duration emits, the pending latest value is emitted and the operator returns to idle. Values arriving during the duration only replace the pending value. |
| [`auditTime`](../operators/auditTime.md) | Time-based specialization of `audit`: the value that arrives when idle starts a fixed-length timer, later values replace the pending value, and the latest value is emitted when the timer fires. |
| [`buffer`](../operators/buffer.md) | Collects source values into an open buffer and, each time the closing notifier emits, emits the buffer as an array and opens a fresh empty one. The current buffer, even if empty, is emitted when the source completes. |
| [`bufferCount`](../operators/bufferCount.md) | Collects source values into arrays of `bufferSize` values, emitting each buffer when it is full; with a `startBufferEvery` offset a new buffer opens every that many values, so buffers may overlap. Partial buffers are emitted when the source completes. |
| [`bufferTime`](../operators/bufferTime.md) | Collects source values into a buffer that is emitted when its time span elapses; an optional creation interval opens overlapping buffers, and an optional maximum size closes a buffer early. Open buffers are emitted when the source completes. |
| [`bufferToggle`](../operators/bufferToggle.md) | Opens a new buffer each time the openings observable emits and closes it, emitting its values, when the closing notifier derived from that opening value emits; buffers may overlap. Open buffers are emitted when the source completes. |
| [`bufferWhen`](../operators/bufferWhen.md) | Collects source values into a buffer whose lifetime is governed by a closing observable obtained from the closing selector; when it emits, the buffer is emitted and a fresh buffer with a new closing observable is started. |
| [`catchError`](../operators/catchError.md) | Forwards source values unchanged until the source errors, then subscribes to the observable returned by the selector and forwards its notifications in place of the error. The selector may rethrow, or return the source itself to retry. |
| [`combineAll`](../operators/combineAll.md) | Deprecated alias of `combineLatestAll`: collects the inner observables of a higher-order source until it completes, then combines their latest values. |
| [`combineLatest`](../operators/combineLatest.md) | Deprecated pipeable form of `combineLatestWith`: subscribes to the source and the other inputs, waits until each has emitted once, and then emits a tuple of latest values whenever any input emits. |
| [`combineLatestAll`](../operators/combineLatestAll.md) | Collects the inner observables emitted by a higher-order source until the source completes, then subscribes to all of them and emits a tuple of latest values whenever any inner emits, once every inner has emitted at least once. |
| [`combineLatestWith`](../operators/combineLatestWith.md) | Subscribes to the source and the supplied inputs, waits until every input has emitted at least once, and from then on emits a tuple of latest values each time any input emits. Completes when every input has completed. |
| [`concat`](../operators/concat.md) | Deprecated pipeable form of `concatWith`: forwards the source until it completes, then subscribes to each supplied input in turn. |
| [`concatAll`](../operators/concatAll.md) | Flattens a higher-order source by subscribing to one inner observable at a time; inners that arrive while another is active are queued and subscribed in order after it completes. |
| [`concatMap`](../operators/concatMap.md) | Projects each source value to an inner observable and subscribes to the inners one at a time in arrival order; projections made while an inner is active are queued (concurrency policy: queue). |
| [`concatMapTo`](../operators/concatMapTo.md) | Deprecated specialization of `concatMap` that maps every source value to the same inner observable, subscribing to it once per source value in sequence. |
| [`concatWith`](../operators/concatWith.md) | Forwards the source until it completes, then subscribes to each supplied input in turn, forwarding values in order; an error from any input propagates immediately. |
| [`connect`](../operators/connect.md) | Multicasts the source through a connector Subject, applies the selector to the shared observable, and subscribes the downstream subscriber to the selector output before connecting the source, so one source subscription feeds every branch inside the selector. |
| [`count`](../operators/count.md) | Counts the source values that satisfy the optional predicate (or all values) and emits the total as a single value when the source completes. |
| [`debounce`](../operators/debounce.md) | Starts a duration observable for each source value, discarding the previous pending value's duration; when the duration emits, the pending latest value is emitted. A pending value is still emitted when the source completes. |
| [`debounceTime`](../operators/debounceTime.md) | Emits a source value only after a quiet period of `dueTime` with no newer value; each new value replaces the pending value and restarts the silence window. A pending value is still emitted when the source completes. |
| [`defaultIfEmpty`](../operators/defaultIfEmpty.md) | Forwards source values unchanged; if the source completes without having emitted any value, emits the default value before completing. |
| [`delay`](../operators/delay.md) | Delays each source value by a fixed duration (or until an absolute date), delivering values in arrival order; completion waits until every pending value has been delivered, while errors propagate immediately. |
| [`delayWhen`](../operators/delayWhen.md) | Delays each source value until the duration observable created for that value emits, so values may be reordered; an optional subscription delay observable defers the source subscription itself. |
| [`dematerialize`](../operators/dematerialize.md) | Converts a source of `ObservableNotification` objects back into the notifications they describe, emitting `next` values and terminating on an `error` or `complete` notification. |
| [`distinct`](../operators/distinct.md) | Forwards a source value only if its key (the value itself, or the result of the key selector) has not been seen before; an optional flushes observable clears the set of remembered keys. |
| [`distinctUntilChanged`](../operators/distinctUntilChanged.md) | Forwards a source value only when it differs from the previously forwarded value according to the comparator (default: strict equality), suppressing consecutive duplicates. |
| [`distinctUntilKeyChanged`](../operators/distinctUntilKeyChanged.md) | Specialization of `distinctUntilChanged` that compares consecutive values by the given property key, optionally with a custom comparator for that property. |
| [`elementAt`](../operators/elementAt.md) | Emits only the source value at the given zero-based index and then completes; if the source completes earlier, emits the default value or errors with `ArgumentOutOfRangeError`. |
| [`endWith`](../operators/endWith.md) | Forwards every source value and, when the source completes, emits the given values in order before completing. |
| [`every`](../operators/every.md) | Tests each source value against the predicate; emits `false` and completes as soon as a value fails, otherwise emits `true` when the source completes. |
| [`exhaust`](../operators/exhaust.md) | Deprecated alias of `exhaustAll`: flattens a higher-order source by subscribing to an inner observable only while no inner is active, dropping inners that arrive meanwhile. |
| [`exhaustAll`](../operators/exhaustAll.md) | Flattens a higher-order source by subscribing to an inner observable only when no inner is active; inners that arrive while one is active are dropped (concurrency policy: ignore while busy). |
| [`exhaustMap`](../operators/exhaustMap.md) | Projects each source value to an inner observable but subscribes only when no inner is active; source values that arrive while an inner is active are dropped. |
| [`expand`](../operators/expand.md) | Emits each source value and projects it to an inner observable; every inner value is likewise emitted and fed back through the projection recursively, with active inners limited by the optional concurrency and excess values buffered. |
| [`filter`](../operators/filter.md) | Forwards only the source values for which the predicate returns true; completion and errors pass through unchanged. |
| [`finalize`](../operators/finalize.md) | Forwards every notification unchanged and runs the callback once when the subscription ends, whether by completion, error, or unsubscription. |
| [`find`](../operators/find.md) | Emits the first source value that satisfies the predicate and completes; if the source completes without a match, emits `undefined`. |
| [`findIndex`](../operators/findIndex.md) | Emits the zero-based index of the first source value that satisfies the predicate and completes; emits `-1` if the source completes without a match. |
| [`first`](../operators/first.md) | Emits the first source value (or the first one satisfying the predicate) and completes; if the source completes first, emits the default value or errors with `EmptyError`. |
| [`flatMap`](../operators/flatMap.md) | Deprecated alias of `mergeMap`: projects each source value to an inner observable and merges all inners concurrently. |
| [`groupBy`](../operators/groupBy.md) | Routes each source value into a `GroupedObservable` chosen by its key, emitting a new group downstream the first time a key is seen; an optional duration selector closes a group, and every group completes or errors with the source. |
| [`ignoreElements`](../operators/ignoreElements.md) | Drops every source value and forwards only the source's completion or error. |
| [`isEmpty`](../operators/isEmpty.md) | Emits `false` and completes as soon as the source emits a value; emits `true` if the source completes without emitting. |
| [`joinAllInternals`](../operators/joinAllInternals.md) | Internal helper behind `combineLatestAll` and `zipAll`: collects the inner observables of a higher-order source until the source completes, then applies the join function to them and forwards the joined observable's values through the optional projection. |
| [`last`](../operators/last.md) | Emits the last source value (or the last one satisfying the predicate) when the source completes; if no value qualifies, emits the default value or errors with `EmptyError`. |
| [`map`](../operators/map.md) | Applies the projection function to each source value, with its index, and forwards the result; completion and errors pass through unchanged. |
| [`mapTo`](../operators/mapTo.md) | Deprecated specialization of `map` that replaces every source value with the same constant. |
| [`materialize`](../operators/materialize.md) | Wraps each `next`, `error`, and `complete` notification from the source in an `ObservableNotification` object emitted as a value; after a terminal notification has been emitted as a value, the output completes normally. |
| [`max`](../operators/max.md) | Reduces the source to its largest value, using the optional comparer, and emits that single value when the source completes; an empty source completes without emitting. |
| [`merge`](../operators/merge.md) | Deprecated pipeable form of `mergeWith`: subscribes to the source and the supplied inputs concurrently and forwards values from all of them as they arrive. |
| [`mergeAll`](../operators/mergeAll.md) | Flattens a higher-order source by subscribing to inner observables as they arrive, up to the optional concurrency limit, with excess inners queued; completes when the source and every inner have completed. |
| [`mergeInternals`](../operators/mergeInternals.md) | Internal engine behind `mergeMap`, `mergeAll`, `mergeScan`, and `expand`: projects values, subscribes to inners up to the concurrency limit, queues the rest, and completes only when the outer source and every inner have completed. |
| [`mergeMap`](../operators/mergeMap.md) | Projects each source value to an inner observable and subscribes to the inners concurrently, up to the optional limit, interleaving their values as they arrive (concurrency policy: allow overlap). |
| [`mergeMapTo`](../operators/mergeMapTo.md) | Deprecated specialization of `mergeMap` that maps every source value to the same inner observable and merges the resulting subscriptions concurrently. |
| [`mergeScan`](../operators/mergeScan.md) | Projects each source value together with the current accumulator to an inner observable; every inner value replaces the accumulator and is emitted, and inners are merged up to the concurrency limit. |
| [`mergeWith`](../operators/mergeWith.md) | Subscribes to the source and the supplied inputs concurrently and forwards values from all of them as they arrive; completes when every input has completed and errors as soon as any input errors. |
| [`min`](../operators/min.md) | Reduces the source to its smallest value, using the optional comparer, and emits that single value when the source completes; an empty source completes without emitting. |
| [`multicast`](../operators/multicast.md) | Deprecated: shares one source subscription through a Subject or Subject factory; without a selector it returns a `ConnectableObservable` that subscribes to the source only when connected, with a selector it connects as soon as the selector output is subscribed. |
| [`observeOn`](../operators/observeOn.md) | Reschedules the delivery of every source notification onto the given scheduler, optionally after a delay, without changing when or how the source produces them. |
| [`onErrorResumeNextWith`](../operators/onErrorResumeNextWith.md) | Forwards the source and, whenever the active source errors or completes, moves on to the next supplied input; errors are swallowed, and the output completes only after the last input terminates. |
| [`pairwise`](../operators/pairwise.md) | Emits each source value together with its predecessor as a two-element array, starting from the second source value. |
| [`partition`](../operators/partition.md) | Deprecated pipeable form: splits the source into two observables, one forwarding the values that satisfy the predicate and one forwarding those that do not; each output holds its own source subscription. |
| [`pluck`](../operators/pluck.md) | Deprecated: maps each source value to the nested property found by walking the given key path, emitting `undefined` when the path cannot be resolved. |
| [`publish`](../operators/publish.md) | Deprecated wrapper around `multicast` with a plain `Subject`: returns a `ConnectableObservable` that subscribes to the source only when connected, or applies a selector over the shared source. |
| [`publishBehavior`](../operators/publishBehavior.md) | Deprecated: multicasts the source through a `BehaviorSubject` seeded with the initial value, so each subscriber immediately receives the current value and then live values once connected. |
| [`publishLast`](../operators/publishLast.md) | Deprecated: multicasts the source through an `AsyncSubject`, so every subscriber receives only the final source value, delivered when the source completes. |
| [`publishReplay`](../operators/publishReplay.md) | Deprecated: multicasts the source through a `ReplaySubject` with the given buffer size and window time, replaying buffered values to late subscribers. |
| [`race`](../operators/race.md) | Deprecated pipeable form of `raceWith`: subscribes to the source and the supplied competitors and mirrors the first one to emit, unsubscribing the others. |
| [`raceWith`](../operators/raceWith.md) | Subscribes to the source and the supplied competitors in order; the first to emit a value wins and its remaining notifications are forwarded, while every other competitor is unsubscribed. |
| [`reduce`](../operators/reduce.md) | Applies the accumulator to each source value, starting from the optional seed, and emits only the final accumulated value when the source completes; without a seed, an empty source completes without emitting. |
| [`refCount`](../operators/refCount.md) | Connects a `ConnectableObservable` when its first subscriber arrives and disconnects it when the subscriber count drops to zero, so the shared source is active only while subscribers exist. |
| [`repeat`](../operators/repeat.md) | Resubscribes to the source each time it completes, up to the given count and optionally after a delay given as a duration or as a notifier factory; errors are forwarded immediately and are never repeated. |
| [`repeatWhen`](../operators/repeatWhen.md) | Resubscribes to the source whenever the notifier observable, built from a subject that receives each completion, emits; completes when the notifier completes and errors when the source or notifier errors. |
| [`retry`](../operators/retry.md) | Resubscribes to the source when it errors, up to the given count and optionally after a delay; once the budget is exhausted the error is forwarded, and `resetOnSuccess` restarts the budget after a value. Completion is never retried. |
| [`retryWhen`](../operators/retryWhen.md) | Resubscribes to the source whenever the notifier observable, built from a subject that receives each error, emits; completes when the notifier completes and errors when the notifier errors. |
| [`sample`](../operators/sample.md) | Keeps the latest source value pending and emits it each time the notifier emits, provided a new value has arrived since the last sample; a pending value is discarded when the source completes. |
| [`sampleTime`](../operators/sampleTime.md) | Emits the latest source value at each tick of a fixed interval, but only if a new value arrived since the previous tick; a pending value is discarded when the source completes. |
| [`scan`](../operators/scan.md) | Applies the accumulator to each source value and emits every intermediate accumulated value; with a seed the first emission is the accumulator applied to the seed and the first value, otherwise the first value itself is emitted as the initial accumulator. |
| [`scanInternals`](../operators/scanInternals.md) | Internal helper behind `scan` and `reduce`: maintains the accumulator and the seed state, and either emits after every step or only the final value on completion, depending on how it is configured. |
| [`sequenceEqual`](../operators/sequenceEqual.md) | Compares the source with another observable value by value using the optional comparator, queuing whichever side is ahead; emits `true` and completes if both sequences end with every pair equal, `false` on the first mismatch or length difference. |
| [`share`](../operators/share.md) | Multicasts the source through a connector Subject shared by all subscribers, connecting on the first subscriber and, by default, disconnecting when the last one leaves; the `resetOnError`, `resetOnComplete`, and `resetOnRefCountZero` options control when the connection is reset. |
| [`shareReplay`](../operators/shareReplay.md) | `share` configured with a `ReplaySubject` connector that replays the last `bufferSize` values to late subscribers; by default (`refCount: false`) the source connection is kept alive after the last subscriber leaves, and the buffer survives source completion. |
| [`single`](../operators/single.md) | Emits the one source value that satisfies the predicate (or the only value) when the source completes; errors with `SequenceError` if a second value matches, `NotFoundError` if values arrived but none matched, or `EmptyError` if the source was empty. |
| [`skip`](../operators/skip.md) | Drops the first `count` source values and forwards every later value unchanged. |
| [`skipLast`](../operators/skipLast.md) | Holds the last `count` source values in a buffer, forwarding each value only once `count` newer values have arrived; the held values are discarded when the source completes. |
| [`skipUntil`](../operators/skipUntil.md) | Drops source values until the notifier emits, then forwards every later value; the notifier is subscribed first and unsubscribed once it has opened the gate. Notifier completion alone never opens the gate. |
| [`skipWhile`](../operators/skipWhile.md) | Drops source values while the predicate holds; from the first value for which it returns false onward, every value is forwarded regardless of the predicate. |
| [`startWith`](../operators/startWith.md) | Emits the given prefix values synchronously (or on the given scheduler) on subscription, and only then subscribes to the source and forwards its values. |
| [`subscribeOn`](../operators/subscribeOn.md) | Defers the subscription to the source onto the given scheduler, optionally after a delay, so the source's subscription side effects run in that scheduler's context; notifications themselves are not rescheduled. |
| [`switchAll`](../operators/switchAll.md) | Flattens a higher-order source by subscribing to each new inner observable and unsubscribing the previously active inner, so only the latest inner's values are forwarded. |
| [`switchMap`](../operators/switchMap.md) | Projects each source value to an inner observable, subscribes to it, and unsubscribes the previously active inner, so only values from the latest inner are forwarded (concurrency policy: only latest). |
| [`switchMapTo`](../operators/switchMapTo.md) | Deprecated specialization of `switchMap` that maps every source value to the same inner observable, resubscribing to it and cancelling the previous subscription on each source value. |
| [`switchScan`](../operators/switchScan.md) | Projects each source value together with the current accumulator to an inner observable, unsubscribing the previously active inner; every value of the current inner replaces the accumulator and is emitted. |
| [`take`](../operators/take.md) | Forwards the first `count` source values and then completes, unsubscribing from the source; `take(0)` completes immediately without subscribing. |
| [`takeLast`](../operators/takeLast.md) | Holds the last `count` source values in a buffer and emits them in order when the source completes; `takeLast(0)` completes immediately without subscribing. |
| [`takeUntil`](../operators/takeUntil.md) | Forwards source values until the notifier emits, then completes and unsubscribes from the source; the notifier is subscribed first, and its completion alone does not stop the source. |
| [`takeWhile`](../operators/takeWhile.md) | Forwards source values while the predicate holds and completes at the first value that fails it; with `inclusive: true` that failing value is emitted before completing. |
| [`tap`](../operators/tap.md) | Runs the given side-effect callbacks for `next`, `error`, `complete`, `subscribe`, `unsubscribe`, and `finalize` without altering the forwarded notifications. |
| [`throttle`](../operators/throttle.md) | Emits the leading source value and starts a duration observable from it, ignoring further values while the duration is active; with `trailing: true` the latest suppressed value is emitted when the duration ends. Defaults to leading only. |
| [`throttleTime`](../operators/throttleTime.md) | Time-based specialization of `throttle`: emits a source value, then suppresses values for the given duration; with `trailing: true` the latest suppressed value is emitted when the timer fires. |
| [`throwIfEmpty`](../operators/throwIfEmpty.md) | Forwards source values unchanged, but if the source completes without having emitted, errors with the result of the error factory (default `EmptyError`). |
| [`timeInterval`](../operators/timeInterval.md) | Emits each source value wrapped in a `TimeInterval` object that records the time elapsed since the previous emission (or since subscription), measured with the given scheduler. |
| [`timeout`](../operators/timeout.md) | Errors with `TimeoutError`, or switches to the fallback observable given by `with`, if the first value does not arrive within `first`, or if any later value does not arrive within `each` of the previous one. |
| [`timeoutWith`](../operators/timeoutWith.md) | Deprecated wrapper around `timeout`: switches to the given fallback observable when the source does not emit within the due time, forwarding the fallback's notifications. |
| [`timestamp`](../operators/timestamp.md) | Emits each source value wrapped in an object that pairs it with the current time as reported by the given timestamp provider. |
| [`toArray`](../operators/toArray.md) | Collects every source value into an array and emits that array (empty if no values arrived) as a single value when the source completes. |
| [`window`](../operators/window.md) | Splits the source into consecutive non-overlapping windows, each a `Subject`-backed observable that receives source values until the boundary notifier emits, at which point the window completes and a new one is emitted. |
| [`windowCount`](../operators/windowCount.md) | Splits the source into windows of `windowSize` values; with a `startWindowEvery` offset a new window opens every that many values, so windows may overlap. Open windows complete with the source. |
| [`windowTime`](../operators/windowTime.md) | Splits the source into windows that close after a fixed time span; an optional creation interval opens overlapping windows and an optional maximum size closes a window early. Open windows complete with the source. |
| [`windowToggle`](../operators/windowToggle.md) | Opens a new window each time the openings observable emits and completes it when the closing notifier derived from that opening value emits or completes; windows may overlap, and open windows complete with the source. |
| [`windowWhen`](../operators/windowWhen.md) | Splits the source into consecutive windows whose lifetime is governed by a closing notifier obtained from the closing selector; when it emits or completes, the current window completes and a new window with a new closing notifier is started. |
| [`withLatestFrom`](../operators/withLatestFrom.md) | Subscribes to the secondary inputs first and, for each source value, emits a tuple of the source value and the latest value of every secondary; source values are dropped until every secondary has emitted. Only the source triggers output. |
| [`zip`](../operators/zip.md) | Deprecated pipeable form of `zipWith`: queues values from the source and the supplied inputs and emits a tuple each time every input has an unconsumed value. |
| [`zipAll`](../operators/zipAll.md) | Collects the inner observables of a higher-order source until it completes, then zips them: values are queued per inner and a tuple is emitted whenever every inner has an unconsumed value. |
| [`zipWith`](../operators/zipWith.md) | Queues values from the source and the supplied inputs and emits a tuple each time every input has at least one unconsumed value; completes as soon as any input completes with an empty queue. |

---

## Coverage

This catalog contains **116 operator modules**, matching the source catalog used for the conversion. `npm run validate` checks that every operator in `spec/operators.json` has a file under `operators/` with the same rules, and that this index lists each of them with the summary from its file.
