#!/bin/bash
# Run the test suite in two processes (alphabetical halves).
#
# Why sharded: 27 model-loading test files in ONE bun process accumulate
# enough GPU residency on a 24 GB machine that an async Metal allocation
# eventually fails — which is the documented-UNCATCHABLE error (PLAN
# Phase 6: the completion-handler throw is std::terminate; bun dies with
# a crash report and zero test output). Each half passes with headroom;
# the union deterministically crosses the line. Two processes return all
# memory between halves. Plain `bun test` still works on machines with
# more headroom.
set -uo pipefail
cd "$(dirname "$0")/.."

# Hygiene gate (the "mess can't re-form" guarantee — binary/large-file
# allowlist + docs-map coverage). Fail fast before any test runs.
printf '== hygiene gate ==\n'
bun scripts/check-hygiene.ts || exit 1
printf '== typecheck (repository, web, portable engine) ==\n'
bun run typecheck || exit 1

# Shard by DIRECTORY (the directory IS the gate): model-free suites first,
# then the weights/oracle-gated tiers in their own process so GPU residency
# from one heavy suite cannot OOM the next (an uncatchable std::terminate).
echo "== shard 1/2: tests/unit tests/serve tests/using (model-free) =="
bun test tests/unit tests/serve tests/using || exit 1
echo "== shard 2/2: tests/parity tests/research (weights/oracle-gated) =="
bun test tests/parity tests/research || exit 1
echo "== all shards green =="
