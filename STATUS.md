# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity contract:** **L1** = mlx-lm bit-exact parity (the naked default) ·
**L2** = mlx-optiq bit-exact parity (mixed-KV composition) · **Lab** = original
optimizations with no external oracle, gated by KL/eval + a paired-A/B win vs
the L1 baseline before any default (docs/design/unified-engine-frontier-plan.md).

## Released: mlx-bun v0.0.13 (2026-08-17)

Qwen3.8-27B text support and the GLM fixed-context admission correction are
published on GitHub, npm, and the Homebrew tap. The signed/notarized arm64
archive is 80,421,168 bytes with SHA-256
`7766573a6693a6038b2e23cee67f337718d971e2cdbc310f511e4d9155cf5b17`;
Apple accepted notarization submission
`edde8b8f-1d8d-4722-878f-0b6eadc63ae5`. The two-shard release gate passed
1,940 tests with 71 intentional skips, zero failures, and 28,382 assertions.
Qwen native MTP is explicitly not part of this release: review proved its
recurrent target state cannot yet satisfy the shared verifier's rollback
contract, so companion artifacts fail early with the precise reason.

## Post-release on main (2026-08-18, unreleased)

Serving changes landed after the v0.0.13 tag: (1) **memory admission now
clamps instead of rejecting** — a fitting prompt with a broad client
`max_tokens` is capped to the room remaining under the safe context on every
model (v0.0.13 scoped this to GLM's fixed context; the generic path still
400'd a prompt with 8k of generation room over a 17-token overshoot —
regression-pinned in tests/server-admission.test.ts). Only a prompt that
leaves no generation slot rejects. (2) **Qwen native MTP is unblocked** —
see the 14g entry below. (3) **Qwen3.8 VISION (images) SERVES and the video
frames pipeline is gated** — 14v LANDED / 14w frames-complete, full detail
in PLAN 14v/14w: dedicated tower port (bit-exact vs mlx-vlm pinned to mlx
0.31.2; new conv3d binding; PIL-fixed-point bicubic; ensure_fused_sdpa's
72→80 pad), interleaved mRoPE via the reference's verbatim Metal kernel with
positions/delta exact, e2e greedy token-exact on 2/3 image fixtures +
step-0-argmax on all, HTTP serve smoke green (image_url content parts;
/v1/models now advertises vision), video preprocessor + gridT>1 tower
BIT-EXACT on the sidecar-extracted fixture clip. (4) **video FILES SERVE**
(14w complete): the AVFoundation sidecar is productized as
`mlx-bun-frame-extract` (src/native/frame_extract.swift → release bundle +
native pack v0.3.0 + dev compile-on-demand), `video_url`/`video` content
parts decode → frames → the gated pipeline on Qwen3.5-family models, and
the serve smoke covers image + video + text isolation on one server.
**RELEASE BLOCKER: publish `native-v0.3.0` and bake its sha256/size into
src/native-pack.ts before the next package tag** (PLAN 14w). A running
`serve` needs a restart to pick all of this up (the CLI symlink serves the
repo working tree).

## Active: TurboQuant weights — rotation-folded quantization (opened 2026-08-17)

New phase in PLAN.md ("TurboQuant weights"): QuaRot/SpinQuant-style
rotation folding ahead of quantization into mlx's existing formats
(affine/mxfp4/nvfp4 — no new kernels), targeting a
`Qwen3.8-27B-MTP-turbo` that beats OptiQ-4bit / plain 4bit at equal
effective bpw (ppl + frozen 6-task eval gate). HF scan: the entire MLX
ecosystem handles outliers by per-layer allocation; nobody ships a
rotation-based quant of this model — that's the gap. **W0 is DONE**
(2026-08-17, branch feature/turboquant-weights): src/quantize/rotate.ts
folds Llama-3.2-1B-Instruct-bf16 (untie → γ → R₁ → per-head R₂) and the
folded model passes the parity gate through the unmodified engine —
teacher-forced two-model KL mean 0.00131 (16×256), greedy trajectories
identical except near-tie flips (margins ≤0.125), per-tensor max|w|
down 3–5×. Evidence in the PLAN.md W0 entry.

**PROGRAM COMPLETE through W5c/W6-staging (2026-08-18 night 2):** THE
artifact = **mjriii/Qwen3.8-27B** (staged in the hub cache, 16.3 GB,
GPTQ + sensitivity-allocated 4/8-bit, vision + video + MTP bundled in
ONE repo) — full board + decision rationale in
docs/design/turboquant-weights.md §FINAL BOARD. Key finding: 27B quality
SATURATES at ≥4.5 bpw on ppl AND MMLU/GSM8K (all top arms tied);
recipes matter below 4 bpw (TQ-mixed staged as the 13 GB variant).
Serve gauntlet on THE artifact: text/image/video ✓ through our engine;
MTP 76% accept (near-tie divergence flag recorded, not claimed
lossless). AWAITING JOSH: publish go (mlx-bun upload), then delete the
51 GB bf16 trunk; Josh-gated frontier tail = quiet-box tps + M4 Pro
24 GB cut + GGUF anchor (W7).

**W1–W4 DONE overnight 2026-08-18 (branch feature/turboquant-weights;
full findings in the PLAN boxes + docs/design/turboquant-weights.md):**
qwen3_5 corridor map (R2 off — attn output gate; DeltaNet folds on its
residual dims; vision seam = merger.linear_fc2; MTP companion same-seed),
streaming fold/quantize at 27B scale (ShardedWriter + Weights.releaseShard
— the naive path OOM'd; fold peak 17.9 GB), fold proven through STOCK
mlx-lm (worst KL 0.0035, flips only at exact ties). **Measured verdict:
rotation-only RTN loses at 4-bit (+5% ppl both scales), wins at ≤4 bpw
(uniform-3 −24%; mixed paired-control worse).** Artifact of record:
`~/models/Qwen3.8-27B-TQ` — rotated mixed 4/3-bit, 3.86 bpw / 13.9 GB
(the 14z M4-Pro fit lever), ppl 4.932 vs plain-4bit 4.659@4.5bpw;
VALIDATED end-to-end (server chat reasoning ✓, vision over HTTP ✓, MTP
harness 71% accept + token-identical ✓; the HTTP MTP lane has a
PRE-EXISTING slice bug reproducing with stock artifacts — recorded).
Next actions: W6 release is STAGED (cards with measured tables in the
artifact dirs) awaiting Josh's go; W5 = GPTQ-on-rotated for the 4-bit
flagship win; frozen 6-task eval cells + quiet-box numbers owed.
Source artifacts: the trunk
and MTP head are SEPARATE repos — mlx-community/Qwen3.8-27B-bf16
(11 shards, 54.7 GB, Josh-run `mlx-bun get`, needed by W4) +
mlx-community/Qwen3.8-27B-MTP-bf16 (MTP companion, ~850 MB, already
local + verified).

## Active: serving architecture consolidation

S0 through S3 are complete in the current worktree. Chat and raw-text,
streaming and non-streaming now share one `CompletionExecutor` for
admission, semantic events, logprobs, finish reason, usage, lane reporting,
and cleanup. `GenerationGateway.place()` creates one immutable scheduling
decision that both reporting and execution use. Model construction now resolves
one immutable declaration containing artifact/config identity, fidelity,
required engine capabilities, and the loader/graph/loop composition. Exact
Qwen3.8 OptiQ and GLM-5.2 Colibri revisions are pinned; dedicated family and
generic routes remain fallbacks. Exact mismatches refuse rather than downgrade,
and profiles cannot rewrite MTP, KV, adapters, grammar, or sampling. The staged
`mjriii/Qwen3.8-27B` quant stays on the Qwen family profile until GPQA evidence
and an immutable published revision exist. S3 now declares `serial` or
`continuous` at the immutable placement seam instead of predicting that a
request is "batched." Active-row count selects B=1 or B=N inside the
continuous scheduler; `--batch 1` and dedicated compositions retain the strict
serial executor. Existing B=1 parity evidence and 0.992–0.996 paired decode
ratios support the current default path. No feature is removed or substituted
to enter the scheduler. Post-S3 review hardening now carries the resolved KV
scheme through placement, cache conversion, and budget projection; rejects
configured caches that cannot actually convert; routes in-process A/B levers
through the runtime snapshot interface; and atomically publishes complete
quantized model directories. Raw scheduler `kvConfig` bypasses are gone, so
production, tests, and diagnostics all use the same `KvScheme` interface.
The scheduler fails fast if a direct caller supplies a scheme it cannot
execute, preventing bf16 service with quantized accounting.
Protocol adapters now retain accumulated usage on
mid-stream failures as well, without adding that bookkeeping to ordinary
OpenAI streaming. A worked numerical oracle now pins the public weight-transform
interface. After the GPQA pause, 97 focused model-free tests and all three real
mixed-KV GPU gates pass: MiniCPM5 B=1 is bit-exact, MiniCPM5 B=2 peaks at KL
1.21e-1 under its 0.2 padded-row bar, and Gemma 12B rotating-quant peaks at KL
0/3.04e-3 under its 1e-3/1e-1 bars.

The final two-shard gate passes 2,064 tests with 75 intentional skips and zero
failures; TypeScript, both Bun entry bundles, web bundle freshness, hygiene,
and whitespace checks pass too. The same acceptance pass fixed three mainline
lifecycle defects rather than carrying them into the PR. A queued chat render
can no longer run after its turn settles and dereference cleared state or
duplicate final content. GLM's compressed-cache row filter now slices padding
before selecting rows, so the owned result preserves exact row values. Atomic
quantization once again accepts a caller-created empty destination while still
refusing populated output. The UI fix was exercised through a real two-turn
browser conversation: streaming, tool cards, context carryover, metrics, and
composer recovery all worked with no runtime exception or duplicated response.
These fixes do not touch the decode loop: the chat change is DOM lifecycle
work, GLM row filtering runs only when rows leave a batch, and atomic
publication is offline I/O.

Post-review hardening also closes two mutability holes: resolved KV schemes
own frozen copies of nested layer/TurboQuant declarations, and placement
freezes the exact request shape before mechanism selection or callbacks. A
fresh interleaved main-vs-branch MiniCPM5 serial benchmark directly covering
the new sampler path measured a 1.000 median-best decode ratio (about 265.0
tok/s on both sides).

Next action (S4): open the PR into `main`, resolve review and CI findings, then
repeat the real conversation smoke on merged `main` and archive this phase.

## Completed: native Colibri/GLM-5.2 port (Phase 21, closed 2026-08-17)

G0–G8 complete and shipped in v0.0.13; G6R stages 0–2 and G7a–c landed
after. The full gate-by-gate record (memory contract, MTP, DSA, learning
shakeouts, serving parity, evidence paths) is archived in
[PLAN-archive.md](PLAN-archive.md) under "STATUS archive 2026-08-18";
the durable engineering record is PLAN.md Phase 21 and
[docs/design/colibri-glm52-port.md](docs/design/colibri-glm52-port.md).
Pre-Colibri stabilization (Phase 22) is likewise closed —
[docs/design/pre-colibri-stabilization.md](docs/design/pre-colibri-stabilization.md).

## Backlog

Open work lives in PLAN.md's unchecked phase boxes (currently: TurboQuant
weights W5/W6, audio A5, serve-lane Qwen-MTP slice bug, frozen-eval cells
for the TQ/GPTQ artifacts). The July-era ranked backlog and workstream
lists were archived verbatim to [PLAN-archive.md](PLAN-archive.md)
("STATUS archive 2026-08-18") — mine them there; do not resurrect them
here (CONTRIBUTING.md rule 4).
