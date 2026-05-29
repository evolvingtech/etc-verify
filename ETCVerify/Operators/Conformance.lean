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
import ETCVerify.Operators.Refinement

/-!
# Conformance

The conformance relation `impl ⊨ spec`, read "impl conforms to spec," is
the verification check at the boundary between an implementation
contract and a specification contract. Operationally, it asserts that
every function satisfying `impl` also satisfies `spec`. It is the
`Implements` relation lifted to the operator level: a statement about
contracts that has its operational meaning in the implementations they
admit.

The relation differs from refinement (`⊑`) in surface but not in
intended use. Refinement is the structural predicate over contracts
(assumes weaker, guarantees stronger on the spec's envelope).
Conformance is the behavioral consequence — that the implementations of
one contract carry over as implementations of the other.

The two are bridged by `conformance_sound`: refinement entails
conformance. This is the practical pattern engineers use — establish
the structural refinement check, and the operational substitutability
of implementations follows.

The converse (`impl ⊨ spec → impl ⊑ spec`) holds under classical
reasoning and inhabited-types assumptions but is not provable
constructively in full generality. The substrate does not commit to it
at this stage.

The vocabulary distinction matters at audit boundaries. "Vendor's
binary64 multiplier conforms to the IEEE 754 binary64 multiplication
specification" is most naturally written `vendor_impl ⊨ ieee754_spec`;
the structural proof obligation a vendor discharges is
`vendor_impl ⊑ ieee754_spec`.

Silences are deliberately not tracked by conformance. The conformance
relation is defined entirely in terms of `Implements`, which itself
inspects only `assumes` and `guarantees`. Silence discipline is a
separate audit property of individual contracts; it is preserved by
the substrate's composition operators but not interrogated by the
conformance check.
-/

namespace ETCVerify

namespace Operators

/-- `impl ⊨ spec`: every function implementing `impl` also implements
`spec`. The operational form of "this implementation contract conforms
to this specification." Conformance is modality-blind: the relation is
defined entirely via `Implements`, which inspects only `assumes` and
`guarantees`. -/
def conformance {M : Type} [ModalData M] {Input Output : Type}
    (impl spec : Contract M Input Output) : Prop :=
  ∀ f : Input → Output, Implements f impl → Implements f spec

/-- Infix notation for conformance. -/
scoped infix:50 " ⊨ " => conformance

/-- Soundness of conformance: a structural refinement of `impl` over
`spec` suffices to establish that every implementation of `impl` is an
implementation of `spec`. -/
theorem conformance_sound {M : Type} [ModalData M] {Input Output : Type}
    {impl spec : Contract M Input Output} (h_ref : impl ⊑ spec) :
    impl ⊨ spec :=
  fun _ h_impl => refinement_sound h_ref h_impl

end Operators

end ETCVerify