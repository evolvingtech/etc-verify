# Timed sequential composition example

A minimum-viable demonstration of the `Timed` modality end-to-end. The example defines two timed contracts on natural numbers (`ingest` and `process`, with latencies of 3 and 5 milliseconds respectively), exhibits implementations of each, and uses the substrate's `sequential_sound` theorem (unchanged from the `Untimed` case) to derive that the function composition of those implementations satisfies the sequential composition of the contracts. It also shows that the composed contract's latency is the sum of the component latencies.

The time type is `Nat`, interpreted as milliseconds; the substrate is parameterized over an arbitrary user-supplied time type, and this example fixes one for concreteness.

## What this example demonstrates

- Constructing a `Contract (Timed Nat) _ _` value: explicit `assumes`, `guarantees`, `silences`, and `extra` fields. Under the `Timed Nat` modality, `extra` has type `TimedFields Nat` and is populated with `{ latency := <value> }`.
- The Path 4b extension promise in practice: the same `sequential_sound` theorem that derives composed-implementation proofs under `Untimed` derives them under `Timed Nat` with no substrate modification; the new modality plugs in via typeclass instances alone (`ModalData (Timed T)`, `ModalSequential (Timed T)`).
- Latency composition via the `ModalSequential (Timed T)` instance: the composed contract's `extra.latency` is the sum of the component latencies (`3 + 5 = 8` ms), closed by `rfl`.
- Reuse of the `⨾` operator notation across modalities: the operator is generic over the modality and dispatches via typeclass resolution.

## What this example does not demonstrate

- Richer timing data. v0.2.1 carries `latency` only; jitter, validity windows, and interval bounds are deliberately deferred.
- Non-trivial timing arithmetic. Latency here is a scalar `Nat` and combines by addition; a downstream package using real-valued or rational time would activate Mathlib in its own package and supply a richer `T`.
- Shared-resource timing. Time-indexed resource budgets (e.g. lunar power profiles, contact-window seconds) are a separate timed example, gated on v0.2.1 T2.
- Side conditions that fail (this composition is trivially compatible at the behavioral level and the timing data does not introduce a feasibility check at sequential composition).
- Cross-modality composition. Composing a `Timed Nat` contract with an `Untimed` contract in one term is out of scope for v0.2.1.

## Running

Open `Example.lean` in VSCode with the Lean 4 extension. The LSP will check the file; no red squiggles in the gutter means every definition type-checks and every proof closes.

Alternatively, from the repo root:

    lake env lean examples/timed-sequential/Example.lean

A clean exit means everything checked.
