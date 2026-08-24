---
name: parity-regen
description: Regenerate parity goldens from the pinned mlx-lm/optiq oracle venv and run the parity gates. Use after an oracle bump, on a new machine, or when a gated parity test skips for a missing golden.
---

# parity-regen

Goldens are a CACHE of the oracle (goldens/README.md): `.json` manifests are
tracked; `.bin` logit blobs are machine-specific and untracked. Regeneration is
always an explicit command, never automatic.

1. Oracle: `/Users/joshrossi/Code/mlx-lm/.venv/bin/python` with the pins in
   docs/reference/environment.md. Weights must already be downloaded
   (`mlx-bun get …`) — never download multi-GB models from a session.
2. `bun scripts/regen.ts <parity|parity-26b|kvq|rotating-kvq|mixed-kv|lora|fused-sdpa|universal|qwen-parity|minicpm5|minicpm5-kv|turboquant|audio-fixtures> [args]`
   — each job drives its python half in scripts/oracle/ and writes to the
   machine-specific golden dir (`tests/goldens.ts` resolution).
3. Model-free oracles: `bun scripts/op-parity-check.ts` (ops vs oracle build),
   `bun scripts/parity-check.ts` (logit/greedy harness).
4. Run the gated suite: `MLX_BUN_TEST_TIER=weights bun test tests/<file>` for
   the family you regenerated (see the test header for its gate), then
   `bash scripts/test.sh` for the full two-shard pass before claiming parity.
5. A golden that differs after regeneration on the SAME machine and oracle is
   a model regression; on a different machine it is expected (fast-SDPA
   dispatch diverges across chips) — record which.
