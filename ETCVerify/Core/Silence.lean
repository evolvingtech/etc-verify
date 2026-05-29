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
# Silences as typed data

A `SilenceTag` represents an aspect of an interface's behavior that the
specification deliberately leaves unspecified. Treating silences as
first-class typed data (rather than as omissions) is one of the
distinguishing characteristics of ETC Verify's contract algebra: every
contract is required to enumerate its silences explicitly, making the
"what does this not commit to?" question mechanically auditable.

The `SilenceTag` structure carries a broad `category` (suitable for
pattern matching by substrate operations) and a free-form `description`
(human-readable detail). Domain-specific modules introduce category
values appropriate to their vocabulary; the substrate makes no
ontological commitments about which categories are valid.
-/

namespace ETCVerify

/--
A typed tag enumerating one aspect of behavior left unspecified by a contract.

The `category` field supports pattern matching by substrate operations
(e.g. "is this contract silent on FMA usage?"). The `description` field
provides human-readable detail for audit and review purposes.
-/
structure SilenceTag where
  /-- Broad category for pattern matching (e.g. "precision", "timing", "FMA_usage"). -/
  category : String
  /-- Human-readable description of what is left unspecified. -/
  description : String
deriving Repr, BEq

namespace SilenceTag

/-- Convenience constructor when description matches the category name. -/
def ofCategory (category : String) : SilenceTag :=
  { category := category, description := category }

end SilenceTag

end ETCVerify