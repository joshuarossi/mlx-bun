// The diffusers pipeline layout through the artifact readers and the family
// registry: model_index.json parsing and its malformed forms, component
// lookup, config loading that leaves config.json snapshots unchanged, the
// MOSS-Image family's role, the openers' refusals, diffusers shard names, a
// pipeline opened from a synthetic snapshot (configs and headers only; no stage
// loads), and the graphs' lifetimes when construction or the conditioner's
// last evaluation fails.
import { afterAll, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/artifacts/config";
import { loadPipelineConfig } from "../../src/artifacts/pipeline-config";
import type { TextToImagePipeline } from "../../src/contracts/mlx/image-generation";
import { parsePipelineIndex, pipelineComponentDir, readPipelineIndex } from "../../src/artifacts/pipeline-index";
import { ShardedSafetensors } from "../../src/artifacts/safetensors";
import { openDiffusersShards } from "../../src/artifacts/diffusers-shards";
import { openModel } from "../../src/models/factory";
import { MLX_IMAGE_GRAPH_TABLES, openImagePipeline } from "../../src/models/image-factory";
import { familyOf } from "../../src/models/families";
import { MossImageConditioner } from "../../src/models/moss-image/text-encoder";
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
  const pipeline = snapshot("pipeline");
  const config = await loadPipelineConfig(pipeline);
  expect(config.modelType).toBe("MOSSImagePipeline");
  expect(familyOf(config)?.graph).toBe("moss-image");
  await expect(loadModelConfig(pipeline)).rejects.toThrow("config.json");
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

test.each(["model.safetensors", "weights.safetensors"])("diffusers files cannot shadow an existing %s checkpoint", async filename => {
  const dir = join(root, `precedence-${filename}`);
  safetensors(join(dir, filename), { existing: [2] });
  // Selecting this unrelated index would load a missing shard instead of the
  // checkpoint that the loader selected before image support was added.
  json(join(dir, "diffusion_pytorch_model.safetensors.index.json"), { weight_map: { image: "missing.safetensors" } });
  safetensors(join(dir, "diffusion_pytorch_model.safetensors"), { image: [3] });
  const shards = await ShardedSafetensors.open(dir);
  try {
    expect(shards.tensorNames).toEqual(["existing"]);
    expect([...shards.files.keys()]).toEqual([filename]);
  } finally { for (const file of shards.files.values()) file.mmap.unmap(); }
});

test("the token-model opener refuses an image pipeline and the image opener refuses a token model", async () => {
  const pipeline = join(root, "refusal-pipeline");
  json(join(pipeline, "model_index.json"), INDEX);
  await expect(openModel(pipeline)).rejects.toThrow("config.json");
  const speech = join(root, "refusal-speech");
  json(join(speech, "config.json"), { model_type: "whisper", n_audio_ctx: 1500 });
  await expect(openImagePipeline(speech)).rejects.toThrow("model_index.json");
});

test("diffusers shard names are found, sharded and single", async () => {
  const single = join(root, "single");
  safetensors(join(single, "diffusion_pytorch_model.safetensors"), { "a.weight": [2, 2] });
  const singleShards = await openDiffusersShards(single);
  try { expect(singleShards.tensorNames).toEqual(["a.weight"]); }
  finally { for (const file of singleShards.files.values()) file.mmap.unmap(); }
  // Existing loaders never select image weights; only the bound reader does.
  await expect(ShardedSafetensors.open(single)).rejects.toThrow();
  const sharded = join(root, "sharded");
  safetensors(join(sharded, "diffusion_pytorch_model-00001-of-00002.safetensors"), { "a.weight": [2, 2] });
  safetensors(join(sharded, "diffusion_pytorch_model-00002-of-00002.safetensors"), { "b.weight": [3] });
  json(join(sharded, "diffusion_pytorch_model.safetensors.index.json"), { weight_map: {
    "a.weight": "diffusion_pytorch_model-00001-of-00002.safetensors", "b.weight": "diffusion_pytorch_model-00002-of-00002.safetensors" } });
  const indexedShards = await openDiffusersShards(sharded);
  try { expect(indexedShards.tensorNames).toEqual(["a.weight", "b.weight"]); }
  finally { for (const file of indexedShards.files.values()) file.mmap.unmap(); }
  await expect(ShardedSafetensors.open(sharded)).rejects.toThrow();
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
    // MFLUX constructs and snaps in float64 before storing float32 levels.
    expect(Array.from(pipeline.schedule.sigmas(8))).toEqual([1, 0.9679999947547913, 0.9259999990463257, 0.8709999918937683,
      0.7910000085830688, 0.6710000038146973, 0.46299999952316284, 0.024000000208616257, 0]);
  } finally { pipeline.dispose(); }
});

test("image loading selects a named graph and refuses an absent name without a fallback", async () => {
  expect(MLX_IMAGE_GRAPH_TABLES["moss-image"]!.generic.id).toBe("moss-image");
  const dir = snapshot("named-graph");
  const opened = await openImagePipeline(dir, { graph: "moss-image" });
  try { expect(opened.profile?.profile.execution.graph).toBe("moss-image"); }
  finally { opened.pipeline.dispose(); }
  await expect(openImagePipeline(dir, { graph: "missing-graph" })).rejects.toThrow("no graph named missing-graph");
});

test("a caller's image graph needs no family registration and supplies its own stage implementations", async () => {
  const dir = snapshot("caller-graph");
  json(join(dir, "model_index.json"), { ...INDEX, _class_name: "CallerImagePipeline" });
  let disposed = false;
  const fake: TextToImagePipeline = {
    defaults: { width: 16, height: 16, steps: 1, guidance: 1, negativePrompt: "", uncondSkipLayers: [] },
    latentChannels: 1, pixelsPerLatent: 1, depth: 1, stageBytes: { conditioner: 0, denoiser: 0, decoder: 0 },
    schedule: { sigmas: () => new Float32Array([1, 0]), timestep: sigma => sigma },
    async conditioner() { throw new Error("the loader must not open a stage"); },
    async denoiser() { throw new Error("the loader must not open a stage"); },
    async decoder() { throw new Error("the loader must not open a stage"); },
    release() {}, dispose() { disposed = true; },
  };
  const opened = await openImagePipeline(dir, { graph: async (directory, config) => {
    expect(directory).toBe(dir);
    expect(config.modelType).toBe("CallerImagePipeline");
    return fake;
  } });
  expect(opened.pipeline).toBe(fake);
  expect(opened.profile).toBeNull();
  expect(disposed).toBe(false);
  opened.pipeline.dispose();
  expect(disposed).toBe(true);
});

test("a snapshot whose components disagree is refused when opened", async () => {
  await expect(openImagePipeline(snapshot("latent-mismatch", { transformer: { latent_channels: 16 } })))
    .rejects.toThrow("transformer latent_channels 16 != VAE latent_channels 2 x patch 2^2");
  await expect(openImagePipeline(snapshot("text-mismatch", { transformer: { text_dim: 32 } })))
    .rejects.toThrow("text encoder hidden_size 24 != transformer text_dim 32");
});

test("a graph whose construction fails partway frees every array its layers already made before the weights are released", async () => {
  // A child process wraps every MLX operation and array factory to see what construction allocates; each graph gets weights that
  // run out a few layers in.
  const script = `
    import { mock } from "bun:test";
    const opsPath = ${JSON.stringify(import.meta.resolve("@mlx-bun/mlx/ops"))};
    const actual = await import(opsPath);
    const { MlxArray } = await import(${JSON.stringify(import.meta.resolve("@mlx-bun/mlx/array"))});
    let created = [];
    const track = (label, out) => {
      for (const array of Array.isArray(out) ? out : [out]) {
        if (!array || typeof array.dispose !== "function") continue;
        const entry = { label, disposed: false }, dispose = array.dispose.bind(array);
        array.dispose = () => { entry.disposed = true; dispose(); };
        created.push(entry);
      }
      return out;
    };
    mock.module(opsPath, () => Object.fromEntries(Object.entries(actual).map(([name, fn]) =>
      [name, typeof fn === "function" ? (...args) => track(name, fn(...args)) : fn])));
    const moss = await import(${JSON.stringify(import.meta.resolve("../../src/models/moss-image/index"))});
    /** Weights holding these tensors (zeros of the given shapes) and nothing else. */
    const weights = shapes => {
      const tensors = Object.fromEntries(Object.entries(shapes).map(([name, shape]) =>
        [name, MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)), shape)]));
      return { has: name => name in tensors, tensor(name) { if (!(name in tensors)) throw new Error("missing " + name); return tensors[name]; }, dispose() {} };
    };
    const factories = ["fromFloat32", "fromInt32"].map(name => { const make = MlxArray[name]; return [name, make]; });
    const leaks = {};
    for (const [graph, shapes, build] of [
      ["transformer", { "video_embedder.weight": [8, 8] },
        w => new moss.MossImageTransformer(w, { quantization: null }, moss.parseMossTransformerConfig({ dim: 8, num_heads: 1, freq_dim: 2, latent_channels: 8 }))],
      ["conditioner", { "language_model.embed_tokens.weight": [50, 8], "language_model.layers.0.input_layernorm.weight": [8],
        "language_model.layers.0.linear_attn.in_proj_qkv.weight": [24, 8] },
        w => new moss.MossImageConditioner(w, { quantization: null, text: { rmsNormEps: 1e-6, headDim: 4, partialRotaryFactor: 0.5,
          ropeParameters: { full_attention: { ropeTheta: 10000 } }, numAttentionHeads: 2, numKeyValueHeads: 1, linearNumKeyHeads: 2,
          linearNumValueHeads: 2, linearKeyHeadDim: 4, linearValueHeadDim: 4, layerTypes: ["linear_attention"], numHiddenLayers: 1 } }, null, null)],
    ]) {
      const w = weights(shapes);
      created = [];
      for (const [name, make] of factories) MlxArray[name] = (...args) => track(name, make.call(MlxArray, ...args));
      let error;
      try { build(w); } catch (caught) { error = String(caught); }
      for (const [name, make] of factories) MlxArray[name] = make;
      if (!error?.includes("missing")) throw new Error(graph + " did not fail on a missing tensor: " + error);
      if (!created.length) throw new Error(graph + " made nothing before failing; the test would prove nothing");
      leaks[graph] = created.filter(entry => !entry.disposed).map(entry => entry.label);
    }
    console.log(JSON.stringify(leaks));
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { cwd: new URL("../../", import.meta.url).pathname, stdout: "pipe", stderr: "pipe" });
  const [code, out, err] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
  expect([code, err.trim()]).toEqual([0, ""]);
  // The decoder's consumed/cast weight port and partial construction are
  // covered in moss-image-vae-mlx.test.ts with real detached bf16 buffers.
  expect(JSON.parse(out.trim())).toEqual({ transformer: [], conditioner: [] });
});

test("the conditioner frees its final norm's output when evaluating it fails", () => {
  const disposed: string[] = [];
  const fake = (label: string, fails = false) => ({
    eval() { if (fails) throw new Error("injected evaluation failure"); },
    dispose() { disposed.push(label); },
    [Symbol.dispose]() { this.dispose(); },
  });
  // The conditioner's own encode over stand-in layers: the embedding's output feeds no layers, and the final norm's fails to evaluate.
  const conditioner = Object.assign(Object.create(MossImageConditioner.prototype) as MossImageConditioner, {
    template: { render: () => "a cat" }, tokenizer: { encode: () => [1, 2] }, layers: [],
    embedding: { forward: () => fake("embedded") }, rope: { tables: () => ({ [Symbol.dispose]() {} }) }, norm: { forward: () => fake("normed", true) },
  });
  expect(() => conditioner.encode("a cat")).toThrow("injected evaluation failure");
  expect(disposed.sort()).toEqual(["embedded", "normed"]);
});
