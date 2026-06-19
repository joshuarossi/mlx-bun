// The finetune JobRunner: wires a submitted finetune job to trainLora.
// Speaks the shared src/jobs/types.ts contract. Registered as kind "finetune"
// so both submitInProcess and the subprocess job-entry resolver find it
// (job-entry.ts KIND_MODULES maps finetune → ../train/job.ts).

import type { JobRunner } from "../jobs/types";
import { registerRunner } from "../jobs/runner";
import {
  setWiredLimit, synchronize, maxRecommendedWorkingSetSize,
} from "../mlx/ffi";
import { gpuStream } from "../mlx/array";
import { trainLora, DEFAULT_TRAIN_CONFIG, type TrainConfig } from "./trainer";
import { probeFormat } from "./dataset";

/** Parse the submit config into a TrainConfig (with model/data paths). */
interface FinetuneSubmit {
  model_dir: string;
  data_dir: string;
  adapter_path: string;
  method?: "sft" | "dpo" | "orpo";
  rank?: number;
  scale?: number;
  rank_scaling?: TrainConfig["rankScaling"];
  target_modules?: string[];
  num_layers?: number;
  iters?: number;
  learning_rate?: number;
  max_seq_length?: number;
  batch_size?: number;
  grad_accumulation_steps?: number;
  seed?: number;
  steps_per_report?: number;
  steps_per_eval?: number;
  weight_decay?: number;
  lora_dropout?: number;
  rs_lora?: boolean;
  lora_plus_ratio?: number;
  grad_checkpoint?: boolean;
  mlp_split?: boolean;
  segment_size?: number;
  save_checkpoints?: boolean;
  dpo_beta?: number;
  dpo_warmup_iters?: number;
  dpo_lr_schedule?: "constant" | "cosine";
  orpo_lambda?: number;
  orpo_warmup_iters?: number;
  orpo_lr_schedule?: "constant" | "cosine";
  orpo_chunk_size?: number;
  orpo_fused_ce?: boolean;
  orpo_flash_ce?: boolean;
  orpo_prefix_shared?: boolean;
  warm_start_adapter?: string;
}

function parseConfig(raw: Record<string, unknown>): { modelDir: string; dataDir: string; cfg: TrainConfig } {
  const c = raw as unknown as FinetuneSubmit;
  if (!c.model_dir) throw new Error("finetune job: missing model_dir");
  if (!c.data_dir) throw new Error("finetune job: missing data_dir");
  if (!c.adapter_path) throw new Error("finetune job: missing adapter_path");

  const cfg: TrainConfig = {
    ...DEFAULT_TRAIN_CONFIG,
    method: c.method ?? "sft",
    rank: c.rank ?? DEFAULT_TRAIN_CONFIG.rank,
    scale: c.scale ?? DEFAULT_TRAIN_CONFIG.scale,
    rankScaling: c.rank_scaling ?? DEFAULT_TRAIN_CONFIG.rankScaling,
    targetModules: c.target_modules ?? DEFAULT_TRAIN_CONFIG.targetModules,
    numLayers: c.num_layers ?? DEFAULT_TRAIN_CONFIG.numLayers,
    iters: c.iters ?? DEFAULT_TRAIN_CONFIG.iters,
    learningRate: c.learning_rate ?? (c.method === "dpo" ? 5e-5 : c.method === "orpo" ? 1e-5 : DEFAULT_TRAIN_CONFIG.learningRate),
    maxSeqLen: c.max_seq_length ?? DEFAULT_TRAIN_CONFIG.maxSeqLen,
    batchSize: c.batch_size ?? DEFAULT_TRAIN_CONFIG.batchSize,
    gradAccumSteps: c.grad_accumulation_steps ?? DEFAULT_TRAIN_CONFIG.gradAccumSteps,
    seed: c.seed ?? DEFAULT_TRAIN_CONFIG.seed,
    stepsPerReport: c.steps_per_report ?? DEFAULT_TRAIN_CONFIG.stepsPerReport,
    stepsPerEval: c.steps_per_eval ?? DEFAULT_TRAIN_CONFIG.stepsPerEval,
    betas: DEFAULT_TRAIN_CONFIG.betas,
    weightDecay: c.weight_decay ?? DEFAULT_TRAIN_CONFIG.weightDecay,
    loraDropout: c.lora_dropout ?? DEFAULT_TRAIN_CONFIG.loraDropout,
    rsLora: c.rs_lora ?? DEFAULT_TRAIN_CONFIG.rsLora,
    loraPlusRatio: c.lora_plus_ratio ?? DEFAULT_TRAIN_CONFIG.loraPlusRatio,
    gradCheckpoint: c.grad_checkpoint ?? DEFAULT_TRAIN_CONFIG.gradCheckpoint,
    mlpSplit: c.mlp_split ?? DEFAULT_TRAIN_CONFIG.mlpSplit,
    segmentSize: c.segment_size ?? DEFAULT_TRAIN_CONFIG.segmentSize,
    saveCheckpoints: c.save_checkpoints ?? DEFAULT_TRAIN_CONFIG.saveCheckpoints,
    dpoBeta: c.dpo_beta ?? DEFAULT_TRAIN_CONFIG.dpoBeta,
    dpoWarmupIters: c.dpo_warmup_iters ?? DEFAULT_TRAIN_CONFIG.dpoWarmupIters,
    dpoLrSchedule: c.dpo_lr_schedule ?? DEFAULT_TRAIN_CONFIG.dpoLrSchedule,
    orpoLambda: c.orpo_lambda ?? DEFAULT_TRAIN_CONFIG.orpoLambda,
    orpoWarmupIters: c.orpo_warmup_iters ?? DEFAULT_TRAIN_CONFIG.orpoWarmupIters,
    orpoLrSchedule: c.orpo_lr_schedule ?? DEFAULT_TRAIN_CONFIG.orpoLrSchedule,
    orpoChunkSize: c.orpo_chunk_size ?? DEFAULT_TRAIN_CONFIG.orpoChunkSize,
    orpoFusedCe: c.orpo_fused_ce ?? DEFAULT_TRAIN_CONFIG.orpoFusedCe,
    orpoFlashCe: c.orpo_flash_ce ?? DEFAULT_TRAIN_CONFIG.orpoFlashCe,
    orpoPrefixShared: c.orpo_prefix_shared ?? DEFAULT_TRAIN_CONFIG.orpoPrefixShared,
    warmStartAdapter: c.warm_start_adapter ?? DEFAULT_TRAIN_CONFIG.warmStartAdapter,
    adapterPath: c.adapter_path,
    baseModel: c.model_dir,
  };
  return { modelDir: c.model_dir, dataDir: c.data_dir, cfg };
}

export const finetuneRunner: JobRunner = async (emit, config) => {
  const { modelDir, dataDir, cfg } = parseConfig(config);

  emit({ type: "stage", stage: "load", progress: 0.01, message: `loading model ${modelDir}` });

  const { loadModelConfig } = await import("../config");
  const { Weights } = await import("../weights");
  const { createModel } = await import("../model/factory");
  const { loadTokenizer } = await import("../tokenizer");
  const { ChatTemplate } = await import("../chat-template");

  const modelConfig = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);
  const model = createModel(weights, modelConfig);
  const tok = await loadTokenizer(modelDir);
  const tmpl = await ChatTemplate.load(modelDir);

  // Scoped wired limit around the whole run (set → train → synchronize →
  // restore). Subprocess-isolated so pinning is safe (PLAN Phase 6 rule:
  // never leave the limit raised process-permanently).
  const oldLimit = setWiredLimit(maxRecommendedWorkingSetSize());
  try {
    const result = await trainLora(model, tok, tmpl, dataDir, cfg, emit);
    return { outputPath: result.adapterPath };
  } finally {
    synchronize(gpuStream);
    setWiredLimit(oldLimit);
    weights.dispose();
  }
};

/** Inspect a dataset directory before submit: counts + detected format. */
export async function inspectDataset(dataDir: string): Promise<{
  ok: boolean;
  n_train: number;
  n_valid: number;
  format: string;
  error?: string;
}> {
  try {
    const trainPath = `${dataDir}/train.jsonl`;
    if (!(await Bun.file(trainPath).exists()))
      return { ok: false, n_train: 0, n_valid: 0, format: "unknown", error: `${trainPath} not found` };
    const nTrain = await countAndProbe(trainPath);
    const validPath = `${dataDir}/valid.jsonl`;
    const nValid = (await Bun.file(validPath).exists()) ? await countAndProbe(validPath) : { n: 0, fmt: "" };
    return {
      ok: true,
      n_train: nTrain.n,
      n_valid: nValid.n,
      format: nTrain.fmt,
    };
  } catch (e) {
    return {
      ok: false, n_train: 0, n_valid: 0, format: "unknown",
      error: e instanceof Error ? e.message : String(e),
    };
  }
}

async function countAndProbe(path: string): Promise<{ n: number; fmt: string }> {
  const text = await Bun.file(path).text();
  const lines = text.split("\n").map((l) => l.trim()).filter(Boolean);
  let fmt = "unknown";
  if (lines.length > 0) fmt = probeFormat(JSON.parse(lines[0]!) as Record<string, unknown>);
  return { n: lines.length, fmt };
}

// Self-register on import (mirrors the dataset/quantize convention).
registerRunner("finetune", finetuneRunner);
