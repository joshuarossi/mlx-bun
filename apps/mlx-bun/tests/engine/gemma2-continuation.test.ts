// Opt-in with real weights: Gemma2 plain-KV generation continuation through the
// app's own serving composition, as `serve --ssd-cache DIR --generation-checkpoint 4`
// builds it: createCacheServices, configureContinuation, and the app engine's
// gateway place/run with checkpoints enabled. Runs only with MLX_BUN_TEST_NATIVE=1
// and MLX_BUN_APP_TEST_GEMMA2_MODEL naming a cached gemma2 snapshot (for example
// mlx-community/gemma-2-2b-it-4bit); loads the model natively on the GPU. The SSD
// directories are temporary. For greedy and for seeded, repetition-penalized
// sampling:
//   control: an uninterrupted request captures a continuation snapshot per
//     interval (its prefix, KV, next token and seed), and after completion no
//     record of it remains durable;
//   interrupted: the same request cancelled after ten tokens captures the
//     control's snapshots up to that point, flushes durably, and leaves a record
//     equal to its latest snapshot;
//   restart: fresh cache services and a fresh engine over that directory select
//     exactly that record, restore it once (restored KV equals the snapshot's),
//     replay the saved prefix and reproduce the control's complete output and
//     every later snapshot; after completion no record remains.
// Snapshots are compared where they are captured (the persistence queue's
// enqueue), not by disk writes: completion may cancel queued writes.
// The restart shares this process's loaded model; a fresh-process restart and
// the comparison against main run outside the repository. This is preservation
// within the tree, not an external-oracle claim, and no cross-version checkpoint
// compatibility is promised.
import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import type { GenerateOptions } from "@mlx-bun/inference/generation";
import type { RequestShape } from "../../src/engine/completion";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_GEMMA2_MODEL;

test.skipIf(!native || !modelDir)("Gemma2 plain-KV generation checkpoints survive cancellation, restore and clean up through the app engine", async () => {
  const ops = await import("@mlx-bun/mlx/ops");
  const { loadContext } = await import("../../src/engine/model-host");
  const { modelServingBinding } = await import("../../src/engine/model-serving");
  const { createCacheServices } = await import("../../src/engine/cache-services");
  const { createAppEngine } = await import("../../src/engine/index");
  const context = await loadContext(modelDir!);
  const root = mkdtempSync(join(tmpdir(), "gemma2-continuation-"));
  const prompt = [2, 105, 2364, 107, 1567, 506, 2390, 107];
  const interval = 4, maxTokens = 16, interruptAt = 10;
  // Valid KV positions of every layer; allocation beyond the offset is excluded.
  const digest = (caches: Cache[]) => {
    const hash = new Bun.CryptoHasher("sha256");
    for (const cache of caches) {
      const [keys, values] = (cache as unknown as { temporalView(): [MlxArray, MlxArray] }).temporalView();
      try {
        for (const plane of [keys, values]) {
          using exact = ops.contiguous(plane);
          hash.update(JSON.stringify(plane.shape)); hash.update(exact.rawBytes());
        }
      } finally { keys.dispose(); values.dispose(); }
    }
    return hash.digest("hex");
  };
  type Snapshot = { key: string; tokens: number[]; generatedTokens: number; pendingToken: number; seed: number;
    seedWasExplicit: boolean; kv: string };
  try {
    expect(context.model.config.modelType).toBe("gemma2");
    for (const [name, sampling, shape] of [
      ["greedy", { temperature: 0 }, {}],
      ["seeded", { temperature: 0.7, repetitionPenalty: 1.1, repetitionContextSize: 32 }, { hasRepetitionPenalty: true }],
    ] as const) {
      const options = (): GenerateOptions => ({ maxTokens, prefillChunkSize: 512, eosTokenIds: [], seed: 42,
        seedWasExplicit: true, ...sampling });
      const requestShape: RequestShape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
        userSeed: true, kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false,
        wantsLogprobs: false, hasDraft: false, ...shape };
      /** One serve lifetime over `dir`: cache services, continuation, engine, one request, close. */
      const serve = async (dir: string, interrupt: boolean) => {
        const binding = await modelServingBinding(context);
        const caches = await createCacheServices(context, binding, { ssdCacheDir: dir, generationCheckpointTokens: interval });
        const store = caches.checkpoints!, persistence = caches.continuationServices.checkpointPersistence!;
        const snapshots: Snapshot[] = [], removed: string[] = [], restored: { tokens: number[]; kv: string }[] = [];
        const enqueue = persistence.enqueue.bind(persistence);
        persistence.enqueue = (attempt, state, meta) => {
          snapshots.push({ key: meta.key, tokens: [...state.cacheTokens], generatedTokens: meta.generatedTokens,
            pendingToken: meta.pendingToken, seed: meta.seed, seedWasExplicit: meta.seedWasExplicit, kv: digest(state.caches) });
          enqueue(attempt, state, meta);
        };
        const removeRecords = store.removeGenerationCheckpoints.bind(store);
        store.removeGenerationCheckpoints = key => { removed.push(key); removeRecords(key); };
        const restore = store.restore.bind(store);
        store.restore = (entry, model) => {
          const loaded = restore(entry, model);
          if (loaded) restored.push({ tokens: [...loaded.tokens], kv: digest(loaded.caches) });
          return loaded;
        };
        binding.gateway.configureContinuation!(caches.continuationServices);
        let flushed: Awaited<ReturnType<typeof caches.close>> | undefined;
        const engine = await createAppEngine(context, { capacity: 4, binding, ownership: "borrowed",
          gateway: { checkpoints: true, stateCodecs: caches.stateCodecs, kvScheme: caches.resolvedKvScheme,
            promptCache: caches.promptCache, adapterNamespace: caches.adapterNamespace },
          beforeModelDispose: async () => { flushed = await caches.close(); } });
        const tokens: number[] = [], abort = new AbortController();
        let outcome: unknown;
        try {
          const placement = engine.gateway.place(requestShape, options());
          expect(placement.execution).toMatchObject({ method: "autoregressive", mechanism: "continuous",
            promptCache: true, checkpoint: true, fill: false, pagedKv: false });
          outcome = await engine.gateway.run(prompt, options(), token => {
            tokens.push(token);
            if (interrupt && tokens.length === interruptAt) abort.abort(new Error("interrupted by test"));
          }, undefined, requestShape, placement, abort.signal).then(stats => stats, error => error);
        } finally { await engine.close(); }
        return { tokens, outcome, snapshots, removed, restored, flushed };
      };
      /** A fresh store over `dir`: the generation record a restart would select. */
      const durable = async (dir: string, key: string) => {
        const binding = await modelServingBinding(context);
        const caches = await createCacheServices(context, binding, { ssdCacheDir: dir, generationCheckpointTokens: interval });
        try { return caches.checkpoints!.findGenerationCheckpoint(prompt, key, ""); }
        finally { expect((await caches.close()).durable).toBe(true); }
      };

      const controlDir = join(root, `${name}-control`), restartDir = join(root, `${name}-restart`);
      const control = await serve(controlDir, false);
      expect(control.outcome, name).toMatchObject({ generatedTokens: maxTokens });
      expect(control.tokens).toHaveLength(maxTokens);
      expect(control.flushed?.durable).toBe(true);
      // One snapshot per interval inside the budget, each the control's own
      // prefix, its next token and the explicit seed.
      const generated = control.snapshots.map(snapshot => snapshot.generatedTokens);
      expect(generated.length).toBeGreaterThanOrEqual(2);
      expect(generated.every((count, index) => count >= (index + 1) * interval && count < (index + 2) * interval &&
        count < maxTokens)).toBe(true);
      const key = control.snapshots[0]!.key;
      for (const snapshot of control.snapshots) {
        expect(snapshot).toMatchObject({ key, seed: 42, seedWasExplicit: true, pendingToken: control.tokens[snapshot.generatedTokens] });
        expect(snapshot.tokens).toEqual([...prompt, ...control.tokens.slice(0, snapshot.generatedTokens)]);
      }
      expect(control.restored).toEqual([]);
      // Completion leaves no record of the request.
      expect(control.removed).toContain(key);
      expect(await durable(controlDir, key)).toBeNull();

      const interrupted = await serve(restartDir, true);
      expect(interrupted.outcome).toBeInstanceOf(Error);
      expect((interrupted.outcome as Error).message).toBe("interrupted by test");
      expect(interrupted.tokens).toEqual(control.tokens.slice(0, interruptAt));
      expect(interrupted.flushed?.durable).toBe(true);
      const before = control.snapshots.filter(snapshot => snapshot.generatedTokens < interruptAt);
      expect(before.length).toBeGreaterThanOrEqual(1);
      expect(interrupted.snapshots).toEqual(before);
      // Cancellation keeps the latest snapshot as the durable record.
      expect(interrupted.removed).not.toContain(key);
      const last = interrupted.snapshots.at(-1)!;
      const saved = await durable(restartDir, key);
      expect(saved?.tokens).toEqual(last.tokens);
      expect(saved?.generationCheckpoint).toMatchObject({ key, cacheNs: "", originalPromptTokens: prompt.length,
        generatedTokens: last.generatedTokens, pendingToken: last.pendingToken, seed: 42, seedWasExplicit: true });

      // Fresh services and engine: exactly that record restores once, the
      // replayed prefix plus the continuation equal the control's output, and
      // every later snapshot (prefix, pending token and KV) equals the control's.
      const restart = await serve(restartDir, false);
      expect(restart.outcome).toMatchObject({ generatedTokens: maxTokens });
      expect(restart.restored).toEqual([{ tokens: last.tokens, kv: last.kv }]);
      expect(restart.tokens).toEqual(control.tokens);
      expect(restart.snapshots).toEqual(control.snapshots.filter(snapshot => snapshot.generatedTokens > last.generatedTokens));
      expect(restart.flushed?.durable).toBe(true);
      expect(restart.removed).toContain(key);
      expect(await durable(restartDir, key)).toBeNull();
    }
  } finally {
    context.dispose();
    rmSync(root, { recursive: true, force: true });
  }
}, 900_000);
