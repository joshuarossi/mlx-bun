// Model-free unit tests for the universal descriptor table, remapping,
// weight audit, and the factory dispatch ladder's reject rung. No weights,
// no GPU work beyond nothing — pure config parsing.

import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../src/config";
import { createModel } from "../src/model/factory";
import {
  ARCHS,
  GENERIC_MODEL_TYPES,
  genericArgsFor,
  MODEL_REMAPPING,
  remapModelType,
} from "../src/model/universal/archs";
import { WeightAudit } from "../src/model/universal/modules";
import { isSupportedModelRecord, supportTier } from "../src/model/support";
import type { Weights } from "../src/weights";

/** Minimal ModelConfig wrapper: genericArgsFor reads modelType + raw only. */
function cfg(modelType: string, raw: Record<string, unknown>): ModelConfig {
  return {
    modelDir: "/nonexistent",
    modelType,
    architectures: [],
    dtype: "bfloat16",
    text: {} as ModelConfig["text"],
    quantization: null,
    kvQuant: null,
    hasVisionSidecar: false,
    eosTokenIds: [],
    raw: { model_type: modelType, ...raw },
  };
}

// Realistic minimal raw configs, one per launch arch.
const RAWS: Record<string, Record<string, unknown>> = {
  llama: {
    hidden_size: 2048, num_hidden_layers: 16, num_attention_heads: 32,
    num_key_value_heads: 8, head_dim: 64, intermediate_size: 8192,
    rms_norm_eps: 1e-5, vocab_size: 128256, rope_theta: 500000,
    max_position_embeddings: 131072, tie_word_embeddings: true,
    rope_scaling: { rope_type: "llama3", factor: 32.0, low_freq_factor: 1.0,
      high_freq_factor: 4.0, original_max_position_embeddings: 8192 },
  },
  smollm3: {
    hidden_size: 2048, num_hidden_layers: 36, num_attention_heads: 16,
    num_key_value_heads: 4, intermediate_size: 11008, rms_norm_eps: 1e-6,
    vocab_size: 128256, rope_theta: 5000000, no_rope_layer_interval: 4,
  },
  qwen2: {
    hidden_size: 896, num_hidden_layers: 24, num_attention_heads: 14,
    num_key_value_heads: 2, intermediate_size: 4864, rms_norm_eps: 1e-6,
    vocab_size: 151936, rope_theta: 1000000, tie_word_embeddings: true,
  },
  qwen3: {
    hidden_size: 1024, num_hidden_layers: 28, num_attention_heads: 16,
    num_key_value_heads: 8, head_dim: 128, intermediate_size: 3072,
    rms_norm_eps: 1e-6, vocab_size: 151936, rope_theta: 1000000,
    max_position_embeddings: 40960, tie_word_embeddings: true,
  },
  gemma: {
    hidden_size: 2048, num_hidden_layers: 18, num_attention_heads: 8,
    num_key_value_heads: 1, head_dim: 256, intermediate_size: 16384,
    rms_norm_eps: 1e-6, vocab_size: 256000, rope_theta: 10000,
  },
  gemma2: {
    hidden_size: 2304, num_hidden_layers: 26, num_attention_heads: 8,
    num_key_value_heads: 4, head_dim: 256, intermediate_size: 9216,
    rms_norm_eps: 1e-6, vocab_size: 256000, rope_theta: 10000,
    query_pre_attn_scalar: 256, attn_logit_softcapping: 50.0,
    final_logit_softcapping: 30.0,
  },
  phi3: {
    hidden_size: 3072, num_hidden_layers: 32, num_attention_heads: 32,
    num_key_value_heads: 32, intermediate_size: 8192, rms_norm_eps: 1e-5,
    vocab_size: 32064, rope_theta: 10000, max_position_embeddings: 131072,
    original_max_position_embeddings: 4096,
    rope_scaling: { type: "longrope", long_factor: [1.0, 1.1], short_factor: [1.0, 1.0] },
  },
  olmo2: {
    hidden_size: 2048, num_hidden_layers: 16, num_attention_heads: 16,
    num_key_value_heads: 16, intermediate_size: 8192, rms_norm_eps: 1e-6,
    vocab_size: 100352, rope_theta: 500000, tie_word_embeddings: true,
  },
  glm4: {
    hidden_size: 4096, num_hidden_layers: 40, num_attention_heads: 32,
    num_key_value_heads: 2, head_dim: 128, intermediate_size: 13696,
    rms_norm_eps: 1e-5, vocab_size: 151552, rope_theta: 10000,
    partial_rotary_factor: 0.5, attention_bias: true,
  },
  granite: {
    hidden_size: 2048, num_hidden_layers: 40, num_attention_heads: 32,
    num_key_value_heads: 8, intermediate_size: 8192, rms_norm_eps: 1e-5,
    vocab_size: 49155, rope_theta: 10000000, attention_multiplier: 0.015625,
    embedding_multiplier: 12.0, residual_multiplier: 0.22, logits_scaling: 8.0,
    attention_bias: false, mlp_bias: false, tie_word_embeddings: true,
    max_position_embeddings: 131072,
  },
  starcoder2: {
    hidden_size: 3072, num_hidden_layers: 30, num_attention_heads: 24,
    num_key_value_heads: 2, intermediate_size: 12288, norm_epsilon: 1e-5,
    vocab_size: 49152, rope_theta: 999999.44,
  },
};

describe("descriptor table completeness", () => {
  test("every launch arch has a descriptor and parses to complete args", () => {
    const launch = ["llama", "smollm3", "qwen2", "qwen3", "gemma", "gemma2",
      "phi3", "olmo2", "glm4", "granite", "starcoder2"];
    for (const arch of launch) {
      expect(GENERIC_MODEL_TYPES.has(arch)).toBe(true);
      const args = ARCHS[arch]!(RAWS[arch]!);
      // no NaN/undefined in the numeric spine
      for (const k of ["hiddenSize", "numHiddenLayers", "intermediateSize",
        "numHeads", "numKvHeads", "headDim", "normEps", "vocabSize",
        "ropeTheta", "attnScale", "partialRotaryFactor"] as const) {
        expect(typeof args[k]).toBe("number");
        expect(Number.isFinite(args[k])).toBe(true);
      }
    }
  });

  test("per-arch deltas encode the mlx-lm sources", () => {
    const a = (n: string) => ARCHS[n]!(RAWS[n]!);

    const llama = a("llama");
    expect(llama.headDim).toBe(64);
    expect(llama.ropeScaling?.rope_type).toBe("llama3");
    expect(llama.tieWordEmbeddings).toBe(true);

    const qwen2 = a("qwen2");
    expect(qwen2.qkvBias).toBe(true); // hardcoded bias=True on q/k/v
    expect(qwen2.oBias).toBe(false);
    expect(qwen2.headDim).toBe(64); // hidden // heads

    const qwen3 = a("qwen3");
    expect(qwen3.qkNorm).toBe("head");
    expect(qwen3.headDim).toBe(128);

    const gemma = a("gemma");
    expect(gemma.norm).toBe("rmsnorm_plus_one");
    expect(gemma.mlp).toBe("geglu"); // PRECISE gelu
    expect(gemma.embedMultiplier).toBe(Math.pow(2048, 0.5));
    expect(gemma.tieWordEmbeddings).toBe(true);

    const gemma2 = a("gemma2");
    expect(gemma2.block).toBe("gemma2");
    expect(gemma2.mlp).toBe("geglu_approx");
    expect(gemma2.attnScale).toBe(1.0 / Math.sqrt(256));
    expect(gemma2.attnLogitSoftcap).toBe(50.0);
    expect(gemma2.finalLogitSoftcap).toBe(30.0);
    expect(gemma2.maskArray).toBe(true);

    const phi3 = a("phi3");
    expect(phi3.fusedQkv).toBe(true);
    expect(phi3.mlp).toBe("fused_swiglu");
    expect(phi3.rope).toBe("phi3");
    expect(phi3.tieWordEmbeddings).toBe(false);
    expect(phi3.originalMaxPositionEmbeddings).toBe(4096);

    const olmo2 = a("olmo2");
    expect(olmo2.block).toBe("post");
    expect(olmo2.qkNorm).toBe("full");

    const glm4 = a("glm4");
    expect(glm4.block).toBe("glm4");
    expect(glm4.mlp).toBe("fused_swiglu");
    expect(glm4.ropeTraditional).toBe(true); // glm4 default
    expect(glm4.partialRotaryFactor).toBe(0.5);
    expect(glm4.tieWordEmbeddings).toBe(false); // lm_head unconditional
    expect(glm4.qkvBias).toBe(true);

    const granite = a("granite");
    expect(granite.attnScale).toBe(0.015625);
    expect(granite.embedMultiplier).toBe(12.0);
    expect(granite.residualMultiplier).toBe(0.22);
    expect(granite.logitsDivisor).toBe(8.0);

    const sc2 = a("starcoder2");
    expect(sc2.norm).toBe("layernorm");
    expect(sc2.mlp).toBe("gelu_mlp");
    expect(sc2.qkvBias).toBe(true);
    expect(sc2.oBias).toBe(true);
    expect(sc2.mlpBias).toBe(true);
    expect(sc2.normEps).toBe(1e-5);

    const smollm3 = a("smollm3");
    expect(smollm3.noRopeLayers).toHaveLength(36);
    // every 4th layer (1-indexed) is NoPE: indexes 3, 7, 11, …
    expect(smollm3.noRopeLayers![2]).toBe(1);
    expect(smollm3.noRopeLayers![3]).toBe(0);
    expect(smollm3.noRopeLayers![7]).toBe(0);
  });

  test("phi3 rope_scaling validation mirrors phi3.py __post_init__", () => {
    const bad = { ...RAWS.phi3!, rope_scaling: { type: "longrope" } }; // no long_factor
    expect(() => ARCHS.phi3!(bad)).toThrow(/long_factor/);
    const unknown = { ...RAWS.phi3!, rope_scaling: { type: "yarn", long_factor: [1] } };
    expect(ARCHS.phi3!(unknown).ropeScaling).toBeNull(); // warned-off in the oracle
  });
});

describe("MODEL_REMAPPING + support tiers", () => {
  test("mistral/iquestcoder remap to llama and are generically supported", () => {
    expect(remapModelType("mistral")).toBe("llama");
    expect(remapModelType("iquestcoder")).toBe("llama");
    expect(genericArgsFor(cfg("mistral", RAWS.llama!))).not.toBeNull();
    expect(supportTier("mistral")).toBe("generic");
    expect(isSupportedModelRecord("mistral")).toBe(true);
  });

  test("generic never shadows targeted", () => {
    expect(supportTier("gemma4")).toBe("targeted");
    expect(supportTier("qwen3")).toBe("targeted"); // dedicated Qwen3Model wins
    expect(supportTier("llama", "mlx-community/MiniCPM5-1B-OptiQ-4bit")).toBe("targeted");
    expect(supportTier("llama", "mlx-community/Llama-3.2-1B-Instruct-4bit")).toBe("generic");
    expect(supportTier("gemma4_assistant")).toBeNull(); // drafters stay excluded
  });

  test("remapped-but-undescribed types stay unsupported", () => {
    expect(remapModelType("kimi_k2")).toBe("deepseek_v3");
    expect(supportTier("kimi_k2")).toBeNull();
  });
});

describe("dispatch ladder reject rung", () => {
  test("unknown arch throws a helpful error naming the surface", () => {
    const config = cfg("mamba2", { hidden_size: 768 });
    expect(() => createModel(null as unknown as Weights, config))
      .toThrow(/unsupported model_type "mamba2".*generic \(Tier-0\)/s);
  });

  test("remapped-unknown arch names the remap target", () => {
    const config = cfg("kimi_k2", {});
    expect(() => createModel(null as unknown as Weights, config))
      .toThrow(/remaps it to "deepseek_v3"/);
  });
});

describe("weight audit", () => {
  const stubWeights = (names: string[]) => ({ tensorNames: names }) as unknown as Weights;

  test("unconsumed tensors are a load error naming them", () => {
    const audit = new WeightAudit();
    audit.use("model.embed_tokens.weight");
    expect(() =>
      audit.finish(stubWeights(["model.embed_tokens.weight", "model.layers.0.mlp.oops.weight"]), []),
    ).toThrow(/model\.layers\.0\.mlp\.oops\.weight/);
  });

  test("sanitize drop patterns allow mlx-lm-discarded tensors", () => {
    const audit = new WeightAudit();
    audit.use("model.embed_tokens.weight");
    audit.finish(
      stubWeights([
        "model.embed_tokens.weight",
        "model.layers.0.self_attn.rotary_emb.inv_freq",
        "lm_head.weight",
      ]),
      [/self_attn\.rotary_emb\.inv_freq/, /^lm_head\.weight$/],
    );
  });
});
