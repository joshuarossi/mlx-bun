// Preconfigured ORPO LoRA launcher — "everything on" by default: the flash-CCE
// Metal head (steel fwd+bwd, [M,V]-free) + segmented backward (gradient-checkpointed
// layer activations) + prefix-sharing (one forward over [prompt; chosen; rejected]).
// Each feature falls back + logs if a precondition isn't met (e.g. a row whose
// chosen/rejected prompts differ → two-forward for that row). Auto-detects e4b and
// sets its required training env flags BEFORE importing the model modules.
//
//   MODEL=/path/to/snapshot DATA=/path/to/datadir bun scripts/train-orpo.ts
//   (DATA dir must contain train.jsonl [+ optional valid.jsonl]; rows are
//    {prompt, chosen, rejected}.)
//
// Knobs (env, with sensible per-model defaults):
//   SEQ   max sequence length          (e4b 8192 · cpm 4096)
//   SEG   segment size (layers/segment) (2 — the validated e4b@8192 sweet spot)
//   ITERS training iterations           (100)
//   LR    learning rate                 (1e-5)
//   RANK  LoRA rank                     (16)   SCALE LoRA scale (2.0)
//   LAMBDA ORPO odds-ratio weight       (0.1)
//   FLASH=0  disable the flash head (use fused MLX quantizedMatmul head instead)
//   PREFIX=0 disable prefix-sharing (plain two-forward branches)
//   SEGOFF=1 disable the segmented backward (hold all layer activations — more memory)
//   ADAPTER  output adapter dir         (~/.cache/mlx-bun/mlx-bun-finetunes/orpo-<model>)

import { readFileSync, existsSync } from "node:fs";
import { basename } from "node:path";

const MODEL = process.env.MODEL;
const DATA = process.env.DATA;
if (!MODEL || !DATA) {
  console.error("usage: MODEL=<snapshot> DATA=<datadir with train.jsonl> bun scripts/train-orpo.ts");
  process.exit(1);
}
if (!existsSync(`${MODEL}/config.json`)) { console.error(`no config.json at ${MODEL}`); process.exit(1); }
if (!existsSync(`${DATA}/train.jsonl`)) { console.error(`no train.jsonl in ${DATA}`); process.exit(1); }

// Detect e4b/Gemma family from the raw config (cheap — no kernel imports yet) and set
// its required training env flags BEFORE the heavy dynamic imports below read them.
// `??=` so an explicitly-set env always wins.
const rawCfg = JSON.parse(readFileSync(`${MODEL}/config.json`, "utf8"));
const isGemma = JSON.stringify(rawCfg).toLowerCase().includes("gemma");
if (isGemma) {
  process.env.MLX_BUN_PERF_KERNEL ??= "0"; // e4b training: disable the inference perf kernels
  process.env.MLX_BUN_FUSED_GELU ??= "0";  // (the training-mode fused GeGLU is enabled by the trainer)
}

const num = (k: string, d: number) => (process.env[k] != null ? Number(process.env[k]) : d);
const SEQ = num("SEQ", isGemma ? 8192 : 4096);
const SEG = process.env.SEGOFF === "1" ? 0 : num("SEG", 2);
const ITERS = num("ITERS", 100);
const LR = num("LR", 1e-5);
const RANK = num("RANK", 16);
const SCALE = num("SCALE", 2.0);
const LAMBDA = num("LAMBDA", 0.1);
const FLASH = process.env.FLASH !== "0";
const PREFIX = process.env.PREFIX !== "0";
// ORPO L_SFT scope: "full" (default; paper/TRL-faithful chosen-NLL over
// prompt+response) | "response" (the pre-2026-07 response-only behavior).
const sftScopeEnv = process.env.SFT_SCOPE ?? "full";
if (sftScopeEnv !== "full" && sftScopeEnv !== "response") {
  console.error(`SFT_SCOPE must be "full" or "response" (got ${sftScopeEnv})`);
  process.exit(1);
}
const SFT_SCOPE: "full" | "response" = sftScopeEnv as "full" | "response";
const SAVE_EVERY = num("SAVE_EVERY", 0); // >0 → save a mountable checkpoint every N steps (crash-safe)
const RESUME = process.env.RESUME ?? "";  // path to an adapter/checkpoint dir → warm-start LoRA weights
const modelName = basename(MODEL.replace(/\/$/, "")).slice(0, 24);
// Adapters live in the cache, NOT the repo — alongside the other finetunes
// (~/.cache/mlx-bun/mlx-bun-finetunes/*). Override with ADAPTER=<dir>.
const ADAPTER = process.env.ADAPTER ?? `${process.env.HOME}/.cache/mlx-bun/mlx-bun-finetunes/orpo-${isGemma ? "e4b" : "cpm5"}`;

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");
const { ChatTemplate } = await import("../src/chat-template");
const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");
const { peakMemory, resetPeakMemory } = await import("../src/mlx/ffi");
import type { JobEvent } from "../src/jobs/types";

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

console.log(`\n=== ORPO LoRA — ${modelName}${isGemma ? " (e4b: PERF_KERNEL=0 FUSED_GELU=0)" : ""} ===`);
console.log(`head:        ${FLASH ? "flash-CCE Metal (steel fwd+bwd, [M,V]-free)" : "fused linear-CE (MLX quantizedMatmul)"}`);
console.log(`segmented:   ${SEG > 0 ? `on (${SEG} layers/segment — bounds activation memory)` : "off (all activations resident)"}`);
console.log(`prefix-share:${PREFIX ? " on (single forward over [prompt; chosen; rejected]; two-forward fallback on prompt mismatch)" : " off (two-forward)"}`);
console.log(`sft_scope:   ${SFT_SCOPE}${SFT_SCOPE === "full" ? " (paper/TRL-faithful chosen-NLL over prompt+response; SFT_SCOPE=response for the old response-only term)" : " (pre-2026-07 response-only chosen-NLL)"}`);
console.log(`seq=${SEQ} iters=${ITERS} lr=${LR} rank=${RANK} scale=${SCALE} λ=${LAMBDA}  → ${ADAPTER}`);
if (RESUME) console.log(`warm-start:  from ${RESUME} (weights only; optimizer + schedule restart)`);
console.log("");

const losses: number[] = [];
let lastStepT = Date.now();
const stepMs: number[] = [];
resetPeakMemory();
await trainLora(model, tok, tmpl, DATA, {
  ...DEFAULT_TRAIN_CONFIG,
  method: "orpo",
  rank: RANK, scale: SCALE, rankScaling: "by_bits", numLayers: -1,
  iters: ITERS, learningRate: LR, orpoLambda: LAMBDA, orpoLrSchedule: "cosine", orpoWarmupIters: Math.min(10, Math.floor(ITERS / 10)),
  orpoFlashCe: FLASH,            // flash-CCE Metal head (implies fused)
  orpoFusedCe: !FLASH,          // fall back to the MLX fused head if FLASH=0
  orpoChunkSize: 512,
  segmentSize: SEG,             // segmented backward (0 = off)
  orpoPrefixShared: PREFIX,     // single concat forward (per-row two-forward fallback)
  sftScope: SFT_SCOPE,          // SFT_SCOPE=response reproduces pre-2026-07 runs
  warmStartAdapter: RESUME,     // RESUME=<adapter/checkpoint dir> → continue from its weights
  maxSeqLen: SEQ, batchSize: 1, seed: 0,
  stepsPerReport: 1, stepsPerEval: SAVE_EVERY > 0 ? SAVE_EVERY : 1_000_000,
  saveCheckpoints: SAVE_EVERY > 0, // crash-safe: mountable checkpoint dirs under <ADAPTER>/checkpoints
  adapterPath: ADAPTER, baseModel: MODEL,
}, (e: JobEvent) => {
  if (e.type === "stage" && e.message) console.log(`  · ${e.message}`);
  if (e.type === "metric" && e.kind === "train") {
    const now = Date.now(); stepMs.push(now - lastStepT); lastStepT = now;
    losses.push(e.loss as number);
    const n = losses.length;
    if (n <= 3 || n % 10 === 0) console.log(`  step ${n}: loss ${(e.loss as number).toFixed(4)}  (${(stepMs[stepMs.length - 1]! / 1000).toFixed(1)}s/step, peak ${(peakMemory() / 1e9).toFixed(1)} GB)`);
  }
});

const finite = losses.every((l) => Number.isFinite(l));
const med = stepMs.slice(1).sort((a, b) => a - b)[Math.floor((stepMs.length - 1) / 2)] ?? stepMs[0] ?? 0;
console.log(`\n=== done: ${losses.length} steps, loss ${losses[0]?.toFixed(4)} → ${losses[losses.length - 1]?.toFixed(4)}${finite ? "" : "  (NON-FINITE!)"}`);
console.log(`    median ${(med / 1000).toFixed(1)}s/step, peak ${(peakMemory() / 1e9).toFixed(1)} GB, adapter → ${ADAPTER}`);
weights.dispose();
