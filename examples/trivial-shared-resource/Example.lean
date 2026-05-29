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
# Trivial shared-resource composition

A minimum-viable example exercising the `sharedResource` operator
end-to-end.

Two contracts on natural numbers — `passThrough` and `increment` — are
each packaged with a per-component resource consumption value (a plain
`Nat`, standing in for whatever resource a domain module would substitute:
watts, kilograms, megabits, contact-window seconds). The shared
resource budget is 10 units; the two components together consume 8,
so the architecture is feasible at the resource level.

The substrate's `sharedResource_sound` theorem then mechanically
delivers a proof that the pointwise pair function
`fun (a, b) => (a, b + 1)` implements the composed contract — given the
two trivial implementation proofs of the components.

The architectural-level feasibility side condition is exposed as a
separate, named theorem `budget_feasible`, demonstrating the substrate
property that resource-feasibility is a checkable proposition distinct
from per-component correctness.
-/

namespace ETCVerifyExamples.TrivialSharedResource

/-- "Pass-through": no precondition; guarantees output equals input. -/
def passThrough : UntimedContract Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i
  silences   := []
  extra      := ()

/-- "Increment": no precondition; guarantees output equals input plus one. -/
def increment : UntimedContract Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i + 1
  silences   := []
  extra      := ()

/-- `passThrough` packaged as a resource user consuming 5 units. -/
def passThroughUser : ResourceUser Untimed Nat Nat Nat where
  contract := passThrough
  consumes := 5

/-- `increment` packaged as a resource user consuming 3 units. -/
def incrementUser : ResourceUser Untimed Nat Nat Nat where
  contract := increment
  consumes := 3

/-- The shared-resource composition of the two users under a budget of 10. -/
def composed : UntimedContract (Nat × Nat) (Nat × Nat) :=
  sharedResource 10 passThroughUser incrementUser

/--
The resource budget is feasible: combined consumption (5 + 3 = 8) fits
within the available budget (10). `decide` discharges this trivially.

This is the architectural-level side condition surfaced by
`sharedResource`. If the budget were smaller — say 5 — the proof would
fail; `decide` would reduce `8 ≤ 5` to `False` and report it.
-/
theorem budget_feasible :
    passThroughUser.consumes + incrementUser.consumes ≤ 10 := by
  decide

/-- The identity function implements `passThrough`. -/
theorem passThrough_implemented : Implements (fun n : Nat => n) passThrough :=
  fun _ _ => rfl

/-- The increment function implements `increment`. -/
theorem increment_implemented : Implements (fun n : Nat => n + 1) increment :=
  fun _ _ => rfl

/--
The pointwise pair function `fun (a, b) => (a, b + 1)` implements the
composed contract.

The proof is `sharedResource_sound` applied to the two component
implementation proofs. The substrate did all the cross-domain
compositional work; this file just plugs in concrete instances.
-/
theorem composed_implemented :
    Implements
      (fun (p : Nat × Nat) => (p.1, p.2 + 1))
      composed := by
  exact sharedResource_sound 10 passThroughUser incrementUser
    (fun n => n) (fun n => n + 1)
    passThrough_implemented increment_implemented

end ETCVerifyExamples.TrivialSharedResource