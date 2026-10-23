// The diffusers pipeline layout through the artifact readers and the family
// registry: model_index.json parsing and its malformed forms, component
// lookup, config loading that leaves config.json snapshots unchanged, the
// MOSS-Image family's role, the openers' refusals, diffusers shard names, and
// a pipeline opened from a synthetic snapshot (configs and headers only; no
// stage loads).
import { afterAll, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/artifacts/config";
import { parsePipelineIndex, pipelineComponentDir, readPipelineIndex } from "../../src/artifacts/pipeline-index";
import { ShardedSafetensors } from "../../src/artifacts/safetensors";
import { UnsupportedModelLoadError, openImagePipeline, openModel } from "../../src/models/factory";
import { familyOf } from "../../src/models/families";
import { isImageModelType, isTranscriptionModelType, supportTier } from "../../src/models/support";

const root = mkdtempSync(join(tmpdir(), "mlx-moss-artifacts-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const write = (path: string, content: string | Uint8Array) => {
  mkdirSync(join(path, ".."), { recursive: true });
  writeFileSync(path, content);
};
const json = (path: string, value: unknown) => write(path, JSON.stringify(value));

/** A safetensors file of float32 tensors given as `name -> shape` (zero-filled). */
function safetensors(path: string, tensors: Record<string, number[]>): void {
  let offset = 0;
  const header: Record<string, unknown> = {};
  for (const [name, shape] of Object.entries(tensors)) {
    const bytes = shape.reduce((a, b) => a * b, 1) * 4;
    header[name] = { dtype: "F32", shape, data_offsets: [offset, offset + bytes] };
    offset += bytes;
  }
  const headerBytes = new TextEncoder().encode(JSON.stringify(header));
  const out = new Uint8Array(8 + headerBytes.length + offset);
  new DataView(out.buffer).setBigUint64(0, BigInt(headerBytes.length), true);
  out.set(headerBytes, 8);
  write(path, out);
}

const INDEX = {
  _class_name: "MOSSImagePipeline", _diffusers_version: "0.38.0",
  scheduler: ["pipeline_moss_image", "MOSSImageScheduler"], text_encoder: ["transformers", "Qwen3_5Model"],
  tokenizer: ["transformers", "Qwen2Tokenizer"], transformer: ["pipeline_moss_image", "MOSSImageTransformer"],
  vae: ["diffusers", "AutoencoderKLFlux2"],
};

test("model_index.json parses into its class and components; metadata and absent optional components are skipped", () => {
  const index = parsePipelineIndex({ ...INDEX, safety_checker: [null, null] });
  expect(index.className).toBe("MOSSImagePipeline");
  expect([...index.components.keys()].sort()).toEqual(["scheduler", "text_encoder", "tokenizer", "transformer", "vae"]);
  expect(index.components.get("vae")).toEqual({ library: "diffusers", className: "AutoencoderKLFlux2" });
});

test("malformed indexes are refused with the reason", () => {
  expect(() => parsePipelineIndex([])).toThrow("must be a JSON object");
  expect(() => parsePipelineIndex({ vae: ["diffusers", "AutoencoderKLFlux2"] })).toThrow("no _class_name");
  expect(() => parsePipelineIndex({ _class_name: "X", vae: "diffusers" })).toThrow("component vae must be [library, class]");
  expect(() => parsePipelineIndex({ _class_name: "X", vae: ["diffusers", 3] })).toThrow("component vae must name a library and a class");
});

test("a component lookup names the missing component or config", async () => {
  const dir = join(root, "components");
  json(join(dir, "model_index.json"), INDEX);
  json(join(dir, "transformer/config.json"), {});
  const index = await readPipelineIndex(dir);
  expect(await pipelineComponentDir(dir, index, "transformer")).toBe(join(dir, "transformer"));
  await expect(pipelineComponentDir(dir, index, "vae")).rejects.toThrow("component vae has no config.json");
  await expect(pipelineComponentDir(dir, index, "controlnet")).rejects.toThrow("declares no controlnet component");
});

test("a pipeline snapshot's class is its model type; a config.json snapshot loads as before", async () => {
  const pipeline = join(root, "pipeline");
  json(join(pipeline, "model_index.json"), INDEX);
  const config = await loadModelConfig(pipeline);
  expect(config.modelType).toBe("MOSSImagePipeline");
  expect(familyOf(config)?.graph).toBe("moss-image");
  const both = join(root, "both");
  json(join(both, "model_index.json"), INDEX);
  json(join(both, "config.json"), { model_type: "qwen3", hidden_size: 64, num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1 });
  expect((await loadModelConfig(both)).modelType).toBe("qwen3");
  await expect(loadModelConfig(join(root, "nothing"))).rejects.toThrow();
});

test("the family declares the image role and nothing else", () => {
  expect(isImageModelType("MOSSImagePipeline")).toBe(true);
  expect(isTranscriptionModelType("MOSSImagePipeline")).toBe(false);
  expect(supportTier("MOSSImagePipeline")).toBe("targeted");
  expect(isImageModelType("qwen3_5")).toBe(false);
});

test("the token-model opener refuses an image pipeline and the image opener refuses a token model", async () => {
  const pipeline = join(root, "refusal-pipeline");
  json(join(pipeline, "model_index.json"), INDEX);
  await expect(openModel(pipeline)).rejects.toBeInstanceOf(UnsupportedModelLoadError);
  await expect(openModel(pipeline)).rejects.toThrow("openImagePipeline");
  const speech = join(root, "refusal-speech");
  json(join(speech, "config.json"), { model_type: "whisper", n_audio_ctx: 1500 });
  await expect(openImagePipeline(speech)).rejects.toThrow("is not a text-to-image model");
});

test("diffusers shard names are found, sharded and single", async () => {
  const single = join(root, "single");
  safetensors(join(single, "diffusion_pytorch_model.safetensors"), { "a.weight": [2, 2] });
  expect((await ShardedSafetensors.open(single)).tensorNames).toEqual(["a.weight"]);
  const sharded = join(root, "sharded");
  safetensors(join(sharded, "diffusion_pytorch_model-00001-of-00002.safetensors"), { "a.weight": [2, 2] });
  safetensors(join(sharded, "diffusion_pytorch_model-00002-of-00002.safetensors"), { "b.weight": [3] });
  json(join(sharded, "diffusion_pytorch_model.safetensors.index.json"), { weight_map: {
    "a.weight": "diffusion_pytorch_model-00001-of-00002.safetensors", "b.weight": "diffusion_pytorch_model-00002-of-00002.safetensors" } });
  expect((await ShardedSafetensors.open(sharded)).tensorNames).toEqual(["a.weight", "b.weight"]);
});

/** Configs of a small but complete MOSS-Image snapshot, with weight headers sized for the byte budget. */
function snapshot(name: string, overrides: { transformer?: Record<string, unknown>; vae?: Record<string, unknown> } = {}): string {
  const dir = join(root, name);
  json(join(dir, "model_index.json"), INDEX);
  json(join(dir, "scheduler/scheduler_config.json"), { num_train_timesteps: 1000, shift: 5, training_shift: 1 });
  json(join(dir, "transformer/config.json"), { dim: 32, ffn_dim: 16, num_heads: 2, num_layers: 3, text_dim: 24, freq_dim: 8,
    latent_channels: 8, rope_base: 10000, ...overrides.transformer });
  json(join(dir, "vae/config.json"), { latent_channels: 2, patch_size: [2, 2], decoder_block_out_channels: [32, 32],
    block_out_channels: [32, 32], up_block_types: ["UpDecoderBlock2D", "UpDecoderBlock2D"], norm_num_groups: 32, ...overrides.vae });
  json(join(dir, "text_encoder/config.json"), { model_type: "qwen3_5", text_config: { model_type: "qwen3_5_text", hidden_size: 24,
    num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 16, rms_norm_eps: 1e-6, vocab_size: 50 } });
  json(join(dir, "tokenizer/tokenizer.json"), {});
  safetensors(join(dir, "transformer/diffusion_pytorch_model.safetensors"), { "layers.0.proj.q.weight": [32, 32], "rope.bands": [2] });
  safetensors(join(dir, "text_encoder/model.safetensors"), { "language_model.norm.weight": [24], "visual.proj.weight": [10, 10] });
  safetensors(join(dir, "vae/diffusion_pytorch_model.safetensors"), { "decoder.conv_in.weight": [32, 2, 3, 3], "encoder.conv_in.weight": [5, 5] });
  return dir;
}

test("a pipeline opens from its configs, reports what each stage holds, and loads no stage", async () => {
  const { pipeline } = await openImagePipeline(snapshot("synthetic"));
  try {
    expect(pipeline.defaults).toEqual({ width: 1024, height: 1024, steps: 50, guidance: 3, negativePrompt: "", uncondSkipLayers: [22] });
    expect([pipeline.latentChannels, pipeline.pixelsPerLatent, pipeline.depth]).toEqual([8, 4, 3]);
    // Only the tensors each stage reads: the derived RoPE bands, the vision tower and the encoder are excluded.
    expect(pipeline.stageBytes).toEqual({ conditioner: 24 * 4, denoiser: 32 * 32 * 4, decoder: 32 * 2 * 9 * 4 });
    // Each stage holds less than its own component's files (headers and unread tensors), never more.
    const files = (component: string) => readdirSync(join(root, "synthetic", component)).filter(file => file.endsWith(".safetensors"))
      .reduce((sum, file) => sum + statSync(join(root, "synthetic", component, file)).size, 0);
    const components = { conditioner: "text_encoder", denoiser: "transformer", decoder: "vae" } as const;
    for (const [stage, component] of Object.entries(components))
      expect(pipeline.stageBytes[stage as keyof typeof components]).toBeLessThan(files(component));
    // The reference's eight levels, exact float32 values (0.463 is the float above f32(0.463): torch's fused linspace step).
    expect(Array.from(pipeline.schedule.sigmas(8))).toEqual([1, 0.9679999947547913, 0.9259999990463257, 0.8709999918937683,
      0.7910000085830688, 0.6710000038146973, 0.46300002932548523, 0.024000000208616257, 0]);
  } finally { pipeline.dispose(); }
});

test("a snapshot whose components disagree is refused when opened", async () => {
  await expect(openImagePipeline(snapshot("latent-mismatch", { transformer: { latent_channels: 16 } })))
    .rejects.toThrow("transformer latent_channels 16 != VAE latent_channels 2 x patch 2^2");
  await expect(openImagePipeline(snapshot("text-mismatch", { transformer: { text_dim: 32 } })))
    .rejects.toThrow("text encoder hidden_size 24 != transformer text_dim 32");
});
