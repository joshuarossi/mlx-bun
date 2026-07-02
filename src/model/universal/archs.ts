// Arch descriptor table for the Tier-0 universal dense module
// (docs/design/generic-model-support.md §3.1). One entry per mlx-lm
// model_type; each parse function is the ~15–25-line transcription of that
// arch's ModelArgs (defaults included) + structural deltas, read from the
// RAW config.json exactly like the oracle's dataclass does.
//
// Support is this table's keys (+ MODEL_REMAPPING aliases) — an explicit,
// declared surface. No config sniffing. A model_type absent here is
// unsupported until a descriptor + green parity manifest entry exist.

import type { ModelConfig } from "../../config";
import type { RopeScalingConfig } from "./rope";

/** mlx_lm/utils.py MODEL_REMAPPING, vendored (free aliases). Only entries
 *  whose TARGET has a descriptor below actually load; the rest are kept so
 *  the reject message can name the real arch. */
export const MODEL_REMAPPING: Record<string, string> = {
  mistral: "llama",
  llava: "mistral3",
  "phi-msft": "phixtral",
  falcon_mamba: "mamba",
  joyai_llm_flash: "deepseek_v3",
  kimi_k2: "deepseek_v3",
  qwen2_5_vl: "qwen2_vl",
  minimax_m2: "minimax",
  iquestcoder: "llama",
};

export function remapModelType(modelType: string): string {
  return MODEL_REMAPPING[modelType] ?? modelType;
}

/** Normalized args for the universal dense forward — the union of the
 *  launch archs' ModelArgs, one value per knob (no optionals left). */
export interface UniversalArgs {
  modelType: string;
  hiddenSize: number;
  numHiddenLayers: number;
  intermediateSize: number;
  numHeads: number;
  numKvHeads: number;
  headDim: number;
  normEps: number;
  vocabSize: number;
  ropeTheta: number;
  ropeTraditional: boolean;
  ropeScaling: RopeScalingConfig | null;
  maxPositionEmbeddings: number | null;
  /** q/k/v projection bias; o and mlp separately (qwen2: qkv only). */
  qkvBias: boolean;
  oBias: boolean;
  mlpBias: boolean;
  tieWordEmbeddings: boolean;
  /** null ⇒ every layer full attention. */
  layerTypes: string[] | null;
  slidingWindow: number | null;
  // ---- block structure ----
  /** pre  = llama (norm → sublayer → residual)
   *  post = olmo2 (sublayer → norm → residual)
   *  gemma2 = sandwich (input/post-attn + pre/post-ffn norms)
   *  glm4 = post-sublayer norms with pre-norms too */
  block: "pre" | "post" | "gemma2" | "glm4";
  norm: "rmsnorm" | "rmsnorm_plus_one" | "layernorm";
  /** qwen3 = per-head RMSNorm over head_dim (before transpose);
   *  olmo2 = full-width RMSNorm on the flat projection (before reshape). */
  qkNorm: "none" | "head" | "full";
  mlp: "swiglu" | "geglu" | "geglu_approx" | "fused_swiglu" | "gelu_mlp";
  /** phi3: one fused qkv_proj, split as activations (mx.split — exactly
   *  what mlx-lm does; the quantized matrix stays fused). */
  fusedQkv: boolean;
  attnScale: number;
  /** gemma2 attention-score softcap ⇒ manual q·kᵀ→tanh→softmax path. */
  attnLogitSoftcap: number | null;
  finalLogitSoftcap: number | null;
  /** granite: logits / logits_scaling. */
  logitsDivisor: number | null;
  /** gemma: hidden**0.5; granite: embedding_multiplier. */
  embedMultiplier: number | null;
  /** granite residual_multiplier. */
  residualMultiplier: number | null;
  rope: "initialize" | "plain" | "phi3";
  /** rope dims = floor(headDim * partialRotaryFactor) (glm4, phi3). */
  partialRotaryFactor: number;
  /** phi3 SuScaledRoPE original context (TOP-LEVEL config key). */
  originalMaxPositionEmbeddings: number;
  /** smollm3: per-layer 1 = rope, 0 = NoPE. null ⇒ rope everywhere. */
  noRopeLayers: number[] | null;
  /** gemma2: create_attention_mask(..., return_array=True). */
  maskArray: boolean;
  /** sanitize: tensors mlx-lm drops on load (audit allowances). */
  dropWeightPatterns: RegExp[];
}

type Raw = Record<string, any>;

const INV_FREQ = /self_attn\.rotary_emb\.inv_freq/;

/** Common fields most archs share; per-arch parsers override the deltas. */
function common(raw: Raw, modelType: string): UniversalArgs {
  const heads = raw.num_attention_heads as number;
  return {
    modelType,
    hiddenSize: raw.hidden_size,
    numHiddenLayers: raw.num_hidden_layers,
    intermediateSize: raw.intermediate_size,
    numHeads: heads,
    numKvHeads: raw.num_key_value_heads ?? heads,
    headDim: Math.floor(raw.hidden_size / heads),
    normEps: raw.rms_norm_eps,
    vocabSize: raw.vocab_size,
    ropeTheta: raw.rope_theta ?? 10000,
    ropeTraditional: raw.rope_traditional ?? false,
    ropeScaling: (raw.rope_scaling as RopeScalingConfig | undefined) ?? null,
    maxPositionEmbeddings: raw.max_position_embeddings ?? null,
    qkvBias: false,
    oBias: false,
    mlpBias: false,
    tieWordEmbeddings: raw.tie_word_embeddings ?? true,
    layerTypes: null,
    slidingWindow: null,
    block: "pre",
    norm: "rmsnorm",
    qkNorm: "none",
    mlp: "swiglu",
    fusedQkv: false,
    attnScale: Math.pow(Math.floor(raw.hidden_size / heads), -0.5),
    attnLogitSoftcap: null,
    finalLogitSoftcap: null,
    logitsDivisor: null,
    embedMultiplier: null,
    residualMultiplier: null,
    rope: "initialize",
    partialRotaryFactor: 1.0,
    originalMaxPositionEmbeddings: 4096,
    noRopeLayers: null,
    maskArray: false,
    dropWeightPatterns: [],
  };
}

function parseLlama(raw: Raw, modelType = "llama"): UniversalArgs {
  const a = common(raw, modelType);
  a.headDim = raw.head_dim ?? a.headDim;
  a.attnScale = Math.pow(a.headDim, -0.5);
  a.qkvBias = raw.attention_bias ?? false;
  a.oBias = raw.attention_bias ?? false; // llama.py wires o_proj bias to the same flag
  a.mlpBias = raw.mlp_bias ?? false;
  a.layerTypes = (raw.layer_types as string[] | undefined) ?? null;
  a.slidingWindow = raw.sliding_window ?? null;
  a.dropWeightPatterns = [INV_FREQ];
  if (a.tieWordEmbeddings) a.dropWeightPatterns.push(/^lm_head\.weight$/);
  return a;
}

export const ARCHS: Record<string, (raw: Raw) => UniversalArgs> = {
  /** llama (+ mistral / iquestcoder via remap): the reference dense block. */
  llama: (raw) => parseLlama(raw),

  /** smollm3: llama with NoPE layers (every no_rope_layer_interval-th). */
  smollm3: (raw) => {
    const a = parseLlama(raw, "smollm3");
    const interval = raw.no_rope_layer_interval ?? 4;
    const list = raw.no_rope_layers as number[] | undefined;
    if (list && list.length !== a.numHiddenLayers)
      throw new Error("`no_rope_layers` length mismatch");
    a.noRopeLayers = list ??
      Array.from({ length: a.numHiddenLayers }, (_, i) => ((i + 1) % interval !== 0 ? 1 : 0));
    return a;
  },

  /** qwen2: llama block + hardcoded q/k/v bias (o unbiased), theta 1e6. */
  qwen2: (raw) => {
    const a = common(raw, "qwen2");
    a.ropeTheta = raw.rope_theta ?? 1000000;
    a.maxPositionEmbeddings = raw.max_position_embeddings ?? 32768;
    a.qkvBias = true;
    a.dropWeightPatterns = [INV_FREQ];
    if (a.tieWordEmbeddings) a.dropWeightPatterns.push(/^lm_head\.weight$/);
    return a;
  },

  /** qwen3: per-head q/k RMSNorm over head_dim BEFORE transpose+rope. */
  qwen3: (raw) => {
    const a = common(raw, "qwen3");
    a.headDim = raw.head_dim; // required in qwen3 ModelArgs
    a.attnScale = Math.pow(a.headDim, -0.5);
    a.qkNorm = "head";
    a.tieWordEmbeddings = raw.tie_word_embeddings ?? false;
    if (a.tieWordEmbeddings) a.dropWeightPatterns = [/^lm_head\.weight$/];
    return a;
  },

  /** gemma (v1): (1+w) RMSNorm, √hidden embed scale, PRECISE-gelu gated
   *  MLP, always-tied head, plain rope (rope_scaling ignored). */
  gemma: (raw) => {
    const a = common(raw, "gemma");
    a.headDim = raw.head_dim; // required
    a.attnScale = Math.pow(a.headDim, -0.5);
    a.norm = "rmsnorm_plus_one";
    a.mlp = "geglu";
    a.embedMultiplier = Math.pow(raw.hidden_size, 0.5);
    a.tieWordEmbeddings = true; // as_linear unconditionally
    a.rope = "plain";
    a.ropeScaling = null;
    return a;
  },

  /** gemma2: gemma + sandwich norms, attention-score softcap (manual
   *  attention), query_pre_attn_scalar scale, final logit softcap,
   *  gelu_approx MLP, always-array mask. mlx-lm runs every layer full
   *  attention (no sliding window in its gemma2) — we match the oracle. */
  gemma2: (raw) => {
    const a = common(raw, "gemma2");
    a.headDim = raw.head_dim; // required
    a.norm = "rmsnorm_plus_one";
    a.block = "gemma2";
    a.mlp = "geglu_approx";
    a.embedMultiplier = Math.pow(raw.hidden_size, 0.5);
    a.tieWordEmbeddings = true;
    a.rope = "plain";
    a.ropeScaling = null;
    a.attnScale = 1.0 / Math.pow(raw.query_pre_attn_scalar ?? 144.0, 0.5);
    a.attnLogitSoftcap = raw.attn_logit_softcapping ?? 50.0;
    a.finalLogitSoftcap = raw.final_logit_softcapping ?? 30.0;
    a.maskArray = true;
    return a;
  },

  /** phi3: fused qkv + fused gate_up (split as ACTIVATIONS, like mlx-lm),
   *  longrope/su (or linear) rope on partial dims, untied head. */
  phi3: (raw) => {
    const a = common(raw, "phi3");
    a.tieWordEmbeddings = raw.tie_word_embeddings ?? false;
    a.fusedQkv = true;
    a.mlp = "fused_swiglu";
    a.rope = "phi3";
    a.partialRotaryFactor = raw.partial_rotary_factor ?? 1.0;
    a.maxPositionEmbeddings = raw.max_position_embeddings ?? 131072;
    a.originalMaxPositionEmbeddings = raw.original_max_position_embeddings ?? 4096;
    // phi3.py __post_init__: rope_scaling must carry {long_factor, type};
    // only longrope/su/linear supported, anything else → scaling off.
    if (a.ropeScaling) {
      for (const key of ["long_factor", "type"])
        if (!(key in a.ropeScaling))
          throw new Error(`rope_scaling must contain keys {'long_factor', 'type'}`);
      const t = String(a.ropeScaling.type);
      if (!["longrope", "su", "linear"].includes(t)) a.ropeScaling = null;
    }
    return a;
  },

  /** olmo2: POST-norm block (norm on sublayer output), full-width q/k
   *  RMSNorm on the flat projections. */
  olmo2: (raw) => {
    const a = common(raw, "olmo2");
    a.headDim = raw.head_dim ?? a.headDim;
    a.attnScale = Math.pow(a.headDim, -0.5);
    a.block = "post";
    a.qkNorm = "full";
    a.qkvBias = raw.attention_bias ?? false;
    a.oBias = raw.attention_bias ?? false;
    a.mlpBias = raw.mlp_bias ?? false;
    a.dropWeightPatterns = [INV_FREQ];
    return a;
  },

  /** glm4: pre+post sublayer norms (post_self_attn / post_mlp), fused
   *  gate_up MLP, PARTIAL rope with traditional=True default, always a
   *  separate lm_head. */
  glm4: (raw) => {
    const a = common(raw, "glm4");
    a.headDim = raw.head_dim ?? a.headDim;
    a.attnScale = Math.pow(a.headDim, -0.5);
    a.block = "glm4";
    a.mlp = "fused_swiglu";
    a.qkvBias = raw.attention_bias;
    a.rope = "plain";
    a.ropeScaling = null;
    a.ropeTraditional = raw.rope_traditional ?? true;
    a.partialRotaryFactor = raw.partial_rotary_factor;
    a.maxPositionEmbeddings = raw.max_position_embeddings ?? 32768;
    a.tieWordEmbeddings = false; // glm4.py constructs lm_head unconditionally
    return a;
  },

  /** granite: llama block scaled everywhere — attention_multiplier as the
   *  SDPA scale, embedding/residual multipliers, logits / logits_scaling. */
  granite: (raw) => {
    const a = common(raw, "granite");
    a.attnScale = raw.attention_multiplier;
    a.embedMultiplier = raw.embedding_multiplier;
    a.residualMultiplier = raw.residual_multiplier;
    a.logitsDivisor = raw.logits_scaling;
    a.qkvBias = raw.attention_bias;
    a.oBias = raw.attention_bias;
    a.mlpBias = raw.mlp_bias;
    a.ropeTraditional = false; // granite.py hardcodes False
    return a;
  },

  /** starcoder2: LayerNorm (bias affine), bias on ALL projections, plain
   *  c_fc→gelu(precise)→c_proj MLP, theta 1e5. */
  starcoder2: (raw) => {
    const a = common(raw, "starcoder2");
    a.normEps = raw.norm_epsilon ?? 1e-5;
    a.vocabSize = raw.vocab_size ?? 49152;
    a.ropeTheta = raw.rope_theta ?? 100000;
    a.norm = "layernorm";
    a.mlp = "gelu_mlp";
    a.qkvBias = true;
    a.oBias = true;
    a.mlpBias = true;
    a.rope = "plain";
    a.ropeScaling = null;
    return a;
  },
};

/** The declared generic support surface (post-remap model_types). */
export const GENERIC_MODEL_TYPES: ReadonlySet<string> = new Set(Object.keys(ARCHS));

/** Descriptor lookup for a loaded config; null ⇒ not generically supported. */
export function genericArgsFor(config: ModelConfig): UniversalArgs | null {
  const arch = remapModelType(config.modelType);
  const parse = ARCHS[arch];
  if (!parse) return null;
  const raw = (config.raw.text_config ?? config.raw) as Raw;
  const args = parse(raw);
  // keep the ORIGINAL model_type visible in errors/labels
  args.modelType = config.modelType;
  return args;
}
