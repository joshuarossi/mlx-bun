// Gemma4 paged KV through the shared execution group on real weights. Full
// attention layers live in block pools (`--paged-kv`); requests enter through
// the public gateway binding (plan, statePolicy, createBatchGroup), as the app
// composes them. Two readers: the gathered arm (block gather into stock SDPA;
// for bf16 pages this is main's bit-exact contract against plain KV) and the
// direct Metal reader (MLX_BUN_PAGED_ATTN=1, Lab numerics). Pages store bf16 or
// affine KV4/KV8, encoded from their first token; sliding layers follow the
// server-wide scheme, as `--kv-quant 4|8 --paged-kv` composes them.
// Checked within this tree:
// - gathered bf16 pages equal plain KV at B1 and B3, block sizes 16 and 256:
//   tokens, every sampled full-vocabulary vector, and each retired row's valid
//   K/V in every layer (main's paged-kv-parity contract, extended to KV planes);
// - direct reads at B3 over bf16, KV4 and KV8 pages: the direct kernel actually
//   serves decode (queries of at most 8 tokens without an array mask), every
//   sampled vector is finite, and greedy tokens equal the gathered arm's
//   (main's model-level acceptance; the reduction is Lab numerics, so vectors
//   are not compared);
// - cancellation for every encoding and reader: a row aborted mid-decode in a
//   B3 cohort rejects with its reason and publishes nothing after the abort,
//   while the survivors' tokens and vectors equal a control that stops that row
//   at the same token; after the drain the same group reproduces a fresh B1 run;
// - durable reuse for every encoding and reader (main's paged-cache-http
//   acceptance): a repeated prompt restores its paged prefix from RAM, then,
//   after a durable flush, from a fresh SSD store through the asynchronous
//   prefetch; the restored caches are pages of the same encoding and reader,
//   the disk run equals the RAM run in tokens and vectors, and both produce the
//   cold run's tokens.
// Not covered: equality with main or an external oracle (main's own plain path
// is the bf16 oracle), HTTP cancellation, media and adapter requests (they
// bypass paging), fresh-process restore, speed.
// Opt in with MLX_BUN_TEST_PAGED_MODEL=/gemma4/snapshot (any Gemma4 artifact).
// Unset skips; a blank value or a non-Gemma4 artifact fails. No downloads.
import { expect, spyOn, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import { releaseAll, sha256 } from "./real-weight-inputs";

type A = any;
const MODEL = "MLX_BUN_TEST_PAGED_MODEL";
const TOKENS = 12, RETIRE_AT = 5;
const ENCODINGS = ["bf16", 4, 8] as const;
const READERS = ["gathered", "direct"] as const;
type Encoding = typeof ENCODINGS[number];
type Reader = typeof READERS[number];

// ---- opt-in and prompts (no native libraries) ----------------------------------------------
export function optIn(env: Record<string, string | undefined>) {
  const model = env[MODEL];
  if (model === undefined) return null;
  if (!model.trim()) throw new Error(`${MODEL} is blank`);
  assert(existsSync(join(model, "config.json")), `${MODEL}: no config.json in ${model}`);
  const raw = JSON.parse(readFileSync(join(model, "config.json"), "utf8"));
  assert(String(raw.model_type).startsWith("gemma4"), `paged KV binds Gemma4 graphs only, not ${raw.model_type}`);
  const vocab = (raw.text_config ?? raw).vocab_size;
  assert(Number.isSafeInteger(vocab) && vocab > 4000, `${MODEL}: invalid vocab_size ${vocab}`);
  return { model, vocab: vocab as number };
}

/** Deterministic IDs away from the vocabulary's special range. Each prompt
 * starts with its own first token, so no two prompts share a reusable prefix. */
function ids(seed: number, length: number, vocab: number): number[] {
  let s = seed >>> 0;
  return Array.from({ length }, (_, i) => i === 0 ? 1000 + seed
    : 2000 + ((s = (Math.imul(s, 1664525) + 1013904223) >>> 0) % (vocab - 4000)));
}
/** Three unequal prompts that cross block boundaries (block 256: past the first
 * block, as main's 280-token rows did), and one reuse prompt long enough for the
 * shared group's prompt snapshot (taken at the last prompt position from 256). */
export function promptsFor(blockSize: number, vocab: number) {
  return { rows: [0, 1, 2].map(row => ids(11 + row, blockSize + 24 + 17 * row, vocab)),
    reuse: ids(29, 256 + 2 * blockSize + 9, vocab) };
}

// ---- recording (native) ------------------------------------------------------------------
interface Tensor { shape: number[]; dtype: string; sha: string }
interface LayerState { kind: string; offset: number; keys: Tensor; values: Tensor }
interface Outcome {
  status: "fulfilled" | "rejected"; reason?: string; finish?: string; generated?: number; cached?: number;
  tokens: number[]; vectors: string[]; finite: boolean; afterRetire: number;
}
interface RowSpec { prompt: number[]; retire?: "abort" | "stop" }
interface Setup { encoding: Encoding; reader: Reader; paged: boolean; blockSize: number }
interface RunOptions {
  /** Prompt cache for the group and the paged state policy. */
  cache?: A;
  /** Record each retired row's valid K/V (rows then carry a cache session). */
  states?: boolean;
  /** Prefetch each prompt through its request namespace first, as the app does. */
  prefetch?: boolean;
  /** One more request on the same group after the cohort drained. */
  after?: RowSpec;
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("Gemma4 paged KV: gathered bf16 equals plain KV; direct reads, cancellation and RAM/SSD reuse per encoding", async () => {
  const ops = await import("@mlx-bun/mlx/ops");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const { loadModelConfig, Weights, createModel } = await import("@mlx-bun/inference");
  const { bindMlxGateway, createRuntimeConfig, withRuntimeConfig } = await import("@mlx-bun/inference/execution");
  const { PromptCache, TieredPromptCache, SsdCacheStore, KVCache, RotatingKVCache, cloneKvCaches, resolveKvScheme } =
    await import("@mlx-bun/inference/state");
  const { PagedKVCache } = await import("@mlx-bun/inference/state/paged");
  const { model: path, vocab } = inputs!;
  const tensor = (a: MlxArray): Tensor => {
    using c = ops.contiguous(a);
    return { shape: [...c.shape], dtype: c.dtypeName, sha: sha256(c.rawBytesView()) };
  };
  /** A retired row's valid K/V per layer: pages gathered to the offset, plain
   * and rotating caches through their chronological view. */
  const rowState = (caches: readonly Cache[]): LayerState[] => caches.map(cache => {
    const owned: MlxArray[] = [];
    const own = (a: MlxArray) => { owned.push(a); return a; };
    try {
      if (cache instanceof PagedKVCache) {
        const [k, v] = cache.pool!.gather(cache.blockTable).map(own) as [MlxArray, MlxArray];
        const cut = (a: MlxArray) => own(a.slice([0, 0, 0, 0], [1, a.shape[1]!, cache.offset, a.shape[3]!]));
        return { kind: "full", offset: cache.offset, keys: tensor(cut(k)), values: tensor(cut(v)) };
      }
      if (cache instanceof KVCache || cache instanceof RotatingKVCache) {
        const [k, v] = cache.temporalView().map(own) as [MlxArray, MlxArray];
        return { kind: cache instanceof KVCache ? "full" : "rotating", offset: cache.offset, keys: tensor(k), values: tensor(v) };
      }
      throw new Error(`unexpected retired cache ${cache.signature()}`);
    } finally { releaseAll(owned.map(a => () => a.dispose())); }
  });

  const config = await loadModelConfig(path);
  const weights = await Weights.open(path);
  const releases: (() => void)[] = [];
  try {
    const model = createModel(weights, config) as A;
    const layers = (() => { const probe: Cache[] = model.makeCache(); try { return probe.length; } finally { releaseAll(probe.map(c => () => c.dispose())); } })();
    const runtimeFor = (reader: Reader) => createRuntimeConfig({ MLX_BUN_COMPILED_DECODE: "0",
      MLX_BUN_PAGED_ATTN: reader === "direct" ? "1" : "0" });
    // Direct dispatch accounting: every view a direct page hands to attention.
    let directCalls = 0;
    const appendAndFetch = PagedKVCache.prototype.appendAndFetch;
    PagedKVCache.prototype.appendAndFetch = function (this: A, k: MlxArray, v: MlxArray) {
      const view = appendAndFetch.call(this, k, v);
      if (!this.direct) return view;
      return { attend(q: MlxArray, scale: number, mask: A) {
        if (q.shape[2]! <= 8 && mask.mode !== "array") directCalls++;
        return view.attend(q, scale, mask);
      }, dispose() { view.dispose(); } };
    };
    releases.push(() => { PagedKVCache.prototype.appendAndFetch = appendAndFetch; });

    /** One execution group per call, bound under the reader's runtime. Rows
     * submit while admission is held, then release together (a real cohort). */
    const runGroup = async (setup: Setup, rows: RowSpec[], opts: RunOptions = {}) => {
      const runtime = runtimeFor(setup.reader);
      const binding = withRuntimeConfig(runtime, () => bindMlxGateway(model));
      const scheme = setup.encoding === "bf16" ? undefined : resolveKvScheme({ override: setup.encoding });
      const options: A = { ...(scheme?.generationOptions ?? {}), ...(setup.paged ? { pagedKv: { blockSize: setup.blockSize } } : {}) };
      const quantizedBatch = scheme ? binding.kvBatchable(scheme) : false;
      assert(!scheme || quantizedBatch, `${scheme?.label} must batch on this graph`);
      const plan = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
        kvQuant: !!scheme, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false },
      options, { continuous: true, quantizedBatch, checkpoints: false });
      assert.equal(plan.mechanism, "continuous", `placement: ${plan.reasons.join(", ")}`);
      assert.equal(plan.pagedKv, setup.paged);
      if (opts.cache) binding.configureContinuation!({ promptCache: opts.cache, checkpoints: null, identity: "gemma4-paged",
        adapterNamespace: (adapters: string[]) => adapters.join(","), cloneState: (caches: Cache[]) => cloneKvCaches(caches) } as A);
      const policy = (prompt: number[]) => binding.statePolicy!(plan, options, prompt.length + TOKENS);
      const states = new Map<string, LayerState[]>();
      const put = opts.cache?.put.bind(opts.cache);
      const putSpy = opts.states ? spyOn(opts.cache, "put").mockImplementation((...args: A[]) => {
        if (typeof args[5] === "string") states.set(args[5], rowState(args[1]));
        return put(...args);
      }) : undefined;
      const prefetched: (() => void)[] = [];
      let held = true;
      const group = binding.createBatchGroup({ maxBatch: 3, runtime, prefillChunkSize: 2048, admissionHeld: () => held,
        ...(scheme ? { kvScheme: scheme } : {}), ...(opts.cache ? { promptCache: opts.cache } : {}) });
      const submit = (row: RowSpec, index: number): Promise<Outcome> => {
        const out: Outcome = { status: "fulfilled", tokens: [], vectors: [], finite: true, afterRetire: 0 };
        const controller = new AbortController();
        let retired = false;
        return group.submit({ promptIds: row.prompt, maxTokens: TOKENS, eosTokenIds: [], compiledDecode: false,
          ...(opts.states ? { cacheSessionId: `row-${index}`, snapshotAt: 0 } : {}),
          statePolicy: policy(row.prompt), signal: controller.signal,
          sample(logits: MlxArray) {
            using exact = ops.contiguous(logits);
            out.vectors.push(sha256(exact.rawBytesView()));
            if (!exact.toFloat32().every(Number.isFinite)) out.finite = false;
            return ops.argmaxAxis(logits, -1);
          },
          onToken(token: number) {
            if (retired) { out.afterRetire++; return; }
            out.tokens.push(token);
            if (row.retire && out.tokens.length === RETIRE_AT) {
              retired = true;
              if (row.retire === "stop") return false;
              controller.abort(new Error("cancelled consumer"));
            }
          } }).then((stats: A) => Object.assign(out, { finish: stats.finishReason, generated: stats.generatedTokens, cached: stats.cachedTokens }),
          (error: unknown) => Object.assign(out, { status: "rejected" as const, reason: (error as Error)?.message ?? String(error) }));
      };
      try {
        if (opts.prefetch) for (const row of rows) prefetched.push(await policy(row.prompt)!.promptCache!.prefetch!(row.prompt, ""));
        const pending = rows.map((row, index) => submit(row, index));
        held = false; group.kick();
        const outcomes = await Promise.all(pending);
        expect(group.activeRows + group.pendingRows).toBe(0);
        const after = opts.after ? await submit(opts.after, rows.length) : undefined;
        return { outcomes, after, states: rows.map((_, index) => states.get(`row-${index}`)) };
      } finally {
        releaseAll(prefetched);
        putSpy?.mockRestore();
        await group.close(); clearCache();
      }
    };
    const label = (setup: Setup) => `${setup.paged ? `paged ${setup.reader}` : "plain"} ${setup.encoding} block ${setup.blockSize}`;
    const completed = (setup: Setup, outcomes: Outcome[]) => {
      for (const outcome of outcomes) expect({ setup: label(setup), status: outcome.status, finish: outcome.finish,
        generated: outcome.generated, finite: outcome.finite })
        .toEqual({ setup: label(setup), status: "fulfilled", finish: "length", generated: TOKENS, finite: true });
    };

    // 1. Gathered bf16 pages equal plain KV (B1 and B3, both block sizes).
    for (const blockSize of [16, 256]) {
      const { rows } = promptsFor(blockSize, vocab);
      for (const batch of [1, 3]) {
        const cohort = rows.slice(0, batch).map(prompt => ({ prompt }));
        const record = async (paged: boolean) => {
          const cache = new PromptCache(2 * 1024 ** 3);
          try {
            const setup: Setup = { encoding: "bf16", reader: "gathered", paged, blockSize };
            const result = await runGroup(setup, cohort, { cache, states: true });
            completed(setup, result.outcomes);
            result.states.forEach((state, row) => {
              // Every layer retired at one offset covering the prompt and the fed tokens.
              expect(state?.length).toBe(layers);
              const offsets = new Set(state!.map(layer => layer.offset));
              expect(offsets.size).toBe(1);
              expect([...offsets][0]!).toBeGreaterThanOrEqual(cohort[row]!.prompt.length + TOKENS - 1);
              expect(state!.some(layer => layer.kind === "full")).toBe(true);
            });
            return { tokens: result.outcomes.map(o => o.tokens), vectors: result.outcomes.map(o => o.vectors), states: result.states };
          } finally { cache.clear(); }
        };
        const plain = await record(false), paged = await record(true);
        expect({ blockSize, batch, paged }).toEqual({ blockSize, batch, paged: plain });
        console.log(`[paged] gathered bf16 equals plain KV: block ${blockSize}, B${batch}`);
      }
    }

    const { rows, reuse } = promptsFor(16, vocab);
    for (const encoding of ENCODINGS) {
      // 2. Direct reads serve decode and keep the gathered arm's greedy tokens.
      const gatheredSetup: Setup = { encoding, reader: "gathered", paged: true, blockSize: 16 };
      const directSetup: Setup = { ...gatheredSetup, reader: "direct" };
      const gathered = await runGroup(gatheredSetup, rows.map(prompt => ({ prompt })));
      const before = directCalls;
      const direct = await runGroup(directSetup, rows.map(prompt => ({ prompt })));
      completed(gatheredSetup, gathered.outcomes); completed(directSetup, direct.outcomes);
      expect(directCalls - before).toBeGreaterThan(0);
      expect({ encoding, direct: direct.outcomes.map(o => o.tokens) }).toEqual({ encoding, direct: gathered.outcomes.map(o => o.tokens) });
      console.log(`[paged] direct ${encoding}: ${directCalls - before} direct attention calls; tokens equal the gathered arm`);

      for (const reader of READERS) {
        const setup: Setup = { encoding, reader, paged: true, blockSize: 16 };
        // 3. Cancellation against a same-shaped stop control, then recovery on the drained group.
        const fresh = await runGroup(setup, [{ prompt: rows[0]! }]);
        const stop = await runGroup(setup, rows.map((prompt, row) => ({ prompt, ...(row === 1 ? { retire: "stop" as const } : {}) })));
        const abort = await runGroup(setup, rows.map((prompt, row) => ({ prompt, ...(row === 1 ? { retire: "abort" as const } : {}) })),
          { after: { prompt: rows[0]! } });
        completed(setup, fresh.outcomes);
        expect(stop.outcomes[1]).toMatchObject({ status: "fulfilled", finish: "stop", generated: RETIRE_AT, afterRetire: 0 });
        expect(abort.outcomes[1]).toMatchObject({ status: "rejected", reason: "cancelled consumer", afterRetire: 0 });
        expect(abort.outcomes[1]!.tokens).toEqual(stop.outcomes[1]!.tokens);
        for (const row of [0, 2]) {
          completed(setup, [abort.outcomes[row]!, stop.outcomes[row]!]);
          expect({ setup: label(setup), row, abort: [abort.outcomes[row]!.tokens, abort.outcomes[row]!.vectors] })
            .toEqual({ setup: label(setup), row, abort: [stop.outcomes[row]!.tokens, stop.outcomes[row]!.vectors] });
        }
        completed(setup, [abort.after!]);
        expect({ setup: label(setup), recovered: [abort.after!.tokens, abort.after!.vectors] })
          .toEqual({ setup: label(setup), recovered: [fresh.outcomes[0]!.tokens, fresh.outcomes[0]!.vectors] });

        // 4. Durable reuse: cold, RAM, then a fresh SSD store after a durable flush.
        const directory = mkdtempSync(join(tmpdir(), "gemma4-paged-"));
        const storeOptions = { dir: directory, maxBytes: 4 * 1024 ** 3, modelId: path, configFingerprint: "gemma4-paged",
          tokenizerHash: "gemma4-paged", verify: true, storage: { layout: "blocks" as const } };
        const tier = (store: A, async: boolean) => ({
          find(tokens: number[], ns: string) { const hit = store.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
          restore(handle: A) { const hit = store.restore(handle, model); return hit ? { ...hit, retain() {} } : null; },
          ...(async ? { async restoreAsync(handle: A) { const hit = await store.restoreAsync(handle, model); return hit ? { ...hit, retain() {} } : null; } } : {}),
          store: (tokens: number[], caches: Cache[], ns: string, attachments: A) => store.store(tokens, caches, ns, attachments),
        });
        // Each SSD restore's caches, observed as the store hands them over.
        const restored: Cache[][] = [];
        const observe = (name: "restore" | "restoreAsync") => {
          const original = SsdCacheStore.prototype[name] as A;
          return spyOn(SsdCacheStore.prototype, name).mockImplementation(function (this: A, ...args: A[]) {
            const note = (loaded: A) => { if (loaded) restored.push([...loaded.caches]); return loaded; };
            const result = original.apply(this, args);
            return result instanceof Promise ? result.then(note) : note(result);
          } as A);
        };
        const spies = [observe("restore"), observe("restoreAsync")];
        const ssd = new SsdCacheStore(storeOptions), cache = new TieredPromptCache(4 * 1024 ** 3, ssd, tier(ssd, false));
        let disk: A;
        try {
          const [cold] = (await runGroup(setup, [{ prompt: reuse }], { cache })).outcomes;
          const [warm] = (await runGroup(setup, [{ prompt: reuse }], { cache })).outcomes;
          expect((await cache.durability.flush()).durable).toBe(true);
          expect(cache.spillQueue.pendingBytes).toBe(0);
          cache.clear();
          const restarted = new SsdCacheStore(storeOptions);
          expect(restarted.scan()).toBeGreaterThan(0);
          disk = new PromptCache(4 * 1024 ** 3, null, tier(restarted, true));
          restored.length = 0;
          const [fromDisk] = (await runGroup(setup, [{ prompt: reuse }], { cache: disk, prefetch: true })).outcomes;
          completed(setup, [cold!, warm!, fromDisk!]);
          expect(cold!.cached).toBe(0);
          expect(warm!.cached).toBeGreaterThan(0);
          expect(fromDisk!.cached).toBe(warm!.cached);
          expect({ setup: label(setup), disk: [fromDisk!.tokens, fromDisk!.vectors] })
            .toEqual({ setup: label(setup), disk: [warm!.tokens, warm!.vectors] });
          expect({ setup: label(setup), warm: warm!.tokens }).toEqual({ setup: label(setup), warm: cold!.tokens });
          expect(restored.length).toBeGreaterThan(0);
          for (const caches of restored) {
            const pages = caches.filter(layer => layer instanceof PagedKVCache) as A[];
            expect(pages.length).toBeGreaterThan(0);
            for (const page of pages) expect({ direct: page.direct, bits: page.quantization?.bits ?? "bf16" })
              .toEqual({ direct: reader === "direct", bits: encoding });
          }
          console.log(`[paged] ${label(setup)}: cancellation, recovery and RAM/SSD reuse (${warm!.cached} cached tokens)`);
        } finally {
          for (const spy of spies) spy.mockRestore();
          try { await cache.durability.flush(); }
          finally { cache.clear(); disk?.clear(); rmSync(directory, { recursive: true, force: true }); }
        }
      }
    }
  } finally {
    try { releaseAll(releases.reverse()); }
    finally {
      try { weights.dispose(); }
      finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()).concat([() => clearCache()])); }
    }
  }
}, 3_600_000);

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in: unset skips; blank or non-Gemma4 artifacts fail (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [MODEL]: " " })).toThrow("blank");
  expect(() => optIn({ [MODEL]: "/nonexistent-paged-model" })).toThrow("no config.json");
});

test("prompts are unequal, cross block boundaries and share no prefix (CPU only)", () => {
  for (const blockSize of [16, 256]) {
    const { rows, reuse } = promptsFor(blockSize, 262_144);
    expect(rows.map(row => row.length)).toEqual([0, 1, 2].map(row => blockSize + 24 + 17 * row));
    expect(rows.every(row => row.length > blockSize)).toBe(true);
    expect(reuse.length).toBeGreaterThan(256 + 2 * blockSize);
    const firsts = [...rows, reuse].map(row => row[0]);
    expect(new Set(firsts).size).toBe(firsts.length);
    expect([...rows, reuse].flat().every(id => id >= 1000 && id < 262_144 - 2000)).toBe(true);
    expect(promptsFor(blockSize, 262_144)).toEqual({ rows, reuse });
  }
});
