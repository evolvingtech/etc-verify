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

import ETCVerify.Core.Modal

/-!
# Time-indexed resources

`TimeIndexed T R` is the canonical resource type for the `sharedResource`
operator under the `Timed T` modality. A scalar resource budget (watts,
megabits, contact-window seconds) is rarely constant across time: a lunar
power rail varies with eclipse cycles, scheduling, and contact windows. The
time-indexed resource replaces a scalar `R` with a function `T → R` giving the
resource value at each instant.

The two instances below — pointwise `Add` and pointwise `LE` — are exactly what
the existing `sharedResource` operator requires (`[Add R] [LE R]`) when
instantiated at `R := TimeIndexed T R'`. Under them, the operator's
resource-feasibility side condition `consumed ≤ available` unfolds to the
pointwise reading

  `∀ t, consumed t ≤ available t`,

i.e. instantaneous demand never exceeds instantaneous supply at any instant.
This is the **pointwise** (per-instant power) interpretation of a shared rail.

## Why pointwise is the v0.2.1 default

Per O-3 the resource *shape* is a resource-type-level distinction, not an
operator or architecture choice. Three shapes are engineering-recognizable:
pointwise (instantaneous demand ≤ instantaneous supply), integral (energy drawn
over a window ≤ energy available — the battery-over-an-eclipse case), and peak
(maximum demand ≤ a rating). v0.2.1 instantiates pointwise first: it is the
most conservative reading (pointwise satisfaction implies any reasonable
integrated satisfaction), it needs only the `Add`/`LE` machinery already used by
the untimed `SharedResource` so it forces no Mathlib activation by itself, and
it corresponds directly to instantaneous engineering intuition. The peak and
transient concern is moreover already carried by the `transient_response`
silence that `sharedResource` emits, so pointwise-plus-that-silence is coherent,
honest scope.

Integral and peak variants are **additive** future resource types — a separate
`TimeIndexed`-family definition each, with its own pointwise-vs-integral-vs-peak
feasibility reading — not a modification of this one and not a re-architecture
of the operator (O-3). They are deliberately deferred from v0.2.1.

The module depends only on Lean core. No Mathlib import is required and none
should be added: the substrate fixes neither the time index `T` nor the
resource `R`; a downstream package choosing real-valued or rational `T`/`R`
activates Mathlib in its own package.

## Silences

This module introduces no silences. It supplies a resource type and its two
ordered-algebra instances; obligations on a composed architecture arise from the
`sharedResource` operator, not from this type.
-/

namespace ETCVerify

/-- A resource whose value varies across a time index `T`. The canonical
resource type for `sharedResource` under the `Timed` modality: where an untimed
budget is a scalar `R`, a timed budget is a function `T → R` giving the resource
value at each instant. `T` is the time index (user-supplied, never fixed by the
substrate) and `R` is the underlying resource (watts, megabits, …). -/
def TimeIndexed (T R : Type) : Type := T → R

/-- Pointwise addition of time-indexed resources: combined consumption at each
instant is the sum of the per-component consumptions at that instant. Supplies
the `[Add R]` the `sharedResource` operator needs when `R := TimeIndexed T R'`. -/
instance {T R : Type} [Add R] : Add (TimeIndexed T R) where
  add f g := fun t => f t + g t

/-- Pointwise order on time-indexed resources: `f ≤ g` exactly when `f t ≤ g t`
at every instant. Supplies the `[LE R]` the `sharedResource` operator needs when
`R := TimeIndexed T R'`; under it the operator's feasibility side condition reads
`∀ t, consumed t ≤ available t` — the instantaneous-power interpretation. -/
instance {T R : Type} [LE R] : LE (TimeIndexed T R) where
  le f g := ∀ t, f t ≤ g t

end ETCVerify
