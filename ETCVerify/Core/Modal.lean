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

/-!
# Modal parameterization core

This module defines the typeclass machinery that parameterizes substrate
contracts over their modality. A modality is a type-level marker (`Untimed`,
`Timed _`, …) that selects which auxiliary data a contract carries and which
modality-aware composition behaviors apply.

The substrate ships with `Untimed` as the only modality. Additional modalities
are user-extensible via published Lean libraries that provide instances of the
typeclasses declared here — no substrate modification required. This file is
the complete interface a third-party modality must satisfy: `ModalData` (the
associated auxiliary-data type) plus one per-operator typeclass for each
operator whose composition behavior is modality-specific
(`ModalSequential`, `ModalSharedResource`).

The module establishes the **identity-vs-values distinction** locked in O-5:
typeclasses dispatch on modality identity; per-modality values (timing data, etc.)
live in named structure fields of the `Extra` type for that modality and are
accessed by structure projection. The substrate does not bury values in
typeclass-default behavior.

The module depends only on Lean core. No Mathlib import is required and none
should be added.

## Silences

This file introduces no silences. The typeclasses declared here are
infrastructure; obligations attached to specific modalities arise in the
modality's own instance file.
-/

namespace ETCVerify

/-- Modality marker for substrate contracts that carry no modality-specific
data. Contracts under this modality preserve the substrate's pre-v0.2.0
semantics exactly. -/
structure Untimed where

/-- Typeclass exposing the modality-specific auxiliary data type. Each
modality `M` instance specifies `Extra : Type` — the type of data that
`Contract M Input Output` carries in its `extra` field. -/
class ModalData (M : Type) where
  Extra : Type

instance : ModalData Untimed where
  Extra := Unit

/-- Typeclass providing modality-aware composition of the `extra` field for
sequential composition. Each modality instantiates this to specify how its
modality-specific data combines under series composition. For `Untimed`,
composition is trivial. For modalities carrying timing data (e.g., `Timed T`),
this is where latency-composition logic plugs in. -/
class ModalSequential (M : Type) [ModalData M] where
  composeExtra : ModalData.Extra M → ModalData.Extra M → ModalData.Extra M

instance : ModalSequential Untimed where
  composeExtra _ _ := ()

/-- Typeclass providing modality-aware composition of the `extra` field for
shared-resource composition. Each modality instantiates this to specify how
its modality-specific data combines when two contracts draw from a common
resource budget. Same shape as `ModalSequential.composeExtra` but distinct
typeclass because the composition semantics differ across operators (sequential
is series; shared-resource is conceptually parallel under a common rail). -/
class ModalSharedResource (M : Type) [ModalData M] where
  composeExtra : ModalData.Extra M → ModalData.Extra M → ModalData.Extra M

instance : ModalSharedResource Untimed where
  composeExtra _ _ := ()

end ETCVerify
