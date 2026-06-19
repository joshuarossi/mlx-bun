// Trainable LoRA parameter management: build A/B leaves, attach them to the
// model's quantized linears for the forward pass, expose a stable flat order
// for value_and_grad argnums, and save the adapter in the AdapterManager.mount
// format (lora_a / lora_b tensor names + optiq_lora_config.json + PEFT
// adapter_config.json).
//
// Init follows mlx-lm LoRALinear.from_base: A ~ uniform(-1/sqrt(in), 1/sqrt(in)),
// B = zeros, so the LoRA residual starts at exactly zero (the adapted model ==
// base model at step 0). Trained in f32. (mlx-lm uses uniform, not normal —
// matching it keeps L1 training faithful to the parent.)

import { mkdirSync } from "node:fs";
import { ptr } from "bun:ffi";
import { C, Dtype } from "../mlx/ffi";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import type { LoraWeights, QuantizedLinear } from "../model/gemma4-base";
import { loadAdapterTensors } from "../lora";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

/** One trainable LoRA target: the owning linear + its A/B leaves. */
export interface TrainableTarget {
  modulePath: string;
  linear: QuantizedLinear;
  lw: LoraWeights;
}

/** The full set of trainable LoRA leaves for one adapter. */
export interface TrainableLora {
  adapterId: string;
  scale: number;
  targets: TrainableTarget[];
}

/** Build trainable A/B leaves for the given ranks (one entry per module path).
 *  Modules absent from `ranks` are skipped. A is normal-init, B is zeros. */
export function buildTrainableLora(
  model: RuntimeModel,
  ranks: Map<string, number>,
  scale: number,
  seed: number,
  rsLora = false,
): TrainableLora {
  const linears = model.loraTargets();
  const key = ops.randomKey(BigInt(seed >>> 0));
  // One subkey per target for reproducible, independent A inits.
  const paths = [...ranks.keys()].filter((p) => linears.has(p)).sort();
  const subkeys = ops.randomSplitNum(key, Math.max(1, paths.length));
  key.dispose();

  const targets: TrainableTarget[] = [];
  paths.forEach((modulePath, i) => {
    const linear = linears.get(modulePath)!;
    const rank = ranks.get(modulePath)!;
    const inF = linear.inFeatures;
    const outF = linear.outFeatures;
    const subkeyRow = subkeys.slice([i, 0], [i + 1, 2]); // [1,2]
    const subkey = ops.reshape(subkeyRow, [2]);          // mlx wants a [2] key
    subkeyRow.dispose();
    const aScale = 1 / Math.sqrt(inF);
    const a = ops.randomUniform([inF, rank], Dtype.float32, -aScale, aScale, subkey);
    subkey.dispose();
    const b = ops.zeros([rank, outF], Dtype.float32);
    // rsLoRA: α/√rank so per-layer rank scaling changes capacity, not step size.
    const lwScale = rsLora ? scale / Math.sqrt(rank) : scale;
    targets.push({ modulePath, linear, lw: { a, b, scale: lwScale, rank } });
  });
  subkeys.dispose();

  return { adapterId: "train", scale, targets };
}

/** Warm-start: overwrite a freshly-built LoRA's A/B leaves with the weights saved in
 *  `dir/adapters.safetensors` (saveAdapter's `${modulePath}.lora_a/b` names), so a run
 *  continues from a checkpoint's WEIGHTS. The optimizer state and LR schedule restart —
 *  Adam re-warms its moments in a few steps — so this is a weights warm-start, not a
 *  bit-perfect resume. The checkpoint's rank/targets must match this LoRA (shapes are
 *  checked). MUST be called BEFORE the optimizer is built so it tracks the loaded
 *  handles. Returns the number of targets loaded. */
export function warmStartFromAdapter(lora: TrainableLora, dir: string): number {
  const file = `${dir}/adapters.safetensors`;
  const tensors = loadAdapterTensors(file); // caller owns; disposed below
  const adopted = new Set<MlxArray>();
  try {
    // Two phases so the swap is atomic: validate EVERY target first (throws before
    // anything is disposed), then dispose+adopt. A mid-loop failure must not leave
    // lora.targets half-replaced (some checkpoint leaves, some fresh init).
    const pending: Array<{ t: (typeof lora.targets)[number]; a: MlxArray; b: MlxArray }> = [];
    for (const t of lora.targets) {
      const a = tensors.get(`${t.modulePath}.lora_a`);
      const b = tensors.get(`${t.modulePath}.lora_b`);
      if (!a || !b) throw new Error(`warm-start: ${t.modulePath} missing lora_a/lora_b in ${file}`);
      if (a.dtype !== Dtype.float32 || b.dtype !== Dtype.float32)
        throw new Error(`warm-start: ${t.modulePath} tensors must be f32`);
      if (a.shape[0] !== t.lw.a.shape[0] || a.shape[1] !== t.lw.a.shape[1] ||
          b.shape[0] !== t.lw.b.shape[0] || b.shape[1] !== t.lw.b.shape[1])
        throw new Error(`warm-start: shape mismatch at ${t.modulePath} — the checkpoint's rank/targets must match this run`);
      pending.push({ t, a, b });
    }
    for (const { t, a, b } of pending) {
      t.lw.a.dispose(); t.lw.b.dispose(); // free the fresh random/zero init
      t.lw.a = a; t.lw.b = b;             // adopt the checkpoint weights as the live leaves
      adopted.add(a); adopted.add(b);
    }
  } finally {
    for (const [, arr] of tensors) if (!adopted.has(arr)) arr.dispose();
  }
  return lora.targets.length;
}

/** Attach the trainable leaves to the model so the forward pass picks them up
 *  via loraState.active. */
export function attachForTraining(model: RuntimeModel, lora: TrainableLora, adapterId: string): void {
  lora.adapterId = adapterId;
  lora.targets.forEach((t, i) => {
    (t.linear.adapters ??= new Map()).set(adapterId, t.lw);
    t.linear.loraState = model.loraState;
    t.linear.dropoutId = i; // stable per-target key for recompute-safe dropout
  });
  model.loraState.active = [adapterId];
}

/** Detach the trainable leaves (after training / before save). */
export function detachTraining(model: RuntimeModel, lora: TrainableLora): void {
  for (const t of lora.targets) t.linear.adapters?.delete(lora.adapterId);
  model.loraState.active = model.loraState.active.filter((x) => x !== lora.adapterId);
  model.loraState.dropoutRate = 0; // disable training dropout for inference
  model.loraState.dropoutSeed = null;
}

/** Set the LoRA scale on every trainable leaf (DPO reference forward uses 0). */
export function setLoraScale(lora: TrainableLora, s: number): void {
  for (const t of lora.targets) t.lw.scale = s;
}

/** A leaves in stable (sorted-by-modulePath) order — the order used for
 *  value_and_grad argnums and AdamW state. */
export function flatA(lora: TrainableLora): MlxArray[] {
  return lora.targets.map((t) => t.lw.a);
}

/** B leaves in the same stable order, appended after all A leaves. */
export function flatB(lora: TrainableLora): MlxArray[] {
  return lora.targets.map((t) => t.lw.b);
}

/** [...A, ...B] — the full differentiable parameter vector. */
export function flatParams(lora: TrainableLora): MlxArray[] {
  return [...flatA(lora), ...flatB(lora)];
}

/** Adapter config written alongside the weights. */
export interface SaveAdapterConfig {
  rank: number;
  scale: number;
  rankScaling: string;
  targetModules: string[];
  numLayers: number;
  method: string;
  baseModel: string;
  /** rsLoRA: if true the effective per-layer scale is α/√rank (the loader must
   *  apply the same, so it's recorded in optiq_lora_config.json). */
  rsLora?: boolean;
}

/** Save the trained adapter into `dir` in the AdapterManager.mount format:
 *  adapters.safetensors (lora_a / lora_b tensor names), optiq_lora_config.json,
 *  and a PEFT-compatible adapter_config.json. */
export function saveAdapter(
  lora: TrainableLora,
  dir: string,
  cfg: SaveAdapterConfig,
  appliedRanks: Record<string, number>,
): void {
  mkdirSync(dir, { recursive: true });

  // Build the native string→array map and insert lora_a / lora_b per target.
  const map = C.mlx_map_string_to_array_new();
  const meta = C.mlx_map_string_to_string_new();
  try {
    for (const t of lora.targets) {
      // Materialize before save (the leaves are live graph nodes).
      t.lw.a.eval();
      t.lw.b.eval();
      if (C.mlx_map_string_to_array_insert(map, ptr(cstr(`${t.modulePath}.lora_a`)), t.lw.a.handle) !== 0)
        throw new Error(`map insert ${t.modulePath}.lora_a failed`);
      if (C.mlx_map_string_to_array_insert(map, ptr(cstr(`${t.modulePath}.lora_b`)), t.lw.b.handle) !== 0)
        throw new Error(`map insert ${t.modulePath}.lora_b failed`);
    }
    const file = `${dir}/adapters.safetensors`;
    if (C.mlx_save_safetensors(ptr(cstr(file)), map, meta) !== 0)
      throw new Error(`mlx_save_safetensors(${file}) failed`);
  } finally {
    C.mlx_map_string_to_array_free(map);
    C.mlx_map_string_to_string_free(meta);
  }

  // optiq_lora_config.json — AdapterManager.readAdapterScale reads
  // lora_parameters.scale + rank from here first.
  const optiqCfg = {
    rank: cfg.rank,
    scale: cfg.scale,
    rank_scaling: cfg.rankScaling,
    method: cfg.method,
    rs_lora: cfg.rsLora ?? false,
    target_modules: cfg.targetModules,
    num_layers: cfg.numLayers,
    lora_parameters: { scale: cfg.scale, rank: cfg.rank, rs_lora: cfg.rsLora ?? false },
    applied_ranks: appliedRanks,
    source_model: cfg.baseModel,
  };
  Bun.write(`${dir}/optiq_lora_config.json`, JSON.stringify(optiqCfg, null, 2) + "\n");

  // PEFT-compatible adapter_config.json (loadable by mlx-lm / PEFT).
  const peftCfg = {
    fine_tune_type: "lora",
    num_layers: cfg.numLayers,
    lora_parameters: { rank: cfg.rank, scale: cfg.scale, dropout: 0.0, keys: null },
    base_model_name_or_path: cfg.baseModel,
    bias: "none",
    fan_in_fan_out: false,
    inference_mode: false,
    init_lora_weights: true,
    lora_alpha: Math.round(cfg.rank * cfg.scale),
    lora_dropout: 0.0,
    peft_type: "LORA",
    r: cfg.rank,
    target_modules: cfg.targetModules,
    task_type: "CAUSAL_LM",
    optiq: { rank_scaling: cfg.rankScaling, applied_ranks: appliedRanks },
  };
  Bun.write(`${dir}/adapter_config.json`, JSON.stringify(peftCfg, null, 2) + "\n");
}

/** Dispose all trainable leaves (frees A/B). */
export function disposeLora(lora: TrainableLora): void {
  for (const t of lora.targets) {
    t.lw.a.dispose();
    t.lw.b.dispose();
  }
}
