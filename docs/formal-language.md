# Formal language layer

## Purpose

`rxjs-bdd` now distinguishes three levels:

1. **Readable BDD** — unrestricted prose intended for people.
2. **Convertible BDD** — a deliberately small context-free language with explicit syntax.
3. **Mealy DSL** — a machine-oriented context-free language that makes state, input, transition, and Action Policy explicit.

The formal layer exists to reduce interpretation. A parser or LLM should not have to infer whether a sentence describes a guard, an event, a state update, or an observable output.

## Grammar model

Each language is specified as a phrase-structure grammar:

```text
G = (N, T, P, S)
```

where:

- `N` is the finite set of non-terminals;
- `T` is the finite set of terminals;
- `N ∩ T = ∅`;
- `P` is the finite set of production rules;
- `S ∈ N` is the start symbol.

The concrete grammars are written in EBNF:

- `spec/convertible-bdd.ebnf`
- `spec/mealy.ebnf`

Both are intended to remain context-free. Context-sensitive constraints belong to semantic analysis, not to the grammar. `Feature:` and `Scenario:` may be followed by a single space before the identifier, as in the examples below.

The complete operator catalog has been converted into Convertible BDD: `spec/convertible/<operator>.feature`, with `spec/convertible/trace.json` linking every scenario to the readable rules it realises. `scripts/convertible-bdd.mjs` parses the language and applies the declaration-free subset of the semantic constraints listed below. The vocabulary conventions are documented in `docs/convertible-catalog.md`.

`scripts/mealy.mjs` parses the Mealy DSL and, because that language has a declaration section, applies the declaration-aware constraints (symbol resolution and arity, constraints 1 to 4) that the Convertible BDD layer cannot. It also projects a parsed machine onto the Machine Semantic Model and, in the other direction, generates Mealy text from a model. The sample in `samples/shopping-cart-checkout/` runs the whole pipeline on a business use case: its Mealy DSL is generated from the machine model and parses back to it, which is the round-trip property `parse(generate(M)) ≡ M` made concrete.

## Formal pipeline

```text
Readable BDD
    ↓ normalization / authoring
Convertible BDD ∈ L(G_BDD)
    ↓ parse
BDD AST
    ↓ semantic analysis
Machine Semantic Model
    ↓ machine analysis
M = (S, S₀, Σ, Γ, T, G)
    ↓
Mealy AST
    ↓ generate
Mealy DSL ∈ L(G_Mealy)
    ↓
RxJS generator
    ↓
RxJS pipeline
```

A direct text-to-text conversion is intentionally avoided. Both syntaxes map through the same semantic model.

## Why a restricted Convertible BDD language?

This is readable but not deterministically parseable:

```text
Given silence timer active
When source value arrives
Then replace pending value
     restart timer
     emit nothing
```

The phrases `silence timer active`, `replace pending value`, and `restart timer` are unrestricted English.

The convertible equivalent makes the roles explicit:

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

The grammar can now determine the syntactic category of every clause.

## BDD-to-machine mapping

```text
BDD                     Semantic role             Mealy role
──────────────────────  ────────────────────────  ───────────────────
Given <predicate>       guard over current state  state predicate
When <event>            input event               Σ
Then <assignment>       state update              T
And <assignment>        state update              T
Then/And emit <output>  observable action         G
Then/And complete       lifecycle output          G
Then/And error <expr>   lifecycle output          G
Then/And <call>         declared machine action   G / effect
```

The important split is that BDD `Then` is not one semantic category. Semantic analysis classifies each effect as either a state update or an Action Policy action.

## Machine semantic model

The semantic model is independent of either concrete syntax. Conceptually:

```text
MachineModel {
  name
  state declarations
  initial state
  input alphabet
  output alphabet
  action declarations
  transitions[]
}

Transition {
  name
  guard
  input
  updates[]
  actions[]
}
```

The classical Mealy projection is:

```text
T : S × Σ -> S
G : S × Σ -> Γ*
```

`Γ*` is used operationally because an RxJS transition may produce zero or more ordered actions, for example:

```text
emit pending.value
complete
```

For pure classical analysis, an ordered action list can be treated as one compound output symbol.

## Semantic constraints

These are deliberately outside the EBNF grammar and must be checked after parsing:

1. every referenced state path must resolve to a declared state member;
2. every input event must match a declared input symbol;
3. every emitted output must match a declared output symbol;
4. every machine action call must be declared;
5. every `Given` expression must type-check to Boolean;
6. a transition must contain exactly one input event;
7. assignments may update state but may not mutate input values;
8. transition names must be unique within a machine;
9. state and input declarations must be type-consistent;
10. lifecycle outputs (`complete`, `error`) terminate the observable side of the machine;
11. after a terminal lifecycle output, later observable emissions are invalid unless the model explicitly represents a new subscription;
12. ambiguity is an error: the converter must not silently guess between state update and output.

## Why this helps an LLM

The language creates hard structural boundaries around the reasoning task.

Instead of asking an LLM to infer an entire machine from prose, the system can ask smaller questions:

```text
Is this a valid predicate?
Which declared input event is this?
Is this Then-effect a state update or an Action Policy action?
Does every referenced symbol exist?
Are transition cases missing?
```

The parser validates syntax first. The semantic checker validates symbol use and machine invariants second. The LLM is then used where interpretation is actually useful: normalization, candidate generation, missing-case analysis, and explanation.

This changes the role of the model from:

```text
prose → guess a machine
```

to:

```text
structured syntax
      +
declared vocabulary
      +
semantic constraints
      ↓
constrained machine analysis
```

That makes generation more repeatable, reviewable, testable, and suitable for round-trip verification.

## Round-trip property

A core design target is:

```text
parse(generate(M)) ≡ M
```

for every valid semantic machine model `M`.

For Convertible BDD, the stronger target is semantic preservation rather than textual equality:

```text
analyze(parse(BDD)) ≡ analyze(parse(generateBDD(analyze(parse(BDD)))))
```

Whitespace, formatting, and harmless syntactic choices may differ; machine meaning must not.

## Example

Convertible BDD:

```gherkin
Feature: CashWithdrawal

Scenario: WithdrawalSucceeds
  Given account.balance >= amount
  When account.withdraw(amount)
  Then account.balance = account.balance - amount
  And emit cash.dispense(amount)

Scenario: WithdrawalRejected
  Given account.balance < amount
  When account.withdraw(amount)
  Then account.balance = account.balance
  And emit withdrawal.reject(InsufficientFunds)
```

Equivalent Mealy DSL:

```text
machine CashWithdrawal {
  state {
    account.balance: CHF;
  }

  input {
    account.withdraw(amount: CHF);
  }

  output {
    cash.dispense(amount: CHF);
    withdrawal.reject(reason: Reason);
  }

  transition WithdrawalSucceeds {
    given account.balance >= amount;
    when account.withdraw(amount);
    then account.balance = account.balance - amount;
    emit cash.dispense(amount);
  }

  transition WithdrawalRejected {
    given account.balance < amount;
    when account.withdraw(amount);
    then account.balance = account.balance;
    emit withdrawal.reject(InsufficientFunds);
  }
}
```

The two texts are different surface languages over the same machine semantics.
