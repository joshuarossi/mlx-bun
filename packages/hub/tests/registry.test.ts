// Registry unit tests (fast tier — synthetic hub dir, in-memory db).

import { describe, expect, test } from "bun:test";
import { chmodSync, mkdtempSync, mkdirSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { hubCacheRoot, modelIdentity, Registry } from "@mlx-bun/hub/registry";

test("model identity uses the snapshot directory even when weight bytes cannot be read", () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-hub-identity-"));
  try {
    const first = join(root, "snapshots", "revision-one"), second = join(root, "snapshots", "revision-two");
    mkdirSync(first, { recursive: true }); mkdirSync(second);
    const weights = join(first, "model.safetensors"); writeFileSync(weights, "weights"); chmodSync(weights, 0);
    const alias = join(root, "alias"); symlinkSync(first, alias);
    expect(modelIdentity(first)).toBe(realpathSync(first));
    expect(modelIdentity(alias)).toBe(modelIdentity(first));
    expect(modelIdentity(second)).not.toBe(modelIdentity(first));
    chmodSync(weights, 0o600); writeFileSync(weights, "replaced weights");
    expect(modelIdentity(first)).toBe(realpathSync(first));
  } finally { rmSync(root, { recursive: true, force: true }); }
});

function makeHub(): string {
  const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
  const snap = join(hub, "models--test--tiny-4bit", "snapshots", "abc123");
  mkdirSync(snap, { recursive: true });
  writeFileSync(join(snap, "config.json"), JSON.stringify({
    model_type: "gemma4_unified",
    quantization: { bits: 4, group_size: 64, mode: "affine" },
    text_config: { num_hidden_layers: 4, hidden_size: 256, vocab_size: 1000 },
  }));
  writeFileSync(join(snap, "model.safetensors"), new Uint8Array(1024));
  writeFileSync(join(snap, "model.safetensors.index.json"), JSON.stringify({
    metadata: { total_parameters: 123456789 },
    weight_map: {},
  }));
  writeFileSync(join(snap, "optiq_vision.safetensors"), new Uint8Array(64));
  writeFileSync(join(snap, "chat_template.jinja"), "{{ '<|tool_call>' }}");
  writeFileSync(join(snap, "README.md"), "---\nlibrary_name: mlx\nlicense: gemma\n---\n# card\n");

  const snap2 = join(hub, "models--test--big-bf16", "snapshots", "def456");
  mkdirSync(snap2, { recursive: true });
  writeFileSync(join(snap2, "config.json"), JSON.stringify({
    model_type: "llama", num_hidden_layers: 2, hidden_size: 64, vocab_size: 100,
  }));
  writeFileSync(join(snap2, "model.safetensors"), new Uint8Array(4096));
  return hub;
}

describe("Registry", () => {
  test("a supplied classifier decides each snapshot's support tier once, at index time", async () => {
    const hub = makeHub();
    const seen: string[] = [];
    const reg = new Registry(":memory:", { supportTier: async record => { seen.push(record.repoId); return record.modelType === "llama" ? "generic" : null; } });
    await reg.scan(hub);
    expect(reg.list().map(m => [m.repoId, m.supportTier])).toEqual(expect.arrayContaining([["test/big-bf16", "generic"], ["test/tiny-4bit", undefined]]));
    const listed = seen.length;
    reg.list(); reg.listCanonical();
    expect(seen).toHaveLength(listed); // listing reads the index, not the classifier
    const plain = new Registry(":memory:");
    await plain.scan(hub);
    expect(plain.list().every(m => m.supportTier === undefined)).toBe(true);
  });

  test("scan indexes snapshots with capabilities", async () => {
    const hub = makeHub();
    const reg = new Registry(":memory:");
    expect(await reg.scan(hub)).toBe(2);

    const all = reg.list();
    expect(all).toHaveLength(2);

    const vision = reg.list({ vision: true });
    expect(vision).toHaveLength(1);
    expect(vision[0]!.repoId).toBe("test/tiny-4bit");
    expect(vision[0]!.quantBits).toBe(4);
    expect(vision[0]!.paramCount).toBe(123456789);
    expect(vision[0]!.hasToolTemplate).toBe(true);
    expect(vision[0]!.hasKvConfig).toBe(false);
    expect(vision[0]!.license).toBe("gemma"); // model-card frontmatter
    expect(reg.resolve("big").license).toBeNull(); // no README

    const small = reg.list({ maxBytes: 2048 });
    expect(small.map((m) => m.repoId)).toEqual(["test/tiny-4bit"]);

    expect(reg.resolve("big").repoId).toBe("test/big-bf16");
    expect(() => reg.resolve("test")).toThrow(/ambiguous/);
    expect(() => reg.resolve("nope")).toThrow(/no model/);
    rmSync(hub, { recursive: true, force: true });
  });
});

describe("Registry drafters", () => {
  test("resolve never selects a speculative-decoding drafter", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
    const snapshot = (repo: string, modelType: string) => {
      const dir = join(hub, `models--test--${repo}`, "snapshots", "abc123");
      mkdirSync(dir, { recursive: true });
      writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: modelType }));
      writeFileSync(join(dir, "model.safetensors"), new Uint8Array(64));
    };
    try {
      snapshot("gemma-e2b", "gemma4");
      snapshot("gemma-e2b-assistant", "gemma4_assistant");
      snapshot("gemma-12b-assistant", "gemma4_unified_assistant");
      const reg = new Registry(":memory:", { isCompanion: type => type.endsWith("_assistant") });
      expect(await reg.scan(hub)).toBe(3);
      expect(reg.list()).toHaveLength(3);
      expect(reg.resolve("gemma").repoId).toBe("test/gemma-e2b");
      expect(() => reg.resolve("assistant")).toThrow(/no model/);
      reg.close();
      // The registry holds no model facts: without a companion predicate nothing is excluded.
      const open = new Registry(":memory:");
      await open.scan(hub);
      expect(open.resolve("e2b-assistant").repoId).toBe("test/gemma-e2b-assistant");
      open.close();
    } finally {
      rmSync(hub, { recursive: true, force: true });
    }
  });
});

test("hubCacheRoot follows huggingface_hub's precedence", () => {
  expect(hubCacheRoot({ HF_HUB_CACHE: "/a", HF_HOME: "/b", XDG_CACHE_HOME: "/c", HOME: "/h" })).toBe("/a");
  expect(hubCacheRoot({ HF_HOME: "/b", XDG_CACHE_HOME: "/c", HOME: "/h" })).toBe("/b/hub");
  expect(hubCacheRoot({ XDG_CACHE_HOME: "/c", HOME: "/h" })).toBe("/c/huggingface/hub");
  expect(hubCacheRoot({ HOME: "/h" })).toBe("/h/.cache/huggingface/hub");
});

test("scan indexes plain model directories beside the hub; an exact id wins over substring matches", async () => {
  const hub = makeHub(), models = mkdtempSync(join(tmpdir(), "mlx-bun-models-"));
  try {
    for (const name of ["tiny-4bit", ".tiny-4bit.tmp-x", "notes"]) mkdirSync(join(models, name));
    writeFileSync(join(models, "tiny-4bit", "config.json"), JSON.stringify({ model_type: "llama" }));
    writeFileSync(join(models, "tiny-4bit", "model.safetensors"), new Uint8Array(8));
    // A staging directory (dot-prefixed) is never indexed, even when complete.
    writeFileSync(join(models, ".tiny-4bit.tmp-x", "config.json"), JSON.stringify({ model_type: "llama" }));
    writeFileSync(join(models, ".tiny-4bit.tmp-x", "model.safetensors"), new Uint8Array(8));
    const reg = new Registry(":memory:", { modelDirs: [models, join(models, "absent")] });
    try {
      expect(await reg.scan(hub)).toBe(3);
      expect(reg.list().map(model => model.repoId).sort()).toEqual(["test/big-bf16", "test/tiny-4bit", "tiny-4bit"]);
      expect(reg.resolve("tiny-4bit").path).toBe(join(models, "tiny-4bit"));
      expect(reg.resolve("test/tiny-4bit").repoId).toBe("test/tiny-4bit");
      expect(() => reg.resolve("tiny")).toThrow("ambiguous");
    } finally { reg.close(); }
  } finally { rmSync(hub, { recursive: true, force: true }); rmSync(models, { recursive: true, force: true }); }
});

describe("Registry diffusers pipelines", () => {
  /** A pipeline snapshot shaped like a diffusers repo: weighted model components, a scheduler and a tokenizer without weights. */
  function pipeline(hub: string, repo: string, index: Record<string, unknown>, components: Record<string, Record<string, number | string>>): string {
    const dir = join(hub, `models--test--${repo}`, "snapshots", "abc123");
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "model_index.json"), JSON.stringify(index));
    for (const [name, files] of Object.entries(components)) {
      mkdirSync(join(dir, name));
      for (const [file, content] of Object.entries(files))
        writeFileSync(join(dir, name, file), typeof content === "number" ? new Uint8Array(content) : content);
    }
    return dir;
  }
  const index = { _class_name: "SomeImagePipeline", _diffusers_version: "0.38.0", scheduler: ["diffusers", "SomeScheduler"],
    text_encoder: ["transformers", "SomeEncoder"], tokenizer: ["transformers", "SomeTokenizer"], transformer: ["diffusers", "SomeTransformer"],
    vae: ["diffusers", "SomeAutoencoder"], safety_checker: [null, null] };
  const components = {
    scheduler: { "scheduler_config.json": "{}" },
    text_encoder: { "config.json": "{}", "model-00001-of-00002.safetensors": 300, "model-00002-of-00002.safetensors": 200, "model.safetensors.index.json": "{}" },
    tokenizer: { "tokenizer.json": "{}", "tokenizer_config.json": "{}" },
    transformer: { "config.json": "{}", "diffusion_pytorch_model.safetensors": 400 },
    vae: { "config.json": "{}", "diffusion_pytorch_model.safetensors": 50 },
  };

  test("a pipeline snapshot is indexed under its class, sized by its components' weights", async () => {
    const hub = makeHub();
    try {
      const dir = pipeline(hub, "image-pipeline", index, components);
      writeFileSync(join(dir, "README.md"), "---\nlicense: apache-2.0\n---\n");
      const reg = new Registry(":memory:");
      expect(await reg.scan(hub)).toBe(3);
      expect(reg.resolve("image-pipeline")).toMatchObject({ path: dir, repoId: "test/image-pipeline", modelType: "SomeImagePipeline", sizeBytes: 950,
        sidecarBytes: 0, expertsBytes: 0, paramCount: null, quantBits: null, hasVisionSidecar: false, hasToolTemplate: false, license: "apache-2.0" });
      reg.close();
    } finally { rmSync(hub, { recursive: true, force: true }); }
  });

  test("a pipeline index without a string _class_name, or a malformed one, is not indexed", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
    try {
      const { _class_name: _, ...unnamed } = index;
      pipeline(hub, "unnamed", unnamed, components);
      pipeline(hub, "numbered", { ...index, _class_name: 7 }, components);
      pipeline(hub, "bad-entry", { ...index, vae: "diffusers" }, components);
      const broken = pipeline(hub, "broken-json", index, components);
      writeFileSync(join(broken, "model_index.json"), "{");
      const reg = new Registry(":memory:");
      expect(await reg.scan(hub)).toBe(0);
      expect(reg.list()).toEqual([]);
      reg.close();
    } finally { rmSync(hub, { recursive: true, force: true }); }
  });

  test("a pipeline whose model component has no weights, whose declared component is missing, or that holds no weights is not indexed", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
    try {
      pipeline(hub, "no-transformer-weights", index, { ...components, transformer: { "config.json": "{}" } });
      const { vae: _, ...withoutVae } = components;
      pipeline(hub, "missing-vae", index, withoutVae);
      pipeline(hub, "weightless", { _class_name: "SomeImagePipeline", scheduler: ["diffusers", "SomeScheduler"] }, { scheduler: components.scheduler });
      const reg = new Registry(":memory:");
      expect(await reg.scan(hub)).toBe(0);
      reg.close();
    } finally { rmSync(hub, { recursive: true, force: true }); }
  });

  test("a quantized pipeline reports the quantization its model components declare, mixed when they differ", async () => {
    const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
    try {
      const q8 = JSON.stringify({ quantization: { bits: 8, group_size: 64, mode: "affine" } });
      pipeline(hub, "q8", index, { ...components, transformer: { ...components.transformer, "config.json": q8 }, text_encoder: { ...components.text_encoder, "config.json": q8 } });
      pipeline(hub, "mixed", index, { ...components, transformer: { ...components.transformer, "config.json": q8 },
        text_encoder: { ...components.text_encoder, "config.json": JSON.stringify({ quantization: { bits: 4, group_size: 64 } }) } });
      const reg = new Registry(":memory:");
      expect(await reg.scan(hub)).toBe(2);
      expect(reg.resolve("test/q8")).toMatchObject({ quantBits: 8, quantGroupSize: 64, quantMode: "affine" });
      expect(reg.resolve("test/mixed")).toMatchObject({ quantBits: null, quantGroupSize: null, quantMode: "mixed" });
      reg.close();
    } finally { rmSync(hub, { recursive: true, force: true }); }
  });

  test("a snapshot with a root config.json is read as before, even beside a model_index.json", async () => {
    const hub = makeHub();
    try {
      const plain = new Registry(":memory:");
      await plain.scan(hub);
      const before = plain.list().map(({ scannedAt: _, ...record }) => record);
      plain.close();
      writeFileSync(join(hub, "models--test--big-bf16", "snapshots", "def456", "model_index.json"), JSON.stringify({ _class_name: "SomeImagePipeline" }));
      const reg = new Registry(":memory:");
      expect(await reg.scan(hub)).toBe(2);
      expect(reg.list().map(({ scannedAt: _, ...record }) => record)).toEqual(before);
      expect(reg.resolve("big").modelType).toBe("llama");
      reg.close();
    } finally { rmSync(hub, { recursive: true, force: true }); }
  });
});
