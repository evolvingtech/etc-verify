# Changelog

All notable changes to ETC Verify™ will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

The name "ETC Verify" is a trademark of Evolving Technologies Corporation (USPTO Serial No. 99842416, application pending).

## [0.2.1] — 2026-06-01

First non-trivial modality on the v0.2.0 Path 4b modal-parameterization layer: `Timed T`, carrying timing data, added entirely as a marker type plus typeclass instances. No operator definition or soundness theorem was edited; `Timed T` composes through the existing generic operators by typeclass synthesis alone. All six named soundness/refinement theorems remain axiom-free. Substrate stays Lean-core; no Mathlib import added.

### Added

- `ETCVerify.Timed` (`ETCVerify/Timed/Basic.lean`): marker type `Timed (T : Type)` for contracts carrying timing data over a user-supplied time type `T`.
- `ETCVerify.TimedFields`: auxiliary timing-data structure carried in the `extra` field under `Timed T`; one field in v0.2.1, `latency : T`.
- `ETCVerify.ModalData (Timed T)` instance: sets `Extra := TimedFields T`.
- `ETCVerify.ModalSequential (Timed T)` instance: composes `extra` by latency summation (`a.latency + b.latency`); requires `[Add T]`. End-to-end latency through a series chain is the sum of per-stage latencies.
- `ETCVerify.TimeIndexed` (`ETCVerify/Timed/TimeIndexed.lean`): time-indexed resource type `TimeIndexed (T R : Type) := T → R`, with pointwise `Add` and `LE` instances, for use as the resource parameter of shared-resource composition under `Timed`. The pointwise `LE` gives the instantaneous reading of feasibility (`∀ t, consumed t ≤ available t`).
- `ETCVerify.ModalSharedResource (Timed T)` instance: composes `extra` latency by `max`; requires `[Max T]`.
- Example `examples/timed-sequential/`: timed sequential composition over `Nat` milliseconds; `sequential_sound` serves `Timed` unchanged and latency sums to 8.
- Example `examples/timed-shared-resource/`: timed shared-resource composition with a pointwise time-indexed budget; composed latency is `max 3 7 = 7`.

### Changed

- Root aggregator (`ETCVerify.lean`): imports the new `ETCVerify/Timed/` modules.
- `docs/mathlib-integration.md` and `lakefile.toml`: Mathlib-trigger notes reconciled to the O-4 design. The user-supplied-time-type `Timed T` keeps the Mathlib trigger out of the substrate; it now arises downstream (a concrete real-valued or rational `T`/`R`) or at a future richer-than-latency timing increment (validity windows, interval reasoning), not in the v0.2.x Timed modality itself.

The pointwise resource shape and the `max` latency-combination rule are conservative engineering-judgment defaults: the most conservative Mathlib-free instantaneous reading of a shared budget, and the parallel-composition rule that a shared rail tracks the slower branch. Both are additive resource-type/instance choices, revisable later without re-architecture if a use case warrants.

## [0.2.0] — 2026-05-19

Architectural migration to Path 4b modal parameterization. The substrate's correctness surface (four named operators, six soundness/refinement theorems) is preserved under the `Untimed` modality, with the architecture now supporting third-party modality extensions via typeclass instances in downstream libraries — no substrate modification required.

### Added

- `ETCVerify.Untimed`: marker type for substrate contracts carrying no modality-specific data.
- `ETCVerify.ModalData`: typeclass exposing the modality-specific auxiliary data type (`Extra : Type`). Instance for `Untimed` sets `Extra := Unit`.
- `ETCVerify.UntimedContract`: type abbreviation for `Contract Untimed Input Output`; source-level continuity for substrate users and within-substrate examples.
- `ETCVerify.Operators.ModalSequential`: per-operator typeclass for sequential-composition modal dispatch. Instance for `Untimed` is trivial.
- `ETCVerify.Operators.ModalSharedResource`: per-operator typeclass for shared-resource-composition modal dispatch. Instance for `Untimed` is trivial.
- `ETCVerify/Diagram/` placeholder directory with README marking the bidirectional algebra–diagram roundtrip future work site (closes audit finding F-005).

### Changed

- `ETCVerify.Contract`: signature now `Contract (M : Type) [ModalData M] (Input Output : Type)`; gains an `extra : ModalData.Extra M` field. Pre-existing `assumes`, `guarantees`, `silences` fields unchanged.
- `ETCVerify.Implements`: signature parameterized over modality `M`; body unchanged (modality-blind).
- `ETCVerify.Operators.Sequential.sequential` (notation `⨾`): signature parameterized over modality with `[ModalSequential M]` constraint; body adds `extra` composition via `ModalSequential.composeExtra`.
- `ETCVerify.Operators.Sequential.sequential_sound`: signature parameterized over modality; proof body unchanged.
- `ETCVerify.Operators.SharedResource.ResourceUser`: wrapper signature now `ResourceUser (M : Type) [ModalData M] (R : Type) (Input Output : Type)`; internal field set preserved exactly (`contract`, `consumes`).
- `ETCVerify.Operators.SharedResource.sharedResource` (notation `⊕[·]`): signature parameterized over modality with `[ModalSharedResource M]` constraint; body adds `extra` composition via `ModalSharedResource.composeExtra`. Architectural feasibility side condition and `transient_response` silence preserved.
- `ETCVerify.Operators.SharedResource.sharedResource_sound`: signature parameterized over modality; proof body unchanged.
- `ETCVerify.Operators.Refinement.refinement` (notation `⊑`): signature parameterized over modality; body unchanged (modality-blind).
- `ETCVerify.Operators.Refinement.refinement_sound`: signature parameterized over modality; proof body unchanged.
- `ETCVerify.Operators.Refinement.refinement_refl`: signature parameterized over modality; proof body unchanged.
- `ETCVerify.Operators.Refinement.refinement_trans`: signature parameterized over modality; proof body unchanged.
- `ETCVerify.Operators.Conformance.conformance` (notation `⊨`): signature parameterized over modality; body unchanged (modality-blind).
- `ETCVerify.Operators.Conformance.conformance_sound`: signature parameterized over modality; proof body unchanged.
- Example files `examples/trivial-sequential/Example.lean` and `examples/trivial-shared-resource/Example.lean` migrated to the `UntimedContract` abbreviation; contract literals gain explicit `extra := ()` field; `ResourceUser` references gain explicit `Untimed` modality argument. Example READMEs updated to match.
- Namespace declaration style standardized to the nested form (`namespace ETCVerify` / `namespace Operators`) across all four operator source files (closes audit finding F-011).
- `CLAUDE.md` augmented with previously undocumented substrate conventions (Apache header per `.lean` file, operator naming convention, scoped notation discipline, examples-lowercase rule, comment-style discipline, no-tautological-lemmas rule) and a brief Path 4b architecture note (closes audit finding F-010).
- `README.md` and `CITATION.cff` cleaned up to remove forward-looking claims about infrastructure not present in the current substrate (closes audit finding F-009). `CITATION.cff` adds `version: 0.2.0`.

All six named soundness/refinement theorems (`sequential_sound`, `sharedResource_sound`, `refinement_sound`, `refinement_refl`, `refinement_trans`, `conformance_sound`) verified axiom-free under the new signatures. Substrate remains Lean-core-only; no Mathlib import added.

## [0.1.0] — 2026-05-18

### Added

- Repository scaffolding: README, LICENSE (Apache 2.0), CITATION.cff, CLAUDE.md.
- Directory structure for substrate modules (Core, Operators, Timed, Diagram), documentation, and examples.
- `ETCVerify.Core.Silence`: `SilenceTag` structure for typed enumeration of aspects deliberately left unspecified in a contract.
- `ETCVerify.Core.Contract`: foundational `Contract` type with `assumes`, `guarantees`, and `silences`.
- `ETCVerify.Core.Contract.Implements`: fundamental satisfaction relation between an implementation and a contract.
- `ETCVerify.Operators.Sequential.sequential` (notation `⨾`): sequential composition of contracts, with side condition exposing interface compatibility gaps.
- `ETCVerify.Operators.Sequential.sequential_sound`: soundness theorem establishing that composed implementations satisfy the composed contract.
- `ETCVerify.Operators.SharedResource.ResourceUser`: structure pairing a contract with its consumption of a shared resource.
- `ETCVerify.Operators.SharedResource.sharedResource` (notation `⊕[·]`): shared-resource composition with architectural-level feasibility side condition.
- `ETCVerify.Operators.SharedResource.sharedResource_sound`: soundness theorem for shared-resource composition.
- `ETCVerify.Operators.Refinement.refinement` (notation `⊑`): structural refinement relation between contracts; weaker assumptions and stronger guarantees on the spec's operating envelope.
- `ETCVerify.Operators.Refinement.refinement_sound`: soundness theorem establishing that a function implementing the stronger contract also implements the weaker one.
- `ETCVerify.Operators.Refinement.refinement_refl`: reflexivity of refinement; every contract refines itself.
- `ETCVerify.Operators.Refinement.refinement_trans`: transitivity of refinement; chains of refinement compose.
- `ETCVerify.Operators.Conformance.conformance` (notation `⊨`): behavioral conformance of an implementation contract to a specification contract; every function implementing `impl` also implements `spec`.
- `ETCVerify.Operators.Conformance.conformance_sound`: bridge theorem connecting refinement to conformance — a structural refinement of the implementation over the spec establishes operational substitutability.