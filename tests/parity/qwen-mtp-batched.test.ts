import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("Qwen MTP graph with request-owned positions", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { MtpModule } = await import("../../src/spec/qwen-mtp-module");
  const { KVCache } = await import("../../src/model/gemma4-base");
  const { BatchedKVCache } = await import("../../src/model/batched-kv");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const digest = (array: InstanceType<typeof MlxArray>) => {
    using data = ops.contiguous(array);
    return createHash("sha256").update(data.rawBytesView()).digest("hex");
  };
  const rowDigest = (array: InstanceType<typeof MlxArray>, row: number) => {
    const lo = array.shape.map(() => 0), hi = [...array.shape]; lo[0] = row; hi[0] = row + 1;
    using view = array.slice(lo, hi); return digest(view);
  };

  test("singleton and batched forwards use the same graph across unequal prefix retention", async () => {
    const path = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    using resources = new DisposableStack();
    const weights = await Weights.open(path); resources.defer(() => weights.dispose());
    const config = await loadModelConfig(path), module = new MtpModule(weights, config, resources);
    const H = config.text.hiddenSize;
    const input = (rows: number, length: number, phase: number) => {
      using f = MlxArray.fromFloat32(Float32Array.from({ length: rows * length * H },
        (_, index) => Math.sin(index * 0.013 + phase) * 0.2), [rows, length, H]);
      return f.astype(Dtype.bfloat16);
    };
    const seeds = [new KVCache(), new KVCache()], base = new BatchedKVCache();
    try {
      for (const [row, length] of [3, 7].entries()) {
        using embeds = input(1, length, row * 0.4), hidden = input(1, length, row * 0.7);
        using output = module.forward(embeds, hidden, seeds[row]!); digest(output);
        const singleton = new BatchedKVCache(); singleton.mergeRows([seeds[row]!]);
        try {
          using nextE = input(1, 1, 1.1), nextH = input(1, 1, 1.7);
          using expected = module.forward(nextE, nextH, seeds[row]!);
          using actual = module.forward(nextE, nextH, singleton);
          expect(digest(actual)).toBe(digest(expected));
        } finally { singleton.dispose(); }
      }
      base.mergeRows(seeds);
      const clone = () => { const result = new BatchedKVCache(); result.mergeRows([base]); return result; };
      using embeds = input(2, 4, 2.1), hidden = input(2, 4, 2.7);
      using nextE = input(2, 1, 3.1), nextH = input(2, 1, 3.7);
      for (const kept of [[1, 4], [4, 1], [2, 3], [4, 4]]) {
        const actual = clone();
        try {
          actual.specRoundBegin(); module.forward(embeds, hidden, actual).dispose(); actual.specRoundRollback(kept);
          using output = module.forward(nextE, nextH, actual);
          for (let row = 0; row < 2; row++) {
            const reference = clone();
            try {
              reference.specRoundBegin(); module.forward(embeds, hidden, reference).dispose();
              reference.specRoundRollback(kept[row]!);
              using expected = module.forward(nextE, nextH, reference);
              expect(rowDigest(output, row)).toBe(rowDigest(expected, row));
              const a = actual.extractRow(row), b = reference.extractRow(row);
              try {
                expect(a.offset).toBe(b.offset);
                expect(digest(a.keys!)).toBe(digest(b.keys!));
                expect(digest(a.values!)).toBe(digest(b.values!));
              } finally { a.dispose(); b.dispose(); }
            } finally { reference.dispose(); }
          }
        } finally { actual.dispose(); }
      }
    } finally { for (const seed of seeds) seed.dispose(); base.dispose(); clearCache(); }
  }, 120000);

  test("device-chained draft rows preserve request controls at B=1 and host-read controls at the same B", async () => {
    const { Qwen35Model } = await import("../../src/model/qwen3_5");
    const { QwenMtpSource } = await import("../../src/spec/qwen-mtp-source");
    const { QwenMtpRows } = await import("../../src/spec/qwen-mtp-rows");
    const { makeSampler } = await import("../../src/sampler");
    using resources = new DisposableStack();
    const targetPath = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draftPath = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const targetWeights = await Weights.open(targetPath); resources.defer(() => targetWeights.dispose());
    const model = new Qwen35Model(targetWeights, await loadModelConfig(targetPath));
    const draftWeights = await Weights.open(draftPath); resources.defer(() => draftWeights.dispose());
    const config = await loadModelConfig(draftPath), module = new MtpModule(draftWeights, config, resources);
    const H = config.text.hiddenSize;
    const target = { hiddenSize: H, layerCount: model.layers.length,
      embed: model.embed.encode.bind(model.embed), logitsFromHidden: model.logitsFromHidden.bind(model) };
    const context = (B: number, length: number, phase: number) => {
      using f = MlxArray.fromFloat32(Float32Array.from({ length: B * length * H },
        (_, index) => Math.sin(index * 0.013 + phase) * 0.2), [B, length, H]);
      return f.astype(Dtype.bfloat16);
    };
    for (const seeded of [false, true]) for (const B of [1, 2]) for (const depth of [1, 2, 4]) {
      const controls: InstanceType<typeof QwenMtpSource>[] = [];
      const state: Array<{ cache: InstanceType<typeof KVCache>; hidden: InstanceType<typeof MlxArray> }> = [];
      let group: InstanceType<typeof QwenMtpRows> | null = null;
      let hostRead: InstanceType<typeof QwenMtpRows> | null = null;
      const processed = Array.from({ length: B }, (_, row) => row ? 7 : 3);
      let rowOrder = Array.from({ length: B }, (_, row) => row);
      const samplerFor = (row: number) => makeSampler(seeded
        ? { temperature: 0.7, topK: 20, topP: 0.9, seed: 100 + row }
        : { temperature: 0 });
      const samplers = Array.from({ length: B }, (_, row) => samplerFor(row));
      const sampleRows = (lp: InstanceType<typeof MlxArray>, steps: readonly number[]) => {
        const tokens: InstanceType<typeof MlxArray>[] = [];
        try {
          for (let row = 0; row < rowOrder.length; row++) {
            using scores = lp.slice([row, 0], [row + 1, lp.shape[1]!]);
            tokens.push(samplers[rowOrder[row]!]!(scores, steps[row]!));
          }
          return ops.concatAxis(tokens, 0);
        } finally { for (const token of tokens) token.dispose(); }
      };
      try {
        for (let row = 0; row < B; row++) {
          const source = new QwenMtpSource(target, module, samplerFor(row)); controls.push(source);
          const length = processed[row]!;
          await source.prefill(Array.from({ length }, (_, token) => token + 1 + row * 10), context(1, length, row * 0.3));
          const attachment = source.checkpoint.capture(length);
          const cache = new KVCache(); cache.restoreState(attachment.tensors[0]!, attachment.tensors[1]!, length - 1);
          state.push({ cache, hidden: attachment.tensors[2]! });
        }
        group = new QwenMtpRows(target, module, { sample: sampleRows }, state);
        if (B > 1) hostRead = new QwenMtpRows(target, module, { sample(lp, steps) {
          using token = sampleRows(lp, steps);
          return ops.fromInt32(token.toIntTokens(), [lp.shape[0]!]);
        } }, state);
        for (let round = 0; round < 3; round++) {
          const pending = Array.from({ length: B }, (_, row) => 31 + round + row * 10);
          const steps = processed.map(length => length - 2);
          const proposals = group.draft(pending, depth, steps);
          const expected: number[][] = hostRead ? hostRead.draft(pending, depth, steps) : [];
          if (!hostRead) for (let row = 0; row < B; row++) expected.push(await controls[row]!.draft([pending[row]!], depth, steps[row]!));
          expect(proposals).toEqual(expected);
          const accepted = Array.from({ length: B }, (_, row) => (round + row) % 2 ? depth : 0);
          using verified = context(B, depth + 1, round + 1.1);
          group.commit(accepted, verified);
          hostRead?.commit(accepted, verified);
          for (let row = 0; row < B; row++) {
            const kept = accepted[row]!;
            processed[row]! += kept + 1;
            const actual = group.extractRow(row);
            const tensors: InstanceType<typeof MlxArray>[] = [];
            let referenceCache: InstanceType<typeof KVCache> | null = null;
            try {
              if (hostRead) {
                const reference = hostRead.extractRow(row); referenceCache = reference.cache;
                tensors.push(...reference.cache.temporalView(), reference.hidden);
              } else {
                const oneContext = verified.slice([row, 0, 0], [row + 1, depth + 1, H]);
                await controls[row]!.commit(depth, kept, oneContext, undefined, expected[row]!.slice(0, kept));
                tensors.push(...controls[row]!.checkpoint.capture(processed[row]!).tensors);
              }
              expect(actual.cache.offset).toBe(processed[row]! - 1);
              expect(digest(actual.cache.keys!)).toBe(digest(tensors[0]!));
              expect(digest(actual.cache.values!)).toBe(digest(tensors[1]!));
              expect(digest(actual.hidden)).toBe(digest(tensors[2]!));
            } finally {
              actual.cache.dispose(); actual.hidden.dispose(); referenceCache?.dispose();
              for (const array of tensors) array.dispose();
            }
          }
        }
        if (hostRead) {
          const saved = group.extractRow(0), savedReference = hostRead.extractRow(0);
          try {
            group.filterRows([1]); hostRead.filterRows([1]); rowOrder = [1];
            expect(group.draft([71], depth, [10])).toEqual(hostRead.draft([71], depth, [10]));
            using oneContext = context(1, depth + 1, 4.1);
            group.commit([0], oneContext); hostRead.commit([0], oneContext);
            group.append([saved]); hostRead.append([savedReference]); rowOrder = [1, 0];
            expect(group.rowCount).toBe(2);
            expect(group.draft([81, 91], depth, [11, 12])).toEqual(hostRead.draft([81, 91], depth, [11, 12]));
            using twoContext = context(2, depth + 1, 4.7);
            group.commit([0, depth], twoContext); hostRead.commit([0, depth], twoContext);
            for (let row = 0; row < 2; row++) {
              const actual = group.extractRow(row), reference = hostRead.extractRow(row);
              try {
                expect(actual.cache.offset).toBe(reference.cache.offset);
                expect(digest(actual.cache.keys!)).toBe(digest(reference.cache.keys!));
                expect(digest(actual.cache.values!)).toBe(digest(reference.cache.values!));
                expect(digest(actual.hidden)).toBe(digest(reference.hidden));
              } finally {
                actual.cache.dispose(); actual.hidden.dispose(); reference.cache.dispose(); reference.hidden.dispose();
              }
            }
            group.filterRows([]); hostRead.filterRows([]);
            group.append([saved]); hostRead.append([savedReference]); rowOrder = [0];
            expect(group.draft([101], depth, [13])).toEqual(hostRead.draft([101], depth, [13]));
          } finally {
            saved.cache.dispose(); saved.hidden.dispose(); savedReference.cache.dispose(); savedReference.hidden.dispose();
          }
        }
      } finally {
        group?.dispose(); hostRead?.dispose(); for (const source of controls) source.dispose();
        for (const row of state) { row.cache.dispose(); row.hidden.dispose(); }
      }
    }
  }, 180000);

  test("zero-proposal rounds retain the same companion state as a rejected depth-one round", async () => {
    const { QwenMtpRows } = await import("../../src/spec/qwen-mtp-rows");
    using resources = new DisposableStack();
    const path = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const weights = await Weights.open(path); resources.defer(() => weights.dispose());
    const config = await loadModelConfig(path), module = new MtpModule(weights, config, resources);
    const H = config.text.hiddenSize;
    const context = (B: number, T: number) => {
      using values = MlxArray.fromFloat32(Float32Array.from({ length: B * T * H },
        (_, i) => Math.sin(i * 0.017) * 0.2), [B, T, H]);
      return values.astype(Dtype.bfloat16);
    };
    const target = { hiddenSize: H, layerCount: 1,
      embed(ids: InstanceType<typeof MlxArray>) { return ops.zeros([ids.shape[0]!, ids.shape[1]!, H], Dtype.bfloat16); },
      logitsFromHidden(hidden: InstanceType<typeof MlxArray>) {
        return ops.zeros([hidden.shape[0]!, hidden.shape[1]!, 16], Dtype.bfloat16);
      },
    };
    for (const B of [1, 2, 4]) {
      const states = Array.from({ length: B }, (_, row) => {
        const cache = new KVCache(), length = row + 3;
        using embeds = ops.zeros([1, length, H], Dtype.bfloat16), hidden = context(1, length);
        module.forward(embeds, hidden, cache).dispose();
        return { cache, hidden: context(1, 1) };
      });
      const zero = new QwenMtpRows({ ...target,
        logitsFromHidden() { throw new Error("zero round projected draft logits"); },
      }, module, { sample() { throw new Error("zero round sampled"); } }, states);
      const control = new QwenMtpRows(target, module, { sample: lp => ops.argmaxAxis(lp, -1) }, states);
      try {
        const pending = Array.from({ length: B }, (_, row) => row + 1), steps = pending.map(() => 7);
        expect(zero.draft(pending, 0, steps)).toEqual(pending.map(() => []));
        control.draft(pending, 1, steps);
        using full = context(B, 2), prefix = full.slice([0, 0, 0], [B, 1, H]);
        zero.commit(pending.map(() => 0), prefix); control.commit(pending.map(() => 0), full);
        for (let row = 0; row < B; row++) {
          const actual = zero.extractRow(row), expected = control.extractRow(row);
          try {
            expect(actual.cache.offset).toBe(row + 4);
            expect(digest(actual.cache.keys!)).toBe(digest(expected.cache.keys!));
            expect(digest(actual.cache.values!)).toBe(digest(expected.cache.values!));
            expect(digest(actual.hidden)).toBe(digest(expected.hidden));
          } finally { actual.cache.dispose(); actual.hidden.dispose(); expected.cache.dispose(); expected.hidden.dispose(); }
        }
      } finally { zero.dispose(); control.dispose(); for (const state of states) { state.cache.dispose(); state.hidden.dispose(); } }
    }
  }, 120000);

});
