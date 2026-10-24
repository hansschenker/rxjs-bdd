# rxjs-bdd — Project Explanations

This document explains what the `rxjs-bdd` repository is, how its parts fit together, and
where the project currently stands. It is written for someone who knows RxJS but has not
read the rest of the repository yet.

---

## 1. What the project is in one paragraph

`rxjs-bdd` is a **behavioral specification of RxJS 7.x operators**. Every operator is
described as a small state machine, and every state-machine transition is written as a
readable **Given / When / Then** rule. The repository contains the human-readable catalog
of those rules for all 116 operator modules, a machine-readable JSON mirror of the same
catalog, two formal EBNF grammars (a strict BDD syntax and a Mealy-machine DSL), a shared
JSON Schema for the semantic machine model that both grammars map onto, and documents
that explain how to turn the rules into state-complete RxJS tests. It is a specification
and teaching project: there is no runtime library, parser, or test suite in the repository
yet.

---

## 2. The core idea

### 2.1 An operator is a machine reacting to events over time

An RxJS operator such as `debounceTime` does not just map values. It holds internal state
(a pending value, a running timer), reacts to several kinds of events (source values, timer
expiry, completion, error, unsubscription), changes that state, and produces output
(emissions, completion, error). That is exactly the shape of a **Mealy machine**:

```text
(State, Event) -> (Next State, Output)
```

or, written as two functions:

```text
T : S × Σ -> S     transition function
G : S × Σ -> O     output function
```

### 2.2 Given / When / Then is the readable form of a transition rule

The project borrows the Given / When / Then shape from Behavior-Driven Development, but
uses it to express **operator semantics**, not just test scenarios:

```text
Given <current state / state predicate>      -> S
When  <input event>                          -> E  (element of Σ)
Then  <next state / transition>              -> S' (via T)
      <Action Policy / output>               -> O  (via G)
```

So one rule

```text
Given silence timer active
When  source value arrives
Then  replace pending value
      restart timer
      emit nothing
```

is the readable spelling of `(silence-timer-active, source-value) -> (pending-replaced + timer-restarted, no-emission)`.

Two further conventions:

- **Compound predicates** are allowed. `Given A` followed by `And B` means the rule applies
  in the state region `A ∧ B`.
- **Multiple rules per operator are expected.** The complete set of rules for an operator is
  its transition specification, not a single example.

### 2.3 Where the idea comes from

The project extends the author's companion repository
[rxjs-operators-state-and-policy-patterns](https://github.com/hansschenker/rxjs-operators-state-and-policy-patterns),
which describes each RxJS operator with a compact **While–Then / When–Then** summary:

```text
while <state/condition> then <state-maintenance policy>
when  <trigger/event>   then <Action Policy>
```

The two notations are complementary. While/When gives a short behavioral summary;
Given/When/Then expands it into explicit transitions. The intended teaching progression is:

```text
While / When behavioral summary
          ↓
Given / When / Then transition rules
          ↓
(State, Event) -> (Next State, Output)
          ↓
T : S × Σ -> S,  G : S × Σ -> O
          ↓
RxJS implementation and tests
```

---

## 3. Repository layout

| Path | What it is |
|---|---|
| `README.md` | Overview, motivation, the `debounceTime` worked example, goals, attribution. |
| `CONTRIBUTORS.md` | Credits the author and the AI model that assisted with the initial formalization. |
| `docs/given-when-then-pattern.md` | Short reference for the canonical rule form, compound predicates, and the testing interpretation. |
| `docs/operators.md` | The human-readable **catalog**: Given / When / Then rules for all 116 RxJS 7.x operator modules. |
| `docs/machine-readable-spec.md` | Explains the JSON mirror of the catalog, its validation invariants, and the contract for LLM-assisted conversion. |
| `docs/formal-language.md` | The formal-language architecture: the three language levels, grammar model, BDD-to-Mealy mapping, semantic constraints, round-trip property. |
| `docs/testing.md` | How a rule becomes a test: marble tests, pure transition-model tests, and conformance tests. |
| `docs/transition-coverage-matrix.md` | The twelve transition categories a state-complete operator test suite should consider. |
| `spec/operators.json` | Machine-readable catalog (version `0.4.0`), one entry per operator with `rules[]` and an optional `note`. |
| `spec/operator-catalog.schema.json` | JSON Schema (draft 2020-12) that structurally validates `operators.json`. |
| `spec/convertible-bdd.ebnf` | EBNF grammar for **Convertible BDD**, the strict, parser-friendly Given / When / Then syntax. |
| `spec/mealy.ebnf` | EBNF grammar for the **Mealy DSL**, the machine-oriented target language. |
| `spec/machine-semantic-model.schema.json` | JSON Schema for the syntax-independent **Machine Semantic Model** that both grammars map onto. |

There is no `package.json`, no source code, and no test runner. Everything is Markdown,
EBNF, and JSON.

---

## 4. The operator catalog

### 4.1 Scope and shape

`docs/operators.md` and `spec/operators.json` cover the same **116 operator modules**,
matching the source catalog in the companion repository. The list follows RxJS 7.x source
modules rather than only the public API, so it includes:

- the mainstream operators (`map`, `filter`, `switchMap`, `debounceTime`, `combineLatest`, ...);
- deprecated pipeable forms kept for completeness (`flatMap`, `mapTo`, `pluck`, `publish`,
  `publishBehavior`, `publishLast`, `publishReplay`, `multicast`, `refCount`, `combineAll`,
  `exhaust`, `timeoutWith`, ...);
- internal helper modules that are not user-facing operators (`mergeInternals`,
  `joinAllInternals`, `scanInternals`).

### 4.2 Seven kinds of rule per operator

Every operator in the catalog has at least one rule of each of seven kinds, listed in lifecycle order:

| `kind` | Heading in `operators.md` | Meaning |
|---|---|---|
| `subscription` | Subscription rule(s) | The initial transition when a **downstream subscriber subscribes**: whether the source is subscribed immediately, deferred (`subscribeOn`, `delayWhen` with a subscription delay), or shared (`share`, `refCount`, `publish*`), the order in which notifiers and inputs are subscribed (`takeUntil` and `skipUntil` subscribe the notifier first, `withLatestFrom` subscribes the secondaries first), and the initial state. |
| `state` | State-conditioned rule | What happens to a value or event **while** a persistent state condition holds (for example, "buffer open", "duration active", "inner subscription active"). |
| `event` | Event-triggered rule | What Action Policy fires on a discrete **boundary** event (for example, "closing notifier emits", "duration ends", "every queue has at least one value"). |
| `completion` | Completion rule(s) | What happens to pending state and output when the source, an input, an inner Observable, or a notifier **completes**. Where the outcome depends on state (a pending value or none, a retry budget left or exhausted), each case is its own rule. |
| `error` | Error rule(s) | What is discarded, propagated, recovered, or swallowed when the source, an input, an inner Observable, or a notifier **errors**. |
| `unsubscription` | Unsubscription rule(s) | What is torn down when the **downstream subscriber unsubscribes**: the source, inner subscriptions, timers, notifiers, and pending state. For multicast operators, what happens when a subscriber detaches from the shared subject. |
| `cancellation` | Cancellation rule(s) | Which active work the operator **itself cancels** in response to an event (a superseded inner in `switchMap`, a restarted timer in `debounceTime`, losers in `race`, the source in `take`), or an explicit statement that it cancels nothing on its own. |

Rule counts in the current catalog:

| Kind | Rules |
|---|---|
| `subscription` | 127 |
| `state` | 116 |
| `event` | 116 |
| `completion` | 190 |
| `error` | 124 |
| `unsubscription` | 121 |
| `cancellation` | 124 |

Keeping `state` and `event` rules apart is a deliberate design rule. A persistent state such as
"duration active" and the event that *ends* that state ("duration ends") are mutually
exclusive, and collapsing them into one Given/When/Then would produce an invalid
transition. The separation prevents that mistake.

Example from the catalog (`audit`):

```text
Subscription rule
Given no subscription is active
When  a downstream subscriber subscribes
Then  subscribe to the source immediately
      start with no pending value and no active duration

State-conditioned rule
Given duration active
When  a source value arrives
Then  replace the pending value using the new source value

Event-triggered rule
Given the corresponding pending state exists
When  duration ends
Then  emit the pending latest value and return to idle

Completion rules
Given no pending value exists or no duration is active
When  the source completes
Then  complete immediately

Given a pending value exists and a duration is active
When  the source completes
Then  defer completion until the duration ends
      emit the pending latest value when the duration ends
      complete

Error rule
Given any state
When  the source or the active duration observable errors
Then  discard the pending value
      unsubscribe the active duration
      error immediately

Unsubscription rule
Given a duration may be active with a pending value
When  the downstream subscriber unsubscribes
Then  unsubscribe from the source
      unsubscribe the active duration
      discard the pending value without emitting it

Cancellation rules
Given a duration is active
When  a source value arrives
Then  cancel nothing
      the running duration continues; the new value only replaces the pending value

Given a duration is active
When  the duration observable emits
Then  unsubscribe the duration observable after its first emission

Note: The first source value starts the duration.
```

### 4.3 The JSON mirror

`spec/operators.json` holds the same information as structured data:

```json
{
  "operator": "audit",
  "rules": [
    { "kind": "state", "given": "duration active",
      "when": "a source value arrives",
      "then": ["replace the pending value using the new source value"] },
    { "kind": "event", "given": "the corresponding pending state exists",
      "when": "duration ends",
      "then": ["emit the pending latest value and return to idle"] }
  ],
  "note": "The first source value starts the duration."
}
```

`then` is an **ordered list**, because one transition may perform several steps
(replace pending value, restart timer, emit nothing). 49 of the 116 operators carry a
`note`; the rest have `note: null`.

`spec/operator-catalog.schema.json` enforces the structural invariants listed in
`docs/machine-readable-spec.md`: non-empty operator name, at least one rule, non-empty
`given` and `when`, at least one `then` statement, and `kind` restricted to `state` or
`event`. The docs are explicit that this proves **structure, not semantic completeness**.
Whether all meaningful source, timer, notifier, inner, completion, error, and teardown
transitions are present is still a human review question.

---

## 5. The formal language layer

The most recent work in the repository (commits from 2026-10-24) adds a formal boundary
between prose and machines. It introduces **three levels of language**:

| Level | Nature | Audience | Where |
|---|---|---|---|
| Readable BDD | Unrestricted English in Given / When / Then shape | People | `docs/operators.md`, README |
| Convertible BDD | Small context-free language; every clause has an unambiguous syntactic role | Parser (and people) | `spec/convertible-bdd.ebnf` |
| Mealy DSL | Machine-oriented context-free language with explicit `state`, `input`, `output`, `action`, and `transition` blocks | Generators / analysis | `spec/mealy.ebnf` |

### 5.1 Why a restricted "Convertible" BDD?

The readable rule

```text
Given silence timer active
When  source value arrives
Then  replace pending value
```

is clear to a human but not deterministically parseable: `silence timer active` and
`replace pending value` are free prose. The convertible form makes every role explicit:

```gherkin
Feature: DebounceTime

Scenario: ReplacePendingValue
  Given timer.active == true
  And pending.exists == true
  When source.next(value)
  Then pending.value = value
  And timer.restart()
  And emit nothing
```

Now a grammar can decide that `timer.active == true` is a predicate, `source.next(value)`
is an event, `pending.value = value` is a state assignment, `timer.restart()` is an action
call, and `emit nothing` is an output.

### 5.2 Grammar model

Each language is a phrase-structure grammar `G = (N, T, P, S)` with non-terminals `N`,
terminals `T`, `N ∩ T = ∅`, productions `P`, and start symbol `S ∈ N`. Both grammars are
deliberately **context-free**; anything context-sensitive (does this symbol exist? does
this predicate type-check?) is pushed to a separate semantic-analysis phase.

The two EBNF files share most of their lower-level productions (`Predicate`, `Expression`,
`Event`, `Assignment`, `StatePath`, `Literal`, ...). They differ at the top:

- **Convertible BDD** (start symbol `Document`): `Feature:` containing `Scenario:` blocks.
  Each scenario has one `Given` (with optional `And` predicates), exactly one `When`, one
  `Then` effect, and any number of `And` effect continuations. An `Effect` is an
  assignment, `emit ...`, an action call, `complete`, `error <expr>`, or `nothing`.
- **Mealy DSL** (start symbol `Machine`): `machine Name { ... }` with declaration blocks
  (`state`, `initial`, `input`, `output`, `action`) and `transition Name { given ...; when ...; then ...; emit ...; do ...; }`
  blocks. Here state updates (`then`), observable outputs (`emit` / `complete` / `error`),
  and side-effect actions (`do`) are syntactically distinct statements.

### 5.3 BDD-to-machine mapping

The key insight is that a BDD `Then` is **not one semantic category**. Semantic analysis
splits each `Then`/`And` effect into either a state update (part of `T`) or an output /
Action Policy (part of `G`):

```text
BDD                     Semantic role             Mealy role
Given <predicate>       guard over current state  state predicate
When <event>            input event               Σ
Then/And <assignment>   state update              T
Then/And emit <output>  observable action         G
Then/And complete       lifecycle output          G
Then/And error <expr>   lifecycle output          G
Then/And <call>         declared machine action   G / effect
```

### 5.4 The Machine Semantic Model

`spec/machine-semantic-model.schema.json` (version `0.1`) defines a syntax-independent
model that both concrete languages map onto:

```text
MachineModel { machine, state[], initial[], inputs[], outputs[], actions[], transitions[] }
Transition   { name, guard, input, updates[], actions[] }
Action       = emit <event> | complete | error <expr> | do <call> | nothing
```

The classical projection is `T : S × Σ -> S` and `G : S × Σ -> Γ*`. The output is `Γ*`
(a sequence) rather than a single symbol because one RxJS transition can produce several
ordered actions, such as "emit pending value" followed by "complete". For pure classical
analysis the ordered list can be treated as a single compound output symbol.

### 5.5 Semantic constraints (checked after parsing)

`docs/formal-language.md` lists twelve constraints that live outside the grammar, including:
every referenced state path, input event, output, and action must be declared; every
`Given` must type-check to Boolean; a transition has exactly one input event; assignments
may update state but never mutate input values; transition names are unique; lifecycle
outputs (`complete`, `error`) terminate the observable side; emissions after a terminal
output are invalid unless a new subscription is modelled explicitly; and **ambiguity is an
error**, never silently resolved.

### 5.6 The pipeline and the round-trip goal

```text
Readable BDD
    ↓ normalization / authoring
Convertible BDD ∈ L(G_BDD)
    ↓ parser
BDD AST
    ↓ semantic analysis
Machine Semantic Model
    ↓ machine analysis
M = (S, S₀, Σ, Γ, T, G)
    ↓ generate
Mealy DSL ∈ L(G_Mealy)
    ↓ RxJS generator
RxJS pipeline
```

Direct text-to-text conversion between the two syntaxes is intentionally avoided; both go
through the shared semantic model. The design target is a **round trip**:
`parse(generate(M)) ≡ M` for every valid machine `M`, and for Convertible BDD the weaker
but sufficient property that semantic meaning survives a parse → generate → parse cycle
even if whitespace and harmless syntactic choices differ.

### 5.7 The intended role of an LLM

The project explicitly positions LLMs as **constrained assistants, not the source of
truth**. Instead of "prose → guess a machine", the system asks small, checkable questions:
is this a valid predicate, which declared input does this match, is this effect a state
update or an output, are transition cases missing? The deterministic parser validates
syntax, the semantic checker validates symbols and machine invariants, and the LLM is used
for normalization, candidate generation, missing-case analysis, and explanation inside
those constraints. Free-form model output must always be re-validated.

---

## 6. From specification to testing

`docs/testing.md` turns the notation into a testing method. A rule maps directly to
Arrange / Act / Assert:

```text
Given S      ->  Arrange the machine in state S
When  E      ->  Act by delivering event E
Then  S', O  ->  Assert next state S' and observable output O
```

Three test layers are described:

1. **Observable behavior test** — `TestScheduler` marble tests asserting emissions,
   completion, errors, and subscription timing.
2. **Transition-model test** — test the pure machine rule directly, modelled as
   `(state, event) => { state, output[] }`.
3. **Conformance test** — feed the same event trace into the pure model and the real RxJS
   operator and compare outputs and termination. This makes the BDD rule an *executable
   semantic oracle*, which the docs call the strongest use of the repository.

`docs/transition-coverage-matrix.md` lists twelve coverage categories that go beyond
ordinary value marbles: source next / complete / error, timer or scheduler event, notifier
event, inner next / complete / error, subscription, unsubscription, concurrency admission,
and cancellation. The coverage criterion is that every meaningful rule has at least one
corresponding test, moving operator testing from **example coverage** toward
**state-transition coverage**.

---

## 7. Worked example: `debounceTime`

The README's canonical example shows the full progression. Behavioral summary (While/When):

```text
while silence timer active
then  replace pending value and restart the timer on each source value

when  configured silence interval elapses
then  emit the pending latest value

when  source completes
then  emit the pending latest value if present and complete

when  source errors
then  discard the pending value and error immediately
```

Expanded transition rules (Given/When/Then):

```text
Given silence timer active        Given pending value exists
When  source value arrives        When  silence interval elapses
Then  replace pending value       Then  emit pending latest value
      restart timer                     clear pending value
      emit nothing

Given pending value exists        Given any state
When  source completes            When  source errors
Then  emit pending latest value   Then  discard pending value
      clear pending value               error immediately
      complete
```

Marble test ideas from `docs/testing.md`: a second value arriving within the window produces
no output and restarts the deadline; a lone value is emitted after the configured interval.

---

## 8. Current state and gaps

The repository was created on 2026-10-23 and its latest commit is from 2026-10-24. The
commit history shows a clear progression: readable notation → full 116-operator catalog →
JSON mirror and schema → testing bridge and coverage matrix → formal grammars and semantic
model. Things worth knowing when working on it:

- **Specification only, no code.** The parser, semantic analyzer, Mealy generator, RxJS
  generator, and conformance tests described in the docs are design intent. None are
  implemented in this repository.
- **Every coverage-matrix row now maps to a rule kind**, but timer, notifier, inner-next,
  and concurrency-admission transitions are still folded into the `state` and `event` rules
  rather than carrying a kind of their own.
- **Some existing `event` rules overlap the new lifecycle rules.** Operators such as
  `count`, `toArray`, `last`, and `endWith` already had an event rule whose trigger is
  source completion. Those were left untouched; the dedicated `completion` rule restates the
  behaviour and splits it by state where the outcome differs.
- **Catalog rules are Readable BDD, not Convertible BDD.** The `given` / `when` / `then`
  strings in `operators.json` are free prose. Converting them to the strict grammar would
  be the next step toward the formal pipeline.
- **No validation has been run in-repo.** `operator-catalog.schema.json` exists, but there
  is no script or CI step that validates `operators.json` against it.
- **Some entries are generic placeholders.** 66 rules use the guard "the operator is
  active" and 12 use the event "the relevant input event occurs". These carry little
  operator-specific information and would need refinement before they are useful as test
  oracles.
- **Internal and deprecated modules are included** (see §4.1), because the list mirrors
  RxJS source modules rather than the documented public API.

---

## 9. How the pieces fit together

```text
 rxjs-operators-state-and-policy-patterns      (companion repo: While–Then / When–Then)
                    │
                    ▼  converted
 docs/operators.md ◄──────────────► spec/operators.json ── validated by ── spec/operator-catalog.schema.json
 (Readable BDD, 116 operators)      (same content as data)
                    │
                    │  normalization (future, LLM-assisted, re-validated)
                    ▼
 spec/convertible-bdd.ebnf  ── parse ──► BDD AST ── analyze ──► spec/machine-semantic-model.schema.json
                                                                        │
                                                                        │  generate
                                                                        ▼
                                                              spec/mealy.ebnf  ── generate ──► RxJS code
                                                                        │
 docs/testing.md + docs/transition-coverage-matrix.md ─────────────────┴──► state-complete conformance tests
```

---

## 10. Glossary

| Term | Meaning in this project |
|---|---|
| **Action Policy** | The output side of a transition: what the operator emits or does when a rule fires (emit, complete, error, side-effect call). |
| **State-maintenance policy** | The `while ... then ...` part of the companion notation; what the operator keeps doing while a state holds. |
| **State-conditioned rule** (`kind: state`) | A rule describing behavior while a persistent state predicate holds. |
| **Event-triggered rule** (`kind: event`) | A rule describing the action taken on a discrete boundary or lifecycle event. |
| **Readable BDD** | Unrestricted Given / When / Then prose for people. |
| **Convertible BDD** | The strict, context-free Given / When / Then language defined in `spec/convertible-bdd.ebnf`. |
| **Mealy DSL** | The machine-oriented language defined in `spec/mealy.ebnf`. |
| **Machine Semantic Model** | The syntax-independent machine representation (`spec/machine-semantic-model.schema.json`) shared by both languages. |
| **Mealy machine** | `M = (S, S₀, Σ, Γ, T, G)`: states, initial state, input alphabet, output alphabet, transition function, output function. |
| **Round-trip property** | `parse(generate(M)) ≡ M`; generating text from a model and parsing it back must preserve meaning. |
| **Transition coverage** | Test coverage measured over state/event combinations rather than over example traces. |
| **Conformance test** | Running the same event trace through the pure transition model and the real RxJS operator and comparing results. |
