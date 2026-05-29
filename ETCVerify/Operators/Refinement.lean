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

import ETCVerify.Core.Contract
import ETCVerify.Core.Modal

/-!
# Refinement

The refinement relation `A ⊑ B`, read "A refines B" or "A is at least as
strong as B," is the structural compatibility predicate of the contract
algebra. It captures vendor-vs-specification compliance: a vendor's
implementation contract refines the standard's interface contract when
the vendor demands no more of the environment (weaker assumptions) and
promises at least as much (stronger guarantees) as the standard does.

Formally `A ⊑ B` is the conjunction of two clauses:
- `∀ i, B.assumes i → A.assumes i`: A operates wherever B operates.
- `∀ i o, B.assumes i → A.guarantees i o → B.guarantees i o`: on B's
  operating envelope, A's guarantees imply B's.

The relation forms a preorder (`refinement_refl`, `refinement_trans`)
and is sound with respect to function-level implementation
(`refinement_sound`): a function implementing the stronger contract
also implements the weaker one.

Silences are deliberately not tracked by refinement. The refinement
relation is an algebraic statement about assumes and guarantees;
silence discipline is a separate audit property of individual contracts
and is preserved across composition operators but not interrogated by
the structural refinement check.
-/

namespace ETCVerify

namespace Operators

/-- `A ⊑ B`: A refines B. A's assumes are weaker (anywhere B operates,
A operates), and on B's operating envelope, A's guarantees imply B's.
Refinement is modality-blind: the relation inspects only `assumes` and
`guarantees`, both of which are independent of the modality `M`. -/
def refinement {M : Type} [ModalData M] {Input Output : Type}
    (A B : Contract M Input Output) : Prop :=
  (∀ i, B.assumes i → A.assumes i) ∧
  (∀ i o, B.assumes i → A.guarantees i o → B.guarantees i o)

/-- Infix notation for refinement. -/
scoped infix:50 " ⊑ " => refinement

/-- Soundness of refinement: a function implementing the stronger
contract also implements the weaker one. The structural refinement
check thus suffices to establish substitutability at the implementation
level. -/
theorem refinement_sound {M : Type} [ModalData M] {Input Output : Type}
    {A B : Contract M Input Output} {f : Input → Output}
    (h_ref : A ⊑ B) (h_impl : Implements f A) :
    Implements f B := by
  intro i h_assumes_B
  have h_assumes_A : A.assumes i := h_ref.1 i h_assumes_B
  have h_guar_A : A.guarantees i (f i) := h_impl i h_assumes_A
  exact h_ref.2 i (f i) h_assumes_B h_guar_A

/-- Refinement is reflexive: every contract refines itself. -/
theorem refinement_refl {M : Type} [ModalData M] {Input Output : Type}
    (A : Contract M Input Output) :
    A ⊑ A :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

/-- Refinement is transitive: chains of refinements compose. -/
theorem refinement_trans {M : Type} [ModalData M] {Input Output : Type}
    {A B C : Contract M Input Output}
    (h_AB : A ⊑ B) (h_BC : B ⊑ C) :
    A ⊑ C :=
  ⟨ fun i h_C => h_AB.1 i (h_BC.1 i h_C),
    fun i o h_C h_A =>
      have h_B : B.assumes i := h_BC.1 i h_C
      have h_g_B : B.guarantees i o := h_AB.2 i o h_B h_A
      h_BC.2 i o h_C h_g_B ⟩

end Operators

end ETCVerify