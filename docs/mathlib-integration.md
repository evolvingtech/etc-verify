# Mathlib Integration

This note records the discipline for adding Mathlib as a dependency to the
ETC Verify substrate. It is intended to be read at the moment activation
is being considered, and to be updated when activation actually happens.

## Current status

Mathlib is **not currently a dependency**. Substrate v0.1 uses only Lean
core types and `Prop`. This is sufficient for the contract algebra and
its operators as currently scoped (`Sequential`, `SharedResource`,
`Refinement`, `Conformance`).

The activation point is staged in `lakefile.toml` as a commented `require`
block. Activating Mathlib is a deliberate decision, not a default.

## Trigger conditions

Add Mathlib when one or more of the following becomes true:

- **Timed extensions.** `ETCVerify/Core/Timed.lean` (planned as substrate
  development item 3) will likely need real-valued time, interval
  reasoning, and tactics like `linarith`. These are Mathlib's natural
  habitat; reinventing them in Lean core would be wasted effort.
- **Ordered-algebra requirements on `SharedResource`.** The current
  `[Add R]` and `[LE R]` constraints are deliberately minimal. When
  resource instantiations need ordered field structure, ordered
  commutative monoid structure, or real-number budgets with
  monotonicity reasoning, Mathlib's `Mathlib.Order` and
  `Mathlib.Algebra` hierarchies become the right tools. Existing
  instances of `OrderedAddCommMonoid` automatically provide `Add` and
  `LE`, so no downstream `SharedResource` user needs to be rewritten —
  Mathlib instances become drop-in.
- **Proof-tactic leverage.** When operator soundness theorems start
  requiring nontrivial arithmetic or order reasoning, Mathlib's tactic
  library (`linarith`, `omega`, `positivity`, `gcongr`) becomes
  substantially more productive than hand-rolled term-mode proofs.
- **Any module about to reinvent Mathlib structure.** Whenever a future
  module is about to define its own version of something that lives in
  `Mathlib.Order` or `Mathlib.Algebra`, stop and activate instead.

## Non-trigger conditions

Do **not** add Mathlib for:

- Convenience imports in modules that don't actually need it. Activation
  has compile-time cost; modules that don't use Mathlib symbols should
  not import them.
- Tactics that Lean core already supplies adequately (`simp`, `rfl`,
  `exact`, `intro`, `apply`, `constructor`, `cases`, `induction`).
- Aesthetic preference for Mathlib idioms over equivalent core
  constructions, absent a real use case.

## Activation procedure

When a trigger condition is met:

1. Uncomment the `[[require]]` block in `lakefile.toml`. Confirm `rev`
   matches the current `lean-toolchain` pin.
2. Run `lake update mathlib`. This resolves and fetches Mathlib at the
   pinned revision.
3. Run `lake build`. Existing modules must continue to build without
   modification; if anything breaks, the activation has caused
   collateral damage and the cause should be identified before
   proceeding.
4. Add `import Mathlib.X` **only** in the specific module(s) that
   triggered the activation. Do not bulk-import in `Core/Contract.lean`,
   the existing operator files, or any module that does not directly
   need Mathlib symbols. Per-module discipline keeps build times
   manageable as the substrate grows.
5. Update `CHANGELOG.md` with the activation event, the trigger module,
   and the Mathlib revision.
6. Update this document's "Current status" section.

## Version coordination

The Mathlib `rev` and the `lean-toolchain` pin must stay in lockstep.
Mathlib release tags match the corresponding Lean toolchain version, so
the mapping is mechanical:

| Lean toolchain | Mathlib revision |
|----------------|------------------|
| `v4.28.0`      | `v4.28.0`        |
| `v4.29.0`      | `v4.29.0`        |
| (future)       | (matching tag)   |

When upgrading the Lean toolchain, both files must change in the same
commit. If Mathlib is active at the time of a toolchain upgrade, the
upgrade sequence is:

1. Bump `lean-toolchain` to the new Lean version.
2. Bump the Mathlib `rev` in `lakefile.toml` to the matching version.
3. Run `lake update` followed by `lake build`.
4. Resolve any deprecations or breakages surfaced by the new versions.
5. Commit the toolchain bump, the Mathlib bump, and any required source
   fixes as a single coordinated change. The commit message should call
   out the coordinated nature.

If Mathlib is not yet active, only `lean-toolchain` changes; the
commented `rev` in the activation block should still be updated to the
new matching version so future activation lands on the right pin.

## Planned upgrade: Lean v4.29.0

The substrate is currently pinned to Lean v4.28.0 to match Loren's global
toolchain. An upgrade to Lean v4.29.0 is planned in the near future. At
that time:

- `lean-toolchain` becomes `leanprover/lean4:v4.29.0`.
- The commented Mathlib `rev` in `lakefile.toml` becomes `v4.29.0`.
- This document's "Current status" and the table above are updated to
  reflect the new pin.
- If Mathlib has been activated by then, the upgrade is the coordinated
  bump described above. If not, only the toolchain and the commented
  rev change.

## Why this discipline

The substrate is positioned as the long-lived shared formal vocabulary
for cross-domain interface verification (see the framework vision and
roadmap document). It will be depended on by code outside ETC's control,
including the planned bidirectional diagram tooling, vendor calibration
modules, and customer-specific verified libraries. Dependencies are
public API in spirit even when not in form: changes to whether Mathlib
is required, and which Mathlib version, propagate to every downstream
user. That argues for activation being deliberate and well-recorded
rather than incidental.