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

-- ETC Verify: top-level module.
-- Importing `ETCVerify` brings the substrate's public API into scope.

import ETCVerify.Core.Silence
import ETCVerify.Core.Contract
import ETCVerify.Operators.Sequential
import ETCVerify.Operators.SharedResource
import ETCVerify.Operators.Refinement
import ETCVerify.Operators.Conformance
import ETCVerify.Timed.Basic
import ETCVerify.Timed.TimeIndexed