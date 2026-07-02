# v0.0.9 release notes (DRAFT — Josh edits + publishes)

Everything since v0.0.8 (2026-06-24). The big themes: the mlx-lm drop-in
surface is now materially complete, ORPO is paper-faithful, mlx-bun runs its
first generically-supported architectures at verified bit-exact parity, and an
adversarial review swept the whole engine — fixing 12 confirmed bugs and
overturning a load-bearing performance assumption.

## Drop-in compatibility with mlx_lm.server (the headline)

- **Endpoints:** `POST /v1/completions` (raw text completion, stream +
  non-stream), `GET /health` (byte-exact body), `GET /v1/models` now lists all
  registry models (+ `/v1/models/<id>`).
- **Request fields:** `min_p`, `xtc_probability`/`xtc_threshold`, `logit_bias`,
  `presence_penalty`/`frequency_penalty` (+ `*_context_size` windows),
  `logprobs`/`top_logprobs` with mlx-lm's EXACT semantics (same distribution,
  same response shape, same [0,11] validation). All L1-faithful ports of
  `sample_utils.py`.
- **Flags/defaults:** port 8080 + loopback host (matching mlx_lm.server;
  `--host 0.0.0.0` = LAN opt-in), `--temp` alias, `--max-tokens`,
  serve `--adapter <dir>` mounts at startup.
- **New CLI verbs:** `fuse` (fold LoRA into base — mlx-lm math, untouched
  modules bit-identical), `convert` (wraps the mixed-precision quantizer,
  `--target-bpw` exposed), `perplexity` (mlx_lm.perplexity methodology),
  `upload` (native HF push).
- Deliberately not ported: `role_mapping` (unreachable — every supported model
  ships a chat template). Remaining: `cache_prompt`, `evaluate` (planned as an
  lm-eval shim), `--draft-model`, awq/dwq/gptq (plan:
  docs/design/mlx-lm-tool-parity-plan.md).

## ORPO: paper-faithful by default

- **`sft_scope: full | response`** (default `full`): the chosen-NLL is now the
  token-mean CE over the full prompt+response — matching the ORPO paper, TRL,
  and xfactlab/orpo — implemented across every path (naive/chunked/fused/
  flash-CCE/prefix-shared/segmented). `response` reproduces old runs
  BIT-EXACTLY (regression-pinned). The odds-ratio terms stay response-only in
  both modes (matches TRL). CLI: `mlx-bun train --sft-scope`.
- The rest of the ORPO stack was adversarially verified correct against
  primary sources (odds-ratio math, gradients vs finite differences,
  prefix-sharing gradient flow, tokenization/label-shift).

## Generic model support (Tier-0)

- **New:** `src/model/universal/` — a config-driven UniversalDense module with
  explicit descriptors for llama, qwen2, qwen3, gemma, gemma2, phi3, olmo2,
  glm4, granite, starcoder2, smollm3 (+ mlx-lm's remapping: mistral etc.).
  bf16 (unquantized) checkpoints now load. Rope factory (llama3/yarn/longrope)
  verified bit-exact vs the oracle.
- **First three archs verified at L1 parity** (bit-exact per-step logits):
  Llama-3.2-1B-Instruct-4bit, Qwen2.5-0.5B-Instruct-4bit, gemma-2-2b-it-4bit.
- Dispatch ladder: dedicated → generated → generic → reject-with-helpful-error.
  Targeted models keep their optimized paths; a model can graduate.
  Design: docs/design/generic-model-support.md.

## Fixed (the adversarial-review wave)

- **`--l2` tier contract restored:** the L2 preset was enabling an
  envelope-gated perf kernel (not bit-exact vs optiq). Bare `--l2` is now
  genuinely optiq-bit-exact; the perf kernel is `--l3`/explicit opt-in.
  `generate --l2/--l3` no longer silently degrades to L1.
- Batched same-millisecond seed collision (identical concurrent completions);
  streaming per-layer KV-quant conversion (the missing half of optiq's
  tight-RAM fix); segmented compiled-decode mid-step failure KV corruption;
  `MLX_BUN_TRAIN_ATTN=flash` now refused on Gemma (unrevalidated crash path);
  eval-loss error swallowing; wrong tokens_per_sec metric; silent steel-kernel
  fallbacks now warn; flash-attention tests extended (D=256, sliding-window,
  non-tile T).
- Memory (the Dreaming): batching default flipped to serial (measured 1.7–1.9×
  faster for the real workload); `memory status` truth; third-person voice fix
  merged.
- CLI audit (14 findings): `fit --ctx` help matched code, `embed` auto-pick
  fixed, pi flag leakage into first message fixed, `--l1/2/3` + `generate` +
  `train-watch` documented, `setup` is a real alias, doc lies corrected.

## Performance truth (research, groundwork for the next release)

- The "decode is at the memory floor" claim was **overturned** with measured
  rooflines: only the 12B is at the bandwidth wall (~92%); CPM5/e4b/26B sit at
  58–70% with the host-side graph build as the top recoverable term. Ranked
  fix plan in-repo; wins land next release.
- The batching engine was audited (numerics solid, engine naive) — hotfixes +
  containment landing; plan: docs/design/batching-v2-plan.md.
- Registry duplicates root-caused (snapshot-per-commit accumulation);
  dedupe + `gc` landing.

## Infra

- CI gate added (typecheck + model-free tests on push/PR) — previously nothing
  ran on push.
- Repo hygiene: scratch artifacts untracked, megakernel research relocated,
  STATUS.md rewritten as a true current-state front door, doc map regenerated.

## Late additions (landed after the first draft)

- **Batching engine v2 (steps 1–3):** Qwen3.5/SSM models no longer fail under
  `--batch` (capability gate + serial drain); per-row failure containment; no
  serial-lane starvation; pipelined batched decode + sane cache cadence; the
  huge admit transient fixed; all GPU work under one lock.
- **Model management:** `ls` deduplicates to one row per repo (snapshot
  history via `ls --all-revisions`); new `mlx-bun gc` reclaims superseded
  snapshots (24.7 GB found on the dev machine) with a safety guard for
  unique files; `get` accepts substring queries; download lockfile, streamed
  resume verification, gated-repo auth hints; vision capability detected from
  config (the unified-vision 12B now shows `vision`). New doc:
  docs/reference/models.md.
- **Pi integration:** web-chat memory tools actually callable; `harness pi`
  registers exactly the served model; tool-calling fixed for Tier-0 generic
  models (Gemma sentinels no longer applied to non-Gemma tokenizers); vision
  advertised to pi; `mlx-bun pi` no longer leaks unknown flags into the first
  message.
- **Website + README:** six-goals restructure, drop-in guide, memory guide,
  the lab page, full CLI reference from a tracked source; deploy now triggers
  on reference-doc edits. NOTE the release sequence: push and publish in the
  same sitting — the site deploys from the push.
- **Test infra:** batched-serving goldens are machine-keyed (the M1-Max
  "failures" were M4-Pro fixtures; all code exonerated — mlx-lm reproduces
  mlx-bun token-for-token per machine); CI gate (typecheck + model-free tests).
- **Research (the lab):** decode-roofline re-measurement overturned the "at
  the floor" assumption (docs/investigations/decode-roofline-lookagain.md);
  curve-sampler distinctness theorem + witness numbers + preregistered
  protocol (docs/planning/curve-sampler-research-plan.md).
