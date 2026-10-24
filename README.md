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
- every operator carries explicit completion, error, unsubscription, and cancellation rules
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

Each operator additionally carries lifecycle rules for the two terminal protocols:

```text
Completion rule
Given <state at the moment of completion>
When  <source / input / inner / notifier completes>
Then  <flush or drop pending state; complete now or defer completion>

Error rule
Given <state at the moment of the error>
When  <source / input / inner / notifier errors>
Then  <discard pending state; error, recover, or swallow>

Unsubscription rule
Given <state at the moment of teardown>
When  <downstream subscriber unsubscribes>
Then  <release source, inners, timers, notifiers, and pending state>

Cancellation rule
Given <active work>
When  <event that supersedes or ends that work>
Then  <cancel the superseded work, or cancel nothing>
```

In `spec/operators.json` these carry `kind: completion`, `kind: error`, `kind: unsubscription`, and `kind: cancellation`, so the *Source complete*, *Source error*, *Unsubscription*, and *Cancellation* rows of the transition coverage matrix can be read directly from the catalog.

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


## Formal language layer

The project now has an explicit formal-language boundary.

The two concrete languages are defined as context-free EBNF grammars:

- `spec/convertible-bdd.ebnf` — strict, parser-friendly Given / When / Then syntax;
- `spec/mealy.ebnf` — machine-oriented Mealy DSL;
- `spec/machine-semantic-model.schema.json` — syntax-independent semantic model shared by both languages;
- `docs/formal-language.md` — grammar model, semantic constraints, BDD-to-Mealy mapping, LLM guidance, and round-trip goals.

Formally:

```text
G_BDD   = (N_BDD,   T_BDD,   P_BDD,   S_BDD)
G_Mealy = (N_Mealy, T_Mealy, P_Mealy, S_Mealy)
```

with `N ∩ T = ∅` and each start symbol belonging to its language's non-terminal set.

The architecture is:

```text
Readable BDD
    ↓ normalization
Convertible BDD ∈ L(G_BDD)
    ↓ parser
BDD AST
    ↓ semantic analysis
Machine Semantic Model
    ↓ machine analysis
M = (S, S₀, Σ, Γ, T, G)
    ↓
Mealy DSL ∈ L(G_Mealy)
    ↓
RxJS generator
    ↓
RxJS pipeline
```

The key design rule is that the converter does **not** perform unconstrained prose-to-code translation. Grammar validation establishes syntactic structure first; semantic validation establishes symbol and machine correctness second; an LLM can then assist with normalization, candidate generation, missing-transition analysis, and explanation inside those constraints.

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


## Machine-readable specification

The complete 116-operator catalog is also available as structured data:

- `spec/operators.json` — machine-readable Given / When / Then rules.
- `spec/operator-catalog.schema.json` — JSON Schema for structural validation.
- `spec/convertible-bdd.ebnf` — formal Convertible BDD grammar.
- `spec/mealy.ebnf` — formal Mealy DSL grammar.
- `spec/machine-semantic-model.schema.json` — shared syntax-independent machine model.
- `docs/machine-readable-spec.md` — semantics and validation invariants.
- `docs/formal-language.md` — formal-language architecture and semantic constraints.

## From specification to testing

The repository now includes a direct testing bridge:

- `docs/testing.md` — maps Given / When / Then rules to RxJS TestScheduler and model-based tests.
- `docs/transition-coverage-matrix.md` — defines the transition categories that a state-complete operator test suite should consider.

The intended progression is:

```text
operator behavior
      ↓
Given / When / Then rules
      ↓
machine-readable specification
      ↓
transition coverage matrix
      ↓
RxJS conformance tests
```
