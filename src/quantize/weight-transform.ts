// Quantizer-facing offline weight-transform seam. Recipe math lives in
// rotate.ts; this module owns planning, family adaptation, and tensor ownership
// so the artifact writer has one contract for every fold implementation.

import type { ModelConfig } from "../config";
import type { MlxArray } from "../mlx/array";
import type { Weights } from "../weights";
import {
  foldLlamaWeights,
  planQwen35Fold,
  planQwenMtpFold,
  QwenFoldContext,
  type FoldGeometry,
  type FoldOptions,
  type QwenFoldOptions,
  type QwenFoldPlan,
} from "./rotate";

/** Serialized alongside a quantized artifact so a folded basis is a property
 *  of the artifact, not an out-of-band experiment-script convention. */
export interface WeightTransformMetadata {
  id: string;
  seed: number;
  family: string;
  deviations: string[];
}

/** Pure output plan. `sourceByOutput` makes cloning/untie operations explicit:
 *  most outputs map to themselves; a synthesized head maps to its embedding. */
export interface WeightTransformPlan {
  readonly id: string;
  readonly outputNames: readonly string[];
  readonly sourceByOutput: ReadonlyMap<string, string>;
  readonly untieWordEmbeddings: boolean;
  readonly metadata: WeightTransformMetadata;
}

/** Per-run executor. `apply` returns a lazy, owned array and never disposes
 *  `source`; the quantizer owns the result and the Weights object owns source. */
export interface WeightTransformContext {
  apply(outputName: string, source: MlxArray): MlxArray;
  dispose(): void;
}

/** Common seam for the Llama, Qwen3.5 trunk, and Qwen MTP fold recipes. */
export interface WeightTransform {
  readonly id: string;
  /** Name/config analysis only: no mlx arrays, model load, or device work. */
  plan(names: readonly string[], config: ModelConfig): WeightTransformPlan;
  createContext(weights: Weights, plan: WeightTransformPlan): WeightTransformContext;
}

export interface LlamaWeightTransformPlan extends WeightTransformPlan {
  readonly kind: "llama";
  readonly geometry: FoldGeometry;
  readonly options: FoldOptions;
}

export interface QwenWeightTransformPlan extends WeightTransformPlan {
  readonly kind: "qwen3_5" | "qwen3_5_mtp";
  readonly hiddenSize: number;
  readonly seed: number;
  readonly fold: QwenFoldPlan;
}

function sourceMap(names: readonly string[]): Map<string, string> {
  return new Map(names.map((name) => [name, name]));
}

function assertPow2(n: number, what: string): void {
  if (n < 2 || (n & (n - 1)) !== 0)
    throw new Error(
      `rotation fold: ${what}=${n} is not a power of two — the Kronecker ` +
      "Hadamard path is not implemented",
    );
}

/** Pure Llama fold plan. Array work remains inside createContext/apply. */
export function planLlamaWeightTransform(
  names: readonly string[],
  config: ModelConfig,
  options: FoldOptions,
): LlamaWeightTransformPlan {
  const has = new Set(names);
  for (const required of ["model.embed_tokens.weight", "model.norm.weight"])
    if (!has.has(required)) throw new Error(`rotation fold: missing tensor ${required}`);
  if (has.has("lm_head.weight"))
    throw new Error("rotation fold: llama adapter currently requires tied embeddings");

  for (let i = 0; i < config.text.numHiddenLayers; i++) {
    const layer = `model.layers.${i}`;
    for (const required of [
      `${layer}.input_layernorm.weight`,
      `${layer}.post_attention_layernorm.weight`,
      `${layer}.self_attn.q_proj.weight`,
      `${layer}.self_attn.k_proj.weight`,
      `${layer}.self_attn.v_proj.weight`,
      `${layer}.self_attn.o_proj.weight`,
      `${layer}.mlp.gate_proj.weight`,
      `${layer}.mlp.up_proj.weight`,
      `${layer}.mlp.down_proj.weight`,
    ]) {
      if (!has.has(required)) throw new Error(`rotation fold: missing tensor ${required}`);
    }
  }

  const geometry: FoldGeometry = {
    numLayers: config.text.numHiddenLayers,
    hiddenSize: config.text.hiddenSize,
    numHeads: config.text.numAttentionHeads,
    numKvHeads: config.text.numKeyValueHeads,
    headDim: config.text.headDim,
  };
  if (options.r1 ?? true) assertPow2(geometry.hiddenSize, "hidden_size");
  if (options.r2 ?? true) assertPow2(geometry.headDim, "head_dim");

  const outputNames = [...names, "lm_head.weight"];
  const sourceByOutput = sourceMap(names);
  sourceByOutput.set("lm_head.weight", "model.embed_tokens.weight");
  return {
    kind: "llama",
    id: "rotation.llama",
    outputNames,
    sourceByOutput,
    untieWordEmbeddings: true,
    geometry,
    options: { ...options },
    metadata: {
      id: "rotation.llama",
      seed: options.seed,
      family: "llama",
      deviations: [
        "no-embedding-mean-centering",
        "no-R4-downproj-input-fold",
        "no-R3",
        "gamma-kept-in-module-as-ones (eps preserved)",
        "fold-precision-f32",
      ],
    },
  };
}

function createLlamaContext(
  weights: Weights,
  plan: LlamaWeightTransformPlan,
): WeightTransformContext {
  const folded = foldLlamaWeights(weights, plan.geometry, plan.options);
  const pending = new Map(folded.tensors.map((tensor) => [tensor.name, tensor.array]));
  return {
    apply(outputName, source) {
      const transformed = pending.get(outputName);
      if (transformed) {
        pending.delete(outputName);
        return transformed;
      }
      // Preserve family-specific tensors outside the fold corridor.
      return source.astype(source.dtype);
    },
    dispose() {
      for (const array of pending.values()) array.dispose();
      pending.clear();
    },
  };
}

function qwenTransformPlan(
  names: readonly string[],
  config: ModelConfig,
  seed: number,
  companion: boolean,
  prefix?: string,
): QwenWeightTransformPlan {
  const fold = companion
    ? planQwenMtpFold(names)
    : planQwen35Fold(
        names,
        prefix ?? (names.includes("language_model.model.norm.weight") ? "language_model." : ""),
      );
  const outputNames = [...names];
  const sourceByOutput = sourceMap(names);
  if (fold.extraHead) {
    outputNames.push(fold.extraHead.name);
    sourceByOutput.set(fold.extraHead.name, fold.extraHead.from);
  }
  const family = companion ? "qwen3_5_mtp" : "qwen3_5";
  return {
    kind: family,
    id: `rotation.${family}`,
    outputNames,
    sourceByOutput,
    untieWordEmbeddings: fold.extraHead !== null,
    hiddenSize: config.text.hiddenSize,
    seed,
    fold,
    metadata: {
      id: `rotation.${family}`,
      seed,
      family,
      deviations: [...fold.deviations],
    },
  };
}

function createQwenContext(
  weights: Weights,
  plan: QwenWeightTransformPlan,
): WeightTransformContext {
  // Lazy mode composes into the quantizer's existing writer. The experiment
  // script keeps QwenFoldContext's eager default because it releases shards.
  const context = new QwenFoldContext(
    weights,
    plan.hiddenSize,
    plan.seed,
    plan.fold.gammaNames,
    false,
  );
  return {
    apply(outputName, source) {
      const extra = plan.fold.extraHead;
      if (extra && outputName === extra.name)
        return context.apply({ kind: "input", gamma: extra.gamma }, source);
      const op = plan.fold.ops.get(outputName);
      if (!op) throw new Error(`weight transform ${plan.id}: unplanned output ${outputName}`);
      return context.apply(op, source);
    },
    dispose: () => context.dispose(),
  };
}

/** Llama-family γ+R1+R2 adapter. */
export function llamaWeightTransform(options: FoldOptions): WeightTransform {
  return {
    id: "rotation.llama",
    plan: (names, config) => planLlamaWeightTransform(names, config, options),
    createContext(weights, plan) {
      if (!("kind" in plan) || plan.kind !== "llama")
        throw new Error(`weight transform rotation.llama received plan ${plan.id}`);
      return createLlamaContext(weights, plan as LlamaWeightTransformPlan);
    },
  };
}

/** Qwen3.5 trunk/VL adapter (R1 only because of the attention output gate). */
export function qwen35WeightTransform(options: QwenFoldOptions): WeightTransform {
  return {
    id: "rotation.qwen3_5",
    plan: (names, config) =>
      qwenTransformPlan(names, config, options.seed, false, options.prefix),
    createContext(weights, plan) {
      if (!("kind" in plan) || plan.kind !== "qwen3_5")
        throw new Error(`weight transform rotation.qwen3_5 received plan ${plan.id}`);
      return createQwenContext(weights, plan as QwenWeightTransformPlan);
    },
  };
}

/** Qwen3.5 MTP companion adapter. Must use the same seed as its trunk. */
export function qwenMtpWeightTransform(seed: number): WeightTransform {
  return {
    id: "rotation.qwen3_5_mtp",
    plan: (names, config) => qwenTransformPlan(names, config, seed, true),
    createContext(weights, plan) {
      if (!("kind" in plan) || plan.kind !== "qwen3_5_mtp")
        throw new Error(`weight transform rotation.qwen3_5_mtp received plan ${plan.id}`);
      return createQwenContext(weights, plan as QwenWeightTransformPlan);
    },
  };
}

/** Select one of the three adapters from the source model and tensor schema. */
export function automaticRotationWeightTransform(
  options: FoldOptions & { prefix?: string },
): WeightTransform {
  return {
    id: "rotation.auto",
    plan(names, config) {
      if (names.includes("fc.weight") && names.includes("pre_fc_norm_hidden.weight"))
        return qwenTransformPlan(names, config, options.seed, true);
      if (config.modelType === "qwen3_5")
        return qwenTransformPlan(names, config, options.seed, false, options.prefix);
      if (config.modelType === "llama")
        return planLlamaWeightTransform(names, config, options);
      throw new Error(`rotation transform: unsupported model_type ${config.modelType}`);
    },
    createContext(weights, plan) {
      if (!("kind" in plan)) throw new Error(`rotation transform: invalid plan ${plan.id}`);
      return plan.kind === "llama"
        ? createLlamaContext(weights, plan as LlamaWeightTransformPlan)
        : createQwenContext(weights, plan as QwenWeightTransformPlan);
    },
  };
}
