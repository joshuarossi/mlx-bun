// Grouped speculation through the public gateway binding on real weights: a
// built-in draft provider over its target, with plain, affine, TurboQuant or
// per-layer KV and an optional delayed start. Requests are placed by the
// binding's plan and bound through methodRequest, then run in the binding's
// execution group, as the app composes them. Checked within this tree:
// - placement: the configured provider/target/KV combination resolves to
//   continuous speculation (a refusal fails with the plan's reasons);
// - B1 equals the serial producer (`specServeRun`) in tokens and draft counts
//   when that producer serves the settings (no per-layer KV, start 0, no custom
//   window, whose wrap ends its speculation), or repeats exactly otherwise; B4
//   cohorts (submitted under an admission hold, released together) prefill as
//   one cohort, repeat exactly and run real rounds;
// - retirement in a B4 cohort: a stop, a consumer failure and an abort at exact
//   counts, no token published after retirement, a survivor to its budget, a
//   drained group, and EOS on the first token; a late joiner with a longer prompt and a joiner
//   admitted during the first prefill chunk, each repeating exactly;
// - companion state: the B4 prefix cohort prefills together; a repeated prompt
//   restores its prompt snapshot with the draft attachment from RAM; stopped and
//   finished rows publish generated prefixes with the provider's attachment, cancelled and failed rows none;
//   continuations restore them from RAM, repeatably and without mutating the
//   stored entries, and, after a durable flush and a provider reload, from a
//   fresh SSD store with identical tokens and entry digests;
// - with MLX_BUN_TEST_SPEC_ADAPTER, multi-row adapter requests with the draft
//   configured: every adapter row is served, speculating only through a
//   provider that supports target adapters and otherwise decoding ordinarily
//   with the draft ignored; the adapter changes the B1 control's logprobs; each
//   row equals its B1 control without a draft (greedy tokens), seeded B4 cohorts
//   repeat, groups never mix adapter contexts, a failing row leaves its peers intact, and prefix reuse stays
//   isolated by adapter. Drafted base rows join these checks where placement
//   serves them; delayed affine KV on MiniCPM5 and encoded Universal graphs
//   refuses them by design (genuine delayed speculation is excluded).
// The first two tests require a combination placement serves; run only the
// adapter test with --test-name-pattern "adapter rows" for such a KV setting.
// Not covered: equality with main or an external oracle, HTTP, speed.
// KIND=glm-mtp is GLM-5.2's checkpoint-native MTP (`--mtp on`), mounted as
// the app's model host mounts it (`apps/mlx-bun/src/engine/model-host.ts`): the
// Colibri runtime opened with the MTP tier planned for one drafting lane, and
// Glm52NativeMtpProvider over that target at the plan's draft depth (the default
// depth here). It takes no draft artifact and only plain KV (see optIn).
// Observers wrap the target forward the bindings call, forwardHiddenAsync where
// the graph provides one (the streamed GLM target), otherwise forwardHidden.
// Opt in with all of
//   MLX_BUN_TEST_SPEC_TARGET=/target/snapshot
//   MLX_BUN_TEST_SPEC_KIND=ngram|two-model|assistant|mtp|dspark|deepspec|glm-mtp
//   MLX_BUN_TEST_SPEC_DRAFT=/draft/snapshot   (every kind but ngram and glm-mtp, which take none)
// and optionally
//   MLX_BUN_TEST_SPEC_KV=bf16|4|8|turbo|config   (config: the target's kv_config.json)
//   MLX_BUN_TEST_SPEC_KV_START=<n>                (default 0)
//   MLX_BUN_TEST_SPEC_DEPTH=<n>                   (default 2, and 3 for prefixes;
//                                                 glm-mtp: the memory plan's MTP draft depth)
//   MLX_BUN_TEST_SPEC_WINDOW=<n>   a custom graph over a Llama-family target's unchanged
//                                  weights: alternating sliding (window n) and full layers
//                                  (not a published model)
//   MLX_BUN_TEST_SPEC_ADAPTER=/adapter/dir        (holds adapters.safetensors)
// None set skips; a partial or invalid opt-in fails before native libraries load.
import { expect, spyOn, test } from "bun:test";
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";

type A = any;
const PREFIX = "MLX_BUN_TEST_SPEC_";
const NAMES = ["TARGET", "KIND", "DRAFT", "KV", "KV_START", "DEPTH", "WINDOW", "ADAPTER"] as const;
const KINDS = ["ngram", "two-model", "assistant", "mtp", "dspark", "deepspec", "glm-mtp"] as const;
/** Providers whose rows prefill the whole prompt (prefillMode "full"), so a
 * cohort submitted together prefills together before any row emits. */
const FULL_PREFILL: readonly Kind[] = ["mtp", "glm-mtp"];
const KVS = ["bf16", "4", "8", "turbo", "config"] as const;
type Kind = typeof KINDS[number];
type Kv = typeof KVS[number];

// ---- opt-in (no native libraries) ------------------------------------------------------
export function optIn(env: Record<string, string | undefined>) {
  const value = (name: typeof NAMES[number]) => env[PREFIX + name];
  if (NAMES.every(name => value(name) === undefined)) return null;
  for (const name of NAMES) if (value(name) !== undefined && !value(name)!.trim()) throw new Error(`${PREFIX}${name} is blank`);
  const target = value("TARGET"), kind = value("KIND") as Kind | undefined, draft = value("DRAFT");
  if (!target || !kind) throw new Error(`speculative group needs ${PREFIX}TARGET and ${PREFIX}KIND`);
  if (!KINDS.includes(kind)) throw new Error(`${PREFIX}KIND must be one of ${KINDS.join(", ")}`);
  if (kind === "ngram" && draft !== undefined) throw new Error(`${PREFIX}KIND=ngram is model-free; drop ${PREFIX}DRAFT`);
  if (kind === "glm-mtp" && draft !== undefined) throw new Error(`${PREFIX}KIND=glm-mtp is checkpoint-native; drop ${PREFIX}DRAFT`);
  if (kind !== "ngram" && kind !== "glm-mtp" && draft === undefined) throw new Error(`${PREFIX}KIND=${kind} needs ${PREFIX}DRAFT`);
  const kv = (value("KV") ?? "bf16") as Kv;
  if (!KVS.includes(kv)) throw new Error(`${PREFIX}KV must be one of ${KVS.join(", ")}`);
  const integer = (name: typeof NAMES[number], min: number) => {
    const raw = value(name);
    if (raw === undefined) return undefined;
    if (!/^\d+$/.test(raw.trim()) || Number(raw) < min) throw new Error(`${PREFIX}${name} must be an integer >= ${min}`);
    return Number(raw);
  };
  const start = integer("KV_START", 0) ?? 0, depth = integer("DEPTH", 1), window = integer("WINDOW", 1);
  if (start > 0 && kv === "bf16") throw new Error(`${PREFIX}KV_START needs a quantized ${PREFIX}KV`);
  for (const [name, dir] of [["TARGET", target], ["DRAFT", draft]] as const)
    if (dir !== undefined) assert(existsSync(join(dir, "config.json")), `${PREFIX}${name}: no config.json in ${dir}`);
  if (kind === "glm-mtp") {
    const raw = JSON.parse(readFileSync(join(target, "config.json"), "utf8"));
    assert.equal(raw.model_type, "glm_moe_dsa", `${PREFIX}KIND=glm-mtp needs a GLM-5.2 (glm_moe_dsa) target, not ${raw.model_type}`);
    // GLM's attention stores a compressed MLA latent cache, not plain or rotating
    // KV: no layer has an affine or TurboQuant conversion, so the gateway's
    // kvBatchable refuses every quantized scheme and the drafted placement these
    // tests require is refused. The KV matrix does not apply to this cache;
    // plain KV is its only layout.
    if (kv !== "bf16") throw new Error(`${PREFIX}KIND=glm-mtp takes plain KV only: GLM's MLA latent cache has no affine or TurboQuant conversion`);
  }
  if (window !== undefined) {
    const raw = JSON.parse(readFileSync(join(target, "config.json"), "utf8"));
    assert(["llama", "mistral"].includes(raw.model_type), `a custom window needs a Llama-family target, not ${raw.model_type}`);
  }
  const adapter = value("ADAPTER");
  if (adapter !== undefined) assert(existsSync(join(adapter, "adapters.safetensors")), `${PREFIX}ADAPTER: no adapters.safetensors in ${adapter}`);
  return { target, kind, draft, kv, start, depth, window, adapter };
}
type Inputs = NonNullable<ReturnType<typeof optIn>>;

/** The attachment a provider's generated prefix carries. */
export function attachmentMatches(kind: Kind, tokens: number, attachment: A): boolean {
  if (kind === "ngram") return attachment?.tensors?.[0]?.shape?.[0] === tokens;
  if (kind === "mtp") return attachment?.metadata?.draftOffset === tokens - 1;
  return attachment?.metadata?.processedTokens === tokens;
}

// ---- shared native setup ---------------------------------------------------------------
async function load(inputs: Inputs) {
  const { loadModelConfig, Weights, createModel, openGlm52RuntimeModel } = await import("@mlx-bun/inference");
  const speculative = await import("@mlx-bun/inference/generation/speculative");
  const { KvScheme, resolveKvScheme } = await import("@mlx-bun/inference/state");
  const config = await loadModelConfig(inputs.target);
  if (inputs.window !== undefined) {
    // One descriptor for both the parsed config and the raw arguments the graph is built from.
    const types = Array.from({ length: config.text.numHiddenLayers }, (_, i) => i % 2 === 0 ? "sliding_attention" : "full_attention");
    const raw = (config.raw.text_config ?? config.raw) as Record<string, unknown>;
    raw.layer_types = [...types]; raw.sliding_window = inputs.window;
    config.text.layerTypes = [...types]; config.text.slidingWindow = inputs.window;
  }
  let model: A, defaultDepth: number | undefined, dispose: () => void;
  if (inputs.kind === "glm-mtp") {
    // `serve --mtp on`, as the app's model host opens it: the Colibri runtime with
    // native MTP planned for one drafting lane (batchSize 1), its other defaults
    // unchanged; the provider's draft depth is the plan's.
    const opened = await openGlm52RuntimeModel(inputs.target, { batchSize: 1, enableMtp: true });
    model = opened.model;
    dispose = () => opened.model.dispose();
    if (!opened.plan.enableMtp) { dispose(); throw new Error("the GLM memory plan leaves native MTP disabled"); }
    defaultDepth = opened.plan.mtpDraftTokens;
  } else {
    const weights = await Weights.open(inputs.target);
    model = createModel(weights, config) as A;
    dispose = () => {
      try { weights.dispose(); }
      finally { for (const file of weights.shards.files.values()) file.mmap.unmap(); }
    };
  }
  if (inputs.window !== undefined) expect({ layerTypes: model.args?.layerTypes, slidingWindow: model.args?.slidingWindow })
    .toEqual({ layerTypes: config.text.layerTypes, slidingWindow: config.text.slidingWindow });
  const loadProvider = async (): Promise<A> => {
    switch (inputs.kind) {
      case "ngram": return new speculative.NgramProvider();
      case "two-model": return speculative.TwoModelProvider.load(inputs.draft!, config.text.vocabSize);
      case "assistant": return speculative.AssistantProvider.load(inputs.draft!);
      case "mtp": return speculative.QwenMtpProvider.load(inputs.draft!);
      case "dspark": return speculative.DflashProvider.load(inputs.draft!);
      case "deepspec": return speculative.DeepspecProvider.load(inputs.draft!);
      case "glm-mtp": return new speculative.Glm52NativeMtpProvider(model);
    }
  };
  const turboQuant = { kBits: 8, vBits: 3 };
  const kv = inputs.kv === "bf16" ? { options: {}, scheme: undefined }
    : inputs.kv === "turbo" ? { options: { turboQuant, quantizedKvStart: inputs.start },
      scheme: resolveKvScheme({ turboQuant, quantizedKvStart: inputs.start }) }
    : inputs.kv === "config" ? (() => {
      const kvConfig = config.kvQuant;
      assert(kvConfig?.length, "the target has no kv_config.json");
      return { options: { kvConfig, quantizedKvStart: inputs.start },
        scheme: resolveKvScheme({ override: "config", config: kvConfig, quantizedKvStart: inputs.start }) };
    })()
    : { options: { kvBits: Number(inputs.kv), kvGroupSize: 64, quantizedKvStart: inputs.start },
      scheme: new KvScheme("affine-uniform", { kvBits: Number(inputs.kv), kvGroupSize: 64, quantizedKvStart: inputs.start }) };
  const requirements = (extra: Record<string, boolean> = {}) => ({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
    userSeed: false, kvQuant: inputs.kv === "4" || inputs.kv === "8" || inputs.kv === "config", turboQuant: inputs.kv === "turbo",
    hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true, ...extra });
  const release = async () => {
    const { clearCache } = await import("@mlx-bun/mlx/ffi");
    try { dispose(); } finally { clearCache(); }
  };
  // The target forward the bindings call: forwardHiddenAsync where the graph
  // provides one, as the execution group and speculative binding select it.
  const targetForward = typeof model.forwardHiddenAsync === "function" ? "forwardHiddenAsync" as const : "forwardHidden" as const;
  return { model, config, loadProvider, kv, requirements, release, defaultDepth, targetForward };
}
type Loaded = Awaited<ReturnType<typeof load>>;

/** The gateway binding for one provider, its placement and its execution group. */
async function bindFor(loaded: Loaded, provider: A, depth: number) {
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const binding = bindMlxGateway(loaded.model, provider ? { provider, numDraftTokens: depth } : undefined);
  const quantizedBatch = loaded.kv.scheme ? binding.kvBatchable(loaded.kv.scheme) : false;
  const place = (options: A, extra: Record<string, boolean> = {}) => binding.plan(loaded.requirements({ ...extra, hasDraft: !!provider }),
    options, { continuous: true, quantizedBatch, checkpoints: false });
  /** A speculative method request; any other placement fails with its reasons. */
  const method = (options: A) => {
    const plan = place(options);
    assert(plan.method === "speculative" && plan.mechanism === "continuous",
      `placement: ${plan.method}/${plan.mechanism} (${plan.reasons.join(", ")})`);
    return binding.methodRequest!(plan, options)!;
  };
  /** An execution group. `held` keeps admission closed until `release()`, so
   * rows submitted meanwhile enter as one cohort. */
  const group = (options: { maxBatch?: number; promptCache?: A; held?: boolean } = {}) => {
    let held = options.held ?? false;
    const created: A = binding.createBatchGroup({ maxBatch: options.maxBatch ?? 4, admissionHeld: () => held,
      ...(loaded.kv.scheme && quantizedBatch ? { kvScheme: loaded.kv.scheme } : {}),
      ...(options.promptCache ? { promptCache: options.promptCache } : {}) });
    return Object.assign(created, { release() { held = false; created.kick(); } });
  };
  return { binding, place, method, group };
}

/** Target forward shapes while no row has produced a token: the prefill cohort. */
function watchPrefill(model: A, method: "forwardHidden" | "forwardHiddenAsync", outputs: number[][]) {
  const shapes: number[][] = [];
  const forward = model[method].bind(model);
  const spy = spyOn(model, method).mockImplementation((ids: A, ...rest: A[]) => {
    if (outputs.every(tokens => tokens.length === 0)) shapes.push([...ids.shape]);
    return forward(ids, ...rest);
  });
  return { shapes, restore: () => spy.mockRestore() };
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("grouped speculation: placement, the serial producer at B1, B4 rounds, retirement, joins and RAM prefix reuse", async () => {
  const { specServeRun } = await import("@mlx-bun/inference/generation/speculative");
  const { PromptCache } = await import("@mlx-bun/inference/state");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const loaded = await load(inputs!);
  const { model } = loaded;
  // Full-prefill providers feed the whole prompt; tail-split ones hold its last token for the first round.
  const prefillLength = (prompt: number[]) => prompt.length - (FULL_PREFILL.includes(inputs!.kind) ? 0 : 1);
  let provider: A;
  try {
    provider = await loaded.loadProvider();
    const depth = inputs!.depth ?? loaded.defaultDepth ?? 2;
    const { method, group: groupOf } = await bindFor(loaded, provider, depth);
    const options: A = { temperature: 0, maxTokens: 24, eosTokenIds: [], ...loaded.kv.options };
    const prompt = [1, 2, 3, 4, 5, 6, 7];
    const reference: number[] = [];
    // The serial producer serves uniform KV4/KV8 or TurboQuant from start 0 only,
    // and stops speculating once a sliding ring wraps (the custom window does).
    const old = inputs!.kv !== "config" && inputs!.start === 0 && inputs!.window === undefined
      ? await specServeRun(model, provider, depth, prompt, options, token => { reference.push(token); }) : undefined;
    clearCache();
    // Rows submitted under an admission hold, released together: one prefill cohort.
    const run = async (count: number) => {
      const group = groupOf({ held: true });
      let maxRows = 0;
      const tokens = Array.from({ length: count }, () => [] as number[]);
      const prefill = watchPrefill(model, loaded.targetForward, tokens);
      try {
        const pending = tokens.map(output => group.submit({
          method: method(options), promptIds: prompt, maxTokens: options.maxTokens, eosTokenIds: [],
          onToken(token: number) { output.push(token); maxRows = Math.max(maxRows, group.activeRows); },
        }));
        group.release();
        const stats = await Promise.all(pending);
        expect(group.activeRows + group.pendingRows).toBe(0);
        // The whole cohort prefills together: its first forward holds every row's prompt.
        expect(prefill.shapes[0]).toEqual([count, prefillLength(prompt)]);
        expect(prefill.shapes.every(shape => shape[0] === count)).toBe(true);
        return { tokens, stats, maxRows };
      } finally { prefill.restore(); await group.close(); clearCache(); }
    };
    const single = await run(1);
    if (old) {
      expect(single.tokens[0]).toEqual(reference);
      expect(single.stats[0]!.generatedTokens).toBe(old.generatedTokens);
      expect(single.stats[0]!.spec?.drafted).toBe(old.spec?.drafted);
      expect(single.stats[0]!.spec?.accepted).toBe(old.spec?.accepted);
    } else {
      reference.push(...single.tokens[0]!);
      const repeated = await run(1);
      expect(repeated.tokens).toEqual(single.tokens);
      expect(repeated.stats.map(stat => stat.spec)).toEqual(single.stats.map(stat => stat.spec));
    }
    const batch = await run(4), repeat = await run(4);
    expect(batch.maxRows).toBe(4);
    expect(repeat.maxRows).toBe(4);
    expect(repeat.tokens).toEqual(batch.tokens);
    for (const stats of batch.stats) {
      expect(stats.generatedTokens).toBe(options.maxTokens);
      expect(stats.finishReason).toBe("length");
      expect(stats.spec!.rounds).toBeGreaterThan(0);
      expect(stats.spec!.drafted).toBeLessThanOrEqual(stats.spec!.rounds! * depth);
      expect(stats.spec!.drafted).toBeGreaterThanOrEqual(inputs!.kind === "ngram" ? 0 : stats.spec!.rounds!);
    }
    console.log(JSON.stringify({ kind: inputs!.kind, kv: inputs!.kv, start: inputs!.start, single: single.stats, batch: batch.stats }));

    // Retirement: stop, consumer failure and abort inside a four-row cohort.
    const retiring = groupOf({ held: true });
    const aborted = new AbortController(), seen = [0, 0, 0, 0];
    let retirementMaxRows = 0;
    try {
      const pending = seen.map((_, row) => retiring.submit({
        method: method(options), promptIds: prompt, maxTokens: 24, eosTokenIds: [],
        ...(row === 2 ? { signal: aborted.signal } : {}),
        onToken() {
          retirementMaxRows = Math.max(retirementMaxRows, retiring.activeRows);
          seen[row]!++;
          if (row === 0 && seen[row] === 3) return false;
          if (row === 1 && seen[row] === 4) throw new Error("consumer failed");
          if (row === 2 && seen[row] === 5) aborted.abort(new Error("request cancelled"));
        },
      }));
      retiring.release();
      const outcomes = await Promise.allSettled(pending);
      expect(retirementMaxRows).toBe(4);
      expect(outcomes[0]).toMatchObject({ status: "fulfilled", value: { generatedTokens: seen[0], finishReason: "stop" } });
      expect(outcomes[1]).toMatchObject({ status: "rejected", reason: { message: "consumer failed" } });
      expect(outcomes[2]).toMatchObject({ status: "rejected", reason: { message: "request cancelled" } });
      expect(outcomes[3]).toMatchObject({ status: "fulfilled", value: { generatedTokens: 24, finishReason: "length" } });
      // No row publishes past its retirement.
      expect(seen).toEqual([3, 4, 5, 24]);
      expect(retiring.activeRows + retiring.pendingRows).toBe(0);
      const eos = await retiring.submit({ method: method(options), promptIds: prompt, maxTokens: 24,
        eosTokenIds: [reference[0]!], onToken() { throw new Error("EOS reached the content sink"); } });
      expect(eos).toMatchObject({ generatedTokens: 1, finishReason: "stop" });
    } finally { await retiring.close(); clearCache(); }

    // A request arriving during decode joins existing target/draft state with
    // an unequal prompt length and a different accepted offset.
    const lateJoin = async () => {
      const group = groupOf();
      const output: number[][] = [[], []];
      let joiner: Promise<unknown> | undefined, maxRows = 0;
      try {
        const first = await group.submit({ method: method(options), promptIds: prompt, maxTokens: 24, eosTokenIds: [],
          onToken(token: number) {
            output[0]!.push(token); maxRows = Math.max(maxRows, group.activeRows);
            if (output[0]!.length === 6) joiner = group.submit({ method: method(options), promptIds: [...prompt, 8, 9, 10],
              maxTokens: 17, eosTokenIds: [], onToken(next: number) { output[1]!.push(next); maxRows = Math.max(maxRows, group.activeRows); } });
          } });
        await joiner;
        expect(first.generatedTokens).toBe(24);
        expect(output.map(tokens => tokens.length)).toEqual([24, 17]);
        expect(maxRows).toBe(2);
        expect(group.activeRows + group.pendingRows).toBe(0);
        return output;
      } finally { await group.close(); clearCache(); }
    };
    expect(await lateJoin()).toEqual(await lateJoin());

    // Submitted while the first target chunk runs: the next chunk holds both
    // prompts before either request has emitted a token.
    const prefillJoin = async () => {
      const group = groupOf();
      const chunked = { ...options, prefillChunkSize: 4 };
      const output: number[][] = [[], []], shapes: number[][] = [];
      let joiner: Promise<unknown> | undefined, submitted = false, sharedBeforeOutput = false;
      const original = model[loaded.targetForward].bind(model);
      const probe = spyOn(model, loaded.targetForward).mockImplementation((ids: A, caches: A, ...rest: A[]) => {
        if (ids.shape[1] === 4) {
          shapes.push([...ids.shape]);
          if (ids.shape[0] === 2 && output.every(tokens => !tokens.length)) sharedBeforeOutput = true;
          if (!submitted) {
            submitted = true;
            joiner = group.submit({ method: method(chunked), promptIds: [...prompt, 8, 9, 10, 11, 12, 13],
              maxTokens: 8, eosTokenIds: [], onToken(token: number) { output[1]!.push(token); } });
          }
        }
        return original(ids, caches, ...rest);
      });
      try {
        await group.submit({ method: method(chunked), promptIds: [...prompt, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
          maxTokens: 8, eosTokenIds: [], onToken(token: number) { output[0]!.push(token); } });
        await joiner;
        expect(sharedBeforeOutput).toBe(true);
        expect(shapes.slice(0, 2)).toEqual([[1, 4], [2, 4]]);
        expect(output.map(tokens => tokens.length)).toEqual([8, 8]);
        expect(group.activeRows + group.pendingRows).toBe(0);
        return output;
      } finally { probe.mockRestore(); await group.close(); clearCache(); }
    };
    expect(await prefillJoin()).toEqual(await prefillJoin());

    // The prompt snapshot and its draft attachment restore from RAM.
    const cache = new PromptCache(512 * 1024 ** 2);
    const cached = groupOf({ promptCache: cache });
    try {
      const outputs: number[][] = [];
      for (let again = 0; again < 2; again++) {
        const output: number[] = []; outputs.push(output);
        const stats = await cached.submit({ method: method(options), promptIds: prompt, maxTokens: 24,
          eosTokenIds: [], onToken(token: number) { output.push(token); } });
        expect(stats.cachedTokens).toBe(again ? prompt.length - 1 : 0);
      }
      expect(outputs[1]).toEqual(outputs[0]);
    } finally { await cached.close(); cache.clear(); clearCache(); }
  } finally {
    try { provider?.dispose(); } finally { await loaded.release(); }
  }
}, 900_000);

test.skipIf(!inputs)("generated prefixes: retired rows publish their companion state; RAM and fresh SSD-store continuations", async () => {
  const { PromptCache, SsdCacheStore, TieredPromptCache, cloneKvCaches, leaseCacheStates, disposeAttachments } =
    await import("@mlx-bun/inference/state");
  const { disposeResources, withResource } = await import("@mlx-bun/inference/execution");
  const ops = await import("@mlx-bun/mlx/ops");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const release = (hit: A) => disposeResources([...hit.caches,
    { dispose: () => disposeAttachments(hit.attachments) }, { dispose: () => hit.retain?.() }]);
  const digest = (entry: { caches: Cache[]; attachments?: A[] }) => {
    const hash = createHash("sha256"), state = cloneKvCaches(entry.caches);
    try {
      hash.update(JSON.stringify(state.map(cache => cache.offset)));
      hash.update(JSON.stringify(entry.attachments?.map((a: A) => [a.schema, a.metadata])));
      withResource(leaseCacheStates(state), (arrays: readonly MlxArray[]) => {
        for (const array of [...arrays, ...(entry.attachments ?? []).flatMap((a: A) => a.tensors as MlxArray[])]) {
          hash.update(JSON.stringify([array.shape, array.dtype]));
          using bytes = ops.contiguous(array); hash.update(bytes.rawBytesView());
        }
      });
      return hash.digest("hex");
    } finally { disposeResources(state); }
  };
  const loaded = await load(inputs!);
  const { model } = loaded;
  const kind = inputs!.kind, depth = inputs!.depth ?? loaded.defaultDepth ?? 3;
  const directory = mkdtempSync(join(tmpdir(), "speculative-prefix-"));
  const options: A = { temperature: 0, seed: 42, maxTokens: 20, ...loaded.kv.options };
  const storeOptions = { dir: directory, maxBytes: 4 * 1024 ** 3, modelId: inputs!.target,
    configFingerprint: "speculative-prefix", tokenizerHash: "speculative-prefix", verify: true, storage: { layout: "blocks" as const } };
  const tier = (store: A, async: boolean) => ({
    find(tokens: number[], ns: string) { const hit = store.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    restore(handle: A) { const hit = store.restore(handle, model); return hit ? { ...hit, retain() {} } : null; },
    ...(async ? { async restoreAsync(handle: A) { const hit = await store.restoreAsync(handle, model); return hit ? { ...hit, retain() {} } : null; } } : {}),
    store: (tokens: number[], caches: Cache[], ns: string, attachments: A) => store.store(tokens, caches, ns, attachments),
  });
  let provider: A, restored: A;
  const ssd = new SsdCacheStore(storeOptions), cache = new TieredPromptCache(4 * 1024 ** 3, ssd, tier(ssd, false));
  const prompts = Array.from({ length: 4 }, (_, row) => [1, 2, 3, 4, 5, 6, 7 + row]);
  const outputs: number[][] = [[], [], [], []];
  const snapshots = new Map<number, { ids: number[]; namespace: string; hash: string }>();
  const put = cache.put.bind(cache) as (...args: A[]) => void;
  const putSpy = spyOn(cache, "put").mockImplementation((...args: A[]) => {
    const row = prompts.findIndex(prompt => prompt.every((token, index) => token === args[0][index]));
    if (row >= 0 && args[0].length > prompts[row]!.length && !snapshots.has(row)) {
      expect({ kind, tokens: args[0].length, matches: attachmentMatches(kind, args[0].length, args[4]?.[0]) })
        .toEqual({ kind, tokens: args[0].length, matches: true });
      snapshots.set(row, { ids: [...args[0]], namespace: args[2]!, hash: digest({ caches: args[1], attachments: args[4] }) });
    }
    return put(...args);
  });
  const prefill = watchPrefill(model, loaded.targetForward, outputs);
  try {
    provider = await loaded.loadProvider();
    const bound = await bindFor(loaded, provider, depth);
    const group = bound.group({ promptCache: cache, held: true });
    const aborted = new AbortController(); let maxRows = 0;
    try {
      const pending = prompts.map((promptIds, row) => group.submit({
        method: bound.method(options), promptIds,
        cacheNamespace: `generated-${row}`, cacheSessionId: `agent-${row}`, maxTokens: 20, eosTokenIds: [],
        ...(row === 3 ? { signal: aborted.signal } : {}),
        onToken(token: number) {
          outputs[row]!.push(token); maxRows = Math.max(maxRows, group.activeRows);
          if (row === 1 && outputs[row]!.length === 6) return false;
          if (row === 2 && outputs[row]!.length === 7) throw new Error("failed consumer");
          if (row === 3 && outputs[row]!.length === 8) aborted.abort(new Error("cancelled consumer"));
        },
      }));
      group.release();
      const outcomes = await Promise.allSettled(pending);
      expect(maxRows).toBe(4);
      // The four rows prefill as one cohort (the snapshot boundary may split the prompt).
      expect(prefill.shapes.length).toBeGreaterThan(0);
      expect(prefill.shapes.every(shape => shape[0] === 4)).toBe(true);
      expect(outcomes.map(value => value.status)).toEqual(["fulfilled", "fulfilled", "rejected", "rejected"]);
      expect([...snapshots.keys()].sort()).toEqual([0, 1]);
    } finally { await group.close(); }
    for (const row of [0, 1]) {
      const snapshot = snapshots.get(row)!, transcript = [...prompts[row]!, ...outputs[row]!];
      expect(snapshot.ids).toEqual(transcript.slice(0, snapshot.ids.length));
      expect(transcript.length - snapshot.ids.length).toBeGreaterThanOrEqual(0);
      expect(transcript.length - snapshot.ids.length).toBeLessThanOrEqual(1);
      const held = cache.take([...snapshot.ids, 31], snapshot.namespace)!;
      try { expect(digest(held)).toBe(snapshot.hash); } finally { release(held); }
    }
    const continueRow = async (row: number, storage: A) => {
      const next = [...prompts[row]!, ...outputs[row]!, 11, 12, 13], tokens: number[] = [];
      const current = await bindFor(loaded, provider, depth);
      const group = current.group({ promptCache: storage });
      try {
        const result = await group.submit({ method: current.method(options),
          promptIds: next, snapshotAt: 1, cacheNamespace: `generated-${row}`, cacheSessionId: `agent-${row}`, maxTokens: 12, eosTokenIds: [],
          onToken(token: number) { tokens.push(token); } });
        expect(result.cachedTokens).toBe(snapshots.get(row)!.ids.length);
        return { tokens, acceptance: result.spec?.acceptanceLengths };
      } finally { await group.close(); }
    };
    const warm: A[] = [];
    for (const row of [0, 1]) {
      warm.push(await continueRow(row, cache));
      expect(await continueRow(row, cache)).toEqual(warm[row]!);
      const snapshot = snapshots.get(row)!, held = cache.take([...snapshot.ids, 32], snapshot.namespace)!;
      try { expect(digest(held)).toBe(snapshot.hash); } finally { release(held); }
      const edited = [...snapshot.ids]; edited[edited.length - 1] = 33;
      const fallback = cache.take([...edited, 34], snapshot.namespace)!;
      try { expect(fallback.tokens).toEqual(prompts[row]!.slice(0, -1)); } finally { release(fallback); }
    }
    expect(cache.sessionHits).toBeGreaterThan(0);
    expect((await cache.durability.flush()).durable).toBe(true);
    expect(cache.spillQueue.pendingBytes).toBe(0);
    cache.clear(); provider.dispose(); provider = await loaded.loadProvider();
    const restarted = new SsdCacheStore(storeOptions);
    expect(restarted.scan()).toBeGreaterThan(0);
    restored = new PromptCache(4 * 1024 ** 3, null, tier(restarted, true));
    for (const row of [0, 1]) {
      const snapshot = snapshots.get(row)!;
      const releasePrefetch = await restored.prefetch([...snapshot.ids, 31], snapshot.namespace);
      const hit = restored.take([...snapshot.ids, 31], snapshot.namespace)!;
      try { expect(digest(hit)).toBe(snapshot.hash); } finally { release(hit); releasePrefetch(); }
      expect(await continueRow(row, restored)).toEqual(warm[row]!);
    }
    console.log(JSON.stringify({ kind, kv: inputs!.kv, depth, generated: outputs.map(tokens => tokens.length), prefill: prefill.shapes,
      prefixes: [...snapshots.values()].map(item => item.ids.length) }));
  } finally {
    putSpy.mockRestore(); prefill.restore();
    try { await cache.durability.flush(); }
    finally {
      cache.clear(); restored?.clear();
      try { provider?.dispose(); }
      finally { await loaded.release(); clearCache(); rmSync(directory, { recursive: true, force: true }); }
    }
  }
}, 900_000);

test.skipIf(!inputs?.adapter)("adapter rows with a configured draft: placement, B1 controls, grouped contexts, failure cleanup and prefix isolation", async () => {
  const { generate, loadTokenizer } = await import("@mlx-bun/inference");
  const { AdapterManager } = await import("@mlx-bun/inference/adapters");
  const { createRowSampling } = await import("@mlx-bun/inference/execution");
  const { makeStepSampler } = await import("@mlx-bun/inference/sampling");
  const { PromptCache } = await import("@mlx-bun/inference/state");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  // The target's own tokenization of a short instruction, so any target family works.
  const prompt = (await loadTokenizer(inputs!.target)).encode("Write one sentence about the sea.");
  expect(prompt.length).toBeGreaterThan(4);
  const loaded = await load(inputs!);
  const { model } = loaded;
  let provider: A;
  const manager = new AdapterManager(model);
  const cache = new PromptCache(1024 ** 3);
  const published: { ids: number[]; namespace: string; attachments: number }[] = [];
  const put = cache.put.bind(cache) as (...args: A[]) => void;
  const publication = spyOn(cache, "put").mockImplementation((...args: A[]) => {
    if (args[0].length > 259) published.push({ ids: [...args[0]], namespace: args[2]!, attachments: args[4]?.length ?? 0 });
    return put(...args);
  });
  const frames: { batch: number; adapters: string[] }[] = [];
  const forward = model[loaded.targetForward].bind(model);
  const probe = spyOn(model, loaded.targetForward).mockImplementation((ids: A, caches: A, ...rest: A[]) => {
    frames.push({ batch: ids.shape[0]!, adapters: [...model.loraState.active] });
    return forward(ids, caches, ...rest);
  });
  type Request = { adapters: string[]; tokens?: number; fail?: boolean };
  try {
    provider = await loaded.loadProvider();
    await manager.mount("upper", inputs!.adapter!);
    const optionsFor = ({ adapters, tokens = 12 }: Request, promptIds: number[], seeded = false) => ({ ...loaded.kv.options,
      logprobs: true, topLogprobs: 3, adapters, maxTokens: tokens, temperature: seeded ? 0.7 : 0, seed: 42, eosTokenIds: [],
      snapshotAt: promptIds.length - 1 });
    const upper = { adapters: ["upper"] }, base = { adapters: [] };
    // Placement, decided once per context by the binding. Every adapter row is
    // served; it speculates only through a provider that supports
    // target adapters, and otherwise decodes ordinarily with the draft ignored.
    const probeBinding = await bindFor(loaded, provider, loaded.defaultDepth ?? 3);
    const adapterPlan = probeBinding.place(optionsFor(upper, prompt), { hasAdapters: true, wantsLogprobs: true });
    expect({ mechanism: adapterPlan.mechanism, reasons: adapterPlan.reasons.filter(r => r.endsWith("-unsupported")) })
      .toEqual({ mechanism: "continuous", reasons: [] });
    if (provider.grouped?.supportsTargetAdapters !== true) expect(adapterPlan.method).toBe("autoregressive");
    const adapterSpeculates = adapterPlan.method === "speculative";
    // Drafted base rows: served, or refused where genuine delayed speculation is excluded.
    const basePlan = probeBinding.place(optionsFor(base, prompt), { wantsLogprobs: true });
    const baseServed = basePlan.mechanism === "continuous";
    if (!baseServed) expect(basePlan.reasons).toContain("continuous-unavailable");
    const expectedMethod = (adapters: string[]) => adapters.length ? adapterPlan.method : basePlan.method;
    const run = async (batch: number, requests: Request[], promptIds = prompt, cached = false, seeded = false) => {
      frames.length = 0;
      const collect = () => {
        const output: number[] = [], metadata: unknown[] = [];
        return { output, metadata, sink(token: number, logprobs?: A) {
          expect(Number.isFinite(logprobs?.logprob)).toBe(true);
          expect(logprobs?.top).toHaveLength(3);
          metadata.push(structuredClone(logprobs)); output.push(token);
        } };
      };
      // B1 control: the direct generator without a draft.
      if (batch === 1) return { frames: [...frames], results: await Promise.all(requests.map(async request => {
        const out = collect();
        const generation = generate(model, promptIds, optionsFor(request, promptIds, seeded));
        for await (const value of generation) out.sink(value.token, value.logprobs);
        return { ...out, stats: generation.stats! };
      })) };
      const bound = await bindFor(loaded, provider, loaded.defaultDepth ?? 3);
      const group = bound.group({ maxBatch: batch, ...(cached ? { promptCache: cache } : {}) });
      try {
        const results = await Promise.all(requests.map(async request => {
          const options = optionsFor(request, promptIds, seeded);
          const hasAdapters = request.adapters.length > 0;
          const plan = bound.place(options, { hasAdapters, wantsLogprobs: true, userSeed: seeded });
          expect({ adapters: request.adapters, mechanism: plan.mechanism, method: plan.method })
            .toEqual({ adapters: request.adapters, mechanism: "continuous", method: expectedMethod(request.adapters) });
          const method = bound.binding.methodRequest!(plan, options);
          const out = collect();
          const onToken = (token: number, logprobs?: A) => {
            out.sink(token, logprobs);
            if (request.fail && out.output.length === 2) throw new Error("adapter callback failed");
          };
          const sampling = method ? undefined : createRowSampling(makeStepSampler(options, { tokenRepresentation: "device",
            grammarWait: "external", historyUpdate: "after-sample", initialHistory: promptIds,
            captureSelectedLogprob: true, captureTopLogprobs: 3 }), onToken);
          try {
            const stats = await group.submit({ promptIds, maxTokens: options.maxTokens, eosTokenIds: [], snapshotAt: options.snapshotAt,
              ...(hasAdapters ? { context: bound.binding.bindAdapterContext!(request.adapters, `adapters:${JSON.stringify(request.adapters)}`),
                cacheNamespace: manager.cacheNamespace(request.adapters) } : { cacheNamespace: "" }),
              ...(method ? { method, onToken } : { sample: sampling!.sample, plainGreedy: sampling!.plainGreedy, onToken: sampling!.onToken }),
            });
            if (plan.method === "speculative") expect(stats.spec!.rounds).toBeGreaterThan(0);
            return { ...out, stats };
          } catch (error) {
            if (!request.fail) throw error;
            expect(String(error)).toContain("adapter callback failed");
            return { ...out, stats: null };
          } finally { sampling?.dispose(); }
        }));
        expect(group.activeRows + group.pendingRows).toBe(0);
        return { results, frames: [...frames] };
      } finally { await group.close(); expect(model.loraState.active).toEqual([]); clearCache(); }
    };
    const serial = await run(1, [upper]), baseSerial = await run(1, [base]);
    // The mounted adapter is live: its control differs from the base control.
    expect(serial.results[0]!.metadata).not.toEqual(baseSerial.results[0]!.metadata);
    expect((await run(4, [upper])).results[0]!.output).toEqual(serial.results[0]!.output);
    const pair = await run(4, [upper, upper]);
    expect(pair.frames.some(frame => frame.batch === 2)).toBe(true);
    expect(pair.frames.every(frame => frame.adapters.join() === "upper")).toBe(true);
    const four = await run(4, [upper, upper, upper, upper], prompt, false, true);
    expect(four.frames.some(frame => frame.batch === 4)).toBe(true);
    expect((await run(4, [upper, upper, upper, upper], prompt, false, true)).results.map(({ output, metadata }) => ({ output, metadata })))
      .toEqual(four.results.map(({ output, metadata }) => ({ output, metadata })));
    const baseAlone = baseServed ? await run(4, [base]) : undefined;
    if (baseAlone) {
      expect(baseAlone.results[0]!.output).toEqual(baseSerial.results[0]!.output);
      const mixed = await run(4, [upper, upper, base, upper]);
      expect(mixed.results.slice(0, 2).map(result => result.output)).toEqual(pair.results.map(result => result.output));
      expect(mixed.results[2]!.output).toEqual(baseAlone.results[0]!.output);
      expect(mixed.results[3]!.output).toEqual(serial.results[0]!.output);
      // Only the two compatible adapter rows ever share a forward; the base row
      // blocks the queue until they retire, then each runs alone.
      expect(mixed.frames.filter(frame => frame.batch > 1).every(frame => frame.adapters.join() === "upper")).toBe(true);
    }
    const failed = await run(4, [{ ...upper, fail: true }, upper, ...(baseAlone ? [base] : [])]);
    expect(failed.results[0]!.stats).toBeNull();
    expect(failed.results[1]!.output).toHaveLength(12);
    if (baseAlone) expect(failed.results[2]!.output).toEqual(baseAlone.results[0]!.output);
    // Prefix reuse stays isolated by adapter.
    const longPrompt = Array.from({ length: 259 }, (_, index) => prompt[index % prompt.length]!);
    const coldUpper = await run(4, [upper], longPrompt, true);
    const generatedUpper = published.at(-1)!;
    expect(generatedUpper.ids.length).toBeGreaterThan(longPrompt.length);
    expect(generatedUpper.attachments).toBe(adapterSpeculates ? 1 : 0);
    expect(coldUpper.results[0]!.stats!.cachedTokens).toBe(0);
    const coldBase = baseAlone ? await run(4, [base], longPrompt, true) : undefined;
    if (coldBase) {
      expect(coldBase.results[0]!.stats!.cachedTokens).toBe(0);
      expect(published.at(-1)!.namespace).not.toBe(generatedUpper.namespace);
    }
    const resumed = await run(4, [upper], [...generatedUpper.ids, 11, 12], true);
    expect(resumed.results[0]!.stats!.cachedTokens).toBe(generatedUpper.ids.length);
    const warmUpper = await run(4, [upper], longPrompt, true);
    expect(warmUpper.results[0]!.stats!.cachedTokens).toBe(258);
    expect(warmUpper.results[0]!.output).toEqual(coldUpper.results[0]!.output);
    if (coldBase) {
      const warmBase = await run(4, [base], longPrompt, true);
      expect(warmBase.results[0]!.stats!.cachedTokens).toBe(258);
      expect(warmBase.results[0]!.output).toEqual(coldBase.results[0]!.output);
    }
    console.log(`[speculative-group] adapter rows ${adapterSpeculates ? "speculate" : "decode ordinarily, draft ignored"}; ` +
      `drafted base rows ${baseServed ? basePlan.method : "refused"}: B1 controls, grouped contexts, failure cleanup and isolated prefix reuse pass`);
  } finally {
    probe.mockRestore(); publication.mockRestore(); cache.clear();
    try { manager.unmount("upper"); provider?.dispose(); } finally { await loaded.release(); clearCache(); }
  }
}, 900_000);

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in: none skips; partial, blank or inconsistent settings fail (CPU only)", () => {
  expect(optIn({})).toBeNull();
  const env = (values: Record<string, string>) => Object.fromEntries(Object.entries(values).map(([k, v]) => [PREFIX + k, v]));
  expect(() => optIn(env({ KV: "4" }))).toThrow("needs MLX_BUN_TEST_SPEC_TARGET and MLX_BUN_TEST_SPEC_KIND");
  expect(() => optIn(env({ TARGET: "/t", KIND: " " }))).toThrow("blank");
  expect(() => optIn(env({ TARGET: "/t", KIND: "eagle" }))).toThrow("KIND must be one of");
  expect(() => optIn(env({ TARGET: "/t", KIND: "ngram", DRAFT: "/d" }))).toThrow("model-free");
  expect(() => optIn(env({ TARGET: "/t", KIND: "mtp" }))).toThrow("needs MLX_BUN_TEST_SPEC_DRAFT");
  expect(() => optIn(env({ TARGET: "/t", KIND: "ngram", KV: "2" }))).toThrow("KV must be one of");
  expect(() => optIn(env({ TARGET: "/t", KIND: "ngram", KV: "4", KV_START: "-1" }))).toThrow("integer >= 0");
  expect(() => optIn(env({ TARGET: "/t", KIND: "ngram", KV_START: "8" }))).toThrow("needs a quantized");
  expect(() => optIn(env({ TARGET: "/t", KIND: "ngram", DEPTH: "0" }))).toThrow("integer >= 1");
  expect(() => optIn(env({ TARGET: "/nonexistent-spec-target", KIND: "ngram" }))).toThrow("no config.json");
  // GLM-5.2 native MTP: no draft artifact, a glm_moe_dsa target, plain KV only, no custom window.
  expect(() => optIn(env({ TARGET: "/t", KIND: "glm-mtp", DRAFT: "/d" }))).toThrow("checkpoint-native");
  const dir = mkdtempSync(join(tmpdir(), "spec-glm-target-"));
  try {
    writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "llama" }));
    expect(() => optIn(env({ TARGET: dir, KIND: "glm-mtp" }))).toThrow("glm_moe_dsa");
    writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "glm_moe_dsa" }));
    expect(optIn(env({ TARGET: dir, KIND: "glm-mtp" }))).toMatchObject({ kind: "glm-mtp", kv: "bf16", draft: undefined, depth: undefined });
    for (const kv of ["4", "8", "turbo", "config"]) expect(() => optIn(env({ TARGET: dir, KIND: "glm-mtp", KV: kv }))).toThrow("plain KV only");
    expect(() => optIn(env({ TARGET: dir, KIND: "glm-mtp", WINDOW: "8" }))).toThrow("Llama-family");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("generated-prefix attachments follow each provider's schema (CPU only)", () => {
  expect(attachmentMatches("ngram", 9, { tensors: [{ shape: [9] }] })).toBe(true);
  expect(attachmentMatches("ngram", 9, { tensors: [{ shape: [8] }] })).toBe(false);
  expect(attachmentMatches("mtp", 9, { metadata: { draftOffset: 8 } })).toBe(true);
  expect(attachmentMatches("mtp", 9, { metadata: { draftOffset: 9 } })).toBe(false);
  for (const kind of ["two-model", "assistant", "dspark", "deepspec", "glm-mtp"] as const) {
    expect(attachmentMatches(kind, 9, { metadata: { processedTokens: 9 } })).toBe(true);
    expect(attachmentMatches(kind, 9, undefined)).toBe(false);
  }
});
