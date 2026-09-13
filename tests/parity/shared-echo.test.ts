// Audit the sampler and wire against the exact scores produced by each
// verification geometry. A sequential target is not a same-geometry oracle.
import { afterAll, describe, expect, spyOn, test } from "bun:test";
import type { GenerateOptions } from "../../src/generate";
import type { MlxPrefixCache } from "../../src/backends/mlx/checkpoint-state";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const path = process.env.MLX_BUN_TEST_SHARED_FILL_MODEL;
describe.skipIf(!path)("shared echo verification", async () => {
  if (!path) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindFillGroupRequests } = await import("../../src/backends/mlx/fill-group");
  const samplerModule = await import("../../src/sampler");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { FillSession } = await import("../../src/fill/fill-session");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const config = await loadModelConfig(path), weights = await Weights.open(path);
  const model = createModel(weights, config), method = bindFillGroupRequests(model);
  const makeSampler = samplerModule.makeStepSampler;
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { leaseCacheState } = await import("../../src/backends/mlx/state-views");
  const { withResource } = await import("../../src/engine/resources");
  const ops = await import("../../src/mlx/ops");
  const digest = (a: import("../../src/mlx/array").MlxArray) => {
    using value = ops.contiguous(a);
    return createHash("sha256").update(value.rawBytesView()).digest("hex");
  };
  const state = (caches: ReturnType<typeof model.makeCache>) => caches.map(cache =>
    withResource(leaseCacheState(cache), arrays => ({ offset: cache.offset, signature: cache.signature(),
      arrays: arrays.map(a => {
        const shape = a.shape;
        using live = cache.signature() !== "ssm" && shape.length === 4 && cache.offset < shape[2]!
          ? a.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        return { dtype: a.dtype, hash: digest(live ?? a) };
      }),
    })));
  afterAll(() => weights.dispose());
  const runtime = createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" });

  for (const B of [1, 2, 4]) for (const format of ["bf16", "kv4", "k8v3", "kv4-delayed", "k8v3-delayed"] as const)
    test(`${format} B${B} exact-score sampling, rejection and retirement`, async () => {
      const quantizedKvStart = format.endsWith("delayed") ? 12 : 0;
      const scheme = resolveKvScheme(format.startsWith("kv") ? { override: 4, quantizedKvStart }
        : format.startsWith("k") ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart } : {});
      let baseline: number[][] = [];
      for (const arm of ["empty", "verify", "reject-first", "reject-tail", "mixed", "stop"] as const) {
        let held = true;
        const checkpoints = new Map<number, { tokens: number[]; caches: ReturnType<typeof model.makeCache>; retain?: () => void }>();
        const cache: MlxPrefixCache = { take: () => null, put(tokens, caches, _ns, retain) {
          const row = tokens[0]! - 30, previous = checkpoints.get(row);
          previous?.caches.forEach(c => c.dispose()); previous?.retain?.();
          checkpoints.set(row, { tokens, caches, retain });
        } };
        const group = new MlxBatchExecutionGroup(model, { maxBatch: B, runtime, kvScheme: scheme,
          promptCache: cache, admissionHeld: () => held, kvBatchCapabilities: { delayedAffine: true } });
        const selected = Array.from({ length: B }, () => [] as number[]);
        const output = Array.from({ length: B }, () => [] as number[]);
        const fills: InstanceType<typeof FillSession>[] = [], proposals: number[][] = [];
        const probe = spyOn(samplerModule, "makeStepSampler").mockImplementation(((options, samplerConfig) => {
          const row = options.seed! - 42;
          if (samplerConfig.tokenRepresentation !== "device") throw new Error("Unexpected sampler in fill binding");
          const actual = makeSampler(options, samplerConfig);
          const reference = makeSampler(options, { ...samplerConfig, historyUpdate: "after-sample" });
          return { ...actual, sample(scores, step) {
            expect(step, `${arm} row ${row} sampling position`).toBe(selected[row]!.length);
            const result = actual.sample(scores, step);
            const expected = reference.sample(scores, selected[row]!.length);
            try {
              const token = expected.token.toIntTokens()[0]!;
              expect(result.token.toIntTokens()[0]!, `${arm} row ${row} exact scores/history`).toBe(token);
              selected[row]!.push(token);
            } finally { expected.token.dispose(); }
            return result;
          }, dispose() { reference.dispose(); actual.dispose(); } };
        }) as typeof samplerModule.makeStepSampler);
        try {
          const requests = output.map((tokens, row) => {
            const prompt = Array.from({ length: 7 }, (_, i) => 30 + row + i);
            const options: GenerateOptions = { ...scheme.generationOptions, temperature: 0.6, topP: 0.95,
              seed: 42 + row, presencePenalty: 0.2, repetitionPenalty: 1.05 };
            const ids = baseline[row]?.slice(3, 8) ?? [];
            if (arm === "reject-first") ids[0] = ids[0] === 0 ? 1 : 0;
            if (arm === "reject-tail") ids[2] = ids[2] === 0 ? 1 : 0;
            proposals.push(ids);
            const fill = new FillSession({ rows: [], echo: null, eos: [] }, prompt, {
              sources: arm === "empty" || (arm === "mixed" && row === B - 1) ? [] : [{
                name: "saved-echo", propose: view => view.length === prompt.length + 3
                  ? { ids, policy: "verify", origin: "echo" } : null,
              }],
            });
            fills.push(fill);
            return group.submit({ promptIds: prompt, maxTokens: 24, eosTokenIds: [],
              onToken(token) { tokens.push(token); if (arm === "stop" && row === 0 && tokens.length === 5) return false; },
              method: method({ ...options, fill }) });
          });
          held = false; group.kick(); await Promise.all(requests);
          if (arm === "empty") baseline = output;
          for (const [row, tokens] of output.entries()) {
            expect(tokens).toEqual(selected[row]!.slice(0, tokens.length));
            expect(tokens.length).toBe(arm === "stop" && row === 0 ? 5 : 24);
            const checkpoint = checkpoints.get(row)!;
            const history = [...Array.from({ length: 7 }, (_, i) => 30 + row + i), ...tokens];
            expect(checkpoint.tokens).toEqual(history.slice(0, checkpoint.tokens.length));
            expect(checkpoint.tokens.length).toBeGreaterThanOrEqual(history.length - 1);
            expect(checkpoint.tokens.length).toBeLessThanOrEqual(history.length);
            expect(checkpoint.caches.map(c => c.offset)).toEqual(checkpoint.caches.map(() => checkpoint.tokens.length));
            if (B === 2 && ["verify", "reject-tail", "stop"].includes(arm)) {
              const dir = mkdtempSync(join(tmpdir(), "mlx-bun-echo-state-"));
              const options = { dir, maxBytes: 4 * 2 ** 30, configFingerprint: "echo-test", tokenizerHash: "ids", modelId: path, verify: true };
              const ram = cloneKvCaches(checkpoint.caches);
              let restored: ReturnType<InstanceType<typeof SsdCacheStore>["restore"]> = null;
              try {
                expect(new SsdCacheStore(options).store(checkpoint.tokens, checkpoint.caches)).toBe(true);
                const reader = new SsdCacheStore(options); expect(reader.scan()).toBe(1);
                const hit = reader.find([...checkpoint.tokens, 911], "");
                expect(hit?.prefixLen).toBe(checkpoint.tokens.length);
                restored = reader.restore(hit!.entry, model);
                expect(restored).not.toBeNull(); expect(restored!.tokens).toEqual(checkpoint.tokens);
                expect(state(restored!.caches)).toEqual(state(ram));
                for (const token of [911, 912]) {
                  using actual = model.forward([token], restored!.caches);
                  using reference = model.forward([token], ram);
                  expect(digest(actual)).toBe(digest(reference));
                  expect(state(restored!.caches)).toEqual(state(ram));
                }
              } finally {
                ram.forEach(c => c.dispose()); restored?.caches.forEach(c => c.dispose());
                rmSync(dir, { recursive: true, force: true });
              }
            }
            if (arm === "empty" || (arm === "mixed" && row === B - 1)) continue;
            const proposal = proposals[row]!;
            let accepted = 0;
            while (accepted < proposal.length && tokens[3 + accepted] === proposal[accepted]) accepted++;
            expect(fills[row]!.stats.verifyAccepted).toBe(accepted);
            expect(fills[row]!.stats.verifyRejected).toBe(proposal.length - accepted);
            expect(fills[row]!.stats.echo).toBe(accepted);
          }
        } finally {
          await group.close(); probe.mockRestore();
          for (const checkpoint of checkpoints.values()) { checkpoint.caches.forEach(c => c.dispose()); checkpoint.retain?.(); }
        }
      }
    }, 120_000);
});
