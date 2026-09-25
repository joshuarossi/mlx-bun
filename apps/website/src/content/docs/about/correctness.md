---
title: Correctness
description: Numerical contracts, evidence, and the limits of migration verification.
---

The refactor preserves behavior before optimizing it. Passing a typecheck or a
synthetic test does not establish that a real model produces the same logits.

L1 compares against the applicable pinned mlx-lm path, bit-exact where the path's
contract requires it. L2 uses the applicable mlx-optiq reference. Lab paths need
explicit numerical criteria and a paired performance comparison before becoming
a default. Compatibility claims apply to named artifacts and configurations,
not every model and every serving option.

Read the [verification policy](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/CONTRIBUTING.md#numerical-and-performance-evidence)
and the inference package's
[current parity evidence](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/packages/inference/README.md#external-parity-evidence).
Remaining model and specialized-path checks live in the
[plan](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/PLAN.md).

Reference oracles, experiments, golden data, and benchmark runs live outside this
repository. The site does not republish the old benchmark ledger or imply that
its measurements verify the new implementation. Historical investigations remain
in [Git history](https://github.com/joshuarossi/mlx-bun/tree/02d723a2875153196f8c6c10bce2daf6f0044655).
