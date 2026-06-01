# Timed shared-resource composition example

A minimum-viable demonstration of the `sharedResource` operator under the `Timed` modality, with a *time-indexed* resource budget. Two timed subsystems — `subsystemA` and `subsystemB` — draw on a common power rail. Each is a `Contract (Timed Nat)` carrying a latency, packaged via `ResourceUser` with a time-indexed consumption profile of type `TimeIndexed Nat Nat`. The substrate's `sharedResource_sound` theorem then mechanically delivers a composed implementation proof, and the `ModalSharedResource (Timed Nat)` instance composes the latencies by `max`.

The time type is `Nat`: latencies are milliseconds, the shared resource is watts, and the resource's time index is discrete instants.

## What this example demonstrates

- Constructing `Contract (Timed Nat) Nat Nat` values carrying timing data in `extra` (`extra := { latency := ... }`).
- A **time-indexed** resource: the budget is `availableBudget : TimeIndexed Nat Nat`, a function from instants to watts, rather than a scalar.
- Packaging a timed contract with a time-indexed consumption profile via `ResourceUser (Timed Nat) (TimeIndexed Nat Nat)`.
- Composing two such users under `sharedResource` with the time-indexed budget.
- The architectural-level feasibility side condition in its **pointwise** form (`budget_feasible`): `∀ t, consumedA t + consumedB t ≤ available t` — instantaneous demand never exceeds instantaneous supply — surfaced as the third conjunct of the composed assumption and provable here by `intro t; decide`.
- The *same* `sharedResource_sound` theorem that serves `Untimed` deriving the composed-implementation proof under `Timed Nat`, with no substrate change.
- Latency composition under sharing (`composed_latency`): the composite's latency is `max 3 7 = 7 ms`. Shared-resource composition is conceptually parallel, so the composite tracks the slower branch — contrast `examples/timed-sequential`, where the series rule *sums* latencies to `8 ms`.

## What this example does not demonstrate

- **Time-varying values.** The budget and both consumption profiles are flat in time (constant functions) so that the pointwise feasibility quantifier `∀ t : Nat, …` stays decidable. The *types* are fully time-indexed; only the chosen *values* are constant. A genuinely time-varying budget over an infinite time index needs either a finite time domain or arithmetic reasoning (`omega`) rather than `decide` — see "Try it" below.
- **Resource shapes other than pointwise.** Feasibility here is the pointwise (instantaneous-power) reading. The integral (energy-over-a-window) and peak (max-demand) shapes are additive future `TimeIndexed`-family resource types per O-3, not modifications of this one.
- **Jitter or validity windows.** Timing is a single scalar `latency`; richer timing fields are deferred.
- The full cross-domain story (PN1 sharing power with C1), which requires substantive component contracts living in domain-specific repositories.

## On the provisional defaults

Two design defaults are instantiated here: the **pointwise** resource shape (§3.5(a) of the v0.2.1 spec) and the **`max`** latency-combination rule under sharing (§3.5(b)). Both were flagged for confirmation against the May 28 LSIC Surface Power Transmission Workshop. The workshop produced no usable signal on either question, so both defaults stand on engineering judgment — pointwise as the most conservative, Mathlib-free instantaneous reading (with the peak/transient concern already carried by the operator's `transient_response` silence); `max` because shared-resource composition is conceptually parallel and the composite tracks the slower branch. Both are revisable as additive resource-type / instance choices per O-3.

## Running

Open `Example.lean` in VSCode with the Lean 4 extension. The LSP will check the file; no red squiggles in the gutter means every definition type-checks and every proof closes.

Alternatively, from the repo root:

    lake env lean examples/timed-shared-resource/Example.lean

A clean exit means everything checked.

## Try it: see infeasibility surface

To see the pointwise architectural side condition fail, lower the rail below the combined draw. The simplest failure: change `availableBudget` to the constant `fun _ => 5`. Then `budget_feasible` breaks — after `intro t`, `decide` reduces `8 ≤ 5` to `False` at every instant.

The more instructive, genuinely time-indexed failure is a localized dip — an eclipse at a single instant:

    def availableBudget : TimeIndexed Nat Nat := fun t => if t = 2 then 4 else 10

Now the rail supplies 10 W everywhere except instant `2`, where it drops to 4 W — below the 8 W combined draw. Feasibility `∀ t, 8 ≤ availableBudget t` is false, and the failure is *located at instant 2*. This is the diagnostic payoff of a time-indexed budget: infeasibility surfaces not just as "the architecture does not compose" but as "it does not compose **at this instant**." Note that proving feasibility for such a time-varying budget is no longer a plain `decide` — it needs `omega` (Lean core) after a case split on the time index, or a finite time domain; the worked proof above keeps the budget flat precisely to stay at `decide` level.
