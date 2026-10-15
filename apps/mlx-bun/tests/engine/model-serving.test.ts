import { expect, test } from "bun:test";

const setup = `
  import { mock } from "bun:test";
  import assert from "node:assert/strict";
  let bound = 0, caches = 0, tensors = 0;
  const released = [];
  const hidden = { dispose() { released.push("hidden"); } };
  const logits = { shape: [1, 1, 2], dispose() { released.push("logits"); },
    slice() { return { toFloat32: () => new Float32Array([0, 0]), dispose() { released.push("last"); } }; } };
  mock.module("@mlx-bun/inference/models", () => ({ declaredGraph: model => model, embeddingDeclarationFor: () => ({ terminator: "fixture" }) }));
  mock.module("@mlx-bun/inference/embeddings", () => ({ isEmbeddingModel: model => model.embeddings === true, embedMany() {}, embeddingTerminatorId() {} }));
  mock.module("@mlx-bun/inference/execution", () => ({ bindMlxGateway(model) {
    bound++; return { capabilities: { sparseAttention: false, method: model.graphCapabilities.method } };
  } }));
  mock.module("@mlx-bun/mlx/ffi", () => ({ MLX_VERSION: "fixture", deviceArchitecture: () => "host-only" }));
  mock.module("@mlx-bun/mlx/ops", () => ({ fromInt32() {
    tensors++; return { dispose() { released.push("input"); } };
  } }));
  mock.module("@mlx-bun/inference/scoring", () => ({
    scoreDecisionAnswers: async () => ({ probabilities: [0.25, 0.75] }),
    sequenceHiddenOperation(model, ids, cache) { return model.sequence?.[0].operation(ids, cache) ?? model.sequenceHidden(ids, cache); },
    sequenceLogitsOperation(model, value) { return model.sequenceLogits?.[0].operation(value) ?? model.logitsFromHidden(value); },
  }));
  const { modelServingBinding } = await import("./src/engine/model-serving.ts");
  const base = () => ({ graphCapabilities: { method: "autoregressive" },
    makeCache() { caches++; return [{ dispose() { released.push("cache"); } }]; },
    loraTargets: () => new Map([["projection", {}]]) });
  const sequence = [{ from: 1, to: Infinity, operation: () => hidden }];
  const sequenceLogits = [{ from: 1, to: Infinity, operation: () => logits }];
  const bind = model => modelServingBinding({ model });
`;

async function hostOnly(script: string) {
  // Keep mocks in a child so sibling engine tests retain their real modules.
  const child = Bun.spawn([process.execPath, "--eval", setup + script], {
    cwd: new URL("../../", import.meta.url).pathname,
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent-serving-binding-fixture" },
    stdout: "pipe", stderr: "pipe",
  });
  const [code, error] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(error).toBe("");
  expect(code).toBe(0);
}

test("denoising binds without scoring and refuses signal before allocating request state", async () => {
  await hostOnly(`
    const model = { ...base(), graphCapabilities: { method: "denoising" },
      trainable: { denoising: { canvasLogits() {} } } };
    const binding = await bind(model);
    assert.equal(bound, 1);
    assert.equal(binding.gateway.capabilities.method, "denoising");
    assert.equal(binding.discovery.adapters, true);
    assert.equal(binding.discovery.training, true);
    await assert.rejects(binding.signal([1], 4, -4), /no full-sequence scoring operation for signal/);
    assert.equal(caches, 0); assert.equal(tensors, 0);
    delete model.loraTargets;
    const custom = await bind(model);
    assert.equal(custom.discovery.adapters, false);
    assert.equal(custom.discovery.training, false);
  `);
});

test("adapter and training discovery follow mount targets and baseline operations", async () => {
  await hostOnly(`
    const baseline = await bind({ ...base(), sequence, sequenceLogits });
    assert.equal(baseline.discovery.adapters, true);
    assert.equal(baseline.discovery.training, true);
    const emptyTargets = await bind({ ...base(), sequence, sequenceLogits, loraTargets: () => new Map() });
    assert.equal(emptyTargets.discovery.adapters, false);
    assert.equal(emptyTargets.discovery.training, false);
    const optionalOnly = await bind({ ...base(), trainable: { lmHead() {} } });
    assert.equal(optionalOnly.discovery.adapters, true);
    assert.equal(optionalOnly.discovery.training, false);
    const noHead = await bind({ ...base(), sequence });
    assert.equal(noHead.discovery.training, false);
    const emptySequence = await bind({ ...base(), sequence: [], sequenceLogits });
    assert.equal(emptySequence.discovery.training, false);
    const legacy = await bind({ ...base(), sequenceHidden: () => hidden, logitsFromHidden: () => logits });
    assert.equal(legacy.discovery.training, true);
  `);
});

test("declared and legacy scoring operations remain callable and release their request state", async () => {
  await hostOnly(`
    for (const ports of [{ sequence, sequenceLogits }, { sequenceHidden: () => hidden, logitsFromHidden: () => logits }]) {
      released.length = 0;
      const binding = await bind({ ...base(), ...ports });
      assert.deepEqual(await binding.signal([1], 4, -4), { bins: [0, 0, 0, 2], vocab: 2 });
      assert.deepEqual(released, ["input", "hidden", "last", "logits", "cache"]);
    }
    assert.equal(caches, 2); assert.equal(tensors, 2);
  `);
});


test("embedding capability composes with decision scoring when sequence and head operations exist", async () => {
  await hostOnly(`
    const binding = await bind({ ...base(), embeddings: true, sequence, sequenceLogits });
    assert.equal(binding.discovery.embeddings, true);
    assert.equal(binding.discovery.decisions, true);
    assert.equal(typeof binding.embed, "function");
    assert.deepEqual(await binding.decide({ prompt: [1], candidates: [[2], [3]] }), [0.25, 0.75]);
    const noHead = await bind({ ...base(), embeddings: true, sequence });
    assert.equal(noHead.discovery.embeddings, true);
    assert.equal(noHead.discovery.decisions, false);
    assert.equal(noHead.decide, undefined);
  `);
});
