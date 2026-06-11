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

FILES=(tests/*.test.ts)
N=${#FILES[@]}
HALF=$((N / 2))

echo "== shard 1/2 (${HALF} files) =="
bun test "${FILES[@]:0:HALF}" || exit 1
echo "== shard 2/2 ($((N - HALF)) files) =="
bun test "${FILES[@]:HALF}" || exit 1
echo "== all shards green =="
