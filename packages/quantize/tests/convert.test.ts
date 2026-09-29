// Native (CPU-stream) checks of the non-quantizing conversion and the quantizer's --dtype:
// real MLX arrays through real safetensors files, no model weights.
import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, cpuStream } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { Weights } from "@mlx-bun/inference";
import { buildQuantizationBlock, convertModelDir, quantizeModelDir, writeShardedSafetensors, type NamedTensor } from "../src/index";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-convert-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const CONFIG = { model_type: "qwen3", architectures: ["Qwen3ForCausalLM"], hidden_size: 64, intermediate_size: 128, num_hidden_layers: 1,
  num_attention_heads: 2, num_key_value_heads: 2, head_dim: 32, vocab_size: 64, rms_norm_eps: 1e-6, tie_word_embeddings: false };

/** Deterministic pseudo-random values in [-1, 1). */
function values(count: number, seed: number): Float32Array {
  const out = new Float32Array(count);
  let state = seed >>> 0;
  for (let i = 0; i < count; i++) { state = (Math.imul(state, 1664525) + 1013904223) >>> 0; out[i] = state / 2 ** 31 - 1; }
  return out;
}
function tensor(name: string, shape: number[], dtype: Dtype, seed: number): NamedTensor {
  const f32 = MlxArray.fromFloat32(values(shape.reduce((a, b) => a * b, 1), seed), shape);
  const array = dtype === Dtype.float32 ? f32 : f32.astype(dtype, cpuStream);
  if (array !== f32) f32.dispose();
  return { name, array };
}
function model(name: string, tensors: NamedTensor[], config: Record<string, unknown> = CONFIG): string {
  const dir = join(root, name);
  mkdirSync(dir);
  writeShardedSafetensors(dir, tensors);
  for (const { array } of tensors) array.dispose();
  writeFileSync(join(dir, "config.json"), JSON.stringify(config));
  writeFileSync(join(dir, "tokenizer.json"), "{}");
  return dir;
}
async function read(dir: string) {
  const weights = await Weights.open(dir);
  return { names: weights.tensorNames.toSorted(), dtype: (name: string) => weights.tensor(name).dtypeName,
    floats: (name: string) => weights.tensor(name).astype(Dtype.float32, cpuStream).toFloat32(), shape: (name: string) => weights.tensor(name).shape,
    close: () => weights.dispose() };
}
const configOf = (dir: string) => JSON.parse(readFileSync(join(dir, "config.json"), "utf8")) as Record<string, unknown>;

const dense = () => [
  tensor("model.embed_tokens.weight", [64, 64], Dtype.bfloat16, 1),
  tensor("model.layers.0.mlp.down_proj.weight", [64, 128], Dtype.bfloat16, 2),
  tensor("model.layers.0.input_layernorm.weight", [64], Dtype.float32, 3),
  tensor("model.layers.0.mlp.gate.e_score_correction_bias", [64], Dtype.float32, 4),
  tensor("lm_head.weight", [64, 64], Dtype.bfloat16, 5),
];

test("convert without options copies every tensor and the config unchanged, with aux files", async () => {
  const src = model("copy-src", dense()), out = join(root, "copy-out");
  const result = await convertModelDir(src, out);
  expect(result.nDequantized).toBe(0);
  const before = await read(src), after = await read(out);
  expect(after.names).toEqual(before.names);
  for (const name of before.names) {
    expect(after.dtype(name)).toBe(before.dtype(name));
    expect(Buffer.compare(Buffer.from(after.floats(name).buffer), Buffer.from(before.floats(name).buffer))).toBe(0);
  }
  before.close(); after.close();
  expect(configOf(out)).toEqual(CONFIG);
  expect(existsSync(join(out, "tokenizer.json"))).toBe(true);
  await expect(convertModelDir(src, out)).rejects.toThrow("output directory already exists");
});

test("--dtype casts floating tensors and leaves router bias and integer tensors alone", async () => {
  const src = model("cast-src", [...dense(), { name: "model.ids", array: MlxArray.fromInt32(Int32Array.from([1, 2, 3, 4]), [4]) }]);
  for (const [dtype, expected] of [["float16", "float16"], ["float32", "float32"], ["bfloat16", "bfloat16"]] as const) {
    const out = join(root, `cast-${dtype}`);
    await convertModelDir(src, out, { dtype });
    const after = await read(out);
    for (const name of ["model.embed_tokens.weight", "model.layers.0.mlp.down_proj.weight", "model.layers.0.input_layernorm.weight", "lm_head.weight"])
      expect(after.dtype(name)).toBe(expected);
    expect(after.dtype("model.layers.0.mlp.gate.e_score_correction_bias")).toBe("float32");
    expect(after.dtype("model.ids")).toBe("int32");
    after.close();
  }
  // The cast values are the source values in the new dtype (bf16 -> fp16 is exact for these magnitudes).
  const before = await read(src), cast = await read(join(root, "cast-float16"));
  expect(cast.floats("model.embed_tokens.weight")).toEqual(before.floats("model.embed_tokens.weight"));
  before.close(); cast.close();
});

test("--dequantize writes dense weights equal to the dequantized tensors and drops the quantization block", async () => {
  const weight = tensor("w", [64, 128], Dtype.bfloat16, 9).array;
  const q = ops.quantize(weight, 64, 4, "affine", cpuStream);
  const expected = ops.dequantize(q.packed, q.scales, q.biases, { bits: 4, groupSize: 64, mode: "affine" }, cpuStream);
  const expectedValues = expected.astype(Dtype.float32, cpuStream).toFloat32().slice();
  const block = buildQuantizationBlock({ bits: 4, groupSize: 64, mode: "affine" }, new Map([["lm_head", false as const]]));
  const src = model("dense-src", [
    { name: "model.layers.0.mlp.down_proj.weight", array: q.packed }, { name: "model.layers.0.mlp.down_proj.scales", array: q.scales },
    { name: "model.layers.0.mlp.down_proj.biases", array: q.biases },
    tensor("lm_head.weight", [64, 64], Dtype.bfloat16, 6), tensor("model.layers.0.input_layernorm.weight", [64], Dtype.bfloat16, 7),
  ], { ...CONFIG, quantization: block, quantization_config: block });
  weight.dispose(); expected.dispose();

  const out = join(root, "dense-out");
  const result = await convertModelDir(src, out, { dequantize: true });
  expect(result.nDequantized).toBe(1);
  const after = await read(out);
  expect(after.names).toEqual(["lm_head.weight", "model.layers.0.input_layernorm.weight", "model.layers.0.mlp.down_proj.weight"]);
  expect(after.shape("model.layers.0.mlp.down_proj.weight")).toEqual([64, 128]);
  expect(after.dtype("model.layers.0.mlp.down_proj.weight")).toBe("bfloat16");
  expect(after.floats("model.layers.0.mlp.down_proj.weight")).toEqual(expectedValues);
  after.close();
  const config = configOf(out);
  expect(config).not.toHaveProperty("quantization"); expect(config).not.toHaveProperty("quantization_config");
  expect(config.model_type).toBe("qwen3");

  // Without -d a quantized source keeps its layout; --dtype casts its scales and biases too.
  const kept = join(root, "dense-kept");
  await convertModelDir(src, kept, { dtype: "float16" });
  const keptTensors = await read(kept);
  expect(keptTensors.names).toContain("model.layers.0.mlp.down_proj.scales");
  expect(keptTensors.dtype("model.layers.0.mlp.down_proj.scales")).toBe("float16");
  expect(keptTensors.dtype("model.layers.0.mlp.down_proj.weight")).toBe("uint32");
  keptTensors.close();
  expect(configOf(kept).quantization).toEqual(block);
});

test("quantizeModelDir --dtype sets the scales/biases and passthrough dtype; without it scales stay bf16 and the rest is untouched", async () => {
  const src = model("quant-src", dense());
  const plain = join(root, "quant-plain"), half = join(root, "quant-half");
  await quantizeModelDir(src, plain, { bits: 4, groupSize: 64 });
  await quantizeModelDir(src, half, { bits: 4, groupSize: 64, dtype: "float16" });
  const a = await read(plain), b = await read(half);
  expect(a.dtype("model.layers.0.mlp.down_proj.scales")).toBe("bfloat16");
  expect(a.dtype("model.layers.0.input_layernorm.weight")).toBe("float32");
  expect(b.dtype("model.layers.0.mlp.down_proj.scales")).toBe("float16");
  expect(b.dtype("model.layers.0.mlp.down_proj.biases")).toBe("float16");
  expect(b.dtype("model.layers.0.input_layernorm.weight")).toBe("float16");
  expect(b.dtype("model.layers.0.mlp.gate.e_score_correction_bias")).toBe("float32");
  expect(b.dtype("model.layers.0.mlp.down_proj.weight")).toBe("uint32");
  a.close(); b.close();
});
