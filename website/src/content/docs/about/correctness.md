---
title: Correctness
description: Numerical contracts, reference implementations, and their limits.
---

mlx-bun compares forward-pass logits with pinned reference implementations.
The comparison uses matching weights, cache state, execution shape, and
numerical settings. The [benchmark ledger](/reference/benchmarks/) records
which checks ran and where differences remain.

The project distinguishes three contracts:

- L1 uses mlx-lm as the oracle for supported matching computations, including
  its uniform affine KV quantization scheme.
- L2 uses mlx-optiq for supported extensions such as per-layer mixed KV.
- Lab methods without an external oracle require their own quality and
  performance evidence. They do not inherit a bit-exact claim from L1 or L2.

Oracle fixtures come from explicit reference runs. Tests compare against
those fixtures; model output is not used to manufacture its own expected
answer. Machine-specific fixtures account for native kernel differences.
The [contribution guide](https://github.com/joshuarossi/mlx-bun/blob/main/CONTRIBUTING.md)
explains how to run the relevant test tiers.

## What parity establishes

Bit-exact logits establish numerical agreement for the computation tested.
They do not guarantee identical full responses across different batching
shapes, sampling policies, or cache schemes. They also do not establish the
truth of a model's answer or rule out hallucinations.

Server behavior defaults are a separate choice. Consult
[server configuration](/reference/server-config/) for compatibility settings,
and the [model roster](/reference/models/) for supported combinations and
modality-specific limits.
