// Model config + quantization metadata reader for the load path.
// Parses HF config.json (Gemma 4 unified layout: text_config nested),
// the OptiQ per-layer quantization map, and kv_config.json when present.

export interface RopeParams {
  ropeTheta: number;
  ropeType: string;
  partialRotaryFactor: number;
  /** ProportionalRoPE frequency multiplier (rope_utils: factor, default 1). */
  factor: number;
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
  /** e2b/e4b: per-layer input embedding width (0 = disabled). */
  hiddenSizePerLayerInput: number;
  vocabSizePerLayerInput: number;
  /** Trailing layers that share KV with earlier same-type layers. */
  numKvSharedLayers: number;
  /** 26B-A4B MoE block: dense MLP + routed experts per layer. */
  enableMoeBlock: boolean;
  numExperts: number;
  topKExperts: number;
  moeIntermediateSize: number;
  /** Qwen3-MoE sparse-block gating (qwen3_moe): a layer is MoE unless it is
   *  in `mlpOnlyLayers` and `(idx+1) % decoderSparseStep == 0` selects it.
   *  `normTopkProb` renormalizes the top-k gate weights. Defaults are inert
   *  for non-qwen3_moe families. */
  decoderSparseStep: number;
  mlpOnlyLayers: number[];
  normTopkProb: boolean;
  /** Qwen3.5 hybrid (gated-DeltaNet) geometry; 0/false for other families. */
  linearNumValueHeads: number;
  linearNumKeyHeads: number;
  linearKeyHeadDim: number;
  linearValueHeadDim: number;
  linearConvKernelDim: number;
  /** Every `fullAttentionInterval`-th layer is full-attention (Qwen3.5). */
  fullAttentionInterval: number;
  /** Qwen3.5 full-attention output gate: q_proj emits 2× and gates the output. */
  attnOutputGate: boolean;
  /** Rotary fraction of head_dim (Qwen3.5 full attention: 0.25 → 64 of 256). */
  partialRotaryFactor: number;
  ropeParameters: Record<string, RopeParams>;
  finalLogitSoftcapping: number | null;
  tieWordEmbeddings: boolean;
  bosTokenId: number;
  eosTokenId: number | number[];
  /** DiffusionGemma: fixed denoising-canvas length (256). Undefined elsewhere. */
  canvasLength?: number;
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

/** TurboQuant scheme (docs/design/turboquant-kv.md): rotation-based KV
 *  quantization, a distinct axis from the uniform/per-layer affine kvQuant
 *  above (composes with it in principle; v1 ships as a standalone CLI-only
 *  runtime lever, same class as uniform kvBits — see
 *  src/generate.ts maybeQuantizeKv). Valid kBits: {2,4,5,8}; vBits:
 *  {2,3,4,5,8} (docs/design/turboquant-kv.md's supported Lloyd-Max tables). */
export interface TurboQuantScheme {
  kBits: number;
  vBits: number;
}

export const TURBOQUANT_VALID_KBITS = [2, 4, 5, 8] as const;
export const TURBOQUANT_VALID_VBITS = [2, 3, 4, 5, 8] as const;

/** Parse `turbo` / `turbo:k<bits>v<bits>` (default k8v3). Returns null for
 *  non-turbo strings (caller falls through to the uniform/config parser);
 *  throws Error with a user-facing message for a malformed turbo spec. */
export function parseTurboQuantScheme(raw: string): TurboQuantScheme | null {
  if (raw !== "turbo" && !raw.startsWith("turbo:")) return null;
  if (raw === "turbo") return { kBits: 8, vBits: 3 };
  const m = /^turbo:k(\d+)v(\d+)$/.exec(raw);
  if (!m) throw new Error(`--kv-quant turbo spec must look like "turbo:k<bits>v<bits>" (got "${raw}")`);
  const kBits = Number(m[1]);
  const vBits = Number(m[2]);
  if (!(TURBOQUANT_VALID_KBITS as readonly number[]).includes(kBits))
    throw new Error(`--kv-quant turbo: kBits must be one of ${TURBOQUANT_VALID_KBITS.join(",")} (got ${kBits})`);
  if (!(TURBOQUANT_VALID_VBITS as readonly number[]).includes(vBits))
    throw new Error(`--kv-quant turbo: vBits must be one of ${TURBOQUANT_VALID_VBITS.join(",")} (got ${vBits})`);
  return { kBits, vBits };
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
    // transformers ≥5.10 configs mix flat scalars into the per-attention-type
    // map (`rope_parameters: { full_attention: {...}, rope_theta: null,
    // rope_type: "default", ... }` — the DeepSpec drafter ships this shape);
    // only object entries are attention-type params.
    if (!p || typeof p !== "object") continue;
    out[kind] = {
      ropeTheta: p.rope_theta,
      ropeType: p.rope_type ?? "default",
      partialRotaryFactor: p.partial_rotary_factor ?? 1.0,
      factor: p.factor ?? 1.0,
    };
  }
  return out;
}

export function parseQuantization(raw: Record<string, any> | undefined): QuantizationConfig | null {
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

/** DiffusionGemma's config.json ships only token ids + canvas_length + the
 *  quant map — the architecture dims live in optiq's `config.py` TextConfig
 *  defaults (and layer_types / rope_parameters are computed in __post_init__).
 *  We reproduce those defaults in snake_case so the generic parser below picks
 *  them up; any field actually present in config.json still overrides. Source:
 *  optiq/vlm/_mlxvlm/models/diffusion_gemma/config.py. */
function diffusionGemmaRawDefaults(): Record<string, any> {
  const numLayers = 30;
  const pattern = ["sliding_attention", "sliding_attention", "sliding_attention",
    "sliding_attention", "sliding_attention", "full_attention"];
  const layer_types = Array.from({ length: numLayers }, (_, i) => pattern[i % pattern.length]);
  layer_types[numLayers - 1] = "full_attention"; // last forced full
  return {
    hidden_size: 2816,
    num_hidden_layers: numLayers,
    num_attention_heads: 16,
    num_key_value_heads: 8,
    num_global_key_value_heads: 2,
    head_dim: 256,
    global_head_dim: 512,
    intermediate_size: 2112,
    moe_intermediate_size: 704,
    hidden_activation: "gelu_pytorch_tanh",
    rms_norm_eps: 1e-6,
    vocab_size: 262144,
    max_position_embeddings: 262144,
    sliding_window: 1024,
    layer_types,
    enable_moe_block: true,
    num_experts: 128,
    top_k_experts: 8,
    final_logit_softcapping: 30.0,
    tie_word_embeddings: true,
    bos_token_id: 2,
    eos_token_id: 1,
    rope_parameters: {
      sliding_attention: { rope_type: "default", rope_theta: 10000.0 },
      full_attention: { rope_type: "proportional", partial_rotary_factor: 0.25, rope_theta: 1000000.0 },
    },
  };
}

export async function loadModelConfig(modelDir: string): Promise<ModelConfig> {
  const raw = (await Bun.file(`${modelDir}/config.json`).json()) as Record<string, any>;
  const modelType = raw.model_type;
  const isDiffusion = modelType === "diffusion_gemma";
  // Gemma 4 unified nests the LM config; plain text models keep it at top level.
  // DiffusionGemma keeps it flat too, but omits all dims — backfill from defaults.
  const baseT = (raw.text_config ?? raw) as Record<string, any>;
  const t = isDiffusion ? { ...diffusionGemmaRawDefaults(), ...baseT } : baseT;
  const isLlama = modelType === "llama";
  const isQwen35 = typeof modelType === "string" && modelType.startsWith("qwen3_5");
  // Plain Qwen3 (Qwen3ForCausalLM, e.g. Qwen3-Embedding): a flat HF config with
  // a scalar rope_theta and no rope_parameters map — handled like llama below.
  const isQwen3 = modelType === "qwen3";
  // Qwen3.5 rope_parameters is a flat dict ({type, rope_theta, mrope_section,
  // partial_rotary_factor}), not the gemma per-attention-type map — and
  // type "default" means plain partial nn.RoPE (mrope_section ignored for text).
  const qwenRope = (t.rope_parameters ?? {}) as Record<string, any>;

  const text: TextConfig = {
    hiddenSize: t.hidden_size,
    numHiddenLayers: t.num_hidden_layers,
    numAttentionHeads: t.num_attention_heads,
    numKeyValueHeads: t.num_key_value_heads,
    headDim: t.head_dim ?? Math.floor(t.hidden_size / t.num_attention_heads),
    numGlobalKeyValueHeads: t.num_global_key_value_heads ?? t.num_key_value_heads,
    globalHeadDim: t.global_head_dim ?? t.head_dim ?? Math.floor(t.hidden_size / t.num_attention_heads),
    attentionKEqV: t.attention_k_eq_v ?? false,
    intermediateSize: t.intermediate_size,
    hiddenActivation: t.hidden_activation ?? t.hidden_act ?? "gelu_pytorch_tanh",
    rmsNormEps: t.rms_norm_eps,
    vocabSize: t.vocab_size,
    maxPositionEmbeddings: t.max_position_embeddings,
    slidingWindow: t.sliding_window ?? 0,
    layerTypes: t.layer_types ?? (isLlama ? Array(t.num_hidden_layers).fill("full_attention") : []),
    hiddenSizePerLayerInput: t.hidden_size_per_layer_input ?? 0,
    vocabSizePerLayerInput: t.vocab_size_per_layer_input ?? t.vocab_size,
    numKvSharedLayers: t.num_kv_shared_layers ?? 0,
    enableMoeBlock: t.enable_moe_block ?? false,
    numExperts: t.num_experts ?? 0,
    // gemma4 uses `top_k_experts`; qwen3_moe uses `num_experts_per_tok`.
    topKExperts: t.top_k_experts ?? t.num_experts_per_tok ?? 0,
    moeIntermediateSize: t.moe_intermediate_size ?? 0,
    decoderSparseStep: t.decoder_sparse_step ?? 1,
    mlpOnlyLayers: t.mlp_only_layers ?? [],
    normTopkProb: t.norm_topk_prob ?? false,
    linearNumValueHeads: t.linear_num_value_heads ?? 0,
    linearNumKeyHeads: t.linear_num_key_heads ?? 0,
    linearKeyHeadDim: t.linear_key_head_dim ?? 0,
    linearValueHeadDim: t.linear_value_head_dim ?? 0,
    linearConvKernelDim: t.linear_conv_kernel_dim ?? 0,
    fullAttentionInterval: t.full_attention_interval ?? 0,
    attnOutputGate: t.attn_output_gate ?? false,
    partialRotaryFactor:
      qwenRope.partial_rotary_factor ?? t.partial_rotary_factor ?? 1.0,
    ropeParameters: isQwen35
      ? {
          full_attention: {
            ropeTheta: qwenRope.rope_theta ?? t.rope_theta ?? 10000,
            ropeType: "default",
            partialRotaryFactor: qwenRope.partial_rotary_factor ?? 1.0,
            factor: 1.0,
          },
        }
      : t.rope_parameters
        ? parseRope(t.rope_parameters)
        : isLlama || isQwen3
          ? {
              full_attention: {
                ropeTheta: t.rope_theta ?? 10000,
                ropeType: "default",
                partialRotaryFactor: 1.0,
                factor: 1.0,
              },
            }
          : {},
    finalLogitSoftcapping: t.final_logit_softcapping ?? null,
    tieWordEmbeddings: t.tie_word_embeddings ?? raw.tie_word_embeddings ?? false,
    bosTokenId: t.bos_token_id ?? raw.bos_token_id,
    eosTokenId: t.eos_token_id ?? raw.eos_token_id,
    canvasLength: raw.canvas_length ?? t.canvas_length,
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
    modelType,
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
