---
title: Benchmarks
description: Find the measured comparisons and understand their scope.
---

The [benchmark ledger](/reference/benchmarks/) is the canonical record of
mlx-bun's performance, numerical parity, and model-quality results. It
includes M1 Max and M4 Pro measurements, the release comparisons, and
remaining regressions. This page links to that record so results and
qualifications stay together as new runs land.

When comparing runs, check the machine, exact model artifact, cache scheme,
speculation settings, request length, concurrency, and software revisions.
A cache hit measures a different workload from fresh prefill. Aggregate
throughput and the speed of one active request answer different questions.

For the current serving behavior, look for the default-batched head-to-head
results. Packed Qwen measurements have their own section because the stock
reference servers cannot load that artifact. Diagnostic runs are labeled in
the ledger with their machine conditions.

The ledger also documents the benchmark command and raw-output conventions
for reproducing a comparison. [Correctness](/about/correctness/) explains what
numerical parity does and does not establish.
