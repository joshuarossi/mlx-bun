import type { TrainConfig } from "@mlx-bun/training";

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
  grad_clip_norm?: number;
  val_max_examples?: number;
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
  sft_scope?: "full" | "response";
  warm_start_adapter?: string;
}

export function parseFinetuneConfig(raw: Record<string, unknown>, defaults: TrainConfig): { modelDir: string; dataDir: string; cfg: TrainConfig } {
  const c = raw as unknown as FinetuneSubmit;
  if (typeof c.model_dir !== "string" || !c.model_dir) throw new Error("finetune job: missing model_dir");
  if (typeof c.data_dir !== "string" || !c.data_dir) throw new Error("finetune job: missing data_dir");
  if (typeof c.adapter_path !== "string" || !c.adapter_path) throw new Error("finetune job: missing adapter_path");

  // Preserve the existing app ORPO recipe: flash-CCE head + prefix-sharing + segmented
  // backward + token-chunked head. defaults keeps them OFF (they're
  // opt-in for SFT), so default them ON here when method=orpo — an explicit
  // value from the API caller still wins via ??. The child runner drops the
  // quantized-head pieces if the base turns out to be unquantized.
  const isOrpo = (c.method ?? "sft") === "orpo";

  // ORPO L_SFT scope: "full" (default; paper/TRL-faithful) | "response"
  // (pre-2026-07 behavior). Validate before loading the model.
  const sftScope = c.sft_scope ?? defaults.sftScope;
  if (sftScope !== "full" && sftScope !== "response")
    throw new Error(`finetune job: sft_scope must be "full" or "response" (got ${JSON.stringify(c.sft_scope)})`);

  const cfg: TrainConfig = {
    ...defaults,
    method: c.method ?? "sft",
    rank: c.rank ?? defaults.rank,
    scale: c.scale ?? defaults.scale,
    rankScaling: c.rank_scaling ?? defaults.rankScaling,
    targetModules: c.target_modules ?? defaults.targetModules,
    numLayers: c.num_layers ?? defaults.numLayers,
    iters: c.iters ?? defaults.iters,
    learningRate: c.learning_rate ?? (c.method === "dpo" ? 5e-5 : c.method === "orpo" ? 1e-5 : defaults.learningRate),
    maxSeqLen: c.max_seq_length ?? defaults.maxSeqLen,
    batchSize: c.batch_size ?? defaults.batchSize,
    gradAccumSteps: c.grad_accumulation_steps ?? defaults.gradAccumSteps,
    seed: c.seed ?? defaults.seed,
    stepsPerReport: c.steps_per_report ?? defaults.stepsPerReport,
    stepsPerEval: c.steps_per_eval ?? defaults.stepsPerEval,
    betas: defaults.betas,
    weightDecay: c.weight_decay ?? defaults.weightDecay,
    loraDropout: c.lora_dropout ?? defaults.loraDropout,
    rsLora: c.rs_lora ?? defaults.rsLora,
    loraPlusRatio: c.lora_plus_ratio ?? defaults.loraPlusRatio,
    gradCheckpoint: c.grad_checkpoint ?? defaults.gradCheckpoint,
    mlpSplit: c.mlp_split ?? defaults.mlpSplit,
    segmentSize: c.segment_size ?? (isOrpo ? 2 : defaults.segmentSize),
    saveCheckpoints: c.save_checkpoints ?? defaults.saveCheckpoints,
    gradClipNorm: c.grad_clip_norm ?? defaults.gradClipNorm,
    valMaxExamples: c.val_max_examples ?? defaults.valMaxExamples,
    dpoBeta: c.dpo_beta ?? defaults.dpoBeta,
    dpoWarmupIters: c.dpo_warmup_iters ?? defaults.dpoWarmupIters,
    dpoLrSchedule: c.dpo_lr_schedule ?? defaults.dpoLrSchedule,
    orpoLambda: c.orpo_lambda ?? defaults.orpoLambda,
    orpoWarmupIters: c.orpo_warmup_iters ?? defaults.orpoWarmupIters,
    orpoLrSchedule: c.orpo_lr_schedule ?? defaults.orpoLrSchedule,
    orpoChunkSize: c.orpo_chunk_size ?? (isOrpo ? 512 : defaults.orpoChunkSize),
    orpoFusedCe: c.orpo_fused_ce ?? defaults.orpoFusedCe,
    orpoFlashCe: c.orpo_flash_ce ?? (isOrpo ? true : defaults.orpoFlashCe),
    orpoPrefixShared: c.orpo_prefix_shared ?? (isOrpo ? true : defaults.orpoPrefixShared),
    sftScope,
    warmStartAdapter: c.warm_start_adapter ?? defaults.warmStartAdapter,
    adapterPath: c.adapter_path,
    baseModel: c.model_dir,
  };
  return { modelDir: c.model_dir, dataDir: c.data_dir, cfg };
}

