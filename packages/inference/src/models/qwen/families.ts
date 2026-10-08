import { L1, defineFamily } from "../family";

/** Qwen3.5 hybrid gated-DeltaNet family (model_type qwen3_5 / qwen3_5_text).
 * Dense MLP only for now: the MoE variant (qwen3_5_moe) is deferred. */
export const QWEN35_FAMILY = defineFamily({
  graph: "qwen3.5",
  accepts: config => (config.modelType === "qwen3_5" || config.modelType === "qwen3_5_text") &&
    !config.text.enableMoeBlock &&
    config.text.numExperts === 0 &&
    config.text.linearNumValueHeads > 0 &&
    config.text.fullAttentionInterval > 0,
  hasModelType: modelType => modelType === "qwen3_5" || modelType === "qwen3_5_text",
  tier: "targeted",
  label: "qwen3_5",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "qwen3.5-dedicated",
  capabilities: ["qwen3.5-graph", "recurrent-state"],
});

/** Plain Qwen3 (model_type `qwen3`, Qwen3ForCausalLM): a standard dense decoder
 * with per-head q/k norm and tied embeddings. Also the text-embedding backbone
 * (mlx-community Qwen3-Embedding-*). Distinct from the qwen3_5 hybrid. */
export const QWEN3_FAMILY = defineFamily({
  graph: "qwen3",
  accepts: config => config.modelType === "qwen3",
  hasModelType: modelType => modelType === "qwen3",
  tier: "targeted",
  label: "qwen3",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "qwen3-dedicated",
  capabilities: ["qwen3-graph"],
  embedding: { terminator: "<|endoftext|>" },
});

/** Qwen3-MoE (model_type `qwen3_moe`): plain-qwen3 attention with a sparse MoE
 * FFN (gate Linear, precise softmax, top-k, renormalize, SwitchGLU experts with
 * compiled swiglu). Distinct from the qwen3 embedding backbone and the
 * qwen3_5 gated-DeltaNet hybrid. */
export const QWEN3_MOE_FAMILY = defineFamily({
  graph: "qwen3-moe",
  accepts: config => config.modelType === "qwen3_moe",
  hasModelType: modelType => modelType === "qwen3_moe",
  tier: "targeted",
  label: "qwen3_moe",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "dedicated",
  profileId: "qwen3-moe-dedicated",
  capabilities: ["qwen3-moe-graph"],
});
