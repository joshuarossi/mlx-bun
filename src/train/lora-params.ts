// Trainable LoRA parameter management: build A/B leaves, attach them to the
// model's quantized linears for the forward pass, expose a stable flat order
// for value_and_grad argnums, and save the adapter in the AdapterManager.mount
// format (lora_a / lora_b tensor names + optiq_lora_config.json + PEFT
// adapter_config.json).
//
// Init follows mlx-lm LoRALinear: A ~ normal(0, 1/sqrt(in)), B = zeros, so the
// LoRA residual starts at exactly zero (the adapted model == base model at
// step 0). Trained in f32.

import { mkdirSync } from "node:fs";
import { ptr } from "bun:ffi";
import { C, Dtype } from "../mlx/ffi";
import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import type { LoraWeights, QuantizedLinear } from "../model/gemma4-base";

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
    const a = ops.randomNormal([inF, rank], Dtype.float32, 0, 1 / Math.sqrt(inF), subkey);
    subkey.dispose();
    const b = ops.zeros([rank, outF], Dtype.float32);
    targets.push({ modulePath, linear, lw: { a, b, scale, rank } });
  });
  subkeys.dispose();

  return { adapterId: "train", scale, targets };
}

/** Attach the trainable leaves to the model so the forward pass picks them up
 *  via loraState.active. */
export function attachForTraining(model: RuntimeModel, lora: TrainableLora, adapterId: string): void {
  lora.adapterId = adapterId;
  for (const t of lora.targets) {
    (t.linear.adapters ??= new Map()).set(adapterId, t.lw);
    t.linear.loraState = model.loraState;
  }
  model.loraState.active = [adapterId];
}

/** Detach the trainable leaves (after training / before save). */
export function detachTraining(model: RuntimeModel, lora: TrainableLora): void {
  for (const t of lora.targets) t.linear.adapters?.delete(lora.adapterId);
  model.loraState.active = model.loraState.active.filter((x) => x !== lora.adapterId);
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
    target_modules: cfg.targetModules,
    num_layers: cfg.numLayers,
    lora_parameters: { scale: cfg.scale, rank: cfg.rank },
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
