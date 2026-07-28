import { afterEach, describe, expect, test } from "bun:test";
import {
  mkdtempSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  loadGlm52Config,
  parseGlm52Config,
  type Glm52Config,
} from "../src/model/glm52-config";
import { ColibriGlm52Container } from "../src/model/glm52-container";

type Dtype = "U8" | "I8" | "F32";

interface TensorSpec {
  name: string;
  dtype: Dtype;
  shape: number[];
}

const DTYPE_BYTES: Record<Dtype, number> = { U8: 1, I8: 1, F32: 4 };
const dirs: string[] = [];

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true });
});

function tempDir(): string {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-container-"));
  dirs.push(dir);
  return dir;
}

function tensorBytes(tensor: TensorSpec): number {
  return tensor.shape.reduce((product, dimension) => product * dimension, 1) *
    DTYPE_BYTES[tensor.dtype];
}

function writeSafetensors(dir: string, filename: string, tensors: TensorSpec[]): string {
  const header: Record<string, {
    dtype: Dtype;
    shape: number[];
    data_offsets: [number, number];
  }> = {};
  let offset = 0;
  for (const tensor of tensors) {
    const end = offset + tensorBytes(tensor);
    header[tensor.name] = {
      dtype: tensor.dtype,
      shape: tensor.shape,
      data_offsets: [offset, end],
    };
    offset = end;
  }
  return writeRawSafetensors(dir, filename, header, offset);
}

function writeRawSafetensors(
  dir: string,
  filename: string,
  header: Record<string, unknown>,
  dataBytes: number,
): string {
  const headerBytes = new TextEncoder().encode(JSON.stringify(header));
  const bytes = new Uint8Array(8 + headerBytes.byteLength + dataBytes);
  new DataView(bytes.buffer).setBigUint64(0, BigInt(headerBytes.byteLength), true);
  bytes.set(headerBytes, 8);
  const path = join(dir, filename);
  writeFileSync(path, bytes);
  return path;
}

function tinyRaw(overrides: Record<string, unknown> = {}): Record<string, any> {
  return {
    architectures: ["GlmMoeDsaForCausalLM"],
    model_type: "glm_moe_dsa",
    vocab_size: 256,
    hidden_size: 128,
    intermediate_size: 64,
    moe_intermediate_size: 32,
    num_hidden_layers: 5,
    first_k_dense_replace: 3,
    num_attention_heads: 4,
    num_key_value_heads: 4,
    n_routed_experts: 8,
    num_experts_per_tok: 2,
    n_shared_experts: 1,
    q_lora_rank: 64,
    kv_lora_rank: 32,
    qk_nope_head_dim: 24,
    qk_rope_head_dim: 8,
    qk_head_dim: 32,
    v_head_dim: 32,
    index_topk: 4096,
    index_head_dim: 16,
    index_n_heads: 2,
    index_topk_freq: 4,
    index_skip_topk_offset: 3,
    n_group: 1,
    topk_group: 1,
    norm_topk_prob: true,
    routed_scaling_factor: 2.5,
    rope_parameters: { rope_type: "default", rope_theta: 10_000 },
    rope_interleave: true,
    indexer_rope_interleave: true,
    tie_word_embeddings: false,
    rms_norm_eps: 1e-5,
    max_position_embeddings: 4096,
    num_nextn_predict_layers: 1,
    index_share_for_mtp_iteration: true,
    eos_token_id: [2, 3],
    ...overrides,
  };
}

function parseTiny(
  overrides: Record<string, unknown> = {},
  generation: Record<string, unknown> | null = { eos_token_id: [3, 4] },
): Glm52Config {
  return parseGlm52Config("/tiny/glm52", tinyRaw(overrides), generation);
}

const MTP_SENTINELS = [
  "eh_proj.weight",
  "enorm.weight",
  "hnorm.weight",
  "shared_head.norm.weight",
  "input_layernorm.weight",
  "post_attention_layernorm.weight",
  "self_attn.q_a_proj.weight",
  "self_attn.kv_a_proj_with_mqa.weight",
  "mlp.gate.weight",
  "mlp.gate.e_score_correction_bias",
];

describe("GLM-5.2 config", () => {
  test("parses the exact tiny geometry, EOS union, and pinned fallback indexer schedule", () => {
    const config = parseTiny();
    expect(config).toMatchObject({
      modelDir: "/tiny/glm52",
      modelType: "glm_moe_dsa",
      architectures: ["GlmMoeDsaForCausalLM"],
      hiddenSize: 128,
      numHiddenLayers: 5,
      numAttentionHeads: 4,
      numKeyValueHeads: 4,
      qLoraRank: 64,
      kvLoraRank: 32,
      qkNopeHeadDim: 24,
      qkRopeHeadDim: 8,
      qkHeadDim: 32,
      vHeadDim: 32,
      firstKDenseReplace: 3,
      intermediateSize: 64,
      moeIntermediateSize: 32,
      numRoutedExperts: 8,
      numExpertsPerToken: 2,
      numSharedExperts: 1,
      normTopkProb: true,
      routedScalingFactor: 2.5,
      rmsNormEps: 1e-5,
      ropeTheta: 10_000,
      ropeInterleave: true,
      vocabSize: 256,
      maxPositionEmbeddings: 4096,
      indexTopk: 4096,
      indexNumHeads: 2,
      indexHeadDim: 16,
      indexerRopeInterleave: true,
      numNextnPredictLayers: 1,
      indexShareForMtpIteration: true,
      eosTokenIds: [2, 3, 4],
      padTokenId: 2,
    });
    expect(config.indexerTypes).toEqual(["full", "full", "full", "shared", "shared"]);
  });

  test("loads config and generation metadata and preserves an explicit schedule", async () => {
    const dir = tempDir();
    writeFileSync(join(dir, "config.json"), JSON.stringify(tinyRaw({
      indexer_types: ["full", "shared", "full", "shared", "full"],
      pad_token_id: 9,
    })));
    writeFileSync(join(dir, "generation_config.json"), JSON.stringify({
      eos_token_id: [3, 5],
    }));
    const config = await loadGlm52Config(dir);
    expect(config.indexerTypes).toEqual(["full", "shared", "full", "shared", "full"]);
    expect(config.eosTokenIds).toEqual([2, 3, 5]);
    expect(config.padTokenId).toBe(9);
  });

  test("rejects malformed or unsupported geometry instead of guessing", () => {
    const rejected: Array<[Record<string, unknown>, RegExp]> = [
      [{ model_type: "glm4" }, /model_type/],
      [{ qk_head_dim: 31 }, /qk_head_dim/],
      [{ n_group: 2 }, /n_group=1/],
      [{ num_experts_per_tok: 9 }, /num_experts_per_tok/],
      [{ index_n_heads: 0 }, /incomplete DSA geometry/],
      [{ indexer_types: ["full"] }, /must have 5 entries/],
      [{ indexer_types: ["full", "shared", "invalid", "shared", "full"] }, /indexer_types\[2\]/],
      [{ rms_norm_eps: Number.NaN }, /must be finite/],
    ];
    for (const [override, pattern] of rejected) {
      expect(() => parseTiny(override)).toThrow(pattern);
    }
    expect(() => parseTiny({ eos_token_id: null }, null)).toThrow(/no EOS/);
  });
});

describe("Colibri GLM-5.2 header-only container", () => {
  test("scans out-* shards and infers per-row/grouped int4 plus MTP int8 metadata", () => {
    const dir = tempDir();
    const perRow = "model.layers.3.mlp.experts.0.down_proj.weight";
    const grouped = "model.layers.3.mlp.experts.0.gate_proj.weight";
    writeSafetensors(dir, "out-00000.safetensors", [
      { name: perRow, dtype: "U8", shape: [64] },
      { name: grouped, dtype: "U8", shape: [256] },
      { name: `${perRow}.qs`, dtype: "F32", shape: [4] },
      { name: `${grouped}.qs`, dtype: "F32", shape: [8] },
    ]);
    const mtp = "model.layers.5.mlp.experts.0.down_proj.weight";
    writeSafetensors(dir, "out-mtp-00000.safetensors", [
      { name: mtp, dtype: "U8", shape: [128] },
      { name: `${mtp}.qs`, dtype: "F32", shape: [4] },
      { name: "ignored.i8", dtype: "I8", shape: [1] },
    ]);
    writeSafetensors(dir, "unrelated.safetensors", [
      { name: "must.not.be.scanned", dtype: "F32", shape: [1] },
    ]);

    const container = ColibriGlm52Container.open(dir);
    expect(container.files.map((file) => file.family)).toEqual(["main", "mtp"]);
    expect(container.has("must.not.be.scanned")).toBe(false);

    const perRowInfo = container.quantized(perRow, 4, 32);
    expect(perRowInfo).toMatchObject({
      bits: 4,
      groupSize: null,
      outputRows: 4,
      inputColumns: 32,
      coalescedNextWeight: grouped,
    });
    expect(perRowInfo.weight.family).toBe("main");
    expect(perRowInfo.scales.dtype).toBe("F32");

    const groupedInfo = container.quantized(grouped, 4, 128);
    expect(groupedInfo.bits).toBe(4);
    expect(groupedInfo.groupSize).toBe(64);
    expect(groupedInfo.coalescedNextWeight).toBeNull();

    const mtpInfo = container.quantized(mtp, 4, 32);
    expect(mtpInfo.bits).toBe(8);
    expect(mtpInfo.groupSize).toBeNull();
    expect(mtpInfo.weight.family).toBe("mtp");
  });

  test("reports DSA absent and a partial MTP family as disabled", () => {
    const dir = tempDir();
    writeSafetensors(dir, "out-00000.safetensors", [
      { name: "model.embed_tokens.weight", dtype: "U8", shape: [1] },
    ]);
    writeSafetensors(dir, "out-mtp-00000.safetensors", [
      { name: "model.layers.5.eh_proj.weight", dtype: "U8", shape: [1] },
      { name: "model.layers.5.enorm.weight", dtype: "F32", shape: [1] },
    ]);
    const capabilities = ColibriGlm52Container.open(dir).capabilities(parseTiny());
    expect(capabilities.hasMtp).toBe(false);
    expect(capabilities.missingMtpTensors).toContain("model.layers.5.hnorm.weight");
    expect(capabilities.hasDsa).toBe(false);
    expect(capabilities.missingDsaTensors).toContain(
      "model.layers.0.self_attn.indexer.wq_b.weight",
    );
    expect(capabilities.missingDsaTensors).toContain(
      "model.layers.2.self_attn.indexer.k_norm.bias",
    );
    expect(capabilities.missingDsaTensors.some((name) => name.includes("layers.3."))).toBe(false);
  });

  test("only advertises MTP after every architectural sentinel is present", () => {
    const dir = tempDir();
    writeSafetensors(dir, "out-00000.safetensors", [
      { name: "model.embed_tokens.weight", dtype: "U8", shape: [1] },
    ]);
    writeSafetensors(
      dir,
      "out-mtp-00000.safetensors",
      MTP_SENTINELS.map((suffix) => ({
        name: `model.layers.5.${suffix}`,
        dtype: suffix.includes("norm") || suffix.endsWith("bias") ? "F32" as const : "U8" as const,
        shape: [1],
      })),
    );
    const capabilities = ColibriGlm52Container.open(dir).capabilities(parseTiny());
    expect(capabilities.hasMtp).toBe(true);
    expect(capabilities.missingMtpTensors).toEqual([]);
  });

  test("rejects duplicate tensors, out-of-bounds data, and malformed shapes", () => {
    const duplicateDir = tempDir();
    const duplicate = { name: "duplicate.weight", dtype: "U8" as const, shape: [1] };
    writeSafetensors(duplicateDir, "out-00000.safetensors", [duplicate]);
    writeSafetensors(duplicateDir, "out-00001.safetensors", [duplicate]);
    expect(() => ColibriGlm52Container.open(duplicateDir)).toThrow(/duplicate Colibri tensor/);

    const boundsDir = tempDir();
    writeRawSafetensors(boundsDir, "out-00000.safetensors", {
      "past.end": { dtype: "F32", shape: [4], data_offsets: [0, 16] },
    }, 0);
    expect(() => ColibriGlm52Container.open(boundsDir)).toThrow(/extends past end/);

    const shapeDir = tempDir();
    writeRawSafetensors(shapeDir, "out-00000.safetensors", {
      bad: { dtype: "F32", shape: [2, 2], data_offsets: [0, 12] },
    }, 12);
    expect(() => ColibriGlm52Container.open(shapeDir)).toThrow(/byte range/);

    const hugeHeaderDir = tempDir();
    const hugeHeader = Buffer.alloc(8);
    hugeHeader.writeBigUInt64LE(100_000_001n);
    writeFileSync(join(hugeHeaderDir, "out-00000.safetensors"), hugeHeader);
    expect(() => ColibriGlm52Container.open(hugeHeaderDir)).toThrow(
      /exceeds 100000000 byte limit/,
    );
  });

  test("rejects quantized tensor dtype, byte geometry, and scale geometry mismatches", () => {
    const dir = tempDir();
    writeSafetensors(dir, "out-00000.safetensors", [
      { name: "wrong.dtype", dtype: "F32", shape: [4] },
      { name: "wrong.dtype.qs", dtype: "F32", shape: [1] },
      { name: "wrong.bytes", dtype: "U8", shape: [7] },
      { name: "wrong.bytes.qs", dtype: "F32", shape: [1] },
      { name: "int8.grouped", dtype: "U8", shape: [32] },
      { name: "int8.grouped.qs", dtype: "F32", shape: [4] },
      { name: "int4.bad-groups", dtype: "U8", shape: [64] },
      { name: "int4.bad-groups.qs", dtype: "F32", shape: [7] },
    ]);
    const container = ColibriGlm52Container.open(dir);
    expect(() => container.quantized("wrong.dtype", 1, 4)).toThrow(/must be U8/);
    expect(() => container.quantized("wrong.bytes", 1, 16)).toThrow(/do not encode logical/);
    expect(() => container.quantized("int8.grouped", 1, 32)).toThrow(
      /grouped scales are only valid for int4/,
    );
    expect(() => container.quantized("int4.bad-groups", 1, 128)).toThrow(
      /do not match per-row or a supported group size/,
    );
    expect(() => container.quantized("wrong.bytes", 0, 16)).toThrow(/invalid logical shape/);
  });
});
