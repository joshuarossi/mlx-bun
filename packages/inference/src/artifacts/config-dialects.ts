// How a `config.json` differs from the plain Hugging Face layout, by `model_type`.
// A dialect is a reading rule for the artifact, not a statement about a model
// family (`models/families.ts` owns those): `loadModelConfig` applies exactly one
// and branches on its fields, never on a model type.

/** How `rope_parameters` is spelled. `map`: a per-attention-type map, absent means none.
 *  `theta`: as `map`, and a flat `rope_theta` stands in for a missing map.
 *  `flat`: one flat dict (`rope_theta`, `partial_rotary_factor`) for full attention. */
export type RopeLayout = "map" | "theta" | "flat";

export interface ConfigDialect {
  /** Text-config fields the config omits: the architecture's own defaults. Fields present still win. */
  readonly textDefaults?: () => Record<string, any>;
  /** Geometry and stop tokens come from a converted container's own parser. */
  readonly container?: "colibri";
  readonly rope: RopeLayout;
  /** `layer_types` when the config declares none: every layer full attention. */
  readonly fullAttentionByDefault?: true;
  /** Refuse a value this loader has not verified rather than mis-read it. */
  readonly validate?: (text: Record<string, any>) => void;
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

/** Qwen3.8 adds output_gate_type ("swish"), which every implementation
 *  (transformers ground truth, mlx-lm pinned + main) currently ignores —
 *  the attention output gate is hardcoded o_proj(out·σ(gate)). Only accept
 *  values verified to mean that; an unknown value must fail at load, not
 *  silently mis-gate a future checkpoint where the field starts mattering. */
function verifyOutputGate(text: Record<string, any>): void {
  if (text.output_gate_type != null && text.output_gate_type !== "swish")
    throw new Error(
      `qwen3_5: unverified output_gate_type "${text.output_gate_type}" (only "swish" ` +
        `is verified to mean the standard sigmoid output gate)`,
    );
}

const PLAIN: ConfigDialect = Object.freeze({ rope: "map" });
const FLAT_THETA: ConfigDialect = Object.freeze({ rope: "theta" });

/** The reading rule for a config's `model_type`. Anything not listed reads as the plain layout. */
export function dialectFor(modelType: unknown): ConfigDialect {
  if (modelType === "diffusion_gemma") return { rope: "map", textDefaults: diffusionGemmaRawDefaults };
  if (modelType === "glm_moe_dsa") return { rope: "map", container: "colibri" };
  // Qwen3.5 rope_parameters is a flat dict ({type, rope_theta, mrope_section,
  // partial_rotary_factor}), not the gemma per-attention-type map — and
  // type "default" means plain partial nn.RoPE (mrope_section ignored for text).
  if (typeof modelType === "string" && modelType.startsWith("qwen3_5")) return { rope: "flat", validate: verifyOutputGate };
  // Llama-style flat configs: a scalar rope_theta and no rope_parameters map.
  if (modelType === "llama") return { rope: "theta", fullAttentionByDefault: true };
  // Plain Qwen3 (Qwen3ForCausalLM, e.g. Qwen3-Embedding): handled like llama for rope.
  if (modelType === "qwen3") return FLAT_THETA;
  return PLAIN;
}
