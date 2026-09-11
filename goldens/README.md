# goldens/ — parity fixtures

Bit-exact oracle fixtures for the parity gates (L1 = mlx-lm, L2 = optiq).

For the complete MiniCPM5 workflow, use the [pinned setup and comparison
recipe](../docs/reference/environment.md#reproduce-the-minicpm5-logit-comparison).
It writes fresh external fixtures and fails on missing inputs.

**Two kinds, two policies:**

- **`.json` manifests — tracked.** Machine-independent or cheap: prompts,
  greedy trajectories, left-padding, shapes, chat-template renders,
  tokenizer fixtures. Small, diffable, and the part reviews care about.
  A manifest that depends on untracked `.bin` blobs must also record the
  oracle/model provenance and each blob's SHA-256; otherwise a stale local
  blob can masquerade as a model regression even after regeneration.
- **`.bin` logit/tensor blobs — NOT tracked** (`.gitignore`d since
  2026-07-02). They are MACHINE-SPECIFIC (metallibs diverge across chips at
  the fast-SDPA dispatch boundary — see PLAN.md "goldens are
  machine-specific") and fully regenerable: each family has a
  `scripts/regen/` generator that drives the oracle selected through
  `MLX_BUN_ORACLE_VENV`. Tracking them put ~180 MB of
  superseded blobs into git history. Most gated tests skip when fixtures are absent. The explicit MiniCPM5
  comparison fails instead, so missing inputs cannot look like a passing
  comparison. The model-free suite needs no downloaded weights or goldens.

**Layout** (`tests/support/goldens.ts` resolution): `goldens/<name>` is the
reference set (the `REFERENCE_MACHINE` box, apple-m4-pro);
`goldens/<machine-key>/<name>` overrides per machine (e.g. `apple-m1-max/`).

**Regenerating on a new machine:** use `bun scripts/regen.ts --help` for
family commands, or the generators under `scripts/oracle/` for batched and
dynamic oracles. `MLX_BUN_GOLDEN_DIR` selects an isolated directory for reads
and writes, without fallback to the reference set.

History note: `.bin` blobs committed before 2026-07-02 still occupy ~179 MB
of git history; reclaiming that requires a one-time history rewrite
(git-filter-repo strip-blobs or `git lfs migrate`) + force-push + re-clones
— tracked as an explicit maintainer decision, not yet done.
