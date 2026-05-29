# Trivial sequential composition example

A minimum-viable demonstration of the ETC Verify substrate end-to-end. The example defines two trivial contracts on natural numbers — `addOne` and `double` — exhibits implementations of each, and uses the substrate's `sequential_sound` theorem to derive that the function composition of those implementations satisfies the sequential composition of the contracts.

## What this example demonstrates

- Constructing an `UntimedContract` value (a `Contract` in the `Untimed` modality): explicit `assumes`, `guarantees`, `silences`, and `extra` fields. Under the `Untimed` modality, `extra : Unit` and is populated with `()`.
- Proving that a function implements a contract via the `Implements` relation.
- Composing contracts with the `⨾` operator (`sequential`).
- Applying the `sequential_sound` theorem to derive a composed-implementation proof from component proofs without writing a new proof by hand.

## What this example does not demonstrate

- Non-trivial contracts (assumptions, real guarantees beyond equality).
- Side conditions that fail (this composition is trivially compatible).
- Silences as typed data (both contracts have empty silence lists).
- Cross-domain composition or shared resources.

Those each have their own examples (forthcoming) as the substrate grows.

## Running

Open `Example.lean` in VSCode with the Lean 4 extension. The LSP will check the file; no red squiggles in the gutter means every definition type-checks and every proof closes.

Alternatively, from the repo root:

    lake env lean examples/trivial-sequential/Example.lean

A clean exit means everything checked.