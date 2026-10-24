// MOSS-Image quantization over a tiny synthetic snapshot (random bf16 tensors in
// the real layout, no download): the DiT's block projections and the
// conditioner's projections and embedding quantize, everything else is kept or
// copied, the output loads through the family's graphs and agrees with the
// full-precision graphs, the reported paths are the published ones, and
// refusals (not a pipeline, already quantized, an unsupported layout in a
// single unsharded file) fail before writing anything.
import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, cpuStream } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { Weights, loadModelConfig, type ModelConfig } from "@mlx-bun/inference/artifacts";
import { MossImageConditioner, MossImageTransformer, parseMossTransformerConfig } from "@mlx-bun/inference/models/moss-image";
import { quantizeMossImageDir, writeShardedSafetensors, type NamedTensor } from "../src/index";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-moss-quantize-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const json = (path: string, value: unknown) => { mkdirSync(join(path, ".."), { recursive: true }); writeFileSync(path, JSON.stringify(value)); };

let seed = 7;
function tensor(name: string, shape: number[], dtype = Dtype.bfloat16, scale = 0.2): NamedTensor {
  const values = Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) }, () => {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return (seed / 2 ** 32 - 0.5) * scale;
  });
  const wide = MlxArray.fromFloat32(values, shape);
  const array = dtype === Dtype.float32 ? wide : wide.astype(dtype, cpuStream);
  if (array !== wide) wide.dispose();
  return { name, array };
}
const ones = (name: string, width: number) => tensor(name, [width], Dtype.bfloat16, 0.1);

const DIT = { dim: 64, ffn_dim: 32, num_heads: 2, num_layers: 2, text_dim: 64, freq_dim: 32, latent_channels: 32, rope_base: 10000 };
// The linear-attention value heads are the real conditioner's 128 wide: the gated norm's summation order is verified for that width.
const TEXT = { model_type: "qwen3_5_text", hidden_size: 64, num_hidden_layers: 2, layer_types: ["linear_attention", "full_attention"],
  num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, rms_norm_eps: 1e-6, vocab_size: 64, intermediate_size: 64,
  full_attention_interval: 2, linear_num_key_heads: 2, linear_key_head_dim: 32, linear_num_value_heads: 4, linear_value_head_dim: 128,
  linear_conv_kernel_dim: 4, rope_parameters: { rope_theta: 1e7, partial_rotary_factor: 0.25, rope_type: "default" }, tie_word_embeddings: false };

function transformerTensors(): NamedTensor[] {
  const out: NamedTensor[] = [tensor("video_embedder.weight", [64, 32]), tensor("video_embedder.bias", [64]),
    tensor("text_embedder.proj.weight", [64, 64]), tensor("text_embedder.proj.bias", [64]), tensor("rope.bands", [4], Dtype.float32),
    tensor("time_embedding.0.weight", [64, 32]), tensor("time_embedding.0.bias", [64]), tensor("time_embedding.2.weight", [64, 64]),
    tensor("time_embedding.2.bias", [64]), tensor("shared_block_modulation.weight", [384, 64]), tensor("shared_block_modulation.bias", [384]),
    ones("final_norm_video.weight", 64), tensor("final_linear_video.weight", [32, 64]), tensor("video_head_modulation.weight", [128, 64]),
    tensor("video_head_modulation.bias", [128])];
  for (const i of [0, 1]) {
    const p = `text_embedder.blocks.${i}`;
    out.push(ones(`${p}.norm1.weight`, 64), ones(`${p}.norm2.weight`, 64), ones(`${p}.q_norm.weight`, 32), ones(`${p}.k_norm.weight`, 32),
      tensor(`${p}.qkv.weight`, [192, 64]), tensor(`${p}.qkv.bias`, [192]), tensor(`${p}.proj.weight`, [64, 64]), tensor(`${p}.proj.bias`, [64]),
      tensor(`${p}.ffn_gate.weight`, [32, 64]), tensor(`${p}.ffn_gate.bias`, [32]), tensor(`${p}.ffn_up.weight`, [32, 64]),
      tensor(`${p}.ffn_up.bias`, [32]), tensor(`${p}.ffn_down.weight`, [64, 32]), tensor(`${p}.ffn_down.bias`, [64]));
    const l = `layers.${i}`;
    out.push(ones(`${l}.norm1.weight`, 64), ones(`${l}.norm2.weight`, 64), ones(`${l}.q_norm.weight`, 32), ones(`${l}.k_norm.weight`, 32),
      ...["q", "k", "v", "o"].map(name => tensor(`${l}.proj.${name}.weight`, [64, 64])), tensor(`${l}.proj.ffn_up_gate.weight`, [64, 64]),
      tensor(`${l}.proj.ffn_down.weight`, [64, 32]));
  }
  return out;
}

function textEncoderTensors(): NamedTensor[] {
  const out: NamedTensor[] = [tensor("language_model.embed_tokens.weight", [64, 64]), ones("language_model.norm.weight", 64), tensor("visual.patch.weight", [8, 8])];
  const mlp = (p: string) => [tensor(`${p}.mlp.gate_proj.weight`, [64, 64]), tensor(`${p}.mlp.up_proj.weight`, [64, 64]), tensor(`${p}.mlp.down_proj.weight`, [64, 64])];
  const delta = "language_model.layers.0", attention = "language_model.layers.1";
  out.push(ones(`${delta}.input_layernorm.weight`, 64), ones(`${delta}.post_attention_layernorm.weight`, 64), ...mlp(delta),
    tensor(`${delta}.linear_attn.in_proj_qkv.weight`, [640, 64]), tensor(`${delta}.linear_attn.in_proj_z.weight`, [512, 64]),
    tensor(`${delta}.linear_attn.in_proj_b.weight`, [4, 64]), tensor(`${delta}.linear_attn.in_proj_a.weight`, [4, 64]),
    tensor(`${delta}.linear_attn.conv1d.weight`, [640, 1, 4]), tensor(`${delta}.linear_attn.A_log`, [4], Dtype.float32),
    tensor(`${delta}.linear_attn.dt_bias`, [4]), ones(`${delta}.linear_attn.norm.weight`, 128), tensor(`${delta}.linear_attn.out_proj.weight`, [64, 512]));
  out.push(ones(`${attention}.input_layernorm.weight`, 64), ones(`${attention}.post_attention_layernorm.weight`, 64), ...mlp(attention),
    tensor(`${attention}.self_attn.q_proj.weight`, [128, 64]), tensor(`${attention}.self_attn.k_proj.weight`, [32, 64]),
    tensor(`${attention}.self_attn.v_proj.weight`, [32, 64]), tensor(`${attention}.self_attn.o_proj.weight`, [64, 64]),
    ones(`${attention}.self_attn.q_norm.weight`, 32), ones(`${attention}.self_attn.k_norm.weight`, 32));
  return out;
}

/** Write a component's tensors under diffusers' or transformers' file name. */
function writeComponent(dir: string, tensors: NamedTensor[], diffusers: boolean): void {
  mkdirSync(dir, { recursive: true });
  try { writeShardedSafetensors(dir, tensors); } finally { for (const t of tensors) t.array.dispose(); }
  if (diffusers) renameSync(join(dir, "model.safetensors"), join(dir, "diffusion_pytorch_model.safetensors"));
}

function snapshot(name: string): string {
  const dir = join(root, name);
  json(join(dir, "model_index.json"), { _class_name: "MOSSImagePipeline", transformer: ["pipeline_moss_image", "MOSSImageTransformer"],
    text_encoder: ["transformers", "Qwen3_5Model"], tokenizer: ["transformers", "Qwen2Tokenizer"], vae: ["diffusers", "AutoencoderKLFlux2"],
    scheduler: ["pipeline_moss_image", "MOSSImageScheduler"] });
  json(join(dir, "transformer/config.json"), DIT);
  writeComponent(join(dir, "transformer"), transformerTensors(), true);
  json(join(dir, "text_encoder/config.json"), { model_type: "qwen3_5", text_config: TEXT });
  writeComponent(join(dir, "text_encoder"), textEncoderTensors(), false);
  json(join(dir, "vae/config.json"), { latent_channels: 8 });
  writeFileSync(join(dir, "vae/diffusion_pytorch_model.safetensors"), "vae bytes");
  json(join(dir, "tokenizer/tokenizer_config.json"), {});
  json(join(dir, "scheduler/scheduler_config.json"), { shift: 5 });
  return dir;
}

const relative = (a: Float32Array, b: Float32Array) => {
  let diff = 0, norm = 0;
  for (let i = 0; i < a.length; i++) { diff += (a[i]! - b[i]!) ** 2; norm += b[i]! ** 2; }
  return Math.sqrt(diff / norm);
};
const read = (x: MlxArray) => { using wide = x.astype(Dtype.float32); using rowMajor = ops.contiguous(wide); return rowMajor.toFloat32(); };
const stubTokenizer = { encode: () => [1, 5, 9, 2] } as unknown as ConstructorParameters<typeof MossImageConditioner>[2];
const stubTemplate = { render: () => "prompt" } as unknown as ConstructorParameters<typeof MossImageConditioner>[3];

async function velocity(dir: string): Promise<Float32Array> {
  const dit = await MossImageTransformer.open(join(dir, "transformer"), parseMossTransformerConfig(DIT));
  try {
    using latents = MlxArray.fromFloat32(Float32Array.from({ length: 32 * 4 }, (_, i) => Math.sin(i)), [1, 32, 2, 2]);
    using wide = MlxArray.fromFloat32(Float32Array.from({ length: 3 * 64 }, (_, i) => Math.cos(i) * 0.5), [1, 3, 64]);
    using context = wide.astype(Dtype.bfloat16);
    using out = dit.velocity(latents, 500, context);
    return read(out);
  } finally { dit.dispose(); }
}

async function hidden(dir: string): Promise<Float32Array> {
  const weights = await Weights.open(join(dir, "text_encoder"));
  const config: ModelConfig = await loadModelConfig(join(dir, "text_encoder"));
  const conditioner = new MossImageConditioner(weights, config, stubTokenizer, stubTemplate);
  try { using out = conditioner.encode("prompt"); return read(out); } finally { conditioner.dispose(); }
}

test("the producer quantizes the projections, keeps the rest, publishes at the destination and loads through the family's graphs", async () => {
  const source = snapshot("source"), output = join(root, "q8");
  const result = await quantizeMossImageDir(source, output, { bits: 8, groupSize: 32 });
  expect(result.outDir).toBe(output);
  expect(result.transformer.outDir).toBe(join(output, "transformer"));
  expect(result.textEncoder.outDir).toBe(join(output, "text_encoder"));
  for (const path of [result.outDir, result.transformer.outDir, result.textEncoder.outDir]) expect(existsSync(path)).toBe(true);
  expect(result.transformer.nQuantized).toBe(2 * 6);
  expect(readFileSync(join(output, "vae/diffusion_pytorch_model.safetensors"), "utf8")).toBe("vae bytes");
  for (const file of ["model_index.json", "tokenizer/tokenizer_config.json", "scheduler/scheduler_config.json", "vae/config.json"])
    expect(existsSync(join(output, file))).toBe(true);

  const transformer = (await loadModelConfig(join(output, "transformer"))).quantization!;
  expect(transformer.default).toMatchObject({ bits: 8, groupSize: 32, mode: "affine" });
  for (const kept of ["video_embedder", "time_embedding.0", "shared_block_modulation", "final_linear_video", "text_embedder.blocks.0.qkv"])
    expect(transformer.perLayer.get(kept)?.mode, kept).toBe("none");
  const text = (await loadModelConfig(join(output, "text_encoder"))).quantization!;
  for (const kept of ["language_model.layers.0.linear_attn.in_proj_a", "language_model.layers.0.linear_attn.in_proj_b"])
    expect(text.perLayer.get(kept)?.mode, kept).toBe("none");
  const q8 = await Weights.open(join(output, "text_encoder"));
  try {
    expect(q8.has("language_model.embed_tokens.scales")).toBe(true);
    expect(q8.has("language_model.layers.1.self_attn.q_proj.scales")).toBe(true);
    expect(q8.has("language_model.layers.0.linear_attn.in_proj_a.scales")).toBe(false);
    expect(q8.has("visual.patch.weight")).toBe(true);
  } finally { q8.dispose(); }

  // The quantized graphs agree with the full-precision ones within 8-bit affine error.
  expect(relative(await velocity(output), await velocity(source))).toBeLessThan(5e-2);
  expect(relative(await hidden(output), await hidden(source))).toBeLessThan(5e-2);
}, 120_000);

test("refusals name their cause and write nothing", async () => {
  const notPipeline = join(root, "not-pipeline");
  json(join(notPipeline, "config.json"), { model_type: "qwen3", hidden_size: 64 });
  await expect(quantizeMossImageDir(notPipeline, join(root, "out-1"), { bits: 8, groupSize: 32 })).rejects.toThrow("not a text-to-image pipeline");

  const quantized = snapshot("already");
  json(join(quantized, "transformer/config.json"), { ...DIT, quantization: { bits: 8, group_size: 32 } });
  await expect(quantizeMossImageDir(quantized, join(root, "out-2"), { bits: 8, groupSize: 32 })).rejects.toThrow("already quantized");

  // A single unsharded file without the expected tensors is refused, not converted.
  const foreign = snapshot("foreign");
  rmSync(join(foreign, "transformer/diffusion_pytorch_model.safetensors"));
  writeComponent(join(foreign, "transformer"), [tensor("blocks.0.attn.weight", [64, 64])], true);
  await expect(quantizeMossImageDir(foreign, join(root, "out-3"), { bits: 8, groupSize: 32 })).rejects.toThrow("has no layers.0.proj.q.weight");
  for (const out of ["out-1", "out-2", "out-3"]) expect(existsSync(join(root, out))).toBe(false);
});
