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
# Shared-resource composition

Given two components in parallel that both draw from a common resource
(e.g. a power budget, a mass budget, a bandwidth allocation, a contact-
window seconds budget), the shared-resource composition expresses the
architecture as a single composed contract on the joint input/output
space, with a feasibility constraint over the shared resource.

The composed contract:

- assumes both components' individual assumptions hold AND the combined
  consumption fits within the available budget;
- guarantees both components' guarantees hold jointly;
- accumulates silences from both components, plus a substrate-added
  silence for transient response (the static feasibility check does not
  model transient resource demands).

The third conjunct of the composed assumption is the **architectural
side condition**: when `A.consumes + B.consumes ≤ available` is
unprovable, the architecture is infeasible at the resource level —
regardless of whether either component is internally correct. This is
the diagnostic property that distinguishes architectural-level
verification from per-component verification.

The substrate is generic over the resource type. Domain modules
instantiate it to specific resources (watts, kilograms, etc.). Only
`Add` and `LE` are required.
-/

namespace ETCVerify

namespace Operators

/--
A contract paired with its consumption of a specific resource.

Resource consumption is treated as a per-component constant in this
substrate version. More sophisticated models (input-dependent consumption,
time-varying profiles, transient envelopes) extend `ResourceUser` in
downstream modules without altering the substrate.
-/
structure ResourceUser (M : Type) [ModalData M] (R : Type) (Input Output : Type) where
  /-- The contract describing the component's interface. -/
  contract : Contract M Input Output
  /-- The component's consumption of the shared resource. -/
  consumes : R

/--
Shared-resource composition: two components in parallel, both drawing
from a common resource budget.

The third conjunct of the composed assumption is the resource-feasibility
side condition; it is independent of the input pair, expressing an
architectural-level constraint that holds or fails regardless of any
particular runtime input.
-/
def sharedResource {M : Type} [ModalData M] [ModalSharedResource M]
    {R : Type} [Add R] [LE R]
    {IA OA IB OB : Type}
    (available : R)
    (A : ResourceUser M R IA OA) (B : ResourceUser M R IB OB)
    : Contract M (IA × IB) (OA × OB) where
  assumes    := fun ⟨iA, iB⟩ =>
    A.contract.assumes iA ∧ B.contract.assumes iB ∧
    A.consumes + B.consumes ≤ available
  guarantees := fun ⟨iA, iB⟩ ⟨oA, oB⟩ =>
    A.contract.guarantees iA oA ∧ B.contract.guarantees iB oB
  silences   :=
    A.contract.silences ++ B.contract.silences ++
    [SilenceTag.mk "transient_response"
       "Static feasibility check; transient resource demands not modeled"]
  extra      := ModalSharedResource.composeExtra A.contract.extra B.contract.extra

/-- Bracket notation for shared-resource composition. -/
scoped notation:60 A " ⊕[" budget "] " B => sharedResource budget A B

/--
Soundness of shared-resource composition.

If `fA` implements `A.contract` and `fB` implements `B.contract`, then
their pointwise pair function `fun ⟨iA, iB⟩ => (fA iA, fB iB)` implements
the shared-resource composition. The resource-feasibility side condition
is consumed but not used in the proof — it is part of the assumption and
discharges trivially when applied.
-/
theorem sharedResource_sound {M : Type} [ModalData M] [ModalSharedResource M]
    {R : Type} [Add R] [LE R]
    {IA OA IB OB : Type}
    (available : R)
    (A : ResourceUser M R IA OA) (B : ResourceUser M R IB OB)
    (fA : IA → OA) (fB : IB → OB)
    (hA : Implements fA A.contract) (hB : Implements fB B.contract) :
    Implements (fun (p : IA × IB) => (fA p.1, fB p.2)) (sharedResource available A B) := by
  intro ⟨iA, iB⟩ hi
  exact ⟨hA iA hi.1, hB iB hi.2.1⟩

end Operators

end ETCVerify