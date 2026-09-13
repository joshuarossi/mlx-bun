// Prepared embeddings against the existing same-machine model operation.
// Synthetic media isolates the inference handoff from encoder differences.
import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import type { Cache } from "../../src/model/gemma4-base";
import type { Row } from "../../src/backends/mlx/batch-group";
import type { MlxArray } from "../../src/mlx/array";

const path = process.env.MLX_BUN_TEST_SHARED_MEDIA_MODEL;
describe.skipIf(!path)("shared prepared media input", async () => {
  if (!path) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Gemma4Model } = await import("../../src/model/gemma4");
  const { MlxPrefillCohort } = await import("../../src/backends/mlx/prefill-cohort");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const { bindEmbeddingsInput } = await import("../../src/backends/mlx/prompt-input");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { withResource, disposeResources } = await import("../../src/engine/resources");
  const ops = await import("../../src/mlx/ops");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype } = await import("../../src/mlx/ffi");
  const weights = await Weights.open(path), model = new Gemma4Model(weights, await loadModelConfig(path));
  afterAll(() => weights.dispose());
  function array(a: MlxArray) {
    using contiguous = ops.contiguous(a);
    return { shape: a.shape, dtype: a.dtype,
      sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") };
  }
  function state(caches: Cache[]) {
    return caches.map(cache => ({ signature: cache.signature(), offset: cache.offset,
      arrays: withResource(leaseCacheStates([cache]), values => values.map(value => {
        const shape = value.shape;
        using live = shape.length === 4 && shape[2]! > cache.offset
          ? value.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        return array(live ?? value);
      })) }));
  }
  for (const B of [1, 2]) test(`queued preparation preserves all active B${B} logit vectors`, async () => {
    const arms: unknown[] = [];
    for (const queued of [false, true]) {
      let held = true;
      const group = new MlxBatchExecutionGroup(model, { maxBatch: B, admissionHeld: () => held,
        runtime: createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" }) });
      const logits = Array.from({ length: B }, () => [] as ReturnType<typeof array>[]);
      const tokens = Array.from({ length: B }, () => [] as number[]);
      const tasks: Promise<void>[] = [];
      let activeAtPreparation = 0;
      try {
        const requests = tokens.map((output, row) => group.submit({
          promptIds: Array.from({ length: 7 }, (_, i) => 40 + row + i), maxTokens: 6, eosTokenIds: [],
          sample(value, step) { logits[row]!.push(array(value)); return ops.fromInt32([123 + row + step], [1]); },
          onToken(token) {
            output.push(token);
            if (!queued || row !== 0 || output.length !== 2) return;
            // Never await a future boundary from inside the token callback.
            tasks.push(group.runPreparation(async () => {
              activeAtPreparation = group.activeRows;
              const caches = model.makeCache();
              try {
                using ids = ops.fromInt32([30, 31, 32, 33, 34, 35, 36], [1, 7]);
                using embeds = model.embed.encode(ids);
                using hidden = model.forwardEmbeddings(embeds, caches, null, ids);
                expect(array(hidden).shape[1]).toBe(7);
              } finally { disposeResources(caches); }
            }));
          },
        }));
        held = false; group.kick();
        await Promise.all(requests); await Promise.all(tasks);
        arms.push({ logits, tokens });
        if (queued) { expect(tasks).toHaveLength(1); expect(activeAtPreparation).toBe(B); }
      } finally { await group.close(); }
    }
    expect(arms[1]).toEqual(arms[0]);
  }, 120_000);
  for (const length of [7, 17]) for (const kind of ["image", "audio", "mixed"] as const)
    for (const format of ["bf16", "kv4-delayed"] as const) {
      test(`${kind} L${length} ${format} full logits/state and continuation`, async () => {
        const prompt = Array.from({ length }, (_, i) => 40 + i);
        using ids = ops.fromInt32(prompt, [1, length]);
        using raw = MlxArray.fromFloat32(Float32Array.from({ length: length * model.config.text.hiddenSize },
          (_, i) => Math.sin(i / 17) * 0.02), [1, length, model.config.text.hiddenSize]);
        using embeddings = raw.astype(Dtype.bfloat16);
        using maskIds = ops.fromInt32(prompt.map((_, i) => i >= 2 && i <= 4 ? 1 : 0), [length]);
        using mask = maskIds.astype(Dtype.bool);
        const image = kind === "image" ? mask : null;
        const multimodal = kind === "image" ? null : mask;
        const maintain = createKvMaintenance(format === "bf16" ? {} : { kvBits: 4, quantizedKvStart: 8 });
        const output: unknown[] = [];
        const finish = (caches: Cache[], logits: MlxArray) => {
          const prefix = { logits: array(logits), state: state(caches) };
          maintain(caches);
          using nextIds = ops.fromInt32([123], [1, 1]);
          using nextHidden = model.forwardHidden(nextIds, caches);
          using nextLogits = model.logitsFromHidden(nextHidden);
          return { prefix, next: { logits: array(nextLogits), state: state(caches) } };
        };
        const control = model.makeCache();
        try {
          maintain(control);
          using hidden = model.forwardEmbeddings(embeddings, control, image, ids, multimodal);
          using tip = hidden.slice([0, length - 1, 0], [1, length, hidden.shape[2]!]);
          using logits = model.logitsFromHidden(tip);
          output.push(finish(control, logits));
        } finally { disposeResources(control); }
        const request = {
          req: { promptIds: prompt, maxTokens: 1, eosTokenIds: [], sample: () => { throw new Error("unused"); },
            onToken() {}, promptInput: bindEmbeddingsInput((tokens, caches) =>
              model.forwardEmbeddings(embeddings, caches, image, tokens, multimodal)) },
          resolve() {}, reject(error: unknown) { throw error; }, current: 0, generated: 0, sampled: 0,
          promptTokens: length, cachedTokens: 0, admittedAt: 0, firstTokenAt: 0,
          fed: [], fedTainted: false, merged: false,
        } satisfies Row;
        const cohort = new MlxPrefillCohort({ model, chunkSize: 2, tailSplit: true, maintain,
          forward: async () => { throw new Error("text prefill was selected"); },
          project: hidden => model.logitsFromHidden(hidden),
          async complete(s, logits) { output.push(finish(s.solo, logits)); disposeResources(s.solo); },
          reject: (_row, error) => { throw error; },
        });
        try {
          cohort.admit(request);
          expect(cohort.canAdmit).toBe(false);
          expect(await cohort.advance({ maxTokens: 1 })).toBe(true);
          expect(output[1]).toEqual(output[0]);
        } finally { cohort.dispose(); }
      }, 120_000);
    }
  for (const kind of ["image", "audio", "mixed"] as const) for (const format of ["bf16", "kv4-delayed", "k8v3-delayed"] as const)
    test(`${kind} ${format} resumes a retained prepared prefix through the ordinary cache port`, async () => {
      const { PromptCache } = await import("../../src/prompt-cache");
      const { cloneKvCaches } = await import("../../src/kv-store");
      const prefix = Array.from({ length: 17 }, (_, i) => 40 + i);
      const tail = Array.from({ length: 7 }, (_, i) => 100 + i), prompt = [...prefix, ...tail];
      using ids = ops.fromInt32(prefix, [1, prefix.length]);
      using raw = MlxArray.fromFloat32(Float32Array.from({ length: prefix.length * model.config.text.hiddenSize },
        (_, i) => Math.sin(i / 17) * 0.02), [1, prefix.length, model.config.text.hiddenSize]);
      using embeddings = raw.astype(Dtype.bfloat16);
      using maskIds = ops.fromInt32(prefix.map((_, i) => i >= 2 && i <= 4 ? 1 : 0), [prefix.length]);
      using mask = maskIds.astype(Dtype.bool);
      const maintain = createKvMaintenance(format === "bf16" ? {} : format === "kv4-delayed"
        ? { kvBits: 4, quantizedKvStart: 8 } : { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 8 });
      const donor = model.makeCache(), cache = new PromptCache(8e9);
      const namespace = `prepared-fixture-${kind}-${format}`;
      const output: unknown[] = [];
      const finish = (caches: Cache[], logits: MlxArray) => {
        const first = { logits: array(logits), state: state(caches) };
        maintain(caches);
        using nextIds = ops.fromInt32([123], [1, 1]);
        using hidden = model.forwardHidden(nextIds, caches);
        using next = model.logitsFromHidden(hidden);
        return { first, next: { logits: array(next), state: state(caches) } };
      };
      try {
        maintain(donor);
        using initial = model.forwardEmbeddings(embeddings, donor, kind === "image" ? mask : null,
          ids, kind === "image" ? null : mask);
        initial.eval();
        cache.put(prefix, cloneKvCaches(donor), namespace);
        const before = state(cache.findExact(prefix, namespace)!.caches);
        maintain(donor);
        using tailIds = ops.fromInt32(tail, [1, tail.length]);
        using hidden = model.forwardHidden(tailIds, donor);
        using tip = hidden.slice([0, tail.length - 1, 0], [1, tail.length, hidden.shape[2]!]);
        using logits = model.logitsFromHidden(tip);
        output.push(finish(donor, logits));
        const starts: number[] = [];
        const row = {
          req: { promptIds: prompt, cacheNamespace: namespace, maxTokens: 1, eosTokenIds: [],
            sample: () => { throw new Error("unused"); }, onToken() {},
            promptInput: bindEmbeddingsInput((tokens, caches, start) => {
              starts.push(start); expect([...tokens.toIntTokens()]).toEqual(tail);
              return model.forwardHidden(tokens, caches);
            }) },
          cacheNamespace: namespace,
          resolve() {}, reject(error: unknown) { throw error; }, current: 0, generated: 0, sampled: 0,
          promptTokens: prompt.length, cachedTokens: 0, admittedAt: 0, firstTokenAt: 0,
          fed: [], fedTainted: false, merged: false,
        } satisfies Row;
        const cohort = new MlxPrefillCohort({ model, chunkSize: 2, tailSplit: true, maintain, promptCache: cache,
          forward: async () => { throw new Error("generic prefill selected"); },
          project: h => model.logitsFromHidden(h),
          async complete(value, lg) { output.push(finish(value.solo, lg)); disposeResources(value.solo); },
          reject: (_row, error) => { throw error; },
        });
        try {
          cohort.admit(row); expect(await cohort.advance({ maxTokens: 1 })).toBe(true);
          expect(starts).toEqual([prefix.length]); expect(row.cachedTokens).toBe(prefix.length);
          expect(output[1]).toEqual(output[0]);
          expect(state(cache.findExact(prefix, namespace)!.caches)).toEqual(before);
        } finally { cohort.dispose(); }
      } finally { disposeResources(donor); cache.clear(); }
    }, 120_000);

});
