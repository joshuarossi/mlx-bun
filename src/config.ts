// Model config + quantization metadata reader for the load path.
// Parses HF config.json (Gemma 4 unified layout: text_config nested),
// the OptiQ per-layer quantization map, and kv_config.json when present.

export interface RopeParams {
  ropeTheta: number;
  ropeType: string;
  partialRotaryFactor: number;
}

export interface TextConfig {
  hiddenSize: number;
  numHiddenLayers: number;
  numAttentionHeads: number;
  numKeyValueHeads: number;
  headDim: number;
  /** Global (full-attention) layers can use different KV geometry. */
  numGlobalKeyValueHeads: number;
  globalHeadDim: number;
  attentionKEqV: boolean;
  intermediateSize: number;
  hiddenActivation: string;
  rmsNormEps: number;
  vocabSize: number;
  maxPositionEmbeddings: number;
  slidingWindow: number;
  /** "sliding_attention" | "full_attention" per layer. */
  layerTypes: string[];
  ropeParameters: Record<string, RopeParams>;
  finalLogitSoftcapping: number | null;
  tieWordEmbeddings: boolean;
  bosTokenId: number;
  eosTokenId: number | number[];
}

export interface QuantSpec {
  bits: number;
  groupSize: number;
  mode: string;
}

export interface QuantizationConfig {
  default: QuantSpec;
  /** Per-module overrides keyed by module path (e.g. "language_model.model.embed_tokens"). */
  perLayer: Map<string, QuantSpec>;
}

export interface KvQuantSpec {
  layerIdx: number;
  bits: number;
  groupSize: number;
}

export interface ModelConfig {
  modelDir: string;
  modelType: string;
  architectures: string[];
  dtype: string;
  text: TextConfig;
  quantization: QuantizationConfig | null;
  kvQuant: KvQuantSpec[] | null;
  hasVisionSidecar: boolean;
  eosTokenIds: number[];
  raw: Record<string, unknown>;
}

function parseRope(raw: Record<string, any>): Record<string, RopeParams> {
  const out: Record<string, RopeParams> = {};
  for (const [kind, p] of Object.entries(raw ?? {})) {
    out[kind] = {
      ropeTheta: p.rope_theta,
      ropeType: p.rope_type ?? "default",
      partialRotaryFactor: p.partial_rotary_factor ?? 1.0,
    };
  }
  return out;
}

function parseQuantization(raw: Record<string, any> | undefined): QuantizationConfig | null {
  if (!raw) return null;
  const def: QuantSpec = {
    bits: raw.bits,
    groupSize: raw.group_size,
    mode: raw.mode ?? "affine",
  };
  const perLayer = new Map<string, QuantSpec>();
  for (const [key, value] of Object.entries(raw)) {
    if (key === "bits" || key === "group_size" || key === "mode") continue;
    if (typeof value === "object" && value !== null) {
      perLayer.set(key, {
        bits: (value as any).bits ?? def.bits,
        groupSize: (value as any).group_size ?? def.groupSize,
        mode: (value as any).mode ?? def.mode,
      });
    } else if (value === false) {
      // mlx convention: `"layer": false` means not quantized
      perLayer.set(key, { bits: 0, groupSize: 0, mode: "none" });
    }
  }
  return { default: def, perLayer };
}

/** Quant spec for a module path, or null if the module is unquantized. */
export function quantFor(q: QuantizationConfig | null, modulePath: string): QuantSpec | null {
  if (!q) return null;
  const spec = q.perLayer.get(modulePath) ?? q.default;
  return spec.mode === "none" ? null : spec;
}

export async function loadModelConfig(modelDir: string): Promise<ModelConfig> {
  const raw = (await Bun.file(`${modelDir}/config.json`).json()) as Record<string, any>;
  // Gemma 4 unified nests the LM config; plain text models keep it at top level.
  const t = (raw.text_config ?? raw) as Record<string, any>;

  const text: TextConfig = {
    hiddenSize: t.hidden_size,
    numHiddenLayers: t.num_hidden_layers,
    numAttentionHeads: t.num_attention_heads,
    numKeyValueHeads: t.num_key_value_heads,
    headDim: t.head_dim,
    numGlobalKeyValueHeads: t.num_global_key_value_heads ?? t.num_key_value_heads,
    globalHeadDim: t.global_head_dim ?? t.head_dim,
    attentionKEqV: t.attention_k_eq_v ?? false,
    intermediateSize: t.intermediate_size,
    hiddenActivation: t.hidden_activation ?? "gelu_pytorch_tanh",
    rmsNormEps: t.rms_norm_eps,
    vocabSize: t.vocab_size,
    maxPositionEmbeddings: t.max_position_embeddings,
    slidingWindow: t.sliding_window ?? 0,
    layerTypes: t.layer_types ?? [],
    ropeParameters: parseRope(t.rope_parameters),
    finalLogitSoftcapping: t.final_logit_softcapping ?? null,
    tieWordEmbeddings: t.tie_word_embeddings ?? raw.tie_word_embeddings ?? false,
    bosTokenId: t.bos_token_id ?? raw.bos_token_id,
    eosTokenId: t.eos_token_id ?? raw.eos_token_id,
  };

  let kvQuant: KvQuantSpec[] | null = null;
  if (await Bun.file(`${modelDir}/kv_config.json`).exists()) {
    const kv = (await Bun.file(`${modelDir}/kv_config.json`).json()) as any[];
    kvQuant = kv.map((e) => ({
      layerIdx: e.layer_idx,
      bits: e.bits,
      groupSize: e.group_size,
    }));
  }

  const eos = raw.eos_token_id ?? text.eosTokenId;
  return {
    modelDir,
    modelType: raw.model_type,
    architectures: raw.architectures ?? [],
    dtype: raw.dtype ?? "bfloat16",
    text,
    quantization: parseQuantization(raw.quantization ?? raw.quantization_config),
    kvQuant,
    hasVisionSidecar: await Bun.file(`${modelDir}/optiq_vision.safetensors`).exists(),
    eosTokenIds: Array.isArray(eos) ? eos : [eos],
    raw,
  };
}
