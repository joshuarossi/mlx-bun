// Generation gateway — the seam between the server's request handlers and the
// two execution lanes: the serial single-queue path (today's default) and the
// continuous-batching scheduler (`--batch N`). The handler builds an onToken
// closure (its own StopMatcher + tool router + SSE stream) and calls run();
// the gateway routes it to the right lane. Per-row SSE fan-out falls out for
// free — each request keeps its own onToken/stream and the scheduler just
// invokes the right row's onToken.
//
// The two lanes are MUTUALLY EXCLUSIVE on the GPU (and on shared model state
// like loraState, which generate() mutates per-generation assuming a serialized
// queue). One AsyncMutex enforces it: a serial run holds it for its duration;
// the scheduler holds it for its whole active period (first admit → batch
// empties). So batched requests run concurrently with EACH OTHER (the point),
// but never alongside a serial-lane generation. A non-batchable request DRAINS
// the batch: while any serial-lane request is waiting, the scheduler stops
// admitting new rows (admissionHeld), finishes the running ones, and releases
// the mutex; the serial request runs solo, then kick() resumes admission.
// (mlx-lm's drain_batch semantics — without this, sustained batchable traffic
// starves the serial lane forever.) Non-generation GPU/model-state work (the
// curve endpoints, adapter mount/unmount) goes through runExclusive() so there
// is exactly ONE mutual-exclusion domain.
//
// v1 batchable gate (the rest → serial): batch>1 AND every model cache is a
// dynamic-B-capable type (KVCache | RotatingKVCache — mirrors mlx-lm
// server.py's all-caches-have-merge check; Qwen3.5's SSMCache has no
// merge/filter/temporalView, so hybrid models route serial until the ArraysCache
// port — batching-v2-plan item h) AND bf16 KV (no kv-quant — the batched
// scheduler runs bf16; mixed-precision-KV batching is the novel-combo L2
// follow-up) AND no vision AND no LoRA adapters AND no repetition penalty
// (per-row logits processors are a later refinement) AND no user-fixed seed
// (reproducibility ⇒ solo, matching mlx-lm's _is_batchable). Temperature /
// top-p / top-k DO batch (each row samples with its own seed). Full-attention
// AND sliding-window (Gemma) models both batch — the scheduler assembles each
// layer's cache by type. Prompt-cache prefix reuse is bypassed under batching
// in v1 (cachedTokens = 0).

import { MlxArray } from "../mlx/array";
import type { RuntimeModel } from "../model/factory";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { KVCache, RotatingKVCache } from "../model/gemma4-base";
import type { GenerateOptions, GenerateStats, TokenLogprobs } from "../generate";
import { makeSampler, toLogprobs } from "../sampler";
import { BatchScheduler } from "./batch-scheduler";

/** Async mutex: acquire() resolves to a release fn; releases run FIFO. */
class AsyncMutex {
  #tail: Promise<void> = Promise.resolve();
  acquire(): Promise<() => void> {
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const wait = this.#tail;
    this.#tail = this.#tail.then(() => gate);
    return wait.then(() => release);
  }
}

export type Vision = { embeddings: MlxArray; imageMask: MlxArray };

/** Per-token sink: returning `false` halts this generation (stop sequence).
 *  `logprobs` is only populated on the serial lane when the request asked for
 *  logprobs capture (GenerateOptions.logprobs / topLogprobs). */
export type OnToken = (
  token: number,
  logprobs?: TokenLogprobs,
) => void | boolean | Promise<void | boolean>;

/** The serial lane — exactly today's runGeneration (prompt-cache reuse + the
 *  generate() pipeline). The gateway calls it under the mutex. */
export type SerialRun = (
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  vision?: Vision,
) => Promise<GenerateStats>;

/** What the batchable decision needs from a request (cheap to compute). */
export interface RequestShape {
  hasVision: boolean;
  hasAdapters: boolean;
  hasRepetitionPenalty: boolean;
  /** The user explicitly set `seed` (reproducibility) — not the random default. */
  userSeed: boolean;
  /** KV quantization is active (kvConfig/kvBits) — batched is bf16-only in v1. */
  kvQuant: boolean;
  /** Any of the mlx-lm sampler/processor extensions is active: min_p, XTC,
   *  logit_bias, presence/frequency penalty. Safe v1: they ALL route to the
   *  serial lane alongside repetition penalty. min_p/XTC are per-row samplers
   *  and could batch (the batched lane already builds a per-row sampler);
   *  keeping them serial until the batched path grows per-row logits
   *  processors keeps one gate for the whole family. */
  hasLogitsExtras: boolean;
  /** The request asked for logprobs/top_logprobs capture. Batch-lane logprobs
   *  are deferred (the scheduler's per-row sampler doesn't capture or read
   *  back logprob arrays yet), so these route to the serial lane like the
   *  other mlx-lm request extensions above. */
  wantsLogprobs: boolean;
}

export class GenerationGateway {
  readonly #mutex = new AsyncMutex();
  readonly #batch: number;
  #scheduler: BatchScheduler | null = null;
  /** Serial-lane requests waiting for / holding the mutex. While > 0 the
   *  scheduler pauses admission (drain) so they can't be starved. */
  #serialWaiters = 0;
  /** Lazy, memoized: can this model's caches do the dynamic-B ops? */
  #cacheBatchable: boolean | null = null;

  constructor(
    private readonly model: RuntimeModel,
    batch: number,
    private readonly serialRun: SerialRun,
  ) {
    this.#batch = Math.max(1, Math.floor(batch));
  }

  /** True if `--batch N` (N>1) is on (batchability is then per-request). */
  get batchingEnabled(): boolean {
    return this.#batch > 1;
  }

  /** Rows currently decoding in the batch (0 if no scheduler / idle). */
  get activeRows(): number {
    return this.#scheduler?.activeRows ?? 0;
  }

  /** Cache-capability gate (mirrors mlx-lm server.py's all-caches-have-merge
   *  check): the scheduler's dynamic-B ops (temporalView/merge/filter) exist
   *  only on KVCache and RotatingKVCache. A hybrid model (Qwen3.5's SSMCache)
   *  routes serial until the batched-SSM port (batching-v2-plan item h). */
  #modelCachesBatchable(): boolean {
    if (this.#cacheBatchable === null) {
      const proto = this.model.makeCache(); // fresh caches hold no buffers
      this.#cacheBatchable = proto.every(
        (c) => c instanceof KVCache || c instanceof RotatingKVCache,
      );
      for (const c of proto) c.dispose();
    }
    return this.#cacheBatchable;
  }

  /** Decide whether a request joins the batch or runs serially. */
  willBatch(shape: RequestShape): boolean {
    // DiffusionGemma is non-autoregressive — the batch scheduler assumes the AR
    // KV-cache decode path, so it always runs serially through generate().
    if (this.model instanceof DiffusionGemmaModel) return false;
    if (!this.batchingEnabled) return false;
    if (!this.#modelCachesBatchable()) return false;
    return (
      !shape.hasVision &&
      !shape.hasAdapters &&
      !shape.hasRepetitionPenalty &&
      !shape.hasLogitsExtras &&
      !shape.wantsLogprobs &&
      !shape.userSeed &&
      !shape.kvQuant
    );
  }

  /** Run `fn` with exclusive ownership of the GPU + shared model state (the
   *  serial lane's lock). THE single mutual-exclusion domain: the serial
   *  generation path, the curve /generate + /signal endpoints, and adapter
   *  mount/unmount all come through here, so nothing runs concurrently with
   *  batched decode steps (or with each other). Registers as a serial waiter
   *  so the scheduler drains (stops admitting) until `fn` has run. */
  async runExclusive<T>(fn: () => Promise<T>): Promise<T> {
    this.#serialWaiters++;
    try {
      const release = await this.#mutex.acquire();
      try {
        return await fn();
      } finally {
        release();
      }
    } finally {
      this.#serialWaiters--;
      if (this.#serialWaiters === 0) this.#scheduler?.kick(); // resume admission
    }
  }

  /** Run one generation on the appropriate lane. onToken is invoked per emitted
   *  token (its `false` halts); resolves with stats when the generation ends. */
  async run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
  ): Promise<GenerateStats> {
    if (!this.willBatch(shape))
      return this.runExclusive(() => this.serialRun(promptIds, options, onToken, vision));

    // Per-row sampler, mirroring generate()'s sampleStep (no logits processors:
    // repetition penalty was excluded by willBatch). Greedy (temperature 0) is
    // argmax; temp>0 uses this request's own seed → independent per-row RNG.
    const sampler = makeSampler(options);
    const sample = (logits1V: MlxArray, step: number): MlxArray => {
      const lp = toLogprobs(logits1V);
      const tok = sampler(lp, step);
      lp.dispose();
      return tok;
    };

    const st = await this.#ensureScheduler().submit({
      promptIds,
      maxTokens: options.maxTokens ?? 512,
      eosTokenIds: options.eosTokenIds ?? this.model.config.eosTokenIds,
      sample,
      onToken,
    });

    return {
      promptTokens: st.promptTokens,
      cachedTokens: st.cachedTokens,
      generatedTokens: st.generatedTokens,
      prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0,
      cacheTokens: [],
    };
  }

  #ensureScheduler(): BatchScheduler {
    if (!this.#scheduler)
      this.#scheduler = new BatchScheduler(this.model, {
        maxBatch: this.#batch,
        lock: { acquire: () => this.#mutex.acquire() },
        // Drain: pause admission while any serial-lane request waits; the
        // runExclusive finally-block kick()s the loop back awake.
        admissionHeld: () => this.#serialWaiters > 0,
      });
    return this.#scheduler;
  }
}
