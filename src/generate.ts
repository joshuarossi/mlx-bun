// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - sampling stays on-device; only the chosen token id crosses to JS

import { MlxArray, gpuStream } from "./mlx/array";
import {
  clearCache,
  maxRecommendedWorkingSetSize,
  setWiredLimit,
  synchronize,
} from "./mlx/ffi";
import * as ops from "./mlx/ops";
import { CompiledDecode } from "./model/compiled-decode";
import { Gemma4Model, KVCache, RotatingKVCache, type Cache } from "./model/gemma4";
import type { RuntimeModel } from "./model/factory";
import type { KvQuantSpec } from "./config";
import {
  makeLogitsProcessors, makeSampler,
  type LogitsProcessorOptions, type SamplerOptions, toLogprobs,
} from "./sampler";

export interface GenerateOptions extends SamplerOptions, LogitsProcessorOptions {
  maxTokens?: number;
  eosTokenIds?: number[];
  prefillChunkSize?: number;
  /** Pre-warmed KV caches (e.g. from the prompt cache). cache[0].offset
   *  prompt tokens are treated as already prefilled; only the suffix is
   *  forwarded. Caller keeps ownership — generate() will not dispose. */
  cache?: Cache[];
  /** Vision path: pre-merged (unscaled) input embeddings [1, L, hidden]
   *  covering the whole prompt; prefilled in one shot (no chunking).
   *  Caller keeps ownership. */
  promptEmbeddings?: MlxArray;
  /** bool [L] marking image tokens (bidirectional attention among them). */
  imageMask?: MlxArray;
  /** Quantize full-attention KV caches to this many bits (4 or 8).
   *  Rotating (sliding-window) caches stay bf16 — they're window-capped
   *  and upstream rotating-cache quantization is NYI. */
  kvBits?: number;
  kvGroupSize?: number;
  /** Per-layer mixed-precision KV from kv_config.json (config.kvQuant).
   *  Overrides kvBits, like optiq serve's --kv-config. layerIdx indexes
   *  the cache list (== layer index for the donor prefix); entries for
   *  rotating/sliding caches are skipped until Phase 9. */
  kvConfig?: KvQuantSpec[];
  /** Convert once a cache's offset reaches this (uniform-kvBits default
   *  5000 = mlx-lm; kvConfig default 0 = optiq serve). */
  quantizedKvStart?: number;
  /** Mounted LoRA adapter ids to apply (resolved/validated by
   *  AdapterManager.resolveSpec). Residuals sum in order. Set on the
   *  model's LoraState for exactly the duration of this generation —
   *  a plain field, safe because the generation queue is serialized. */
  adapters?: string[];
}

/** Port of mlx-lm maybe_quantize_kv_cache + optiq serve's per-layer
 *  patched variant (incl. patch_rotating_to_quantized: rotating caches
 *  convert too — Phase 9). kvConfig overrides kvBits, matching optiq's
 *  --kv-config precedence; shipped kv_config.json files list
 *  full-attention layers only, so rotating quantization engages through
 *  uniform kvBits (like optiq --kv-bits) or a config that names sliding
 *  layers. */
export function maybeQuantizeKv(cache: Cache[], options: GenerateOptions): void {
  const { kvBits, kvConfig } = options;
  if (!kvBits && !kvConfig?.length) return;
  const start = options.quantizedKvStart ?? (kvConfig?.length ? 0 : 5000);
  const byLayer = kvConfig?.length
    ? new Map(kvConfig.map((e) => [e.layerIdx, e]))
    : null;
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (!(c instanceof KVCache || c instanceof RotatingKVCache) || c.offset < start) continue;
    // OptiQ's mixed-KV hook skips empty caches: the first prompt prefill
    // runs bf16, then the populated cache is quantized before decode.
    // Converting empty caches at start=0 makes prefill itself quantized
    // and diverges from the oracle path.
    if (c.offset === 0) continue;
    if (byLayer) {
      const e = byLayer.get(i);
      if (e) cache[i] = c.toQuantized(e.groupSize, e.bits);
    } else {
      cache[i] = c.toQuantized(options.kvGroupSize ?? 64, kvBits!);
    }
  }
}

export interface GenerateStats {
  promptTokens: number;
  /** Prompt tokens skipped via a pre-warmed cache. */
  cachedTokens: number;
  generatedTokens: number;
  prefillTps: number;
  decodeTps: number;
  prefillMs: number;
  decodeMs: number;
  /** Exact token sequence whose KV now lives in the cache (prompt + every
   *  decoded token that was forwarded, including a trailing EOS the
   *  pipeline forwarded before reading it). For PromptCache.put(). */
  cacheTokens: number[];
}

export interface GeneratedToken {
  token: number;
  index: number;
}

export class Generation implements AsyncIterable<GeneratedToken> {
  stats: GenerateStats | null = null;
  readonly #iter: AsyncGenerator<GeneratedToken, GenerateStats>;

  constructor(iter: AsyncGenerator<GeneratedToken, GenerateStats>) {
    this.#iter = iter;
  }

  async *[Symbol.asyncIterator](): AsyncGenerator<GeneratedToken> {
    try {
      while (true) {
        const r = await this.#iter.next();
        if (r.done) {
          this.stats = r.value;
          return;
        }
        yield r.value;
      }
    } finally {
      // Consumer broke early (e.g. a decoded-text stop sequence fired):
      // drive the inner generator's shutdown so its finallys run (array
      // disposal, wired/adapter scopes) and capture the stats its
      // early-return path still reports.
      if (this.stats === null) {
        const r = await this.#iter.return(undefined as unknown as GenerateStats);
        if (r.done && r.value) this.stats = r.value;
      }
    }
  }
}

// Scoped wired limit, raised only for near-ceiling models. mlx-lm's
// wired_limit context wires unconditionally per generation; we deviate
// with a measured justification (PLAN Phase 6 verification findings):
// - 26B-A4B (16.4 GB = 92% of the 17.8 GiB working set) NEEDS wiring —
//   8.6 tok/s without, 32.3 with (Metal evicts weight buffers per token).
// - 12B/e4b (≤47%) hit reference parity WITHOUT wiring, and wiring in a
//   multi-model process (the test suite) pins memory the OTHER resident
//   models need — async GPU exec OOM, which is uncatchable (the mlx
//   completion-handler throw terminates the process).
// Scope semantics match the reference: set → generate → synchronize →
// restore; nothing stays pinned between generations. Re-entrant: only
// the outermost wiring scope touches the limit.
const WIRE_THRESHOLD = 0.75;
let wiredScopeDepth = 0;
let wiredOldLimit = 0;
function enterWiredScope(): void {
  if (wiredScopeDepth++ === 0)
    wiredOldLimit = setWiredLimit(maxRecommendedWorkingSetSize());
}
function exitWiredScope(): void {
  if (--wiredScopeDepth === 0) {
    synchronize(gpuStream);
    setWiredLimit(wiredOldLimit);
  }
}

export function generate(
  model: RuntimeModel,
  promptTokens: number[],
  options: GenerateOptions = {},
): Generation {
  let inner = generateInner(model, promptTokens, options);
  if (options.adapters?.length) inner = adapterScoped(model, options.adapters, inner);
  const wire =
    process.env.MLX_BUN_FORCE_WIRE === "1" ||
    model.weightsBytes > WIRE_THRESHOLD * maxRecommendedWorkingSetSize();
  return new Generation(wire ? wiredScoped(inner) : inner);
}

/** Hold the model's active-adapter list for exactly this generation. */
async function* adapterScoped(
  model: RuntimeModel,
  adapters: string[],
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  model.loraState.active = adapters;
  try {
    return yield* inner;
  } finally {
    model.loraState.active = [];
  }
}

/** Wrap the generator so the wired limit is held exactly while it runs
 *  (incl. early break/return/throw — finally fires on .return()). */
async function* wiredScoped(
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  enterWiredScope();
  try {
    return yield* inner;
  } finally {
    exitWiredScope();
  }
}

async function* generateInner(
  model: RuntimeModel,
  promptTokens: number[],
  options: GenerateOptions,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  const {
    maxTokens = 512,
    eosTokenIds = model.config.eosTokenIds,
    prefillChunkSize = 2048,
  } = options;
  const sampler = makeSampler(options);
  const processors = makeLogitsProcessors(options);
  const needsTokenHistory = processors.length > 0;

  const ownsCache = !options.cache;
  const cache = options.cache ?? model.makeCache();
  const cachedTokens = cache[0]!.offset;
  if (cachedTokens >= promptTokens.length)
    throw new Error(
      `pre-warmed cache (${cachedTokens} tokens) must be a strict prefix of the prompt (${promptTokens.length})`,
    );
  /** device-side token history (only maintained when processors need it) */
  let history: MlxArray | null = null;

  // logits [1,1,V] → sampled token array [1] (all on-device)
  const sampleStep = (logits3d: MlxArray, step: number): MlxArray => {
    const V = logits3d.shape[2]!;
    let logits = ops.reshape(logits3d, [1, V]);
    for (const p of processors) logits = disposing(logits, p(history, logits));
    const lp = toLogprobs(logits);
    logits.dispose();
    const tok = sampler(lp, step);
    lp.dispose();
    return tok;
  };

  const pushHistory = (tok: MlxArray) => {
    if (!needsTokenHistory) return;
    if (!history) {
      history = ops.reshape(tok, [1]);
    } else {
      const prev = history;
      history = ops.concatAxis([prev, tok], 0);
      prev.dispose();
    }
  };

  // Decode-loop state lives at function scope so the finally can still
  // report stats and dispose in-flight arrays when the consumer
  // terminates the generator early (break on a stop sequence — the
  // forced .return() resumes at the yield and runs the finally).
  let prefillMs = 0;
  let tDecode = 0;
  let decodeMs = 0;
  let generated = 0;
  const forwarded: number[] = [];
  let pending: MlxArray | null = null;
  let nextPending: MlxArray | null = null;
  let finished = false;
  let threw = false;
  const makeStats = (): GenerateStats => ({
    promptTokens: promptTokens.length,
    cachedTokens,
    generatedTokens: generated,
    prefillMs,
    decodeMs,
    prefillTps: ((promptTokens.length - cachedTokens) / prefillMs) * 1000,
    decodeTps: (generated / decodeMs) * 1000,
    cacheTokens: [...promptTokens, ...forwarded],
  });

  try {
    // ---- prefill ----
    maybeQuantizeKv(cache, options);
    const tPrefill = performance.now();
    let h0: MlxArray;
    if (options.promptEmbeddings) {
      if (cachedTokens !== 0)
        throw new Error("promptEmbeddings cannot be combined with a pre-warmed cache");
      if (needsTokenHistory)
        history = ops.fromInt32(promptTokens, [promptTokens.length]);
      // e2b/e4b need the spliced token ids to build per-layer inputs
      // (image positions zeroed inside forwardEmbeddings).
      const embedIds = ops.fromInt32(promptTokens, [1, promptTokens.length]);
      h0 = model.forwardEmbeddings(
        options.promptEmbeddings, cache, options.imageMask ?? null, embedIds,
      );
      embedIds.dispose();
    } else {
      let pos = cachedTokens;
      while (promptTokens.length - pos > prefillChunkSize) {
        const chunk = promptTokens.slice(pos, pos + prefillChunkSize);
        const ids = ops.fromInt32(chunk, [1, chunk.length]);
        const h = model.forwardHidden(ids, cache);
        ids.dispose();
        h.dispose(); // logits never computed for non-final chunks
        ops.evalAll(cache.flatMap((c) => c.state()));
        maybeQuantizeKv(cache, options);
        // mlx-lm _prefill clears the allocator cache after every chunk;
        // without this, prefill transients pile up in the buffer cache
        // and the first decode step pays a one-shot reclaim stall that
        // scales with prompt length (~800 ms after an 8k prefill —
        // measured, scripts/decode-split.ts; the context-scaling decode
        // gap's main term).
        clearCache();
        pos += prefillChunkSize;
      }
      if (needsTokenHistory) {
        history = ops.fromInt32(promptTokens, [promptTokens.length]);
      }
      const lastChunk = promptTokens.slice(pos);
      const ids0 = ops.fromInt32(lastChunk, [1, lastChunk.length]);
      h0 = model.forwardHidden(ids0, cache);
      ids0.dispose();
    }
    const [, L0, H] = h0.shape as [number, number, number];
    const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
    h0.dispose();
    const logits0 = model.logitsFromHidden(hLast);
    hLast.dispose();
    pending = sampleStep(logits0, 0); // token array [1]
    logits0.dispose();
    // mirror mlx-lm generate_step: async-dispatch the first token's
    // compute; the prefill clock keeps running until the token ARRIVES
    // (first itemUint32 below). mlx-lm stops its prompt clock at the
    // first yielded token, which bills the prefill→decode boundary
    // (allocator reclaim of prefill transients + first-step dispatch)
    // to prompt_time, not decode — replicated so cross-stack decode
    // tok/s measure the same quantity. The boundary cost is real and
    // scales with prompt length; it belongs to "having prefilled".
    ops.asyncEvalAll([pending]);

    // ---- decode (pipelined) ----
    // Compiled decode (docs/design/optimization_plan.md Phase A): replay the per-step
    // graph in C++ instead of rebuilding it through bun:ffi every token.
    // Bit-exact with the uncompiled path (tests/compiled-decode.test.ts);
    // MLX_BUN_COMPILED_DECODE=0 is the kill switch / A-B lever. LoRA
    // generations stay uncompiled (adapter weights would bake into the
    // trace as constants). Any unsupported cache state falls back for
    // the rest of the generation.
    // MoE models stay uncompiled: GatherQMM lacks output_shapes in mlx
    // 0.6.0, and shapeless replay re-infers the whole tape whenever the
    // growing attention windows change shape (= every step). Remove this
    // when upstream implements GatherQMM::output_shapes.
    let compiled =
      process.env.MLX_BUN_COMPILED_DECODE !== "0" &&
      !options.adapters?.length &&
      model.config.modelType.startsWith("gemma4") &&
      !model.config.text.enableMoeBlock
        ? CompiledDecode.for(model as Gemma4Model)
        : null;
    let stop = false;
    while (!stop) {
      const cur = pending!;
      // build step n+1's graph from the *unread* pending token
      nextPending = null;
      if (generated + 1 < maxTokens) {
        maybeQuantizeKv(cache, options);
        pushHistory(cur);
        let logits: MlxArray | null = null;
        let evalWith: MlxArray[] = [];
        if (compiled && CompiledDecode.supports(cache)) {
          try {
            const r = compiled.step(cur, cache);
            logits = r.logits;
            evalWith = r.evalWith;
          } catch (e) {
            // growth done by a partial prepare is benign for the
            // uncompiled path (updateAndFetch re-checks capacity)
            compiled = null;
            console.warn(`compiled decode disabled for this generation: ${e}`);
          }
        }
        if (!logits) {
          const ids = ops.reshape(cur, [1, 1]);
          const h = model.forwardHidden(ids, cache);
          ids.dispose();
          logits = model.logitsFromHidden(h);
          h.dispose();
        }
        nextPending = sampleStep(logits, generated + 1);
        logits.dispose();
        ops.asyncEvalAll([nextPending, ...evalWith]);
      }

      // sync-read step n's token while n+1 computes
      const token = ops.itemUint32(cur);
      if (generated === 0) {
        // first token arrived: prompt clock stops, decode clock starts
        // (mlx-lm stream_generate's n==0 clock swap; the first token is
        // "free" on the decode clock there too)
        prefillMs = performance.now() - tPrefill;
        tDecode = performance.now();
      }
      cur.dispose();
      pending = null;
      generated++;
      // if a next-step graph was built, this token's KV entered the cache
      if (nextPending !== null) forwarded.push(token);

      if (eosTokenIds.includes(token)) {
        nextPending?.dispose();
        nextPending = null;
        stop = true;
      } else {
        yield { token, index: generated - 1 };
        // mlx-lm generate_step: clear_cache after token 0 (drops the
        // remaining prefill transients) and every 256 tokens after
        if ((generated - 1) % 256 === 0) clearCache();
        if (nextPending === null) {
          stop = true;
        } else {
          pending = nextPending;
          nextPending = null;
        }
      }
    }
    decodeMs = performance.now() - tDecode;
    finished = true;
    return makeStats();
  } catch (e) {
    threw = true;
    throw e;
  } finally {
    if (!finished) {
      pending?.dispose();
      nextPending?.dispose();
    }
    if (ownsCache) for (const c of cache) c.dispose();
    history?.dispose();
    if (!finished && !threw) {
      // forced early return (consumer break at a yield): still report
      // stats — `forwarded` only lists tokens whose KV actually entered
      // the cache, so cacheTokens stays exact for PromptCache.put().
      decodeMs = performance.now() - tDecode;
      return makeStats();
    }
  }
}

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
