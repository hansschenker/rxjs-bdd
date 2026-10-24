# The Convertible BDD catalog

The readable Given / When / Then catalog in `docs/operators.md` has been converted into the
strict **Convertible BDD** language defined by `spec/convertible-bdd.ebnf`. The result lives in
`spec/convertible/`:

| Path | What it is |
|---|---|
| `spec/convertible/<operator>.feature` | One `Feature` per operator (116 files). Every `Scenario` is one deterministic transition of the operator's state machine. |
| `spec/convertible/trace.json` | Maps every scenario back to the catalog rules it realises, so coverage of the readable catalog can be checked mechanically. |
| `scripts/convertible-bdd.mjs` | Recursive-descent parser for the grammar plus the declaration-free semantic checks listed below. Used by `npm run validate`. |

Every feature file parses under the grammar, passes the semantic checks, and realises every rule
of its operator in `spec/operators.json`. `npm run validate` enforces all three, locally and in CI.

## Why the conversion is not one scenario per catalog rule

The eleven rule kinds of the readable catalog are **coverage views**. For `take`, the state,
event, and cancellation rules all describe the same `(state, source value)` transition from
different rows of the transition coverage matrix. A Mealy machine needs exactly one transition
per guard and input event, so the converted catalog merges those views:

```text
Scenario: TakeFinalValue            <- realises catalog rules 3 (state), 4 (event), 8 (cancellation)
  Given subscription.active == true
  And taken + 1 == count
  When source.next(value)
  Then taken = taken + 1
  And emit value
  And complete
  And source.unsubscribe()
```

The mapping is therefore many-to-many and is kept outside the feature files, in `trace.json`:

```json
{ "version": "0.6.0", "operators": { "take": { "TakeFinalValue": [3, 4, 8], "…": [] } } }
```

The validator checks that every scenario has a trace entry, every traced index exists, and every
catalog rule of every operator is realised by at least one scenario. Conversely, a catalog rule
that bundles alternatives ("emit the trailing value when trailing is enabled, otherwise return to
idle") becomes several scenarios with disjoint guards, because a `Then` clause cannot branch.

## Vocabulary conventions

The grammar has no declaration section, so the vocabulary is a convention shared by all 116
features. The same name always means the same thing.

### Input events (`When`)

| Event | Meaning |
|---|---|
| `subscriber.subscribe()` / `subscriber.unsubscribe()` | The downstream subscriber subscribes or unsubscribes. |
| `source.next(value)` / `source.complete()` / `source.error(err)` | Source protocol. |
| `inner.next(value)` / `inner.complete()` / `inner.error(err)` | An inner observable (projected, configured, or flattened). Join operators add an `index` argument. |
| `input.next(value, index)` / `input.complete(index)` / `input.error(err, index)` | One of several inputs (`combineLatest`, `zip`, `merge`, `concat`, …). `competitor.*` in `race`, `secondary.*` in `withLatestFrom`, `compareTo.*` in `sequenceEqual`. |
| `notifier.*`, `duration.*`, `closing.*`, `openings.*`, `boundary.*`, `flushes.*`, `subscriptionDelay.*`, `resetNotifier.*`, `delayNotifier.*` | Secondary observables, named by role. |
| `timer.fire()`, `task.fire()`, `interval.tick()`, `creation.tick()`, `closeTimer.fire(index)`, `delayTimer.fire()` | Scheduled actions firing. |
| `scheduler.runNext(value)` / `runComplete()` / `runError(err)` / `run(subscribeSource)` | Scheduler-dispatched work (`observeOn`, `subscribeOn`). |
| `connection.connect()` | `connect()` called on a `ConnectableObservable`. |
| `replacement.*`, `fallback.*`, `selectorOutput.*`, `joined.*`, `group.*` | Observables the operator switches to or produces. |

### State paths (`Given`, assignments)

Booleans and counters describe the machine state: `subscription.active`, `source.completed`,
`pending.exists` / `pending.value`, `inner.active`, `active.count`, `queue.length`,
`buffers.count`, `windows.count`, `ready.count`, `gate.open`, `refCount`, `connected`,
`executing`, `soFar`, `winner.selected`, `collecting`, and so on. `subscription.active == true`
is the standard "live" guard; the terminal effects `complete` and `error` end the subscription
implicitly.

Configuration appears as plain identifiers (`concurrent`, `dueTime`, `count`, `bufferSize`,
`startBufferEvery`, `leading`, `trailing`, `seed`) or as shape paths when behaviour depends on
how the operator was configured (`defaultValue.configured == true`, `delay.kind == "number"`,
`resetOnError.kind == "immediate"`, `selector.configured == false`). `now` is the scheduler clock.

Guards are always comparisons and may reference the input event's arguments, so a guard such as
`predicate(value, index) == true` is a predicate over state and input together.

### Effects (`Then` / `And`)

| Form | Used for |
|---|---|
| `path = expression` | State update. |
| `emit expression` | One output value. `emit nothing` marks a transition that deliberately produces no output. |
| `complete` / `error expression` | Terminal protocol. Written before any teardown actions that follow. |
| `nothing` | A transition that changes nothing at all (for example a notifier completing that the operator ignores). |
| `object.action(args)` | A declared machine action: `source.subscribe()`, `inner.subscribe(project(value))`, `timer.start(dueTime)`, `queue.push(value)`, `subject.next(value)`, … |
| `output.emitEach(collection)` | Emitting every element of a collection as separate values (`bufferCount` on completion, `endWith`, `startWith`, `takeLast`). |

Collections such as buffers, windows, queues, and latest-value maps are modelled through helper
actions and query calls (`buffers.pushAll(value)`, `queues.othersNonEmpty(index) == true`,
`latest.has(index) == false`) rather than as primitive state, which keeps the scenarios
readable at the cost of leaving those helpers undeclared.

## Scenario naming

Scenario names are PascalCase identifiers describing the transition, unique within a feature:
`SubscribeSource`, `ReplacePendingValue`, `TaskFiresAtDeadline`, `CompleteWithPending`,
`LastSubscriberLeavesImmediateReset`. Operators built from the same template share names, which
makes families easy to compare side by side (`mergeMap` and `concatMap`, `audit` and `auditTime`).

## Semantic checks

Beyond the grammar, `scripts/convertible-bdd.mjs` enforces the constraints from
`docs/formal-language.md` that can be checked without type declarations:

1. scenario names are unique within a feature (constraint 8);
2. an event name is always used with the same number of arguments, and so is an action;
3. an assignment never targets an argument of the `When` event (constraint 7);
4. no `emit` follows `complete` or `error`, and there is at most one terminal effect (constraint 11);
5. `nothing` is never combined with other effects;
6. two scenarios never share the same event and the same guard text, which would make the
   machine non-deterministic.

The validator additionally checks that the feature name equals the operator name, that the set of
feature files equals the set of catalog operators, and that `trace.json` is complete and in range.

## Known limitations

- There are no declarations, so symbol resolution and typing (constraints 1 to 5 and 9) are not
  checked. Generating the Machine Semantic Model (`spec/machine-semantic-model.schema.json`) from
  the features is the natural next step and would make those checks possible.
- Synchronous subtleties are not expressed: `takeUntil` skipping the source when the notifier
  completes synchronously, or `race` stopping its subscriptions when a competitor emits during
  subscription.
- Subject-based operators (`publish*`, `multicast`, `share`, `refCount`) model a single
  representative subscriber plus counters; per-subscriber delivery is left to the subject.
- The readable catalog's generic `state` and `event` rules are often realised by the same scenario
  as a more specific kind; the trace records this rather than hiding it.

## Editing

The feature files are the source of truth for this layer. Edit them directly, keep `trace.json`
in step, and run `npm run validate`. The validator reports the file, scenario, line, and clause
of any grammar violation, semantic problem, or coverage gap.
