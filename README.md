# rxjs-bdd

A readable behavioral specification for RxJS operators using **Given / When / Then** rules grounded in explicit state-machine semantics.

This project extends the ideas developed in [rxjs-operators-state-and-policy-patterns](https://github.com/hansschenker/rxjs-operators-state-and-policy-patterns).

## Core idea

An RxJS operator can be described as a machine reacting to events over time:

```text
Given <current state / state predicate>
When  <input event>
Then  <next state / transition>
      <Action Policy / output>
```

This is the readable form of a Mealy-style transition rule:

```text
(State, Event) -> (Next State, Output)
```

or, separating transition and output:

```text
T : S × Σ -> S
G : S × Σ -> O
```

The correspondence is:

```text
Given  -> current state / state predicate
When   -> input event
Then   -> state transition + Action Policy
```

## Why Given / When / Then?

Given / When / Then is already familiar from Behavior-Driven Development (BDD), executable specifications, and testing DSLs. Here it is used as a compact language for **operator semantics**, not merely as a scenario-testing syntax.

BDD commonly describes an example:

```text
Given some precondition
When an event occurs
Then an outcome is expected
```

For RxJS operator analysis, the same shape can directly expose a state-machine rule:

```text
Given state S
When event E
Then next state S'
     output O
```

So:

```text
Given S
When E
Then S' + O
```

corresponds to:

```text
(S, E) -> (S', O)
```

## Relationship to While–Then / When–Then

The companion repository introduced:

```text
while <state/condition> then <state-maintenance policy>
when  <trigger/event> then <Action Policy>
```

The two notations serve complementary purposes:

- **While–Then / When–Then** gives a concise behavioral summary of an operator.
- **Given / When / Then** expands behavior into explicit transition rules.
- **Given** identifies the current state or state predicate.
- **When** identifies the event.
- **Then** states the transition and Action Policy.

A useful teaching progression is therefore:

```text
While / When behavioral summary
          ↓
Given / When / Then transition rules
          ↓
(State, Event) -> (Next State, Output)
          ↓
T : S × Σ -> S
G : S × Σ -> O
          ↓
RxJS implementation and tests
```

## Full RxJS 7.x operator catalog

The complete source catalog has now been converted to Given / When / Then form:

- **116 / 116 operator modules converted**
- see [docs/operators.md](docs/operators.md)
- source baseline: [rxjs-operators-state-and-policy-patterns](https://github.com/hansschenker/rxjs-operators-state-and-policy-patterns)

The catalog keeps two kinds of rules separate:

```text
State-conditioned rule
Given <state predicate>
When  <event relevant while that state holds>
Then  <state transition / maintenance>

Event-triggered rule
Given <required state>
When  <boundary / lifecycle / source / inner event>
Then  <Action Policy>
```

This separation is important: a persistent state condition and the event that exits that state must not accidentally be collapsed into one invalid transition.

## Canonical example: debounceTime

Behavioral summary:

```text
while silence timer active
then replace pending value and restart the timer on each source value

when configured silence interval elapses
then emit the pending latest value

when source completes
then emit the pending latest value if present and complete

when source errors
then discard the pending value and error immediately
```

Expanded transition rules:

```text
Given silence timer active
When source value arrives
Then replace pending value
     restart timer
     emit nothing

Given pending value exists
When silence interval elapses
Then emit pending latest value
     clear pending value

Given pending value exists
When source completes
Then emit pending latest value
     clear pending value
     complete

Given any state
When source errors
Then discard pending value
     error immediately
```

The first rule maps directly to:

```text
S  = silence timer active
E  = source value arrives
S' = pending value replaced + timer restarted
O  = no emission
```

## State predicates can be compound

`Given` is not limited to a single boolean condition:

```text
Given inner subscription active
And source not completed
When inner value arrives
Then emit inner value
```

This corresponds to a compound state predicate such as `A ∧ B`.

## Multiple rules are expected

An operator normally has several transitions:

```text
Given <state A>
When <event X>
Then ...

Given <state A>
When <event Y>
Then ...

Given <state B>
When <event X>
Then ...
```

Together, the rules form a readable transition specification rather than a single example.

## Goals

This repository is intended to support:

- teaching RxJS operator behavior;
- deriving transition tables;
- designing state-complete tests;
- comparing related operators;
- documenting lifecycle semantics such as completion and error;
- making state, event, transition, cancellation, concurrency, and output explicit;
- bridging readable BDD-style language with Mealy-machine analysis.

## Related project

See [hansschenker/rxjs-operators-state-and-policy-patterns](https://github.com/hansschenker/rxjs-operators-state-and-policy-patterns) for the RxJS 7.x While–Then / When–Then operator catalog.

## Contributors

- **hansschenker** — project author and direction.
- **OpenAI GPT-5.6 Sol** — assisted with the Given / When / Then formalization, its mapping to Mealy state-machine semantics, the `debounceTime` worked example, and the initial project documentation.

See [CONTRIBUTORS.md](CONTRIBUTORS.md).

## Attribution

RxJS is maintained by the ReactiveX/RxJS project. This repository is an independent behavioral-analysis and teaching project and is not an official RxJS repository.
