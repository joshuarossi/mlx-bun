// Drafter quantization over a tiny synthetic DeepSpec checkpoint (random
// tensors, no weights download): every matmul weight and both gather tables
// quantize, the confidence head stays bf16, the output loads through the
// drafter loader, and refusals name their cause.
import { afterAll, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, cpuStream } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { Weights } from "@mlx-bun/inference";
import { drafterQuantizePredicate, quantizeDrafterDir, quantizeModelDir, writeShardedSafetensors, type NamedTensor } from "../src/index";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-drafter-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const HIDDEN = 64, VOCAB = 64, RANK = 64, TAPS = 2, INTER = 128, HEADS = 2, HEAD_DIM = 32;
const CONFIG = {
  architectures: ["Gemma4DSparkModel"], hidden_size: HIDDEN, num_hidden_layers: 1, num_attention_heads: HEADS, global_head_dim: HEAD_DIM,
  num_global_key_value_heads: 1, attention_k_eq_v: true, intermediate_size: INTER, hidden_activation: "gelu_pytorch_tanh", rms_norm_eps: 1e-6,
  vocab_size: VOCAB, block_size: 3, mask_token_id: 0, target_layer_ids: [1, 2], num_target_layers: 4, markov_rank: RANK, markov_head_type: "vanilla",
  enable_confidence_head: true, confidence_head_with_markov: true, rope_theta: 10000, partial_rotary_factor: 1,
};

function tensor(name: string, shape: number[], seed: number): NamedTensor {
  let state = seed >>> 0;
  const values = Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) }, () => { state = (Math.imul(state, 1664525) + 1013904223) >>> 0; return (state / 2 ** 32 - 0.5) * 0.2; });
  const f32 = MlxArray.fromFloat32(values, shape);
  const array = f32.astype(Dtype.bfloat16, cpuStream);
  f32.dispose();
  return { name, array };
}

/** Every tensor DeepspecDrafter.load reads, at tiny sizes. */
function checkpoint(name: string, config: Record<string, unknown> = CONFIG): string {
  const p = "layers.0";
  const shapes: [string, number[]][] = [
    ["embed_tokens.weight", [VOCAB, HIDDEN]], ["fc.weight", [HIDDEN, TAPS * HIDDEN]], ["hidden_norm.weight", [HIDDEN]], ["norm.weight", [HIDDEN]],
    ["lm_head.weight", [VOCAB, HIDDEN]],
    [`${p}.self_attn.q_proj.weight`, [HEADS * HEAD_DIM, HIDDEN]], [`${p}.self_attn.k_proj.weight`, [HEAD_DIM, HIDDEN]],
    [`${p}.self_attn.o_proj.weight`, [HIDDEN, HEADS * HEAD_DIM]], [`${p}.self_attn.q_norm.weight`, [HEAD_DIM]], [`${p}.self_attn.k_norm.weight`, [HEAD_DIM]],
    [`${p}.input_layernorm.weight`, [HIDDEN]], [`${p}.post_attention_layernorm.weight`, [HIDDEN]],
    [`${p}.pre_feedforward_layernorm.weight`, [HIDDEN]], [`${p}.post_feedforward_layernorm.weight`, [HIDDEN]],
    [`${p}.mlp.gate_proj.weight`, [INTER, HIDDEN]], [`${p}.mlp.up_proj.weight`, [INTER, HIDDEN]], [`${p}.mlp.down_proj.weight`, [HIDDEN, INTER]],
    [`${p}.layer_scalar`, [1]],
    ["markov_head.markov_w1.weight", [VOCAB, RANK]], ["markov_head.markov_w2.weight", [VOCAB, RANK]],
    ["confidence_head.proj.weight", [1, HIDDEN + RANK]], ["confidence_head.proj.bias", [1]],
  ];
  const tensors = shapes.map(([tensorName, shape], i) => tensor(tensorName, shape, i + 1));
  const dir = join(root, name);
  mkdirSync(dir);
  writeShardedSafetensors(dir, tensors);
  for (const { array } of tensors) array.dispose();
  writeFileSync(join(dir, "config.json"), JSON.stringify(config));
  return dir;
}
async function names(dir: string) {
  const weights = await Weights.open(dir);
  const out = { all: weights.tensorNames.toSorted(), dtype: (n: string) => weights.tensor(n).dtypeName };
  return { ...out, close: () => weights.dispose() };
}
const configOf = (dir: string) => JSON.parse(readFileSync(join(dir, "config.json"), "utf8"));

describe("drafterQuantizePredicate", () => {
  test("keeps only the confidence head full precision", () => {
    expect(drafterQuantizePredicate("confidence_head.proj")).toBe(false);
    for (const base of ["layers.0.self_attn.q_proj", "fc", "lm_head", "markov_head.markov_w2", "embed_tokens", "markov_head.markov_w1"])
      expect(drafterQuantizePredicate(base)).toBe(true);
  });
});

test("quantizes every matmul weight and gather table, keeps the confidence head bf16, and the result loads", async () => {
  const src = checkpoint("src"), out = join(root, "out");
  const stages: string[] = [];
  const result = await quantizeDrafterDir(src, out, { bits: 4, groupSize: 64, onProgress: stage => stages.push(stage) });
  const after = await names(out);
  try {
    for (const base of ["embed_tokens", "fc", "lm_head", "layers.0.self_attn.q_proj", "layers.0.self_attn.k_proj", "layers.0.self_attn.o_proj",
      "layers.0.mlp.gate_proj", "layers.0.mlp.up_proj", "layers.0.mlp.down_proj", "markov_head.markov_w1", "markov_head.markov_w2"])
      expect(after.all).toContain(`${base}.scales`);
    // The confidence head is shape-eligible (128 % 64 == 0) yet stays a plain bf16 weight.
    expect(after.all).not.toContain("confidence_head.proj.scales");
    expect(after.dtype("confidence_head.proj.weight")).toBe("bfloat16");
    expect(after.dtype("layers.0.input_layernorm.weight")).toBe("bfloat16");
  } finally { after.close(); }
  const config = configOf(out);
  expect(config.quantization.bits).toBe(4);
  expect(config.quantization.group_size).toBe(64);
  expect(config.quantization["confidence_head.proj"]).toBe(false); // mlx's "left unquantized"
  expect(config.architectures).toEqual(["Gemma4DSparkModel"]);
  expect(result.nQuantized).toBe(11);
  expect(stages.length).toBeGreaterThan(0);
});

test("without the drafter policy the same checkpoint would quantize the confidence head", async () => {
  const src = checkpoint("plain-src"), out = join(root, "plain-out");
  await quantizeModelDir(src, out, { bits: 4, groupSize: 64 });
  const after = await names(out);
  try { expect(after.all).toContain("confidence_head.proj.scales"); } finally { after.close(); }
});

describe("refusals", () => {
  test("a source that is already quantized", async () => {
    const quantized = join(root, "already");
    const src = checkpoint("for-already");
    await quantizeDrafterDir(src, quantized, { bits: 4, groupSize: 64, skipLoadSmoke: true });
    await expect(quantizeDrafterDir(quantized, join(root, "again"), { bits: 4, groupSize: 64 })).rejects.toThrow("already quantized");
  });

  test("a checkpoint that is not a DeepSpec drafter names the verb for ordinary models", async () => {
    const src = checkpoint("wrong-arch", { ...CONFIG, architectures: ["Qwen3ForCausalLM"] });
    await expect(quantizeDrafterDir(src, join(root, "wrong-out"), { bits: 4, groupSize: 64 })).rejects.toThrow("mlx-bun convert -q");
  });
});
