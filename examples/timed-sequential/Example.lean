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
# Timed sequential composition

A minimum-viable example exercising the `Timed` modality end-to-end. The time
type is `Nat`, read as milliseconds.

Two timed contracts on natural numbers:

- `ingest`  : guarantees `output = input + 1`; carries a latency of 3 ms.
- `process` : guarantees `output = 2 * input`; carries a latency of 5 ms.

The sequential composition `ingest ⨾ process` is derived by the *same*
`sequential_sound` theorem that serves the `Untimed` modality. The substrate
was not modified to accommodate `Timed`. In addition, the composed contract's
`extra.latency` is the sum `3 + 5 = 8 ms`, computed by the
`ModalSequential (Timed Nat)` instance.

The point is twofold: the Path 4b architecture carries a new modality through
the existing operator and theorem with zero substrate change, and the timing
data composes correctly alongside the behavioral contract.
-/

namespace ETCVerifyExamples.TimedSequential

/-- "Ingest": no precondition; guarantees output equals input plus one;
latency 3 ms. -/
def ingest : Contract (Timed Nat) Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = i + 1
  silences   := []
  extra      := { latency := 3 }

/-- "Process": no precondition; guarantees output equals twice the input;
latency 5 ms. -/
def process : Contract (Timed Nat) Nat Nat where
  assumes    := fun _ => True
  guarantees := fun i o => o = 2 * i
  silences   := []
  extra      := { latency := 5 }

/-- `fun n => n + 1` implements `ingest`. -/
theorem ingest_implemented : Implements (fun n : Nat => n + 1) ingest :=
  fun _ _ => rfl

/-- `fun n => 2 * n` implements `process`. -/
theorem process_implemented : Implements (fun n : Nat => 2 * n) process :=
  fun _ _ => rfl

/-- The composed implementation satisfies the composed contract. The proof is
the substrate's `sequential_sound`, unchanged from the `Untimed` case. -/
theorem ingest_then_process_implemented :
    Implements ((fun n : Nat => 2 * n) ∘ (fun n : Nat => n + 1)) (ingest ⨾ process) :=
  sequential_sound ingest process
    (fun n => n + 1) (fun n => 2 * n)
    ingest_implemented process_implemented

/-- The composed contract's latency is the sum of the component latencies:
`3 + 5 = 8 ms`. This is the `ModalSequential (Timed Nat)` instance doing its
work; under `Untimed` the analogous field would be the uninformative `()`. -/
theorem ingest_then_process_latency :
    (ingest ⨾ process).extra.latency = 8 :=
  rfl

end ETCVerifyExamples.TimedSequential
