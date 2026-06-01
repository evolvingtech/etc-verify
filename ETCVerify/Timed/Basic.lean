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
# Timed modality

The `Timed T` modality is the substrate's first non-trivial modality. It
carries timing data in the `extra` field of a contract and composes that data
under the algebra's operators. It is parameterized over a user-supplied time
type `T`: the substrate fixes no concrete notion of time and depends only on
Lean core. A downstream package wanting real-valued or rational time supplies
that `T` (activating Mathlib in its own package if needed); the substrate
itself adds no Mathlib dependency.

This module is the worked example of the Path 4b extension promise: `Timed T`
plugs into the four operators and inherits the six soundness/refinement
theorems with no modification to any operator or theorem. Only typeclass
instances are added here.

v0.2.1 carries a single timing field, `latency`. Richer timing data (jitter,
validity windows, interval bounds) is deliberately deferred: it is a later
increment and is the point at which interval/order reasoning (and therefore a
Mathlib dependency in downstream packages) naturally enters.

## Silences

This module introduces no silences. A timed contract author may attach
timing-related `SilenceTag`s (category `"timing"`) to individual contracts to
record timing aspects deliberately left unmodeled; that is contract-author
discipline, not substrate machinery.
-/

namespace ETCVerify

/-- Modality marker for contracts carrying timing data, parameterized over a
user-supplied time type `T`. Parallel to `Untimed`; the marker is never
constructed in user code. What gets constructed is `Contract (Timed T) Input
Output`, whose `extra` field has type `TimedFields T`. -/
structure Timed (T : Type) where

/-- Auxiliary timing data carried by `Contract (Timed T) _ _` in its `extra`
field. v0.2.1 carries exactly one field, `latency`. Future timing data (jitter,
validity windows, interval bounds) would extend this structure with additional
named fields; they are deferred from v0.2.1 by design (see the module header).
Per O-5, timing values live in named fields accessed by projection, never in
typeclass-default behavior, to keep them inspectable for the planned
bidirectional diagram tooling. -/
structure TimedFields (T : Type) where
  /-- End-to-end latency carried by this contract, in the units of `T`. -/
  latency : T

instance {T : Type} : ModalData (Timed T) where
  Extra := TimedFields T

/-- Sequential composition of timing data: end-to-end latency through a series
chain is the sum of per-stage latencies. This is the first non-trivial
`composeExtra` in the substrate; the `Untimed` instance ignores its arguments,
whereas this one combines them. Requires only `[Add T]` (Lean core). -/
instance {T : Type} [Add T] : ModalSequential (Timed T) where
  composeExtra a b := ({ latency := a.latency + b.latency } : TimedFields T)

/-- Shared-resource composition of timing data: the composite's latency is the
`max` of the component latencies. Shared-resource composition is conceptually
parallel — two components drawing on a common rail run concurrently (the
`sharedResource` operator's own doc-comment frames it so) — so the composite is
governed by the slower branch, not by their sum. (Summation is the *series*
rule and belongs to `ModalSequential`; using it here would be wrong.) Requires
only `[Max T]` (Lean core).

Provenance: `max` is adopted on engineering judgment. The May 28 LSIC Surface
Power Transmission Workshop produced no usable signal on the latency-combination
question, so this is the conceptually-parallel default rather than a
workshop-confirmed rule. It is revisable: a different combination semantics
would be an additive change to this instance, not a re-architecture. -/
instance {T : Type} [Max T] : ModalSharedResource (Timed T) where
  composeExtra a b := ({ latency := max a.latency b.latency } : TimedFields T)

end ETCVerify
