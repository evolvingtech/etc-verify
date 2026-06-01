/-
Copyright (c) 2026 Evolving Technologies Corporation
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Authors: Loren Abdulezer
-/

import ETCVerify

open ETCVerify
open ETCVerify.Operators

/-!
# Timed shared-resource composition

A minimum-viable example exercising the `Timed` modality through the
`sharedResource` operator, with a *time-indexed* resource budget. The time type
is `Nat`: latencies are read as milliseconds, the shared resource as watts, and
the resource's time index as discrete instants.

Two timed subsystems draw on a common power rail:

- `subsystemA` : guarantees `output = input`;       latency 3 ms; draws 5 W.
- `subsystemB` : guarantees `output = input + 1`;   latency 7 ms; draws 3 W.

The resource is `TimeIndexed Nat Nat` — a budget that is a function of time, not
a scalar. Here the available rail is a constant `10 W` at every instant and each
subsystem's draw is constant, so the architecture is feasible; the *type* is
nonetheless time-indexed, and feasibility is the **pointwise** proposition
`∀ t, consumedA t + consumedB t ≤ available t` (the third conjunct of the
composed contract's assumption), the instantaneous-power reading of the rail.

Two substrate properties are demonstrated end-to-end, both with no substrate
modification:

1. The *same* `sharedResource_sound` theorem that serves the `Untimed` modality
   derives the composed implementation proof under `Timed Nat`.
2. The composed contract's `extra.latency` is the `max` of the component
   latencies (`max 3 7 = 7 ms`), computed by the `ModalSharedResource (Timed Nat)`
   instance — shared-resource composition being conceptually parallel, the
   composite tracks the slower branch. Contrast `examples/timed-sequential`,
   where the *series* rule sums latencies instead.

The provisional defaults instantiated here (pointwise resource shape; `max`
latency combination) were adopted on engineering judgment — the May 28 LSIC
Surface Power Transmission Workshop produced no usable signal on either question.
Both are revisable as additive resource-type / instance choices per O-3.
-/

namespace ETCVerifyExamples.TimedSharedResource

/-- "Subsystem A": no precondition; guarantees output equals input; latency
3 ms. -/
def subsystemA : Contract (Timed Nat) Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i
  silences   := []
  extra      := { latency := 3 }

/-- "Subsystem B": no precondition; guarantees output equals input plus one;
latency 7 ms. -/
def subsystemB : Contract (Timed Nat) Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i + 1
  silences   := []
  extra      := { latency := 7 }

/-- The shared power rail: a time-indexed budget of a constant 10 W at every
instant. The value is flat in time here to keep the feasibility proof
decidable; the `TimeIndexed Nat Nat` type permits any time-varying profile
(see the README "try it"). -/
def availableBudget : TimeIndexed Nat Nat := fun _ => 10

/-- `subsystemA` packaged as a resource user drawing a constant 5 W. -/
def userA : ResourceUser (Timed Nat) (TimeIndexed Nat Nat) Nat Nat where
  contract := subsystemA
  consumes := fun _ => 5

/-- `subsystemB` packaged as a resource user drawing a constant 3 W. -/
def userB : ResourceUser (Timed Nat) (TimeIndexed Nat Nat) Nat Nat where
  contract := subsystemB
  consumes := fun _ => 3

/-- The shared-resource composition of the two users under the time-indexed
rail. -/
def composed : Contract (Timed Nat) (Nat × Nat) (Nat × Nat) :=
  sharedResource availableBudget userA userB

/--
The time-indexed budget is feasible: at every instant the combined draw
(`5 + 3 = 8 W`) fits within the available rail (`10 W`). Under the pointwise
`LE (TimeIndexed Nat Nat)` instance this is `∀ t, 5 + 3 ≤ 10`; `intro t`
discharges the time index and `decide` closes the instant-wise inequality.

This is the architectural-level side condition surfaced by `sharedResource`,
now in its pointwise time-indexed form. If the rail dipped below 8 W at some
instant — an eclipse — the proof would fail *at that instant*; see the README.
-/
theorem budget_feasible :
    userA.consumes + userB.consumes ≤ availableBudget := by
  intro t
  -- At this instant the goal reduces to the closed inequality `5 + 3 ≤ 10`;
  -- `show` discharges the (here vacuous) dependence on `t` so `decide` has no
  -- free variable to object to.
  show 8 ≤ 10
  decide

/-- The identity function implements `subsystemA`. -/
theorem subsystemA_implemented : Implements (fun n : Nat => n) subsystemA :=
  fun _ _ => rfl

/-- The increment function implements `subsystemB`. -/
theorem subsystemB_implemented : Implements (fun n : Nat => n + 1) subsystemB :=
  fun _ _ => rfl

/--
The pointwise pair function `fun (a, b) => (a, b + 1)` implements the composed
contract.

The proof is `sharedResource_sound` applied to the two component implementation
proofs — the *same* theorem authored against `Untimed`, now serving `Timed Nat`
with no substrate change.
-/
theorem composed_implemented :
    Implements
      (fun (p : Nat × Nat) => (p.1, p.2 + 1))
      composed :=
  sharedResource_sound availableBudget userA userB
    (fun n => n) (fun n => n + 1)
    subsystemA_implemented subsystemB_implemented

/-- The composed contract's latency is the `max` of the component latencies:
`max 3 7 = 7 ms`. This is the `ModalSharedResource (Timed Nat)` instance doing
its work; shared-resource composition is conceptually parallel, so the composite
tracks the slower branch rather than summing (contrast the sequential example,
where latency is `3 + 5 = 8`). -/
theorem composed_latency :
    composed.extra.latency = 7 := by
  decide

end ETCVerifyExamples.TimedSharedResource
