import { afterEach, describe, expect, test } from "bun:test";
import {
  mkdirSync,
  mkdtempSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/config";
import {
  isGlm52Config,
  isSupportedModelConfig,
  isSupportedModelRecord,
  supportTier,
} from "../../src/model/support";

const dirs: string[] = [];

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true });
});

function modelDir(
  config: Record<string, unknown>,
  generation?: Record<string, unknown>,
): string {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-support-"));
  dirs.push(dir);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "config.json"), `${JSON.stringify(config)}\n`);
  if (generation)
    writeFileSync(
      join(dir, "generation_config.json"),
      `${JSON.stringify(generation)}\n`,
    );
  return dir;
}

function glm52Raw(): Record<string, unknown> {
  const layers = 78;
  return {
    model_type: "glm_moe_dsa",
    architectures: ["GlmMoeDsaForCausalLM"],
    dtype: "bfloat16",
    hidden_size: 6144,
    num_hidden_layers: layers,
    num_attention_heads: 64,
    num_key_value_heads: 64,
    q_lora_rank: 2048,
    kv_lora_rank: 512,
    qk_nope_head_dim: 192,
    qk_rope_head_dim: 64,
    qk_head_dim: 256,
    v_head_dim: 256,
    first_k_dense_replace: 3,
    intermediate_size: 12288,
    moe_intermediate_size: 2048,
    n_routed_experts: 256,
    num_experts_per_tok: 8,
    n_shared_experts: 1,
    n_group: 1,
    topk_group: 1,
    norm_topk_prob: true,
    routed_scaling_factor: 2.5,
    hidden_act: "silu",
    rms_norm_eps: 1e-5,
    rope_parameters: { rope_theta: 8_000_000, rope_type: "default" },
    rope_interleave: true,
    vocab_size: 154880,
    max_position_embeddings: 1_048_576,
    index_topk: 2048,
    index_n_heads: 32,
    index_head_dim: 128,
    indexer_rope_interleave: true,
    indexer_types: Array.from(
      { length: layers },
      (_, layer) => (layer < 3 || (layer - 2) % 4 === 0 ? "full" : "shared"),
    ),
    num_nextn_predict_layers: 1,
    index_share_for_mtp_iteration: true,
    tie_word_embeddings: false,
    bos_token_id: null,
    pad_token_id: 154820,
    eos_token_id: [154820, 154827],
    // This describes the source checkpoint, not Colibri's converted tensors.
    quantization_config: {
      quant_method: "fp8",
      fmt: "e4m3",
      weight_block_size: [128, 128],
    },
  };
}

describe("GLM-5.2 generic config and support registration", () => {
  test("maps the dedicated MLA/MoE geometry and unions every EOS id", async () => {
    const dir = modelDir(glm52Raw(), {
      eos_token_id: [154827, 154829],
      pad_token_id: 154820,
    });
    const config = await loadModelConfig(dir);
    const t = config.text;

    expect(config.modelType).toBe("glm_moe_dsa");
    expect(config.architectures).toEqual(["GlmMoeDsaForCausalLM"]);
    expect(config.dtype).toBe("bfloat16");
    expect(config.eosTokenIds).toEqual([154820, 154827, 154829]);
    expect(t.eosTokenId).toEqual([154820, 154827, 154829]);

    expect(t.hiddenSize).toBe(6144);
    expect(t.numHiddenLayers).toBe(78);
    expect(t.numAttentionHeads).toBe(64);
    expect(t.numKeyValueHeads).toBe(64);
    expect(t.headDim).toBe(256);
    expect(t.numGlobalKeyValueHeads).toBe(64);
    expect(t.globalHeadDim).toBe(256);
    expect(t.intermediateSize).toBe(12288);
    expect(t.hiddenActivation).toBe("silu");
    expect(t.rmsNormEps).toBe(1e-5);
    expect(t.vocabSize).toBe(154880);
    expect(t.maxPositionEmbeddings).toBe(1_048_576);
    expect(t.layerTypes).toHaveLength(78);
    expect(new Set(t.layerTypes)).toEqual(new Set(["full_attention"]));

    expect(t.enableMoeBlock).toBe(true);
    expect(t.numExperts).toBe(256);
    expect(t.topKExperts).toBe(8);
    expect(t.moeIntermediateSize).toBe(2048);
    expect(t.decoderSparseStep).toBe(1);
    expect(t.mlpOnlyLayers).toEqual([0, 1, 2]);
    expect(t.normTopkProb).toBe(true);

    expect(t.partialRotaryFactor).toBe(0.25);
    expect(t.ropeParameters).toEqual({
      full_attention: {
        ropeTheta: 8_000_000,
        ropeType: "default",
        partialRotaryFactor: 0.25,
        factor: 1,
      },
    });
    expect(t.tieWordEmbeddings).toBe(false);
    expect(config.quantization).toBeNull();
  });

  test("registers glm_moe_dsa as dedicated targeted support", async () => {
    const config = await loadModelConfig(modelDir(glm52Raw()));
    expect(isGlm52Config(config)).toBe(true);
    expect(supportTier("glm_moe_dsa")).toBe("targeted");
    expect(isSupportedModelRecord("glm_moe_dsa")).toBe(true);
    expect(isSupportedModelConfig(config)).toBe(true);
    expect(supportTier("glm4")).toBe("generic");
  });

  test("preserves config-only EOS and ordinary parsing for other families", async () => {
    const dir = modelDir({
      model_type: "qwen3",
      architectures: ["Qwen3ForCausalLM"],
      dtype: "bfloat16",
      hidden_size: 1024,
      num_hidden_layers: 4,
      num_attention_heads: 8,
      num_key_value_heads: 2,
      head_dim: 128,
      intermediate_size: 3072,
      hidden_act: "silu",
      rms_norm_eps: 1e-6,
      vocab_size: 32000,
      max_position_embeddings: 4096,
      rope_theta: 1_000_000,
      tie_word_embeddings: true,
      bos_token_id: 1,
      eos_token_id: 5,
      quantization: { bits: 4, group_size: 64, mode: "affine" },
    }, {
      // Only GLM-5.2 unions generation_config; this must remain ignored here.
      eos_token_id: [5, 6],
    });
    const config = await loadModelConfig(dir);

    expect(config.modelType).toBe("qwen3");
    expect(config.eosTokenIds).toEqual([5]);
    expect(config.text.headDim).toBe(128);
    expect(config.text.ropeParameters.full_attention?.ropeTheta).toBe(1_000_000);
    expect(config.text.enableMoeBlock).toBe(false);
    expect(config.quantization?.default).toEqual({
      bits: 4,
      groupSize: 64,
      mode: "affine",
    });
  });
});
