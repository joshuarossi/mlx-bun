---
title: Correctness
description: Numerical contracts, evidence, and the limits of verification.
---

mlx-bun preserves numerical behavior before optimizing it. Passing a typecheck or a
synthetic test does not establish that a real model produces the same logits.

L1 compares against the applicable pinned mlx-lm path, bit-exact where the path's
contract requires it. L2 uses the applicable mlx-optiq reference. Lab paths need
explicit numerical criteria and a paired performance comparison before becoming
a default. Compatibility claims apply to named artifacts and configurations,
not every model and every serving option.

Read the [verification policy](https://github.com/joshuarossi/mlx-bun/blob/main/CONTRIBUTING.md#numerical-and-performance-evidence)
and the inference package's
[parity evidence](https://github.com/joshuarossi/mlx-bun/blob/main/packages/inference/README.md#external-parity-evidence).
Open model and specialized-path checks live in the
[plan](https://github.com/joshuarossi/mlx-bun/blob/main/PLAN.md).

Reference oracles, experiments, golden data, and benchmark runs live outside this
repository. The site does not republish the old benchmark ledger or imply that
its measurements verify the current implementation. Historical investigations remain
in [Git history](https://github.com/joshuarossi/mlx-bun/tree/02d723a2875153196f8c6c10bce2daf6f0044655).
