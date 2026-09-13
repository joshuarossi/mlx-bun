// Same-B media continuation: independent CPU position construction versus the
// request-owned device position path, including padding and row retirement.
import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import type { MlxArray } from "../../src/mlx/array";
import type { Cache } from "../../src/model/gemma4-base";
import type { MlxDecodeState } from "../../src/backends/mlx/prompt-input";
import type { MropeRequestState } from "../../src/model/qwen3-mrope";

const path = process.env.MLX_BUN_TEST_QWEN_MEDIA_MODEL;
describe.skipIf(!path)("Qwen request-owned media positions", async () => {
  if (!path) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindQwenMediaInput } = await import("../../src/backends/mlx/qwen-prompt-input");
  const { bindEmbeddingsInput } = await import("../../src/backends/mlx/prompt-input");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const { mropePositionIds } = await import("../../src/model/qwen3-mrope");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(path), model = new Qwen35Model(weights, await loadModelConfig(path));
  afterAll(() => weights.dispose());
  const hash = (value: MlxArray) => {
    using contiguous = ops.contiguous(value);
    return { shape: value.shape, dtype: value.dtype,
      sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") };
  };
  function state(length: number, row: number): MropeRequestState {
    return { delta: -2 - row, positions: [0, 1, 2].map(axis =>
      Int32Array.from({ length }, (_, i) => i < 2 ? i : i < 5 ? 2 + (axis + row + i) % 2 : i - 2 - row)) as MropeRequestState["positions"] };
  }
  type ReferenceState = MlxDecodeState & { delta: number };
  function referenceDecode(delta: number): ReferenceState {
    return { key: "qwen-cpu-position-reference", delta,
      forward(ids: MlxArray, caches: Cache[], rows: readonly MlxDecodeState[]) {
        const B = rows.length, L = ids.shape[1]!, cache = caches[model.faIdx]!;
        const offsetArray = (cache as Cache & { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
        const offsets = offsetArray?.toIntTokens() ?? Array(B).fill(cache.offset);
        const joint: number[] = [];
        for (let axis = 0; axis < 3; axis++) for (let row = 0; row < B; row++)
          for (let i = 0; i < L; i++) joint.push(offsets[row]! + (rows[row] as ReferenceState).delta + i);
        using positions = ops.fromInt32(joint, [3, B, L]);
        return model.forwardHiddenAtPositions(ids, caches, positions);
      },
    };
  }
  for (const B of [1, 2, 4]) for (const format of ["bf16", "kv4-delayed", "k8v3-delayed"] as const) {
    test(`${format} B${B} unequal prompts and retirement preserve every logit vector`, async () => {
      const scheme = resolveKvScheme(format === "kv4-delayed" ? { override: 4, quantizedKvStart: 12 }
        : format === "k8v3-delayed" ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 12 } : {});
      const arms: unknown[] = [];
      for (const reference of [true, false]) {
        let held = true;
        const group = new MlxBatchExecutionGroup(model, { maxBatch: B, kvScheme: scheme,
          kvBatchCapabilities: { delayedAffine: true }, admissionHeld: () => held,
          runtime: createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" }) });
        const owned: MlxArray[] = [], widths: number[] = [];
        const original = model.forwardHiddenAtPositions.bind(model);
        model.forwardHiddenAtPositions = (ids, caches, positions) => {
          widths.push(ids.shape[0]!); return original(ids, caches, positions);
        };
        const logits = Array.from({ length: B }, () => [] as ReturnType<typeof hash>[]);
        const tokens = Array.from({ length: B }, () => [] as number[]);
        try {
          const requests = tokens.map((output, row) => {
            const length = [7, 17, 9, 19][row]!;
            const prompt = Array.from({ length }, (_, i) => 40 + row + i), positions = state(length, row);
            using ids = ops.fromInt32(prompt, [1, length]);
            const embeddings = model.embed.encode(ids); owned.push(embeddings);
            const input = reference ? { ...bindEmbeddingsInput((ids, caches) => {
              using nativePositions = mropePositionIds(positions, 0, ids.shape[1]!);
              return model.forwardEmbeddingsAtPositions(embeddings, caches, nativePositions);
            }), decodeState: referenceDecode(positions.delta) } : bindQwenMediaInput(model, embeddings, positions);
            return group.submit({ promptIds: prompt, promptInput: input,
              maxTokens: [12, 8, 10, 9][row]!, eosTokenIds: [],
              sample(value, step) { logits[row]!.push(hash(value)); return ops.fromInt32([123 + row * 20 + step], [1]); },
              onToken(token) { output.push(token); },
            });
          });
          held = false; group.kick();
          await Promise.all(requests);
          expect(Math.max(...widths)).toBe(B);
          expect(widths.at(-1)).toBe(1);
          expect(model.mrope).toBeNull();
          arms.push({ logits, tokens, widths });
        } finally {
          await group.close(); model.forwardHiddenAtPositions = original;
          for (const value of owned) value.dispose();
        }
      }
      expect(arms[1]).toEqual(arms[0]);
    }, 120_000);
  }
  for (const format of ["bf16", "kv4-delayed", "k8v3-delayed"] as const)
    test(`${format} retained media prefix preserves recurrent state and positioned continuation`, async () => {
      const { PromptCache } = await import("../../src/prompt-cache");
      const { cloneKvCaches } = await import("../../src/kv-store");
      const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
      const { MlxPrefillCohort } = await import("../../src/backends/mlx/prefill-cohort");
      const { leaseCacheStates } = await import("../../src/backends/mlx/state-views");
      const { withResource, disposeResources } = await import("../../src/engine/resources");
      const prefix = Array.from({ length: 17 }, (_, i) => 40 + i), tail = [90, 91, 92, 93, 94, 95, 96];
      const prompt = [...prefix, ...tail], positions = state(prompt.length, 0);
      using ids = ops.fromInt32(prefix, [1, prefix.length]);
      using embeddings = model.embed.encode(ids);
      using initialPositions = mropePositionIds(positions, 0, prefix.length);
      const maintain = createKvMaintenance(format === "bf16" ? {} : format === "kv4-delayed"
        ? { kvBits: 4, quantizedKvStart: 8 } : { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 8 });
      const donor = model.makeCache(), cache = new PromptCache(8e9), namespace = `qwen-media-${format}`;
      const cachesHash = (caches: Cache[]) => caches.map(c => ({ signature: c.signature(), offset: c.offset,
        arrays: withResource(leaseCacheStates([c]), values => values.map(value => {
          const shape = value.shape;
          using live = shape.length === 4 && shape[2]! > c.offset
            ? value.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, c.offset, shape[3]!]) : null;
          return hash(live ?? value);
        })) }));
      const output: unknown[] = [];
      const finish = (caches: Cache[], logits: MlxArray) => {
        const first = { logits: hash(logits), caches: cachesHash(caches) };
        maintain(caches);
        using next = ops.fromInt32([123], [1, 1]);
        using pos = ops.fromInt32(Array(3).fill(prompt.length + positions.delta), [3, 1, 1]);
        using hidden = model.forwardHiddenAtPositions(next, caches, pos);
        using result = model.logitsFromHidden(hidden);
        return { first, next: { logits: hash(result), caches: cachesHash(caches) } };
      };
      try {
        maintain(donor);
        using initial = model.forwardEmbeddingsAtPositions(embeddings, donor, initialPositions); initial.eval();
        cache.put(prefix, cloneKvCaches(donor), namespace);
        const before = cachesHash(cache.findExact(prefix, namespace)!.caches);
        maintain(donor);
        using tailIds = ops.fromInt32(tail, [1, tail.length]);
        using tailPositions = mropePositionIds(positions, prefix.length, tail.length);
        using hidden = model.forwardHiddenAtPositions(tailIds, donor, tailPositions);
        using tip = hidden.slice([0, tail.length - 1, 0], [1, tail.length, hidden.shape[2]!]);
        using logits = model.logitsFromHidden(tip); output.push(finish(donor, logits));
        const row = {
          req: { promptIds: prompt, cacheNamespace: namespace, maxTokens: 1, eosTokenIds: [],
            sample: () => { throw new Error("unused"); }, onToken() {},
            promptInput: bindQwenMediaInput(model, embeddings, positions) },
          cacheNamespace: namespace, resolve() {}, reject(error: unknown) { throw error; },
          current: 0, generated: 0, sampled: 0, promptTokens: prompt.length, cachedTokens: 0,
          admittedAt: 0, firstTokenAt: 0, fed: [], fedTainted: false, merged: false,
        } satisfies import("../../src/backends/mlx/batch-group").Row;
        const cohort = new MlxPrefillCohort({ model, chunkSize: 2, tailSplit: true, maintain, promptCache: cache,
          forward: async () => { throw new Error("generic prefill selected"); }, project: h => model.logitsFromHidden(h),
          async complete(value, lg) { output.push(finish(value.solo, lg)); disposeResources(value.solo); },
          reject: (_row, error) => { throw error; },
        });
        try {
          cohort.admit(row); expect(await cohort.advance({ maxTokens: 1 })).toBe(true);
          expect(row.cachedTokens).toBe(prefix.length); expect(output[1]).toEqual(output[0]);
          expect(cachesHash(cache.findExact(prefix, namespace)!.caches)).toEqual(before);
          expect(model.mrope).toBeNull();
        } finally { cohort.dispose(); }
      } finally { disposeResources(donor); cache.clear(); }
    }, 120_000);

});
