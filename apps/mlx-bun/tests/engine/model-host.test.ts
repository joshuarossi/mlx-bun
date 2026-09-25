import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadContext, detectDraftKind, ownModelContext, getVisionTower, getAudioTower,
  type ModelContext, type ServedModelInfo } from "../../src/engine/model-host";
import { createAppEngine } from "../../src/engine/index";
import type { ModelBinding } from "../../src/engine/model-binding";
import { runtimeConfig } from "@mlx-bun/inference/runtime/config";

function context() {
  return { model: { config: {}, weightsBytes: 0 }, modelId: "fake", vision: null,
    audio: null, loadVision: null, loadAudio: null } as unknown as Omit<ModelContext<ServedModelInfo>, "dispose">;
}

test("model context releases every owned resource once, even if one release throws", () => {
  const released: string[] = []; const c = context();
  c.vision = { dispose() { released.push("vision"); } } as typeof c.vision;
  const host = ownModelContext(c, [
    { dispose() { released.push("compiled"); } },
    { dispose() { released.push("adapters"); } },
    { dispose() { released.push("draft"); throw new Error("draft cleanup failed"); } },
    { dispose() { released.push("model constants"); } },
    { dispose() { released.push("weights"); } },
  ]);
  expect(() => host.dispose()).toThrow("draft cleanup failed"); host.dispose();
  expect(released).toEqual(["vision", "compiled", "adapters", "draft", "model constants", "weights"]);
  expect(getVisionTower(host as ModelContext)).toBeNull();
  expect(getAudioTower(host as ModelContext)).toBeNull();
});

test("lazy towers are loaded once and owned by the model context", () => {
  let loads = 0, disposed = 0; const c = context();
  c.loadVision = () => { loads++; return { dispose() { disposed++; } } as NonNullable<typeof c.vision>; };
  const host = ownModelContext(c, []);
  expect(getVisionTower(host as ModelContext)).toBe(getVisionTower(host as ModelContext));
  expect(loads).toBe(1); host.dispose(); expect(disposed).toBe(1);
  expect(getVisionTower(host as ModelContext)).toBeNull();
});

test("draft detection preserves explicit artifact conventions without loading MLX", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-app-draft-"));
  try {
    for (const [config, expected] of [
      [{ architectures: ["Gemma4DSparkModel"] }, "deepspec"],
      [{ model_type: "gemma4_assistant" }, "assistant"],
      [{ model_type: "qwen3_5_mtp" }, "mtp"],
      [{ model_type: "qwen3" }, "two-model"],
    ] as const) {
      writeFileSync(join(dir, "config.json"), JSON.stringify(config));
      expect(await detectDraftKind(dir)).toBe(expected);
    }
    writeFileSync(join(dir, "dspark.json"), "{}"); expect(await detectDraftKind(dir)).toBe("dspark");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("an explicit replacement binding is used without inspecting a legacy model", async () => {
  let released = 0; const host = ownModelContext(context(), [{ dispose() { released++; } }]);
  const supplied = { gateway: { runtime: runtimeConfig() } } as ModelBinding;
  const engine = await createAppEngine(host, { capacity: 1, binding: supplied });
  expect(engine.binding).toBe(supplied); await engine.close(); await engine.close(); expect(released).toBe(1);
});

test("engine construction failure releases its transferred model context", async () => {
  let released = 0; const host = ownModelContext(context(), [{ dispose() { released++; } }]);
  const supplied = { gateway: { runtime: runtimeConfig() } } as ModelBinding;
  await expect(createAppEngine(host, { capacity: 0, binding: supplied })).rejects.toThrow("positive integer");
  expect(released).toBe(1);
});


test("injected model loading resolves its profile without importing native model constructors", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-app-provider-"));
  const previous = process.env.MLX_BUN_LIBMLXC;
  process.env.MLX_BUN_LIBMLXC = "/nonexistent-injected-provider-must-not-load-native";
  let selected = 0, disposed = 0;
  try {
    writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3",
      hidden_size: 8, num_hidden_layers: 1, num_attention_heads: 2,
      num_key_value_heads: 2, intermediate_size: 16, vocab_size: 32,
      max_position_embeddings: 64, tie_word_embeddings: true }));
    const loaded = await loadContext(dir, "replacement", {
      draftKind: "ngram", numDraftTokens: 7,
      implementations: { select(config, profile) {
        selected++;
        expect(config.modelType).toBe("qwen3");
        expect(profile.profile.execution.graph).toBe("qwen3");
        return { id: "replacement", graph: "qwen3", loader: "safetensors", loop: "autoregressive",
          async create(source, selectedConfig, selectedProfile) {
            expect(source.modelDir).toBe(dir); expect(source.modelId).toBe("replacement");
            expect(source.options.draftKind).toBe("ngram"); expect(source.options.numDraftTokens).toBe(7);
            const supplied = context(); supplied.model = { config: selectedConfig, weightsBytes: 0 };
            supplied.profile = selectedProfile;
            return ownModelContext(supplied, [{ dispose() { disposed++; } }]);
          },
        };
      } },
    });
    expect(selected).toBe(1); expect(loaded.profile.profile.execution.graph).toBe("qwen3");
    loaded.dispose(); expect(disposed).toBe(1);
  } finally {
    if (previous === undefined) delete process.env.MLX_BUN_LIBMLXC; else process.env.MLX_BUN_LIBMLXC = previous;
    rmSync(dir, { recursive: true, force: true });
  }
});

test("closing the app drains borrowed execution before disposing the model", async () => {
  const events: string[] = [];
  const entered = Promise.withResolvers<void>(); const finish = Promise.withResolvers<void>();
  const host = ownModelContext(context(), [{ dispose() { events.push("model disposed"); } }]);
  const execution = { method: "autoregressive", mechanism: "continuous", pagedKv: false,
    promptCache: false, checkpoint: false, fill: false, compiledDecode: false,
    grammarJump: false, reasons: [] } as const;
  const supplied = { gateway: { runtime: runtimeConfig(), config: { eosTokenIds: [2] },
    cachesBatchable: () => true, plan: () => execution,
    continuationRequest(_plan: unknown, _opts: unknown, _prompt: unknown, onToken: unknown) {
      return { continuation: {}, sample() {}, plainGreedy: true, onToken, dispose() {} };
    },
    createBatchGroup() { return { activeRows: 0, pendingRows: 0, projectedKvBytes: 0,
      async submit() { entered.resolve(); await finish.promise; events.push("execution stopped");
        return { promptTokens: 1, cachedTokens: 0, generatedTokens: 1, prefillMs: 0, decodeMs: 0 }; },
      kick() {}, async close() { events.push("group closed"); },
    }; },
  } } as unknown as ModelBinding;
  const engine = await createAppEngine(host, { capacity: 1, binding: supplied });
  const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
    userSeed: false, kvQuant: false, turboQuant: false, hasLogitsExtras: false,
    hasGrammar: false, wantsLogprobs: false, hasDraft: false };
  const run = engine.completion.run([1], {}, () => {}, undefined, shape, engine.completion.place(shape)).catch(() => {});
  await entered.promise; const closing = engine.close();
  await Promise.resolve(); expect(events).toEqual([]);
  finish.resolve(); await run; await closing;
  expect(events).toEqual(["execution stopped", "group closed", "model disposed"]);
});

test("compiled runner retirement is idempotent and never allocates an absent runner", async () => {
  // Isolate module mocks: exercise the actual runner registry and retirement
  // with a fake native closure, without changing any sibling test's modules.
  const script = `
    import { mock } from "bun:test";
    import assert from "node:assert/strict";
    import { dirname, join } from "node:path";
    const source = dirname(import.meta.resolve("@mlx-bun/inference"));
    let allocations = 0, releases = 0, materializations = 0;
    class ArrayValue {
      shape = [1, 1, 1, 1];
      slice() { return new ArrayValue(); }
      dispose() {}
    }
    class NativeClosure {
      constructor() { allocations++; }
      apply() { throw new Error("fake native application"); }
      dispose() { releases++; }
    }
    mock.module("@mlx-bun/mlx/array", () => ({ MlxArray: ArrayValue }));
    mock.module("@mlx-bun/mlx/compile", () => ({ CompiledFunction: NativeClosure }));
    mock.module("@mlx-bun/mlx/ops", () => ({ fromInt32: () => new ArrayValue() }));
    mock.module("@mlx-bun/mlx/ffi", () => ({ Dtype: {} }));
    for (const [file, name] of [["kv", "KVCache"], ["quantized-kv", "QuantizedKVCache"],
      ["rotating-kv", "RotatingKVCache"], ["rotating-quantized-kv", "RotatingQuantizedKVCache"]]) {
      mock.module(join(source, "state", file + ".ts"), () => ({ [name]: class {} }));
    }
    const { CompiledDecode } = await import("@mlx-bun/inference/generation/compiled-decode");
    const model = { config: { text: { numKvSharedLayers: 1, enableMoeBlock: false } }, perLayerWidth: 0,
      materializeGraphConstants() { materializations++; } };
    CompiledDecode.release(model);
    assert.equal(materializations, 0); assert.equal(allocations, 0);
    const runner = CompiledDecode.for(model);
    const cache = { offset: 1, keys: new ArrayValue(), values: new ArrayValue(),
      prepareDecodeStep: () => ({ fetch: "concat", activeLen: 1 }) };
    assert.throws(() => runner.step(new ArrayValue(), [cache]), /fake native application/);
    assert.equal(allocations, 1);
    CompiledDecode.release(model); CompiledDecode.release(model); runner.dispose();
    assert.equal(releases, 1); assert.equal(allocations, 1); assert.equal(materializations, 1);
    assert.throws(() => runner.step(new ArrayValue(), [cache]), /disposed/);
    const replacement = CompiledDecode.for(model);
    assert.notEqual(replacement, runner);
    assert.equal(materializations, 2);
    CompiledDecode.release(model); assert.equal(allocations, 1);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], {
    cwd: new URL("../../", import.meta.url).pathname,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent-compiled-lifecycle" },
    stdout: "pipe", stderr: "pipe",
  });
  const [code, error] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(error).toBe(""); expect(code).toBe(0);
});
