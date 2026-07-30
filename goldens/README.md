# goldens/ — parity fixtures

Bit-exact oracle fixtures for the parity gates (L1 = mlx-lm, L2 = optiq).

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
  `scripts/regen-*.ts` generator that drives the oracle venv
  (`/Users/joshrossi/Code/mlx-lm/.venv`). Tracking them put ~180 MB of
  superseded blobs into git history. Tests gate on FILE PRESENCE (they skip
  when a fixture is absent), so a fresh clone runs the model-free suite
  untouched and grows its local fixtures by running the regen scripts.

**Layout** (`tests/goldens.ts` resolution): `goldens/<name>` is the
reference set (the `REFERENCE_MACHINE` box, apple-m4-pro);
`goldens/<machine-key>/<name>` overrides per machine (e.g. `apple-m1-max/`).

**Regenerating on a new machine:** run the relevant `scripts/regen-*.ts`
(each documents its oracle invocation), or the family's
`scripts/gen-*-golden.py` under the oracle venv for batched/dynamic oracles.

History note: `.bin` blobs committed before 2026-07-02 still occupy ~179 MB
of git history; reclaiming that requires a one-time history rewrite
(git-filter-repo strip-blobs or `git lfs migrate`) + force-push + re-clones
— tracked as an explicit maintainer decision, not yet done.
