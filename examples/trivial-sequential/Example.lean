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
# Trivial sequential composition

A minimum-viable example exercising the substrate end-to-end.

Two contracts on natural numbers:

- `addOne` accepts any input and guarantees its output equals `input + 1`.
- `double` accepts any input and guarantees its output equals `2 * input`.

The sequential composition `addOne ⨾ double` is a contract on naturals
that says: "first add one, then double the result." Two concrete
implementations — `(· + 1)` and `(2 * ·)` — are each shown to implement
their respective contract. The substrate's soundness theorem
`sequential_sound` then mechanically derives that the composition of
these implementations implements the composed contract.

The point of this example is to demonstrate that the substrate is wired
correctly and that the algebra delivers what it should: given component
implementation proofs, the composed implementation proof comes for free.
-/

namespace ETCVerifyExamples.TrivialSequential

/-- "Add one": no precondition; guarantees output equals input plus one. -/
def addOne : UntimedContract Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i + 1
  silences   := []
  extra      := ()

/-- "Double": no precondition; guarantees output equals twice the input. -/
def double : UntimedContract Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = 2 * i
  silences   := []
  extra      := ()

/-- The function `fun n => n + 1` implements the `addOne` contract. -/
theorem addOne_implemented : Implements (fun n : Nat => n + 1) addOne :=
  fun _ _ => rfl

/-- The function `fun n => 2 * n` implements the `double` contract. -/
theorem double_implemented : Implements (fun n : Nat => 2 * n) double :=
  fun _ _ => rfl

/--
The composed function `(2 * ·) ∘ (· + 1)` implements `addOne ⨾ double`.

The proof is `sequential_sound` applied to the two component
implementation proofs. The substrate did all the compositional work;
this file just plugs in concrete instances.
-/
theorem addOne_then_double_implemented :
    Implements ((fun n : Nat => 2 * n) ∘ (fun n : Nat => n + 1)) (addOne ⨾ double) :=
  sequential_sound addOne double
    (fun n => n + 1) (fun n => 2 * n)
    addOne_implemented double_implemented

end ETCVerifyExamples.TrivialSequential