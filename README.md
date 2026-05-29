# ETC Verify

**ETC Verify™** is a formal verification framework for cross-domain interface composition in complex engineered systems. It provides a Lean-based contract algebra with operators for sequential composition, shared-resource composition, refinement, and conformance checking.

This repository contains the foundational substrate: the core `Contract` type — parameterized over a modality marker — with explicit assumes, guarantees, silences, and modality-specific auxiliary data; the algebra's named operators with their soundness theorems. The substrate ships with `Untimed` as the only modality (preserving pre-v0.2.0 semantics); additional modalities are user-extensible via typeclass instances in downstream libraries without substrate modification.

ETC Verify is developed by [Evolving Technologies Corporation](https://www.evolvingtech.com). The name "ETC Verify" is a trademark of Evolving Technologies Corporation (USPTO Serial No. 99842416, application pending).

## Status

Active development. This is foundational substrate work; the algebra is being built incrementally, with each operator and its soundness theorem landing in turn. See [CHANGELOG.md](CHANGELOG.md) for current state.

## What ETC Verify is

A typed algebraic substrate for verification of architectural-level claims about engineering systems, where:

- Interfaces are first-class objects with explicit assumes, guarantees, and silences.
- Architectures are expressions in the algebra, composed via named operators.
- Verification produces named, located side conditions when composition obligations cannot be discharged.
- Edits to component contracts cascade through the kernel automatically, surfacing newly-failing or newly-satisfied obligations.

## What ETC Verify is not

A theorem prover; a model checker; an MBSE tool; a domain-specific verification framework for a particular industry. The substrate is general; calibration to specific engineering domains (aerospace ICDs, automotive interface specs, etc.) is layered on top in domain-specific repositories.

## Getting started

To be written as the substrate matures.

## License

Copyright (c) 2026 Evolving Technologies Corporation. Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text and [NOTICE](NOTICE) for attribution requirements.

The name "ETC Verify" is a trademark of Evolving Technologies Corporation.

## Citation

If you use ETC Verify in academic or technical work, please cite using the metadata in [CITATION.cff](CITATION.cff).

## Contributing

To be written.