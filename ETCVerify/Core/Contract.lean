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

import ETCVerify.Core.Silence
import ETCVerify.Core.Modal

/-!
# Contracts: the foundational type of the algebra

A `Contract M Input Output` is the substrate's first-class representation of
an interface in the contract-based design tradition. It bundles four
pieces:

- `assumes`: a predicate on inputs and environment, expressing what the
  interface requires of its callers.
- `guarantees`: a predicate relating valid inputs to outputs, expressing
  what the interface promises.
- `silences`: an explicit list of typed tags enumerating aspects of behavior
  that the contract deliberately leaves unspecified.
- `extra`: modality-specific auxiliary data, with type and meaning supplied
  by the `[ModalData M]` instance for the contract's modality `M`. For the
  `Untimed` modality (the only modality in v0.2.0), `extra` has type `Unit`
  and is uninformative; modalities such as `Timed _` use this field to
  carry timing data.

The composition operators of the algebra (sequential, parallel,
shared-resource, refinement, conformance) operate over `Contract` and
produce new `Contract` values whose `assumes`, `guarantees`, and
`silences` are derived from those of the components.

In some contract-based design literature, the same notion is called an
"Interface" or an "Assumption/Guarantee pair"; the substrate uses
`Contract` for consistency with its filename and to emphasize the
commitment-and-obligation framing.
-/

namespace ETCVerify

/--
A contract describes an interface as assumes, guarantees, silences, and
modality-specific auxiliary data.

Type parameters:
- `M`: the modality (e.g. `Untimed`, `Timed _`). Selects via `[ModalData M]`
  the type of auxiliary data the contract carries in its `extra` field.
- `Input`: the type of inputs the interface receives.
- `Output`: the type of outputs the interface produces.

Fields:
- `assumes`: predicate on inputs expressing the contract's environmental requirements.
- `guarantees`: predicate on (input, output) pairs expressing the contract's promises.
- `silences`: list of `SilenceTag` enumerating aspects deliberately left unspecified.
- `extra`: modality-specific auxiliary data, of type `ModalData.Extra M`.
-/
structure Contract (M : Type) [ModalData M] (Input Output : Type) where
  assumes    : Input → Prop
  guarantees : Input → Output → Prop
  silences   : List SilenceTag
  extra      : ModalData.Extra M


/--
A function `f : Input → Output` implements a contract `c` if, for every input
satisfying the contract's assumptions, the corresponding output satisfies the
contract's guarantees.

This is the fundamental satisfaction relation between implementations and
contracts. Operators in the algebra have soundness theorems stated in terms
of `Implements`: given implementations of component contracts, the composed
implementation satisfies the composed contract.

`Implements` is modality-blind: its body inspects only `assumes` and
`guarantees`. The modality parameter is carried through the signature so the
relation can be stated uniformly across modalities.
-/
def Implements {M : Type} [ModalData M] {Input Output : Type}
    (f : Input → Output) (c : Contract M Input Output) : Prop :=
  ∀ i, c.assumes i → c.guarantees i (f i)


/-- Type abbreviation for contracts in the `Untimed` modality. Exists for
source-level continuity with pre-v0.2.0 substrate users and within-substrate
examples. -/
abbrev UntimedContract (Input Output : Type) : Type := Contract Untimed Input Output


end ETCVerify