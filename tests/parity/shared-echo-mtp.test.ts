import { afterAll, describe, expect, spyOn, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxPrefixCache, CheckpointAttachment } from "../../src/backends/mlx/checkpoint-state";

const path = process.env.MLX_BUN_TEST_SHARED_ECHO_MODEL;
const draft = process.env.MLX_BUN_TEST_SHARED_ECHO_DRAFT;
describe.skipIf(!path || !draft)("shared echo with MTP", async () => {
  if (!path || !draft) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { disposeAttachments } = await import("../../src/backends/mlx/checkpoint-state");
  const { leaseCacheState } = await import("../../src/backends/mlx/state-views");
  const { withResource } = await import("../../src/engine/resources");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { createRuntimeConfig } = await import("../../src/runtime-config");
  const { FillSession } = await import("../../src/fill/fill-session");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const samplerModule = await import("../../src/sampler");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(path), model = createModel(weights, await loadModelConfig(path));
  const provider = await QwenMtpProvider.load(draft), method = bindSpeculativeGroupRequests(model, provider, 2);
  afterAll(() => { provider.dispose(); weights.dispose(); });
  const makeSampler = samplerModule.makeStepSampler;
  const hash = (a: import("../../src/mlx/array").MlxArray) => {
    using contiguous = ops.contiguous(a);
    return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
  };
  const state = (caches: ReturnType<typeof model.makeCache>) => caches.map(cache =>
    withResource(leaseCacheState(cache), arrays => ({ offset: cache.offset, signature: cache.signature(),
      arrays: arrays.map(a => {
        const s = a.shape;
        using live = cache.signature() !== "ssm" && s.length === 4 && cache.offset < s[2]!
          ? a.slice([0, 0, 0, 0], [s[0]!, s[1]!, cache.offset, s[3]!]) : null;
        return { dtype: a.dtype, hash: hash(live ?? a) };
      }) })));
  const attachmentState = (entries: CheckpointAttachment[] = []) => entries.map(a =>
    ({ schema: a.schema, metadata: a.metadata, tensors: a.tensors.map(hash) }));
  for (const [B, format] of [[1, "kv4"], [2, "kv4"], [4, "kv4"], [2, "k8v3"],
    [2, "kv4-delayed"], [2, "k8v3-delayed"]] as const)
    test(`${format} B${B} sampled echo, rejection, retirement and paired SSD state`, async () => {
      const quantizedKvStart = format.endsWith("delayed") ? 12 : 0;
      const scheme = resolveKvScheme(format.startsWith("kv") ? { override: 4, quantizedKvStart }
        : { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart });
      let baseline: number[][] = [];
      for (const arm of ["baseline", "echo", "reject", "stop"] as const) {
        let held = true;
        type Checkpoint = { tokens: number[]; caches: ReturnType<typeof model.makeCache>; attachments: CheckpointAttachment[]; retain?: () => void };
        const checkpoints = new Map<number, Checkpoint>();
        const dispose = (c: Checkpoint) => { c.caches.forEach(a => a.dispose()); disposeAttachments(c.attachments); c.retain?.(); };
        const cache: MlxPrefixCache = { take: () => null, put(tokens, caches, _ns, retain, attachments) {
          const row = tokens[0]! - 30, previous = checkpoints.get(row);
          if (previous) dispose(previous);
          checkpoints.set(row, { tokens, caches, attachments: attachments ?? [], retain });
        } };
        const group = new MlxBatchExecutionGroup(model, { maxBatch: B, kvScheme: scheme, promptCache: cache,
          runtime: createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0" }), admissionHeld: () => held,
          kvBatchCapabilities: { delayedAffine: true } });
        const output = Array.from({ length: B }, () => [] as number[]), selected = output.map(() => [] as number[]);
        const fills: InstanceType<typeof FillSession>[] = [], proposed: { start: number; ids: number[] }[] = [];
        const probe = spyOn(samplerModule, "makeStepSampler").mockImplementation(((options, config) => {
          if (config.tokenRepresentation !== "number") throw Error("Expected speculative number sampler");
          const row = options.seed! - 42, actual = makeSampler(options, config), reference = makeSampler(options, config);
          return { ...actual, async sample(scores, step) {
            expect(step).toBe(selected[row]!.length);
            const result = await actual.sample(scores, step), expected = await reference.sample(scores, step);
            expect(result.token).toBe(expected.token); selected[row]!.push(result.token);
            return result;
          }, dispose() { actual.dispose(); reference.dispose(); } };
        }) as typeof samplerModule.makeStepSampler);
        try {
          const jobs = output.map((tokens, row) => {
            const prompt = Array.from({ length: 7 }, (_, i) => 30 + row + i);
            let offered = false;
            const fill = new FillSession({ rows: [], echo: null, eos: [] }, prompt, { sources:
              arm === "baseline" || (B === 4 && row === B - 1) ? [] : [{ name: "saved-copy", propose(view) {
                const start = view.length - prompt.length;
                if (offered || start < 3) return null;
                offered = true;
                const ids = baseline[row]!.slice(start, start + 6);
                if (arm === "reject") ids[0] = ids[0] === 0 ? 1 : 0;
                proposed[row] = { start, ids };
                return { ids, policy: "verify", origin: "echo" };
              } }] });
            fills.push(fill);
            return group.submit({ promptIds: prompt, maxTokens: 32, eosTokenIds: [],
              onToken(token) { tokens.push(token); if (arm === "stop" && row === 0 && tokens.length === 8) return false; },
              method: method({ ...scheme.generationOptions, fill, seed: 42 + row,
                temperature: 0.6, topP: 0.95, presencePenalty: 0.2, repetitionPenalty: 1.05 }) });
          });
          held = false; group.kick(); const results = await Promise.all(jobs);
          if (arm === "baseline") baseline = output;
          else if (arm !== "reject") expect(fills.reduce((n, fill) => n + fill.stats.verifyEvents, 0)).toBeGreaterThan(0);
          else expect(fills.reduce((n, fill) => n + fill.stats.verifyEvents, 0)).toBe(0);
          if (arm === "reject") expect(output).toEqual(baseline);
          for (const [row, tokens] of output.entries()) {
            expect(tokens).toEqual(selected[row]!.slice(0, tokens.length));
            expect(tokens.length).toBe(arm === "stop" && row === 0 ? 8 : 32);
            expect(results[row]!.spec?.drafted).toBeGreaterThan(0);
            const spec = results[row]!.spec!;
            expect(spec.acceptanceLengths!.length).toBe(spec.rounds!);
            expect(spec.acceptanceLengths!.reduce((sum, n) => sum + n, 0)).toBe(spec.accepted);
            const cp = checkpoints.get(row)!, history = [...Array.from({ length: 7 }, (_, i) => 30 + row + i), ...tokens];
            expect(cp.tokens).toEqual(history.slice(0, cp.tokens.length));
            expect(cp.tokens.length).toBeGreaterThanOrEqual(history.length - 1);
            expect(cp.caches.map(c => c.offset)).toEqual(cp.caches.map(() => cp.tokens.length));
            expect(cp.attachments[0]!.metadata.draftOffset).toBe(cp.tokens.length - 1);
            const proposal = proposed[row];
            if (proposal) {
              let accepted = 0;
              while (accepted < proposal.ids.length && tokens[proposal.start + accepted] === proposal.ids[accepted]) accepted++;
              expect(fills[row]!.stats.verifyAccepted).toBe(accepted);
            }
            if (B !== 2 || arm === "baseline") continue;
            const dir = mkdtempSync(join(tmpdir(), "mlx-bun-echo-mtp-state-"));
            try {
              const options = { dir, maxBytes: 4 * 2 ** 30, configFingerprint: "echo-mtp-test", tokenizerHash: "ids", modelId: path, verify: true };
              expect(new SsdCacheStore(options).store(cp.tokens, cp.caches, "", cp.attachments)).toBe(true);
              const reader = new SsdCacheStore(options); expect(reader.scan()).toBe(1);
              const hit = reader.find([...cp.tokens, 911], "")!;
              const restored = reader.restore(hit.entry, model)!;
              try {
                expect(restored.tokens).toEqual(cp.tokens);
                expect(state(restored.caches)).toEqual(state(cp.caches));
                expect(attachmentState(restored.attachments)).toEqual(attachmentState(cp.attachments));
                for (const token of [911, 912]) {
                  using actual = model.forward([token], restored.caches), reference = model.forward([token], cp.caches);
                  expect(hash(actual)).toBe(hash(reference));
                }
              } finally { restored.caches.forEach(c => c.dispose()); disposeAttachments(restored.attachments); }
            } finally { rmSync(dir, { recursive: true, force: true }); }
          }
        } finally { await group.close(); probe.mockRestore(); for (const cp of checkpoints.values()) dispose(cp); }
      }
    }, 180_000);
});
