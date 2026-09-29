import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

describe.skipIf(process.env.MLX_BUN_TEST_NATIVE !== "1")("fuseAdapter dequantize", () => {
  let mlx: typeof import("@mlx-bun/mlx/array");
  let ffi: typeof import("@mlx-bun/mlx/ffi");
  let ops: typeof import("@mlx-bun/mlx/ops");
  let artifacts: typeof import("@mlx-bun/inference/artifacts");
  let fuseAdapter: typeof import("../../src/fuse").fuseAdapter;
  const root = mkdtempSync(join(tmpdir(), "mlx-training-fuse-"));
  afterAll(() => rmSync(root, { recursive: true, force: true }));
  beforeAll(async () => {
    mlx = await import("@mlx-bun/mlx/array"); ffi = await import("@mlx-bun/mlx/ffi"); ops = await import("@mlx-bun/mlx/ops");
    artifacts = await import("@mlx-bun/inference/artifacts"); ({ fuseAdapter } = await import("../../src/fuse"));
  });

  const values = (count: number, seed: number) => {
    const out = new Float32Array(count); let state = seed >>> 0;
    for (let i = 0; i < count; i++) { state = (Math.imul(state, 1664525) + 1013904223) >>> 0; out[i] = state / 2 ** 31 - 1; }
    return out;
  };
  const bf16 = (shape: number[], seed: number) => {
    const f32 = mlx.MlxArray.fromFloat32(values(shape.reduce((a, b) => a * b, 1), seed), shape);
    const array = f32.astype(ffi.Dtype.bfloat16, mlx.cpuStream); f32.dispose(); return array;
  };
  const spec = { bits: 4, groupSize: 64, mode: "affine" } as const;
  const dequantized = (q: { packed: import("@mlx-bun/mlx/array").MlxArray; scales: import("@mlx-bun/mlx/array").MlxArray; biases: import("@mlx-bun/mlx/array").MlxArray }) =>
    ops.dequantize(q.packed, q.scales, q.biases, spec, mlx.cpuStream);

  function base() {
    const dir = join(root, "base"); mkdirSync(dir);
    const tensors: import("@mlx-bun/inference/artifacts").NamedTensor[] = [];
    const modules: Record<string, ReturnType<typeof ops.quantize>> = {};
    for (const [index, name] of ["model.layers.0.self_attn.q_proj", "model.layers.0.mlp.down_proj"].entries()) {
      const weight = bf16([8, 64], 10 + index), q = ops.quantize(weight, 64, 4, "affine", mlx.cpuStream); weight.dispose();
      modules[name] = q;
      tensors.push({ name: `${name}.weight`, array: q.packed }, { name: `${name}.scales`, array: q.scales }, { name: `${name}.biases`, array: q.biases });
    }
    tensors.push({ name: "model.norm.weight", array: bf16([64], 20) });
    artifacts.writeShardedSafetensors(dir, tensors);
    const block = { group_size: 64, bits: 4, mode: "affine" };
    writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", architectures: ["Qwen3ForCausalLM"], hidden_size: 64, intermediate_size: 64,
      num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2, head_dim: 32, vocab_size: 8, quantization: block, quantization_config: block }));
    writeFileSync(join(dir, "tokenizer.json"), "{}");
    return { dir, modules };
  }
  function adapter(a: Float32Array, b: Float32Array) {
    const dir = join(root, "adapter"); mkdirSync(dir);
    const entries = { "model.layers.0.self_attn.q_proj.lora_a": { shape: [64, 2], data: a }, "model.layers.0.self_attn.q_proj.lora_b": { shape: [2, 8], data: b } };
    let offset = 0; const header: Record<string, unknown> = {}, chunks: Buffer[] = [];
    for (const [name, { shape, data }] of Object.entries(entries)) {
      const bytes = Buffer.from(data.buffer); header[name] = { dtype: "F32", shape, data_offsets: [offset, offset + bytes.length] };
      chunks.push(bytes); offset += bytes.length;
    }
    const json = JSON.stringify(header), padded = Buffer.from(json.padEnd(Math.ceil(json.length / 8) * 8)), length = Buffer.alloc(8);
    length.writeBigUInt64LE(BigInt(padded.length));
    writeFileSync(join(dir, "adapters.safetensors"), Buffer.concat([length, padded, ...chunks]));
    writeFileSync(join(dir, "adapter_config.json"), JSON.stringify({ lora_parameters: { rank: 2, scale: 2 } }));
    return dir;
  }

  test("--dequantize writes dense weights for fused and untouched modules and drops the quantization block", async () => {
    const { dir, modules } = base(), a = values(128, 31), b = values(16, 32), adapterDir = adapter(a, b);
    const kept = join(root, "kept"), dense = join(root, "dense");
    const stats = await fuseAdapter(dir, adapterDir, kept);
    expect(stats.fusedModules).toBe(1);
    const denseStats = await fuseAdapter(dir, adapterDir, dense, undefined, { dequantize: true });
    expect(denseStats.fusedModules).toBe(1);

    const keptWeights = await artifacts.Weights.open(kept), denseWeights = await artifacts.Weights.open(dense);
    expect(keptWeights.tensorNames).toContain("model.layers.0.self_attn.q_proj.scales");
    expect(denseWeights.tensorNames.toSorted()).toEqual(["model.layers.0.mlp.down_proj.weight", "model.layers.0.self_attn.q_proj.weight", "model.norm.weight"]);
    const floats = (weights: typeof denseWeights, name: string) => weights.tensor(name).astype(ffi.Dtype.float32, mlx.cpuStream).toFloat32();

    // An untouched quantized module is exactly its dequantized weight.
    const untouched = dequantized(modules["model.layers.0.mlp.down_proj"]!);
    expect(floats(denseWeights, "model.layers.0.mlp.down_proj.weight")).toEqual(untouched.astype(ffi.Dtype.float32, mlx.cpuStream).toFloat32());
    // The fused module is W + (scale * B)^T A^T in bf16, computed here from the adapter's own numbers.
    const w = dequantized(modules["model.layers.0.self_attn.q_proj"]!);
    const delta = new Float32Array(8 * 64);
    for (let o = 0; o < 8; o++) for (let i = 0; i < 64; i++) delta[o * 64 + i] = 2 * (b[o]! * a[i * 2]! + b[8 + o]! * a[i * 2 + 1]!);
    const wf = w.astype(ffi.Dtype.float32, mlx.cpuStream).toFloat32();
    const fused = floats(denseWeights, "model.layers.0.self_attn.q_proj.weight");
    for (let i = 0; i < fused.length; i++) expect(Math.abs(fused[i]! - (wf[i]! + delta[i]!))).toBeLessThan(0.05);
    expect(denseWeights.tensor("model.layers.0.self_attn.q_proj.weight").dtypeName).toBe("bfloat16");
    keptWeights.dispose(); denseWeights.dispose();

    const config = JSON.parse(readFileSync(join(dense, "config.json"), "utf8"));
    expect(config).not.toHaveProperty("quantization"); expect(config).not.toHaveProperty("quantization_config");
    expect(JSON.parse(readFileSync(join(kept, "config.json"), "utf8")).quantization).toEqual({ group_size: 64, bits: 4, mode: "affine" });
  });
});
