#!/bin/bash
# Keep the model-free tier together; run native test files in fresh processes.
# Models can retain process-lifetime mmap/native state, and runtime overrides
# can affect a later file's module initialization. A whole native directory in
# one process both crosses laptop memory limits and contaminates parity cells.
set -uo pipefail
cd "$(dirname "$0")/.."

# Hygiene gate (the "mess can't re-form" guarantee — binary/large-file
# allowlist + docs-map coverage). Fail fast before any test runs.
printf '== hygiene gate ==\n'
bun scripts/check-hygiene.ts || exit 1
printf '== typecheck (repository, web, portable engine) ==\n'
bun run typecheck || exit 1

echo "== model-free: tests/unit tests/serve tests/using =="
bun test tests/unit tests/serve tests/using || exit 1
for file in tests/parity/*.test.ts tests/research/*.test.ts; do
  [ -f "$file" ] || continue
  echo "== native: $file =="
  bun test "$file" || exit 1
done
echo "== all test tiers green =="
