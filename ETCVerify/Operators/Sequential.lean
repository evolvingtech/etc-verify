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
# Sequential composition

Given contracts `A : Contract M I X` and `B : Contract M X O` in the same
modality `M`, the sequential composition `A ⨾ B : Contract M I O` represents
wiring A's output into B's input. The composed contract:

- assumes both `A.assumes i` and that every intermediate value A might
  produce on input `i` satisfies `B.assumes`;
- guarantees that there exists some intermediate value witnessing the
  composition: A produces it on input `i`, and B produces the final output
  from it;
- accumulates silences from both components.

The second conjunct of the composed assumption is the *side condition*
that exposes interface compatibility gaps: when
`∀ m, A.guarantees i m → B.assumes m` is unprovable, the composition has a
gap at the A→B interface — A's output may not satisfy B's input
requirements. This is one of the architectural-level diagnostic
properties the algebra surfaces.

The soundness theorem `sequential_sound` establishes that if `fA`
implements `A` and `fB` implements `B`, then their composition `fB ∘ fA`
implements `A ⨾ B`. The theorem is proved once here; every concrete
sequential composition in user code inherits its conclusion automatically.
-/

namespace ETCVerify

namespace Operators

/--
Sequential composition of two contracts: pipe A's output to B's input.

The composed assumption requires both `A.assumes i` and that any
intermediate value A might produce on input `i` satisfies `B.assumes`.
The composed guarantee asserts existence of an intermediate value
witnessing the composition. Silences accumulate from both components.
-/
def sequential {M : Type} [ModalData M] [ModalSequential M] {I X O : Type}
    (A : Contract M I X) (B : Contract M X O) : Contract M I O where
  assumes    := fun i => A.assumes i ∧ (∀ m, A.guarantees i m → B.assumes m)
  guarantees := fun i o => ∃ m, A.guarantees i m ∧ B.guarantees m o
  silences   := A.silences ++ B.silences
  extra      := ModalSequential.composeExtra A.extra B.extra

/-- Infix notation for sequential composition. -/
scoped infixl:65 " ⨾ " => sequential

/--
Soundness of sequential composition.

If `fA` implements `A` and `fB` implements `B`, then their composition
`fB ∘ fA` implements `A ⨾ B`.

The witness for the existential in `(A ⨾ B).guarantees` is the intermediate
value `fA i` produced by the first implementation; the side condition in
`(A ⨾ B).assumes` then licenses applying `fB`'s implementation guarantee.
-/
theorem sequential_sound {M : Type} [ModalData M] [ModalSequential M]
    {I X O : Type}
    (A : Contract M I X) (B : Contract M X O)
    (fA : I → X) (fB : X → O)
    (hA : Implements fA A) (hB : Implements fB B) :
    Implements (fB ∘ fA) (A ⨾ B) := by
  intro i hi
  refine ⟨fA i, ?_, ?_⟩
  · exact hA i hi.1
  · have hAi : A.guarantees i (fA i) := hA i hi.1
    have hBassumes : B.assumes (fA i) := hi.2 (fA i) hAi
    exact hB (fA i) hBassumes

end Operators

end ETCVerify