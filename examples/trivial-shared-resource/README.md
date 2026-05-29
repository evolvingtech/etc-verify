# Trivial shared-resource composition example

A minimum-viable demonstration of the `sharedResource` operator end-to-end. The example defines two trivial contracts on natural numbers — `passThrough` and `increment` — packages each with a resource consumption value via `ResourceUser`, and composes them under a shared budget. The substrate's `sharedResource_sound` theorem then mechanically delivers a composed implementation proof.

## What this example demonstrates

- Constructing an `UntimedContract` value (a `Contract` in the `Untimed` modality) with no preconditions. Under `Untimed`, `extra : Unit` and is populated with `()`.
- Packaging a contract with its resource consumption via `ResourceUser Untimed`.
- Composing two `ResourceUser Untimed` values under a shared budget via `sharedResource`.
- The architectural-level feasibility side condition (`budget_feasible` theorem): combined consumption ≤ available budget, surfaced as a checkable proposition distinct from per-component correctness.
- Applying `sharedResource_sound` to derive a composed-implementation proof from component proofs.

## What this example does not demonstrate

- Non-trivial contracts (real assumptions, complex guarantees).
- Resource types beyond `Nat` (e.g., real-valued power budgets, time-varying profiles).
- The full cross-domain story (PN1 sharing power with C1) — this requires substantive component contracts, which live in domain-specific repositories.
- The diagnostic display when feasibility fails (this requires interactive inspection in VSCode; try lowering the budget in `composed` and watching `composed_implemented` break).

## Running

Open `Example.lean` in VSCode with the Lean 4 extension. The LSP will check the file; no red squiggles in the gutter means every definition type-checks and every proof closes.

Alternatively, from the repo root:

    lake env lean examples/trivial-shared-resource/Example.lean

A clean exit means everything checked.

## Try it: see infeasibility surface

To see the architectural side condition fail diagnostically, change the budget from 10 to 5 in the definition of `composed`. The file's `composed` definition still type-checks (the composition exists as a type-level object), but `budget_feasible` fails — `decide` reduces `8 ≤ 5` to `False`. The substrate's architectural diagnostic is exactly this: infeasibility surfaces as a specific failing conjunct that's identifiable by name and located in the composed contract's assumption.