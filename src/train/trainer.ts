// LoRA trainer: SFT (masked cross-entropy) and DPO loops over a single
// quantized base, differentiating only the LoRA A/B leaves.
//
// The value_and_grad closure differentiates [...flatA, ...flatB]. Inside the
// closure we swap the incoming primal handles into the LoraWeights so the
// model's forward builds its graph against the differentiated leaves; after
// AdamW.step replaces a leaf, the writeback callback pushes the new handle
// back into the LoraWeights so the next forward (and the next closure swap)
// sees it. Base quantized weights are never in argnums — they stay frozen.

import { MlxArray, pinnedBufferCount } from "../mlx/array";
import { clearCache, peakMemory, activeMemory, cacheMemory, resetPeakMemory } from "../mlx/ffi";

const MEM_LOG = process.env.MLX_BUN_MEM_LOG === "1";
const gbStr = (b: number) => `${(b / 1e9).toFixed(2)}GB`;
import { ValueAndGrad } from "../mlx/autograd";
import * as ops from "../mlx/ops";
import { evalAll } from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import { Gemma4Model, type GradCheckpointCtx } from "../model/gemma4";
import { MiniCPM5Model } from "../model/minicpm5";
import { setTrainingAttn } from "../model/flash-attention";
import { setFusedGeluTraining } from "../model/fused-geglu-kernel";
import { SegmentedBackward, SegmentedBackwardGemma4, SegmentedBackwardOrpo, SegmentedBackwardOrpoGemma4, SegmentedBackwardOrpoPrefix, SegmentedBackwardOrpoPrefixGemma4, planSegmentsBySize } from "./segmented";
import type { LoadedTokenizer } from "../tokenizer";
import type { ChatTemplate } from "../chat-template";
import type { Emit } from "../jobs/types";
import {
  loadSftDataset, iterateSftBatches, loadDpoDataset, iterateDpoBatches,
  rowLength, type SftBatch, type DpoBatch,
} from "./dataset";
import {
  buildTrainableLora, attachForTraining, detachTraining, flatParams,
  saveAdapter, disposeLora, warmStartFromAdapter, type TrainableLora, type SaveAdapterConfig,
} from "./lora-params";
import { resolveRanks, bitsMapFromModel, readPerLayerKl, DEFAULT_TARGET_MODULES, type RankScaling } from "./rank";
import { sftLoss, dpoLoss, dpoRefLogps, dpoMetrics, orpoLoss, orpoMetrics, type ChunkCtx, type SftScope } from "./loss";
import { orpoLossPrefixShared, orpoLossPrefixSharedGemma, splitPrefixBatch } from "./prefix-shared";
import { AdamW, warmupCosineSchedule } from "./optimizer";
import { writeFileSync, appendFileSync, mkdirSync } from "node:fs";

export interface TrainConfig {
  method: "sft" | "dpo" | "orpo";
  rank: number;
  scale: number;
  rankScaling: RankScaling;
  targetModules: string[];
  numLayers: number;
  iters: number;
  learningRate: number;
  maxSeqLen: number;
  batchSize: number;
  gradAccumSteps: number;
  seed: number;
  stepsPerReport: number;
  stepsPerEval: number;
  betas: [number, number];
  weightDecay: number;
  /** LoRA-input dropout (PEFT-style), 0 = off. Training-only regularizer for
   *  small preference sets. Recompute-safe: the mask is keyed by (step, layer)
   *  so segmented/checkpointed recompute reproduces it. */
  loraDropout: number;
  /** rsLoRA: scale the LoRA update by α/√rank instead of α, so per-layer rank
   *  scaling (by_bits/by_kl) changes capacity, not step size. Saved in the
   *  adapter config so inference applies the same per-layer scale. */
  rsLora: boolean;
  /** LoRA+: LR multiplier for the B leaves (A stays at the base LR). >1 speeds
   *  the B-driven early learning (B is zero-init). 1 = off. */
  loraPlusRatio: number;
  /** Gradient checkpointing: recompute layer activations in the backward pass
   *  to bound memory at long context (mlx-lm grad_checkpoint; default in optiq).
   *  Numerically identical to off — pure memory↔compute trade. */
  gradCheckpoint: boolean;
  /** Intra-layer MLP split (lever 4): with gradCheckpoint on (Gemma4 only),
   *  checkpoint the attention and MLP sub-blocks separately with the post-attn
   *  residual as the boundary, so the backward recompute holds max(attn,MLP)+hMid
   *  instead of the whole layer. Numerically identical to gradCheckpoint alone —
   *  a finer memory↔compute split. No effect unless gradCheckpoint is on. */
  mlpSplit: boolean;
  /** Segmented backward: layers per segment (0 = off). Streams the SFT backward
   *  segment-by-segment so only one segment's activations are live at a time —
   *  beats per-layer checkpointing at long context, where naive checkpointing
   *  holds every layer's recompute activations at once and crashes. B=1 SFT
   *  only (the responseOnlyCe path); mutually exclusive with gradCheckpoint.
   *  Numerically identical to off. See docs/design/segmented-backward-training.md. */
  segmentSize: number;
  /** Keep ALL eval-step checkpoints (full mountable adapters under
   *  checkpoints/step-<NNNNN>-val<loss>/) + write metrics.json. Off by default
   *  so server finetune jobs and tests stay clean; the chunk-finetune script
   *  turns it on so the best-ON-TASK checkpoint can be chosen by the real eval
   *  afterward (val is only a proxy — we keep them all and let the eval pick). */
  saveCheckpoints: boolean;
  /** Gradient clipping: scale grads so their global L2 norm ≤ this before the
   *  optimizer step (0 = off). Standard ORPO/DPO stability guard — without it a
   *  single high-norm batch makes AdamW take a huge step and the loss diverges. */
  gradClipNorm: number;
  /** Cap validation examples evaluated per eval step (0 = all). Val accuracy is
   *  correct/total over a FIXED subset — bounds the denominator AND the per-eval
   *  cost (full val over thousands of pairs is minutes each). */
  valMaxExamples: number;
  // DPO
  dpoBeta: number;
  dpoWarmupIters: number;
  dpoLrSchedule: "constant" | "cosine";
  // ORPO (reference-free; method-prefixed knobs, mirroring the dpo trio).
  /** λ — weights ONLY the odds-ratio term (the SFT-NLL term stays unweighted). */
  orpoLambda: number;
  orpoWarmupIters: number;
  orpoLrSchedule: "constant" | "cosine";
  /** Token-chunk size for the ORPO head (0 = off). >0 computes the B=1
   *  response-only LM head in token-chunks, each rematerialized in the backward,
   *  bounding the dominant `[M, vocab]` logits term to `[chunkSize, vocab]`.
   *  Exact (numerically identical). Non-segmented path only (segmentSize takes
   *  precedence). See docs/design/orpo-training.md → chunked fused log-prob. */
  orpoChunkSize: number;
  /** Use the FUSED linear cross-entropy head (Liger/CCE-style): one CustomVjp with
   *  an analytic softmax−onehot backward — no autograd through the head, no
   *  retained `[M,vocab]` logits in either direction. Composes with
   *  `orpoChunkSize` as the token-chunk size (defaults to 512 when unset). B=1,
   *  non-segmented path only; Gemma + MiniCPM5 heads. Value bit-exact vs the
   *  full-logits head, grads in the bf16 class. See docs/design/orpo-training.md
   *  → fused linear-CE head. */
  orpoFusedCe: boolean;
  /** Route the fused linear-CE head through the flash-CCE Metal kernel: in-kernel
   *  quantized logits + online softmax (fwd) and dh accumulation (bwd) — neither
   *  `[M,vocab]` nor a dequantized head touches HBM. Lowest memory + fastest on
   *  large vocab (e4b 262k / CPM 130k). Implies the fused head; the Apple-CCE coeff
   *  filter is on by default in the backward. B=1, non-segmented path. */
  orpoFlashCe: boolean;
  /** Shared prompt-prefix ORPO (lever 7): one forward over [prompt; chosen; rejected]
   *  with a block-sparse mask + block-wise RoPE, so the shared prompt is encoded ONCE
   *  (token cost 2(P+R) → P+2R). B=1, non-segmented path; MiniCPM5 + Gemma4 (e4b).
   *  Falls back to the two-forward orpoLoss for rows whose chosen/rejected prompts
   *  differ. Composes with orpoFlashCe/orpoFusedCe (each branch routes through the
   *  [M,V]-free head). See src/train/prefix-shared.ts. */
  orpoPrefixShared: boolean;
  /** ORPO L_SFT scope (`sft_scope`). "full" (default; paper/TRL-faithful):
   *  the chosen-NLL term is the token-mean cross-entropy over the FULL
   *  prompt+response (only padding excluded), computed from the same chosen
   *  forward — matching TRL's ORPOTrainer chosen_nll_loss. "response":
   *  L_NLL = -ℓw (response-only), bit-exact to pre-sft_scope runs. The
   *  odds-ratio ℓw/ℓr terms are response-only length-normalized means in BOTH
   *  modes (that also matches TRL). Applies to every ORPO path (naive /
   *  chunked / fused / flash / prefix-shared / segmented). orpo only. */
  sftScope: SftScope;
  /** Warm-start: path to an existing adapter dir (with adapters.safetensors) whose
   *  LoRA weights initialize this run instead of the random/zero init. Continues
   *  training from a checkpoint's weights; the optimizer state and LR schedule restart.
   *  Rank/targets must match the checkpoint. "" = off (fresh init). */
  warmStartAdapter: string;
  // output
  adapterPath: string;
  baseModel: string;
}

export interface TrainResult {
  adapterPath: string;
  appliedRanks: Record<string, number>;
  numIters: number;
}

export const DEFAULT_TRAIN_CONFIG: TrainConfig = {
  method: "sft",
  rank: 8,
  scale: 1.0,
  rankScaling: "by_bits",
  targetModules: [...DEFAULT_TARGET_MODULES],
  numLayers: -1,
  iters: 100,
  learningRate: 2e-4,
  maxSeqLen: 512,
  batchSize: 1,
  gradAccumSteps: 1,
  seed: 0,
  stepsPerReport: 10,
  stepsPerEval: 50,
  betas: [0.9, 0.999],
  weightDecay: 0.01,
  loraDropout: 0.0, // off by default
  rsLora: false, // off by default (opt-in; recommended when rank_scaling != constant)
  loraPlusRatio: 1.0, // 1 = off
  mlpSplit: false, // default off; only effective with gradCheckpoint (Gemma4)
  gradCheckpoint: false, // default off until validated; flip to true (optiq default) after
  segmentSize: 0, // default off; >0 enables segmented backward (MiniCPM5 SFT B=1)
  saveCheckpoints: false, // off by default; scripts opt in (keep-all-checkpoints + metrics.json)
  gradClipNorm: 1.0, // on by default (standard ORPO/DPO guard); 0 = off
  valMaxExamples: 256, // fixed val subset → fast, meaningful correct/total

  dpoBeta: 0.1,
  dpoWarmupIters: 0,
  dpoLrSchedule: "cosine",

  orpoLambda: 0.1, // paper's primary value + TRL default; weights only L_OR
  orpoWarmupIters: 0,
  orpoLrSchedule: "cosine",
  orpoChunkSize: 0, // default off; >0 = token-chunked head (bounds the [M,vocab] term)
  orpoFusedCe: false, // default off; true = fused linear-CE head (analytic backward, no [M,vocab])
  orpoFlashCe: false, // default off; true = flash-CCE Metal-kernel head (implies fused)
  orpoPrefixShared: false, // default off; true = shared prompt-prefix single forward (B=1)
  sftScope: "full", // paper/TRL-faithful chosen-NLL over prompt+response; "response" = pre-2026-07 behavior
  warmStartAdapter: "", // default off; path to an adapter dir to warm-start LoRA weights from
  adapterPath: "adapters",
  baseModel: "",
};

/** Run a LoRA fine-tune. Emits per-step train metrics, periodic val metrics,
 *  and a final stage:done with the adapter path + applied ranks. Saves the
 *  adapter (last + best-on-val) and returns where it landed. */
export async function trainLora(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  emit: Emit,
): Promise<TrainResult> {
  emit({ type: "stage", stage: "setup", progress: 0.02, message: "resolving ranks" });

  // Mixed-precision rank scaling: feed the per-layer bits (from the loaded
  // model's quant specs) and, for by_kl, the recorded KL sensitivities
  // (optiq_metadata.json). Without these maps, by_bits/by_kl silently fell back
  // to uniform rank — so the "give the sensitive (8-bit) layers more adapter
  // capacity" policy (optiq: one sensitivity signal, two optimizations — the
  // bit assignment AND the LoRA rank) never actually fired.
  const bitsMap = bitsMapFromModel(model);
  const klMap = cfg.rankScaling === "by_kl" ? await readPerLayerKl(cfg.baseModel) : undefined;
  const ranks = resolveRanks(model, {
    rank: cfg.rank,
    rankScaling: cfg.rankScaling,
    targetModules: cfg.targetModules,
    numLayers: cfg.numLayers,
    bitsMap,
    klMap,
  });
  const appliedRanks: Record<string, number> = Object.fromEntries(ranks);

  // Surface the rank spread so mixed-precision scaling is observable (e.g.
  // "r8×140 r16×28" means 28 sensitive layers got the wider adapter).
  const rankCounts = new Map<number, number>();
  for (const r of ranks.values()) rankCounts.set(r, (rankCounts.get(r) ?? 0) + 1);
  const rankSpread = [...rankCounts.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([r, n]) => `r${r}×${n}`)
    .join(" ");
  emit({ type: "stage", stage: "setup", progress: 0.03,
    message: `ranks (${cfg.rankScaling}): ${rankSpread}` });

  const lora = buildTrainableLora(model, ranks, cfg.scale, cfg.seed, cfg.rsLora);
  // Warm-start: continue from a saved adapter/checkpoint's weights (optimizer + LR
  // schedule restart fresh). Must run before the optimizer is built (below) so it
  // tracks the loaded leaves. Rank/targets must match the checkpoint.
  if (cfg.warmStartAdapter) {
    const n = warmStartFromAdapter(lora, cfg.warmStartAdapter);
    emit({ type: "stage", stage: "setup", progress: 0.035,
      message: `warm-start: loaded ${n} LoRA targets from ${cfg.warmStartAdapter} (optimizer + LR schedule restart)` });
  }
  attachForTraining(model, lora, "train");
  model.loraState.dropoutRate = cfg.loraDropout; // per-step seed set inside the loop
  // Training-mode fused GeGLU (Gemma e4b): kernel forward + hand-derived vjp, so
  // autograd flows and the backward recomputes the gelu from the primal instead
  // of retaining the spelled-out intermediates. No-op for non-Gemma models.
  // Cleared in the finally below.
  setFusedGeluTraining(true);

  const saveCfg: SaveAdapterConfig = {
    rank: cfg.rank,
    scale: cfg.scale,
    rankScaling: cfg.rankScaling,
    targetModules: cfg.targetModules,
    numLayers: cfg.numLayers,
    method: cfg.method,
    baseModel: cfg.baseModel,
    rsLora: cfg.rsLora,
  };

  // Keep-ALL-checkpoints + a durable metrics record. At each eval step we
  // snapshot the adapter to checkpoints/step-<NNNNN>-val<loss>/ — a full,
  // mountable adapter — so the best-ON-TASK checkpoint can be chosen by the
  // real eval afterward (val is only a proxy for task quality, so we do NOT
  // pick for the user). The loss/val trajectory is written to metrics.json so
  // runs are comparable and survive (the tee'd stdout log is ephemeral). We
  // wrap `emit` rather than touching the loops: it already streams train/val
  // metrics, and the live LoRA leaves are the current step's weights at emit
  // time, so saving here captures exactly that checkpoint.
  const trainHistory: { step: number; loss: number }[] = [];
  // For preference methods (dpo/orpo) the val MARGIN (mean chosen−rejected
  // log-odds) and accuracy are the meaningful early-stop signals — val loss is a
  // weak proxy. Capture them when the loop emits them so metrics.json lets you
  // pick the best-MARGIN checkpoint (overfit shows as train↑ / val-margin flat).
  const valHistory: { step: number; loss: number; margin?: number; accuracy?: number; checkpoint: string | null }[] = [];
  const startedAt = Date.now();

  // Live, append-only metrics stream (the source `mlx-bun train-watch` tails).
  // Always on — it's the durable per-step record, a few MB at most, single
  // writer, append-only. The first line is a `meta` record (totals + config) so
  // a viewer attaching mid-run has the denominators (iters) and run identity
  // without replaying. Each subsequent line is a metric event + a wall-clock `t`
  // (ms) so the viewer derives s/step and ETA itself. Best-effort: a logging
  // failure must never kill a run.
  mkdirSync(cfg.adapterPath, { recursive: true });
  const metricsJsonl = `${cfg.adapterPath}/metrics.jsonl`;
  const writeMetricLine = (o: Record<string, unknown>) => {
    try { appendFileSync(metricsJsonl, JSON.stringify(o) + "\n"); } catch { /* never throw */ }
  };
  try { writeFileSync(metricsJsonl, ""); } catch { /* truncate prior run's stream */ }
  writeMetricLine({
    type: "meta", t: startedAt, method: cfg.method, model: cfg.baseModel,
    iters: cfg.iters, learning_rate: cfg.learningRate, max_seq_length: cfg.maxSeqLen,
    batch_size: cfg.batchSize, rank: cfg.rank, scale: cfg.scale,
    orpo_lambda: cfg.method === "orpo" ? cfg.orpoLambda : undefined,
    sft_scope: cfg.method === "orpo" ? cfg.sftScope : undefined,
    adapter_path: cfg.adapterPath,
  });

  const collect: Emit = (e) => {
    if (e.type === "metric") writeMetricLine({ ...e, t: Date.now() });
    if (e.type === "metric" && e.kind === "train") {
      trainHistory.push({ step: e.step, loss: e.loss });
    } else if (e.type === "metric" && e.kind === "val") {
      let checkpoint: string | null = null;
      if (cfg.saveCheckpoints) {
        const tag = `step-${String(e.step).padStart(5, "0")}-val${e.loss.toFixed(4)}`;
        checkpoint = `${cfg.adapterPath}/checkpoints/${tag}`;
        saveAdapter(lora, checkpoint, saveCfg, appliedRanks);
        emit({ type: "stage", stage: "checkpoint", progress: e.step / cfg.iters,
               message: `checkpoint ${tag}` });
      }
      const ev = e as { step: number; loss: number; margin?: number; accuracy?: number };
      valHistory.push({ step: ev.step, loss: ev.loss, margin: ev.margin, accuracy: ev.accuracy, checkpoint });
    }
    emit(e);
  };

  try {
    const result =
      cfg.method === "dpo"
        ? await dpoLoop(model, tok, tmpl, dataDir, cfg, lora, collect)
        : cfg.method === "orpo"
          ? await orpoLoop(model, tok, tmpl, dataDir, cfg, lora, collect)
          : await sftLoop(model, tok, tmpl, dataDir, cfg, lora, collect);

    // Final save (last adapter).
    detachTraining(model, lora);
    saveAdapter(lora, cfg.adapterPath, saveCfg, appliedRanks);

    // Durable, structured run record alongside the adapter (only when we kept
    // checkpoints). Pick the best-val one for convenience, but ship ALL of them
    // — the real eval decides; val is only a proxy.
    if (cfg.saveCheckpoints) {
      let bestVal: { step: number; loss: number; checkpoint: string | null } | null = null;
      for (const v of valHistory) if (bestVal === null || v.loss < bestVal.loss) bestVal = v;
      // Best by MARGIN too (preference methods) — the better checkpoint signal.
      let bestMargin: typeof valHistory[number] | null = null;
      for (const v of valHistory)
        if (v.margin !== undefined && (bestMargin === null || v.margin > (bestMargin.margin ?? -Infinity))) bestMargin = v;
      writeFileSync(`${cfg.adapterPath}/metrics.json`, JSON.stringify({
        config: {
          method: cfg.method, rank: cfg.rank, scale: cfg.scale,
          learningRate: cfg.learningRate, maxSeqLen: cfg.maxSeqLen,
          segmentSize: cfg.segmentSize, iters: cfg.iters,
          numLayers: cfg.numLayers, baseModel: cfg.baseModel,
          orpoLambda: cfg.method === "orpo" ? cfg.orpoLambda : undefined,
          sftScope: cfg.method === "orpo" ? cfg.sftScope : undefined,
        },
        wallSeconds: (Date.now() - startedAt) / 1000,
        peakGb: peakMemory() / 1e9,
        finalTrainLoss: trainHistory.at(-1)?.loss ?? null,
        finalValLoss: valHistory.at(-1)?.loss ?? null,
        bestVal,
        bestMargin, // null for SFT (no margin); the recommended pick for dpo/orpo
        valTrajectory: valHistory,
        trainLosses: trainHistory,
      }, null, 2));
    }

    emit({
      type: "stage",
      stage: "done",
      progress: 1,
      message: `adapter saved to ${cfg.adapterPath}`,
      adapter_path: cfg.adapterPath,
      applied_ranks: appliedRanks,
    });
    return { adapterPath: cfg.adapterPath, appliedRanks, numIters: result.numIters };
  } finally {
    setFusedGeluTraining(false);
    disposeLora(lora);
  }
}

// ---------------------------------------------------------------------------
// SFT loop
// ---------------------------------------------------------------------------

async function sftLoop(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  lora: TrainableLora,
  emit: Emit,
): Promise<{ numIters: number }> {
  emit({ type: "stage", stage: "data", progress: 0.05, message: "loading SFT dataset" });
  const train = await loadSftDataset(`${dataDir}/train.jsonl`, tok, tmpl);
  const valid = (await fileExists(`${dataDir}/valid.jsonl`))
    ? await loadSftDataset(`${dataDir}/valid.jsonl`, tok, tmpl)
    : [];

  const params = flatParams(lora);
  const opt = new AdamW(
    params,
    { lr: cfg.learningRate, betas: cfg.betas, eps: 1e-8, weightDecay: cfg.weightDecay },
    (i, p) => writeParam(lora, i, p),
  );

  // Segmented backward: stream the SFT backward segment-by-segment (only one
  // segment's activations live at a time). Phase A is MiniCPM5 SFT B=1 only;
  // it replaces the single value_and_grad below and is mutually exclusive with
  // gradient checkpointing (see docs/design/segmented-backward-training.md).
  const useSegmented = cfg.segmentSize > 0;
  let segmented: SegmentedBackward | SegmentedBackwardGemma4 | null = null;
  if (useSegmented) {
    if (model instanceof MiniCPM5Model)
      segmented = new SegmentedBackward(model, lora, planSegmentsBySize(model.layers.length, cfg.segmentSize));
    else if (model instanceof Gemma4Model)
      segmented = new SegmentedBackwardGemma4(model, lora, planSegmentsBySize(model.layers.length, cfg.segmentSize));
    else
      throw new Error("segmented backward (segmentSize > 0) is only wired for MiniCPM5 and Gemma4");
    emit({ type: "stage", stage: "setup", progress: 0.04,
      message: `segmented backward: ${Math.ceil(model.layers.length / cfg.segmentSize)} segments of <=${cfg.segmentSize} layers` });
  }

  // The value_and_grad loss closure: temporarily swap the differentiated
  // primals into the LoraWeights so the forward graph differentiates them,
  // build the SFT loss against the active batch, then restore the original
  // leaf wrappers (the primal wrappers get disposed by the autograd closure;
  // the graph already captured their handles). Not built on the segmented path
  // (segmentedSftGrads runs its own per-segment value_and_grads).
  let currentBatch: SftBatch | null = null;
  const vag = useSegmented
    ? null
    : new ValueAndGrad((primals) => {
        const saved = swapPrimals(lora, primals);
        try {
          return sftLoss(model, currentBatch!);
        } finally {
          restorePrimals(lora, saved);
        }
      }, params.map((_, i) => i));

  // Gradient checkpointing: group each layer's LoRA weights so forwardLayers
  // can thread them as explicit checkpoint inputs (see Gemma4Model.gradCkpt).
  // Checkpoints are created per forward and disposed after each step's backward.
  let ckptCtx: GradCheckpointCtx | null = null;
  if (!useSegmented && cfg.gradCheckpoint && model instanceof Gemma4Model) {
    // Partition each layer's LoRA into the attention sub-block (self_attn.*) and
    // the MLP sub-block (everything else in the layer: gate/up/down_proj +
    // per_layer_*) so the split-MLP checkpoint can wrap them independently.
    const byLayer: GradCheckpointCtx["byLayer"] = new Map();
    for (const t of lora.targets) {
      const m = t.modulePath.match(/\.layers\.(\d+)\./);
      if (!m) continue;
      const li = Number(m[1]);
      const ll = byLayer.get(li) ?? byLayer.set(li, { attn: [], mlp: [] }).get(li)!;
      (t.modulePath.includes(".self_attn.") ? ll.attn : ll.mlp).push(t.lw);
    }
    ckptCtx = { byLayer, splitMlp: cfg.mlpSplit, keepAlive: [] };
    model.gradCkpt = ckptCtx;
    if (cfg.mlpSplit) emit({ type: "stage", stage: "setup", progress: 0.04,
      message: "grad checkpoint: intra-layer attn/MLP split" });
  }

  // Training attention. Default = mlx fused SDPA (ops.sdpa): exact dQ/dK/dV
  // (finite-difference verified) and fast, but O(L²) backward memory. The
  // hand-rolled flash kernel is an opt-in (MLX_BUN_TRAIN_ATTN=flash) O(L)-memory
  // path for memory-bound long context — now correct (its dK-transpose and
  // dQ-causal-barrier bugs were fixed; FD-validated in
  // scripts/experiments/flash-fd-check.ts), though ~30× slower than ops.sdpa.
  // Cleared in finally.
  //
  // GEMMA GUARD (same convention as the PERF_KERNEL/FUSED_GELU sanitization in
  // cli.ts / job.ts, but enforced at the trainer): e4b on this path SIGTRAPed
  // (uncatchable native crash) at multi-K sequence lengths (>=2K, reproduced in
  // scripts/experiments/segmented-grad-test-e4b.ts; docs/reference/training.md)
  // and has NOT been re-validated at that scale since the two kernel fixes —
  // the regression tests stop at T<=256. cli.ts even defaults e4b seq to 8192,
  // so a stale `export MLX_BUN_TRAIN_ATTN=flash` from a MiniCPM5 experiment
  // would otherwise ride silently into a crash mid-run. Refuse it for Gemma
  // until the >=2K re-validation lands; MiniCPM5 stays allowed.
  if (process.env.MLX_BUN_TRAIN_ATTN === "flash") {
    if (model instanceof Gemma4Model)
      throw new Error(
        "MLX_BUN_TRAIN_ATTN=flash is disabled for Gemma models: e4b SIGTRAPs on this " +
          "path at seq >= 2048 (docs/reference/training.md) and it has not been " +
          "re-validated at that scale since the kernel fixes. Unset MLX_BUN_TRAIN_ATTN " +
          "(ops.sdpa, the default, is exact and ~30x faster) or train MiniCPM5.",
      );
    emit({ type: "stage", stage: "setup", progress: 0.045,
      message: "training attention: hand-rolled flash kernel (MLX_BUN_TRAIN_ATTN=flash; O(L) memory, ~30x slower than ops.sdpa)" });
    setTrainingAttn("flash");
  }

  // Pad with the eos id when available (a real sentinel token); padded
  // positions are excluded from both the loss and attention masks, so the
  // exact pad value never affects the result — it just must be a valid id.
  const padId = tok.eosTokenId ?? 0;
  const batches = iterateSftBatches(train, cfg.batchSize, cfg.maxSeqLen, cfg.seed, true, padId);
  // tokens/sec follows mlx-lm's tuner convention: accumulate the response-token
  // count across the REPORT WINDOW and divide by the window's own wall time
  // (validation time excluded) — not one step's count extrapolated over the
  // whole run, which jumps ~10x step-to-step on variable-length data.
  let windowTokens = 0;
  let windowStart = Date.now();

  try {
    for (let step = 1; step <= cfg.iters; step++) {
      if (MEM_LOG) resetPeakMemory();

      // One optimizer step over cfg.gradAccumSteps micro-batches (pass-through
      // when 1). afterMicroEval frees each micro-batch's gradient-checkpoint
      // closures right after its backward so they don't pile up across
      // accumulation.
      const { loss: lossVal, grads } = accumulateStep(
        cfg.gradAccumSteps,
        () => {
          currentBatch = batches.next().value as SftBatch;
          windowTokens += countResponseTokens(currentBatch);
          return segmented ? segmented.step(currentBatch!) : vag!.apply(flatParams(lora));
        },
        ckptCtx
          ? () => {
              for (const ck of ckptCtx!.keepAlive) ck.dispose();
              ckptCtx!.keepAlive.length = 0;
            }
          : undefined,
      );

      const gradNorm = globalNorm(grads); // grads already materialized above
      clipGradsByNorm(grads, gradNorm, cfg.gradClipNorm);
      opt.step(grads);
      opt.evalState();
      if (MEM_LOG) {
        const pk = peakMemory(), act = activeMemory(), ch = cacheMemory();
        clearCache();
        console.log(`  [mem] step ${step}: PEAK(live)=${gbStr(pk)} active=${gbStr(act)} cache=${gbStr(ch)} -> after clearCache active=${gbStr(activeMemory())}`);
      } else {
        clearCache();
      }

      if (step % cfg.stepsPerReport === 0 || step === 1) {
        const elapsed = (Date.now() - windowStart) / 1000;
        emit({
          type: "metric",
          kind: "train",
          step,
          loss: lossVal,
          grad_norm: gradNorm,
          learning_rate: opt.lr,
          tokens_per_sec: elapsed > 0 ? windowTokens / elapsed : 0,
          progress: step / cfg.iters,
          message: `step ${step}/${cfg.iters} loss=${lossVal.toFixed(4)}`,
        });
        windowTokens = 0;
        windowStart = Date.now();
      }

      if (valid.length > 0 && step % cfg.stepsPerEval === 0) {
        // Eval is forward-only (no backward), so disable checkpointing for it —
        // it adds no benefit and a forward-only pass fits without it.
        if (ckptCtx) (model as Gemma4Model).gradCkpt = null;
        const tVal = Date.now();
        const { loss: vLoss, used, skipped } = evalSftLoss(model, valid, cfg);
        if (ckptCtx) (model as Gemma4Model).gradCkpt = ckptCtx;
        // A silently-shrinking val set must be visible: rows whose supervised
        // span is empty after truncation are skipped BY DESIGN (mlx-lm drops
        // them at dataset build time) — report how many, and over what n the
        // mean was taken. Any other per-row failure now rethrows (see
        // evalSftLoss).
        emit({ type: "metric", kind: "val", step, loss: vLoss, progress: step / cfg.iters,
          val_rows_used: used, val_rows_skipped: skipped,
          ...(skipped > 0 ? { message: `val loss over ${used} rows (${skipped} skipped: no response tokens to supervise)` } : {}) });
        // validation wall time is not training throughput — keep it out of the window
        windowStart += Date.now() - tVal;
      }
    }
  } finally {
    setTrainingAttn(null);
    vag?.dispose();
    segmented?.dispose();
    opt.dispose();
    if (ckptCtx) {
      (model as Gemma4Model).gradCkpt = null;
      for (const ck of ckptCtx.keepAlive) ck.dispose();
    }
  }
  return { numIters: cfg.iters };
}

function evalSftLoss(
  model: RuntimeModel, valid: ReturnType<typeof Array.prototype.slice>, cfg: TrainConfig,
): { loss: number; used: number; skipped: number } {
  let total = 0;
  let n = 0;
  let skipped = 0;
  for (const ex of valid as { ids: number[]; promptLen: number }[]) {
    let ids = ex.ids;
    let promptLen = ex.promptLen;
    if (ids.length < 2) { skipped++; continue; }
    if (ids.length > cfg.maxSeqLen) {
      ids = ids.slice(0, cfg.maxSeqLen);
      promptLen = Math.min(promptLen, Math.max(0, ids.length - 1));
    }
    const batch: SftBatch = { ids: [ids], promptLens: [promptLen] };
    try {
      const loss = sftLoss(model, batch);
      total += loss.toFloat32()[0]!;
      loss.dispose();
      n++;
    } catch (e) {
      // ONLY the empty-supervision row is skippable (a truncated row whose
      // response fell entirely past maxSeqLen — mlx-lm drops these at dataset
      // build). Everything else (MLX OOM/shape/vjp errors surface as catchable
      // JS Errors via the ffi handler) must rethrow: swallowing them silently
      // reduces the val set to its easy rows and reports a plausible loss.
      if (e instanceof Error && e.message === "sftLoss: no response tokens to supervise") skipped++;
      else throw e;
    }
    clearCache();
  }
  return { loss: n > 0 ? total / n : 0, used: n, skipped };
}

// ---------------------------------------------------------------------------
// DPO loop
// ---------------------------------------------------------------------------

async function dpoLoop(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  lora: TrainableLora,
  emit: Emit,
): Promise<{ numIters: number }> {
  emit({ type: "stage", stage: "data", progress: 0.05, message: "loading DPO dataset" });
  const train = await loadDpoDataset(`${dataDir}/train.jsonl`, tok, tmpl, cfg.maxSeqLen);
  const valid = (await fileExists(`${dataDir}/valid.jsonl`))
    ? await loadDpoDataset(`${dataDir}/valid.jsonl`, tok, tmpl, cfg.maxSeqLen)
    : [];

  const params = flatParams(lora);
  const opt = new AdamW(
    params,
    { lr: cfg.learningRate, betas: cfg.betas, eps: 1e-8, weightDecay: cfg.weightDecay },
    (i, p) => writeParam(lora, i, p),
  );

  const schedule =
    cfg.dpoLrSchedule === "cosine" || cfg.dpoWarmupIters > 0
      ? warmupCosineSchedule(cfg.learningRate, cfg.dpoWarmupIters, cfg.iters)
      : null;

  // Reference log-probs are computed each step OUTSIDE value_and_grad (so the
  // reference activations free before the policy forwards), then read as
  // detached constants inside the closure.
  let currentBatch: DpoBatch | null = null;
  let refChosen: MlxArray | null = null;
  let refRejected: MlxArray | null = null;

  const vag = new ValueAndGrad((primals) => {
    const saved = swapPrimals(lora, primals);
    try {
      return dpoLoss(model, currentBatch!, cfg.dpoBeta, refChosen!, refRejected!);
    } finally {
      restorePrimals(lora, saved);
    }
  }, params.map((_, i) => i));

  const padId = tok.eosTokenId ?? 0;
  const batches = iterateDpoBatches(train, cfg.batchSize, cfg.seed, true, padId);
  const t0 = Date.now();

  try {
    for (let step = 1; step <= cfg.iters; step++) {
      if (schedule) opt.lr = schedule(step);

      // One optimizer step over cfg.gradAccumSteps micro-batches (pass-through
      // when 1). Reference log-probs are recomputed per micro-batch OUTSIDE the
      // policy value_and_grad and read as detached constants inside it;
      // afterMicroEval frees them once that micro-batch's grads are materialized.
      const { loss: lossVal, grads } = accumulateStep(
        cfg.gradAccumSteps,
        () => {
          currentBatch = batches.next().value as DpoBatch;
          const refs = dpoRefLogps(model, lora, currentBatch);
          refChosen = refs.refChosen;
          refRejected = refs.refRejected;
          return vag.apply(flatParams(lora));
        },
        () => {
          refChosen?.dispose();
          refRejected?.dispose();
          refChosen = refRejected = null;
        },
      );

      const gradNorm = globalNorm(grads);
      clipGradsByNorm(grads, gradNorm, cfg.gradClipNorm);
      opt.step(grads);
      opt.evalState();
      clearCache();

      if (step % cfg.stepsPerReport === 0 || step === 1) {
        const m = dpoMetrics(model, lora, currentBatch!, cfg.dpoBeta);
        const elapsed = (Date.now() - t0) / 1000;
        emit({
          type: "metric",
          kind: "train",
          step,
          loss: lossVal,
          grad_norm: gradNorm,
          learning_rate: opt.lr,
          accuracy: m.accuracy,
          margin: m.margin,
          tokens_per_sec: 0,
          progress: step / cfg.iters,
          message: `step ${step}/${cfg.iters} loss=${lossVal.toFixed(4)} acc=${m.accuracy.toFixed(2)} margin=${m.margin.toFixed(3)}`,
        });
        clearCache();
      }

      if (valid.length > 0 && step % cfg.stepsPerEval === 0) {
        let vl = 0, va = 0, vm = 0, vn = 0;
        for (const ex of valid) {
          const vb: DpoBatch = {
            chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
            chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
          };
          const m = dpoMetrics(model, lora, vb, cfg.dpoBeta);
          vl += m.loss; va += m.accuracy; vm += m.margin; vn++;
          clearCache();
        }
        emit({
          type: "metric", kind: "val", step,
          loss: vn ? vl / vn : 0,
          accuracy: vn ? va / vn : 0,
          margin: vn ? vm / vn : 0,
          progress: step / cfg.iters,
        });
      }
    }
  } finally {
    vag.dispose();
    opt.dispose();
    // Cast: refs are only ever assigned inside the accumulateStep closures, so
    // TS's flow analysis narrows these to their `null` initializer here.
    (refChosen as MlxArray | null)?.dispose();
    (refRejected as MlxArray | null)?.dispose();
  }
  return { numIters: cfg.iters };
}

// ---------------------------------------------------------------------------
// ORPO loop (reference-free: 2 forwards/step, no reference pass)
// ---------------------------------------------------------------------------

async function orpoLoop(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  lora: TrainableLora,
  emit: Emit,
): Promise<{ numIters: number }> {
  emit({ type: "stage", stage: "data", progress: 0.05, message: "loading preference dataset" });
  const train = await loadDpoDataset(`${dataDir}/train.jsonl`, tok, tmpl, cfg.maxSeqLen);
  const valid = (await fileExists(`${dataDir}/valid.jsonl`))
    ? await loadDpoDataset(`${dataDir}/valid.jsonl`, tok, tmpl, cfg.maxSeqLen)
    : [];

  const params = flatParams(lora);
  // LoRA+: B leaves (the second half of flatParams) get a higher LR than A.
  const nT = lora.targets.length;
  const lrScale = cfg.loraPlusRatio !== 1
    ? params.map((_, i) => (i < nT ? 1 : cfg.loraPlusRatio))
    : undefined;
  if (lrScale) emit({ type: "stage", stage: "setup", progress: 0.04,
    message: `LoRA+ : B leaves at ${cfg.loraPlusRatio}× LR` });
  const opt = new AdamW(
    params,
    { lr: cfg.learningRate, betas: cfg.betas, eps: 1e-8, weightDecay: cfg.weightDecay, lrScale },
    (i, p) => writeParam(lora, i, p),
  );

  const schedule =
    cfg.orpoLrSchedule === "cosine" || cfg.orpoWarmupIters > 0
      ? warmupCosineSchedule(cfg.learningRate, cfg.orpoWarmupIters, cfg.iters)
      : null;

  // Segmented backward for ORPO: stream chosen+rejected backwards segment-by-segment.
  // MiniCPM5 + Gemma4 (e4b) — same model coverage as SFT segmented. B=1 only.
  const useSegmented = cfg.segmentSize > 0;
  // Prefix-sharing + segmented backward COMPOSE (M3-composition): the segmented
  // backward streams the ONE prefix-shared concat forward [prompt; chosen; rejected]
  // (block-sparse mask via PrefixSharedCache + block-wise RoPE via the prefix plan)
  // segment-by-segment — so the prompt-encode-once saving holds AT long seq. Composed
  // for BOTH MiniCPM5 and Gemma4/e4b (the e4b variant threads donor-KV + the
  // logical-position sliding-window prefix mask through the segment boundaries).
  const useSegmentedPrefix = cfg.orpoPrefixShared && useSegmented;
  if (cfg.orpoPrefixShared && !(model instanceof MiniCPM5Model || model instanceof Gemma4Model))
    throw new Error("orpoPrefixShared is only wired for MiniCPM5 and Gemma4");
  // Fused linear-CE head INSIDE the segmented backward (orpo_fused_ce): bounds the
  // head term to [chunk,V] alongside the per-segment layer savings. 0 = the
  // full-[M,V] responseOnlyLogpMean head (unchanged). Reuses orpoChunkSize as the
  // token-chunk (default 512), same as the non-segmented path.
  // "flash implies fused": orpoFlashCe alone must still bound the segmented head to
  // [chunk,V]. The non-prefix segmented class has no flash path, so flash routes
  // through its fused/checkpoint chunked head (boundedHeadFromHidden) — never the
  // full-[M,V] responseOnlyLogpMean, which would reintroduce [M,vocab] on e4b.
  const segUsesFusedHead = cfg.orpoFusedCe || cfg.orpoFlashCe;
  const segFusedChunk = segUsesFusedHead ? (cfg.orpoChunkSize > 0 ? cfg.orpoChunkSize : 512) : 0;
  // The prefix segmented head gathers response positions then routes per-branch
  // through the [M,V]-free flash/fused head (branchLogpMeanGathered, which takes a
  // ChunkCtx). Its own sink is managed per-step inside the class.
  const segPrefixChunk: ChunkCtx | undefined =
    cfg.orpoFusedCe || cfg.orpoFlashCe
      ? { chunkSize: cfg.orpoChunkSize > 0 ? cfg.orpoChunkSize : 512, fused: true, flash: cfg.orpoFlashCe, sink: [] }
      : undefined;
  let segmentedOrpo: SegmentedBackwardOrpo | SegmentedBackwardOrpoGemma4 | null = null;
  let segmentedOrpoPrefix: SegmentedBackwardOrpoPrefix | SegmentedBackwardOrpoPrefixGemma4 | null = null;
  if (useSegmented) {
    const ranges = planSegmentsBySize(model.layers.length, cfg.segmentSize);
    if (useSegmentedPrefix) {
      // The composed prefix-shared segmented backward (MiniCPM5 or Gemma4/e4b), plus a
      // plain segmented-ORPO fallback for rows whose chosen/rejected prompts differ
      // (splitPrefixBatch returns null -> two-forward segmented step).
      if (model instanceof MiniCPM5Model) {
        segmentedOrpoPrefix = new SegmentedBackwardOrpoPrefix(model, lora, ranges, cfg.orpoLambda, segPrefixChunk, cfg.sftScope);
        segmentedOrpo = new SegmentedBackwardOrpo(model, lora, ranges, cfg.orpoLambda, segFusedChunk, cfg.sftScope);
      } else {
        segmentedOrpoPrefix = new SegmentedBackwardOrpoPrefixGemma4(model as Gemma4Model, lora, ranges, cfg.orpoLambda, segPrefixChunk, cfg.sftScope);
        segmentedOrpo = new SegmentedBackwardOrpoGemma4(model as Gemma4Model, lora, ranges, cfg.orpoLambda, segFusedChunk, cfg.sftScope);
      }
      emit({ type: "stage", stage: "setup", progress: 0.04,
        message: `orpo segmented + prefix-share (${model instanceof Gemma4Model ? "e4b" : "MiniCPM5"}): single concat forward streamed over ${Math.ceil(model.layers.length / cfg.segmentSize)} segments of <=${cfg.segmentSize} layers (two-forward fallback on prompt mismatch)` });
    } else if (model instanceof MiniCPM5Model)
      segmentedOrpo = new SegmentedBackwardOrpo(model, lora, ranges, cfg.orpoLambda, segFusedChunk, cfg.sftScope);
    else if (model instanceof Gemma4Model)
      segmentedOrpo = new SegmentedBackwardOrpoGemma4(model, lora, ranges, cfg.orpoLambda, segFusedChunk, cfg.sftScope);
    else
      throw new Error("segmented backward (segmentSize > 0) for ORPO is only wired for MiniCPM5 and Gemma4");
    if (!useSegmentedPrefix) emit({ type: "stage", stage: "setup", progress: 0.04,
      message: `orpo segmented backward: ${Math.ceil(model.layers.length / cfg.segmentSize)} segments of <=${cfg.segmentSize} layers${segFusedChunk > 0 ? ` + fused linear-CE head (${segFusedChunk}/chunk)` : ""}` });
  }

  // Token-chunked head (non-segmented path only): the per-chunk checkpoints are
  // collected here and disposed after each micro-step's grads are eval'd (the
  // afterMicroEval hook below) — that is when their backward recompute has run.
  const chunkSink: Array<{ dispose(): void }> = [];
  // Fused linear-CE head reuses orpoChunkSize as the token-chunk (default 512 when
  // unset); otherwise the Checkpoint token-chunked head fires only when
  // orpoChunkSize > 0. Both are non-segmented-path only.
  const fusedChunkSize = cfg.orpoChunkSize > 0 ? cfg.orpoChunkSize : 512;
  const chunk: ChunkCtx | undefined = useSegmented
    ? undefined
    : cfg.orpoFusedCe || cfg.orpoFlashCe
      ? { chunkSize: fusedChunkSize, fused: true, flash: cfg.orpoFlashCe, sink: chunkSink }
      : cfg.orpoChunkSize > 0
        ? { chunkSize: cfg.orpoChunkSize, sink: chunkSink }
        : undefined;
  if (chunk) emit({ type: "stage", stage: "setup", progress: 0.04,
    message: chunk.flash
      ? `orpo flash-CCE (Metal kernel) head: ${chunk.chunkSize} tokens/chunk`
      : chunk.fused
        ? `orpo fused linear-CE head: ${chunk.chunkSize} tokens/chunk`
        : `orpo chunked head: ${cfg.orpoChunkSize} tokens/chunk` });
  if (cfg.orpoPrefixShared && !useSegmentedPrefix) emit({ type: "stage", stage: "setup", progress: 0.04,
    message: `orpo prefix-sharing: single forward over [prompt; chosen; rejected] (two-forward fallback on prompt mismatch)` });
  const disposeChunkSink = () => { for (const c of chunkSink) c.dispose(); chunkSink.length = 0; };

  // No reference forward (the whole point of ORPO) — the closure just builds the
  // monolithic L_NLL + λ·L_OR over the active batch against the swapped primals.
  let currentBatch: DpoBatch | null = null;
  const vag = useSegmented
    ? null
    : new ValueAndGrad((primals) => {
        const saved = swapPrimals(lora, primals);
        try {
          // Prefix-sharing (B=1): one forward over [prompt; chosen; rejected] when the
          // row's chosen/rejected share an identical prompt; else fall back two-forward.
          if (cfg.orpoPrefixShared) {
            const split = splitPrefixBatch(currentBatch!);
            if (split) {
              if (model instanceof MiniCPM5Model)
                return orpoLossPrefixShared(model, split.promptIds, split.chosenResp, split.rejectedResp, cfg.orpoLambda, chunk, cfg.sftScope);
              return orpoLossPrefixSharedGemma(model as Gemma4Model, split.promptIds, split.chosenResp, split.rejectedResp, cfg.orpoLambda, chunk, cfg.sftScope);
            }
            notePrefixFallback();
          }
          return orpoLoss(model, currentBatch!, cfg.orpoLambda, chunk, cfg.sftScope);
        } finally {
          restorePrimals(lora, saved);
        }
      }, params.map((_, i) => i));

  const padId = tok.eosTokenId ?? 0;
  const batches = iterateDpoBatches(train, cfg.batchSize, cfg.seed, true, padId);
  const t0 = Date.now();

  let dropoutCounter = 0;
  // Prefix-share falls back to the two-forward path for any row whose chosen/rejected
  // prompts aren't byte-identical (splitPrefixBatch → null). Log the FIRST fallback +
  // count them, so a silent loss of the prompt-encode-once saving is visible.
  let prefixFallbacks = 0;
  const notePrefixFallback = () => {
    prefixFallbacks++;
    if (prefixFallbacks === 1) emit({ type: "stage", stage: "train", progress: 0,
      message: `prefix-share: row prompt mismatch → two-forward fallback for this row (saving lost only on mismatched rows; counting…)` });
  };
  try {
    for (let step = 1; step <= cfg.iters; step++) {
      if (schedule) opt.lr = schedule(step);

      // One optimizer step over cfg.gradAccumSteps micro-batches (pass-through
      // when 1) — the long-context lever for a larger effective batch without
      // the B>1 activation memory (see docs/design/orpo-training.md, Batching).
      const { loss: lossVal, grads } = accumulateStep(cfg.gradAccumSteps, () => {
        currentBatch = batches.next().value as DpoBatch;
        // Per-micro-step dropout seed: constant across this micro-step's forward
        // AND its backward recompute (segmented/chunked), so the mask reproduces.
        if (cfg.loraDropout > 0) model.loraState.dropoutSeed = ++dropoutCounter;
        // Segmented + prefix-share: stream the single concat forward when the row's
        // chosen/rejected share an identical prompt; else fall back to the plain
        // two-forward segmented step (segmentedOrpo, built alongside).
        if (segmentedOrpoPrefix) {
          const split = splitPrefixBatch(currentBatch!);
          if (split) return segmentedOrpoPrefix.stepPrefix(split.promptIds, split.chosenResp, split.rejectedResp);
          notePrefixFallback();
          return segmentedOrpo!.step(currentBatch!);
        }
        return segmentedOrpo ? segmentedOrpo.step(currentBatch!) : vag!.apply(flatParams(lora));
      }, disposeChunkSink); // free this micro-step's head checkpoints once its grads are eval'd

      model.loraState.dropoutSeed = null; // metrics/val below run dropout-free
      const gradNorm = globalNorm(grads);
      clipGradsByNorm(grads, gradNorm, cfg.gradClipNorm);
      opt.step(grads);
      opt.evalState();
      clearCache();

      if (step % cfg.stepsPerReport === 0 || step === 1) {
        // Diagnostics recompute the two forwards (like dpoMetrics) — cheap at
        // B=1 (response-only head, no full logits) and gated by stepsPerReport.
        // Reusing the value_and_grad forward is a shared-with-DPO follow-on.
        const m = orpoMetrics(model, currentBatch!, cfg.orpoLambda, cfg.sftScope);
        const elapsed = (Date.now() - t0) / 1000;
        emit({
          type: "metric",
          kind: "train",
          step,
          loss: lossVal,
          grad_norm: gradNorm,
          learning_rate: opt.lr,
          accuracy: m.accuracy,
          margin: m.margin,
          tokens_per_sec: 0,
          peak_gb: peakMemory() / 1e9,
          active_gb: activeMemory() / 1e9,
          pinned: pinnedBufferCount(),
          progress: step / cfg.iters,
          message: `step ${step}/${cfg.iters} loss=${lossVal.toFixed(4)} nll=${m.nll.toFixed(4)} or=${m.or.toFixed(4)} acc=${m.accuracy.toFixed(2)} margin=${m.margin.toFixed(3)}`,
        });
        clearCache();
      }

      if (valid.length > 0 && step % cfg.stepsPerEval === 0) {
        // Val accuracy is correct/total over a FIXED subset (cap bounds both the
        // denominator and the per-eval cost). Each val example is a single B=1
        // pair, so m.accuracy ∈ {0,1} and va sums to the integer correct count.
        const valSet = cfg.valMaxExamples > 0 ? valid.slice(0, cfg.valMaxExamples) : valid;
        let vl = 0, va = 0, vm = 0, vn = 0;
        for (const ex of valSet) {
          const vb: DpoBatch = {
            chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
            chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
          };
          const m = orpoMetrics(model, vb, cfg.orpoLambda, cfg.sftScope);
          vl += m.loss; va += m.accuracy; vm += m.margin; vn++;
          clearCache();
        }
        emit({
          type: "metric", kind: "val", step,
          loss: vn ? vl / vn : 0,
          accuracy: vn ? va / vn : 0,
          n_correct: Math.round(va),
          n_total: vn,
          margin: vn ? vm / vn : 0,
          progress: step / cfg.iters,
        });
      }
    }
  } finally {
    disposeChunkSink(); // defensive: free any head checkpoints a throw left behind
    segmentedOrpoPrefix?.dispose();
    segmentedOrpo?.dispose();
    vag?.dispose();
    opt.dispose();
  }
  return { numIters: cfg.iters };
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/** Swap the incoming value_and_grad primals into the LoraWeights so the
 *  forward graph differentiates them. Order: [...A, ...B] over sorted targets.
 *  Returns the displaced original leaves so the caller can restore them (the
 *  primal wrappers are disposed by the autograd closure after this returns). */
function swapPrimals(lora: TrainableLora, primals: MlxArray[]): MlxArray[] {
  const n = lora.targets.length;
  const saved: MlxArray[] = [];
  for (let i = 0; i < n; i++) {
    saved.push(lora.targets[i]!.lw.a, lora.targets[i]!.lw.b);
    lora.targets[i]!.lw.a = primals[i]!;
    lora.targets[i]!.lw.b = primals[n + i]!;
  }
  return saved;
}

/** Restore the original leaves displaced by swapPrimals (saved order is
 *  [a0, b0, a1, b1, ...]). */
function restorePrimals(lora: TrainableLora, saved: MlxArray[]): void {
  for (let i = 0; i < lora.targets.length; i++) {
    lora.targets[i]!.lw.a = saved[2 * i]!;
    lora.targets[i]!.lw.b = saved[2 * i + 1]!;
  }
}

/** Write a replaced param (AdamW output) back into its LoraWeights leaf. */
function writeParam(lora: TrainableLora, i: number, p: MlxArray): void {
  const n = lora.targets.length;
  if (i < n) lora.targets[i]!.lw.a = p;
  else lora.targets[i - n]!.lw.b = p;
}

/** Run one optimizer step's worth of gradient over `accumSteps` micro-batches:
 *  backward each micro-batch, mean-accumulate the per-micro grads (each scaled
 *  by 1/accumSteps), and return the mean loss + summed grads — a drop-in for the
 *  single value_and_grad the loops used to call inline. The caller passes the
 *  returned grads to opt.step (which takes ownership and disposes them).
 *
 *  accumSteps <= 1 is a pass-through identical to the pre-accumulation path (one
 *  micro-batch, no scaling) so the proven B=1 loops stay byte-for-byte unchanged.
 *  For accumSteps > 1 the running accumulator (and that micro-batch's loss) is
 *  eval'd before the next micro-batch's forward builds, so only ONE micro-batch's
 *  activations are ever live — peak memory does NOT grow with accumSteps (the
 *  whole point: a larger effective batch without the B>1 activation memory).
 *
 *  The combined `evalAll([value, ...grads])` per micro-batch is deliberate: a
 *  separate eval of `value` first would materialize then free the forward,
 *  forcing the backward to recompute and hold every layer's activations — which
 *  silently defeats gradient checkpointing (verified). Keep loss + grads in one
 *  eval.
 *
 *  `afterMicroEval` runs once per micro-batch right after its grads are
 *  materialized (its backward is complete), in BOTH the pass-through and
 *  accumulating paths — it frees per-micro-batch state the loss closure captured
 *  (gradient-checkpoint closures for SFT, reference log-probs for DPO) so that
 *  state does not pile up across accumulation.
 *
 *  `micro` returns the micro-batch loss scalar + grads in flatParams order
 *  ([...A, ...B] over targets); it transfers ownership of both to this helper,
 *  which disposes the per-micro value and grads. */
export function accumulateStep(
  accumSteps: number,
  micro: () => { value: MlxArray; grads: MlxArray[] },
  afterMicroEval?: () => void,
): { loss: number; grads: MlxArray[] } {
  if (accumSteps <= 1) {
    const { value, grads } = micro();
    evalAll([value, ...grads]);
    const loss = value.toFloat32()[0]!;
    value.dispose();
    afterMicroEval?.();
    return { loss, grads };
  }

  const scale = 1 / accumSteps;
  let acc: MlxArray[] | null = null;
  let lossSum = 0;
  try {
    for (let i = 0; i < accumSteps; i++) {
      const { value, grads } = micro();
      if (acc === null) {
        acc = grads.map((g) => {
          const s = ops.mulScalar(g, scale);
          g.dispose();
          return s;
        });
      } else {
        const prev = acc;
        acc = grads.map((g, j) => {
          const s = ops.mulScalar(g, scale);
          const sum = ops.add(prev[j]!, s);
          s.dispose();
          prev[j]!.dispose();
          g.dispose();
          return sum;
        });
      }
      // Eval the running accumulator (+ this micro-batch's loss) now so the
      // micro-batch's forward/backward graph frees before the next one builds —
      // this is what keeps peak flat across accumSteps.
      evalAll([value, ...acc]);
      lossSum += value.toFloat32()[0]!;
      value.dispose();
      afterMicroEval?.();
      clearCache();
    }
    const grads = acc!;
    acc = null; // ownership handed to the caller
    return { loss: lossSum / accumSteps, grads };
  } finally {
    // Non-null only if a micro-batch threw mid-accumulation (nulled on success).
    if (acc) for (const a of acc) a.dispose();
  }
}

/** L2 norm over all grads (also forces eval). */
function globalNorm(grads: MlxArray[]): number {
  const partial: MlxArray[] = grads.map((g) => {
    const sq = ops.square(g);
    const flat = ops.reshape(sq, [g.size]);
    const sum = ops.sumAxis(flat, 0, false);
    sq.dispose();
    flat.dispose();
    return sum;
  });
  evalAll(partial);
  let sumSq = 0;
  for (const p of partial) {
    sumSq += p.toFloat32()[0]!;
    p.dispose();
  }
  return Math.sqrt(sumSq);
}

/** Clip grads in place to a global L2 norm of `maxNorm` (no-op if off or under
 *  the cap). Scales every grad by maxNorm/normVal and disposes the originals so
 *  the optimizer takes ownership of the clipped copies. `normVal` is the already-
 *  computed global norm (avoids a second pass). */
function clipGradsByNorm(grads: MlxArray[], normVal: number, maxNorm: number): void {
  if (maxNorm <= 0 || !(normVal > maxNorm)) return;
  const s = maxNorm / normVal;
  for (let i = 0; i < grads.length; i++) {
    const g = grads[i]!;
    grads[i] = ops.mulScalar(g, s);
    g.dispose();
  }
}

/** Supervised (response) tokens across ALL rows of the batch — the count
 *  tokens/sec is reported over (mlx-lm's n_tokens counts every row too). */
function countResponseTokens(batch: SftBatch): number {
  let total = 0;
  for (let r = 0; r < batch.ids.length; r++) {
    const promptLen = batch.promptLens[r]!;
    const len = batch.ids[r]!.length;
    total += Math.max(0, len - Math.max(promptLen, 1));
  }
  return total;
}

async function fileExists(path: string): Promise<boolean> {
  return Bun.file(path).exists();
}
