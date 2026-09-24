# Refactor plan

Open work only; delete a block when its exit criteria are met. New files need
Josh's approval. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

## Verify the migrated library

- [ ] Restore the minimum reproducible oracle and comparison tooling. Recover
  `scripts/oracle/requirements.lock` and setup from the historical source linked
  in ARCHITECTURE; preserve the complete lock, Python version, and Metal wheel
  hash in executable configuration. Audit script dependencies before migration.
  Exit: a documented command sets up and validates the pinned reference without
  relying on one developer's environment; setup does not download model weights.
- [ ] Establish real-weight parity for Qwen Trellis, Gemma, and MiniCPM against
  their applicable oracle and main. Cover logits, state continuation, and the
  relevant specialized paths under identical artifacts and settings. Exit:
  reproducible comparisons meet the numerical contracts, with curated evidence;
  synthetic tests alone do not close this item.
- [ ] Run paired same-machine performance comparisons against main using the
  same artifacts and configuration. Exit: decode, prefill, complete-request time,
  and memory evidence is recorded; regressions are resolved or explicitly reviewed.

## Make the developer contract reproducible

- [ ] Source README examples from executable examples or existing behavior tests;
  run them in CI alongside typechecking and the architecture gate. Exit: displayed
  examples have one tested source and missing native prerequisites are explicit.
- [ ] Integrate the existing packed-package consumer checks into repeatable release
  validation. Exit: clean Bun projects import both high-level and component APIs
  and exercise bundled natives without depending on the checkout.
- [ ] Establish short contributor and agent entry guidance with the verification
  tooling. Exit: rules and commands have one home, with no duplicated status ledger.

## Migrate applications after library verification

- [ ] Agree app ownership before adding files. Move Pi protocols, job contracts,
  engine host, and completion clients into their respective app domains; recover
  their originals from `src/contracts/` in the historical source. Exit: apps consume
  library interfaces without app contracts or upward imports inside the library.
- [ ] Preserve the `mlx-bun` terminal experience and Bun, Homebrew, curl-script,
  and source-checkout installation paths. Add generated surface reference and
  coverage checks with the CLI/server migration. Exit: the app and its install
  paths work from release artifacts, with documented public surfaces matching code.
