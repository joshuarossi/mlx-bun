import { AdmissionPool } from "@mlx-bun/inference/execution/admission";
import { cleanupFailure, disposeResources } from "@mlx-bun/inference/runtime/resources";
import type { createRowSampling, MlxGatewayBinding, MlxBatchGroup, RowPromptCache } from "@mlx-bun/inference/execution";
import type { GenerateOptions, GenerateStats } from "@mlx-bun/inference/generation";
import type { KvScheme } from "@mlx-bun/inference/state/kv-scheme";
import type { RuntimeConfig } from "@mlx-bun/inference/runtime/config";
import type { PromptResponseTrace } from "@mlx-bun/inference/runtime/trace";
import type { CacheCodecProvider } from "@mlx-bun/inference/state";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { CompletionEngine, RequestShape, GenerationPlacement, Vision, OnToken } from "./completion";
import { acquireReservation } from "./preparation";

/** Async mutex: acquire() resolves to a release fn; releases run FIFO. */
class AsyncMutex {
  #tail: Promise<void> = Promise.resolve();
  /** Holders + waiters. > 0 means somebody owns or wants the engine. */
  #pending = 0;
  get locked(): boolean {
    return this.#pending > 0;
  }
  acquire(signal?: AbortSignal): Promise<() => void> {
    if (signal?.aborted) return Promise.reject(signal.reason);
    this.#pending++;
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const wait = this.#tail;
    this.#tail = this.#tail.then(() => gate);
    let released = false;
    const unlock = () => {
      if (released) return; // idempotent: a double release must not skew #pending
      released = true;
      this.#pending--;
      release();
    };
    return new Promise((resolve, reject) => {
      let settled = false;
      const abort = () => {
        if (settled) return;
        settled = true;
        signal?.removeEventListener("abort", abort);
        // Release this waiter's gate, not its predecessor's. Later acquirers
        // still wait for the active holder, preserving mutual exclusion.
        unlock();
        reject(signal!.reason);
      };
      signal?.addEventListener("abort", abort, { once: true });
      wait.then(() => {
        if (settled) return;
        settled = true;
        signal?.removeEventListener("abort", abort);
        resolve(unlock);
      });
    });
  }
}

export function disposeUnstartedRequest(options: GenerateOptions, vision?: Vision): void {
  disposeResources([options.grammar, vision?.embeddings, vision?.imageMask,
    vision?.multimodalMask, options.visionPixels].filter((resource) => resource != null));
}

/** One app execution lane: lone and concurrent requests use the same library
 * scheduler. Exclusive leases protect mutations and managed jobs. */
export class GenerationGateway implements CompletionEngine {
  #closed = false;
  readonly #runtime: RuntimeConfig;
  readonly #binding: MlxGatewayBinding;
  readonly #requests: AdmissionPool;
  readonly #mutex = new AsyncMutex();
  readonly #batch: number;
  #scheduler: MlxBatchGroup | null = null;
  #rowsSubmitted = 0;

  #exclusiveWaiters = 0;
  /** Lazy, memoized: can the configured KV scheme convert every named cache? */
  #kvSchemeBatchable: boolean | null = null;
  constructor(
    binding: MlxGatewayBinding,
    capacity: number,
    private readonly opts: {
      kvBudgetBytes?: number;
      checkpoints?: boolean;
      stateCodecs?: CacheCodecProvider;
    
      kvScheme?: KvScheme;
    
      promptCache?: RowPromptCache;
      adapterNamespace?: (adapters: string[]) => string;
    } = {},
  ) {
    this.#binding = binding;
    this.#runtime = this.#binding.runtime;
    this.opts = Object.freeze({ ...opts });
    if (!Number.isSafeInteger(capacity) || capacity < 1) throw new Error("execution capacity must be a positive integer");
    this.#batch = capacity;
    this.#requests = new AdmissionPool(this.#batch);
  }

  /** Rows currently decoding in the batch (0 if no scheduler / idle). */
  get activeRows(): number {
    return this.#scheduler?.activeRows ?? 0;
  }

  /** Queued + mid-prefill rows waiting behind the batch (0 when idle). */
  get pendingRows(): number {
    return this.#scheduler?.pendingRows ?? 0;
  }

  get busy(): boolean {
    return this.#requests.active > 0 || this.#requests.queued > 0 ||
      this.#mutex.locked || this.activeRows > 0 || this.pendingRows > 0;
  }

  async close(): Promise<void> {
    this.#closed = true;
    this.#requests.close();
    try { await this.#scheduler?.close(); }
    finally { await this.onIdle(); }
  }

  /** Observe idleness. Call runWhenIdle for background work that must also
   * acquire ownership atomically with the idle check. */
  async onIdle(pollMs = 20): Promise<void> {
    while (this.busy) await new Promise<void>((r) => setTimeout(r, pollMs));
  }

  /** Background work waits without requesting a batch drain. The final busy
   * check and mutex acquisition have no await between them, so a foreground
   * request cannot enter between the check and ownership registration. */
  async runWhenIdle<T>(fn: () => Promise<T>, pollMs = 20): Promise<T> {
    while (this.busy) await new Promise<void>(resolve => setTimeout(resolve, pollMs));
    return this.runExclusive(fn);
  }

  get submittedRows(): number {
    return this.#rowsSubmitted;
  }

  /** Projected aggregate KV bytes of admitted rows / the --kv-budget cap. */
  get kvBytes(): { projected: number; budget: number | null } {
    return {
      projected: this.#scheduler?.projectedKvBytes ?? 0,
      budget: this.#scheduler?.kvBudgetBytes ?? this.opts.kvBudgetBytes ?? null,
    };
  }

  #kvBatchable(): boolean {
    return this.#kvSchemeBatchable ??= !!this.opts.kvScheme && this.#binding.kvBatchable(this.opts.kvScheme);
  }

  place(shape: RequestShape, options: GenerateOptions = {}): GenerationPlacement {
    if (this.#closed) throw new Error("generation gateway is closed");
    const frozenShape = Object.freeze(shape);
    const execution = this.#binding.plan(frozenShape, options, {
      continuous: this.#binding.cachesBatchable(),
      quantizedBatch: (shape.kvQuant || shape.turboQuant) && this.#kvBatchable(),
      checkpoints: this.opts.checkpoints === true,
    });
    if (execution.mechanism !== "continuous")
      throw new Error(`model ${this.#binding.config.modelType} method ${execution.method} does not support shared execution: ${execution.reasons.join(", ")}`);
    return Object.freeze({ shape: frozenShape, mechanism: "continuous", execution });
  }

  /** Shared by inference, preparation and managed GPU subprocesses. */
  async acquireExecutionLease(
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<DisposableResource> {
    if (this.#closed) throw new Error("generation gateway is closed");
    this.#exclusiveWaiters++;
    const closeAdmission = trace?.begin("engine.admission_wait", { mechanism: "exclusive" });
    const resume = () => {
      this.#exclusiveWaiters--;
      if (this.#exclusiveWaiters === 0) this.#scheduler?.kick();
    };
    try {
      const release = await this.#mutex.acquire(signal);
      let released = false;
      return { dispose: () => {
        if (released) return;
        released = true;
        release(); resume();
      } };
    } catch (error) { resume(); throw error; }
    finally { closeAdmission?.(); }
  }

  async runExclusive<T>(
    fn: () => Promise<T>,
    trace?: PromptResponseTrace,
    signal?: AbortSignal,
  ): Promise<T> {
    const lease = await this.acquireExecutionLease(signal, trace);
    try { return await fn(); } finally { lease.dispose(); }
  }

  /** Preparation reads model weights without replacing active model state.
   * A compatible backend can perform it between existing decode iterations. */
  runPreparation<T>(work: () => Promise<T>, signal?: AbortSignal): Promise<T> {
    if (this.#closed) return Promise.reject(new Error("generation gateway is closed"));
    if (signal?.aborted) return Promise.reject(signal.reason);
    const group = this.#ensureScheduler();
    return group?.runPreparation
      ? group.runPreparation(work, signal)
      : this.runExclusive(work, undefined, signal);
  }

  get mediaBatchingEnabled(): boolean { return !!this.#binding.mediaInput; }

  /** Run one generation through the shared scheduler. onToken is invoked per emitted
   *  token (its `false` halts); resolves with stats when the generation ends. */
  async run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
    placement: GenerationPlacement,
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<GenerateStats> {
    let reservation;
    const closeRequestWait = trace?.begin("engine.request_wait", { capacity: this.#batch });
    try { reservation = await acquireReservation(this.#requests, signal); }
    catch (error) { cleanupFailure(error, () => disposeUnstartedRequest(options, vision)); }
    finally { closeRequestWait?.(); }
    let releasePrefix: (() => void) | undefined;
    try {
      try {
        const adapters = options.adapters?.length
          ? this.opts.adapterNamespace?.(options.adapters) ?? JSON.stringify(options.adapters) : "";
        const baseNamespace = this.#binding.prefixNamespace?.(placement.execution, options, adapters) ??
          (placement.execution?.method === "speculative" ? null : adapters);
        const namespace = baseNamespace !== null && vision?.prefixIdentity
          ? JSON.stringify(["prepared-prefix-v1", vision.prefixIdentity, baseNamespace]) : baseNamespace;
        if ((!vision || placement.execution?.promptCache) && namespace !== null) {
          const closePrefetch = this.opts.promptCache?.prefetch ? trace?.begin("cache.prefetch") : undefined;
          try { releasePrefix = await this.opts.promptCache?.prefetch?.(promptIds, namespace, options.cacheSessionId); }
          finally { closePrefetch?.(); }
        }
      } catch (error) { cleanupFailure(error, () => disposeUnstartedRequest(options)); }
      return await this.#run(promptIds, options, onToken, vision, shape, placement, signal, trace);
    } finally {
      disposeResources([{ dispose: () => releasePrefix?.() }, reservation,
        ...(vision
          ? [vision.embeddings, vision.imageMask, vision.multimodalMask].filter(value => value != null) : [])]);
    }
  }

  async #run(
    promptIds: number[],
    options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken,
    vision: Vision | undefined,
    shape: RequestShape,
    placement: GenerationPlacement,
    signal?: AbortSignal,
    trace?: PromptResponseTrace,
  ): Promise<GenerateStats> {
    const disposeUnstarted = () => disposeUnstartedRequest(options);
    if (placement.shape !== shape) {
      disposeUnstarted();
      throw new Error("generation placement does not belong to this request shape");
    }
    try {
      signal?.throwIfAborted();
    } catch (e) {
      // The gateway is the first component that accepts ownership of a
      // compiled controller. An aborted request never reaches the scheduler.
      disposeUnstarted();
      throw e;
    }
    let sampling: ReturnType<typeof createRowSampling> | undefined;
    let closeAdmission: (() => void) | undefined;
    let st;
    try {
      const adapters = options.adapters?.length ? [...options.adapters] : undefined;
      const adapterKey = adapters ? JSON.stringify(adapters) : "";
      const adapterNamespace = () => adapters ? this.opts.adapterNamespace?.(adapters) ?? adapterKey : "";
      const cacheNamespace = vision?.prefixIdentity
        ? () => JSON.stringify(["prepared-prefix-v1", vision.prefixIdentity, adapterNamespace()])
        : adapters ? adapterNamespace : "";
      const context = adapters
        ? this.#binding.bindAdapterContext?.(adapters, `adapters:${adapterKey}`) : undefined;

      // The scheduler owns grammar ready/accept sequencing. StepSampler owns the
      // shared processors -> mask -> logprobs -> sample -> history contract.
      const method = this.#binding.methodRequest?.(placement.execution, options);
      const continuation = method ? undefined : this.#binding.continuationRequest?.(placement.execution, options, promptIds, onToken);
      if (!method && !continuation) {
        const [{ createRowSampling }, { makeStepSampler }] = await Promise.all([
          import("@mlx-bun/inference/execution"), import("@mlx-bun/inference/sampling"),
        ]);
        sampling = createRowSampling(makeStepSampler(options, {
        tokenRepresentation: "device", grammarWait: "external",
        historyUpdate: "after-sample", initialHistory: promptIds,
        captureSelectedLogprob: options.logprobs === true,
        captureTopLogprobs: options.topLogprobs,
        }), onToken);
      } else { sampling = continuation; }

      signal?.throwIfAborted();
      this.#rowsSubmitted++;
      closeAdmission = trace?.begin("engine.admission_wait", {
        mechanism: "continuous",
      });
      st = await this.#ensureScheduler().submit({
        promptIds, context, cacheNamespace, cacheSessionId: options.cacheSessionId, prefillChunkSize: options.prefillChunkSize,
        ...(vision ? { promptInput: this.#binding.mediaInput!(vision) } : {}),
        continuation: continuation?.continuation,
        statePolicy: this.#binding.statePolicy?.(placement.execution, options, promptIds.length + (options.maxTokens ?? 512)),
        compiledDecode: placement.execution?.compiledDecode,
        maxTokens: options.maxTokens ?? 512,
        eosTokenIds: options.eosTokenIds ?? this.#binding.config.eosTokenIds,
        ...(method ? { method, onToken } : { sample: sampling!.sample,
          plainGreedy: sampling!.plainGreedy, onToken: sampling!.onToken }),
        onAdmitted: closeAdmission,
        trace,
        ...(signal ? { signal } : {}),
        // B1: pass the per-row grammar controller through. The scheduler drives
        // accept/ready/terminate; this gateway OWNS disposal (finally below)
        // across resolve, reject, eviction, and the whole-batch-drop error path.
        ...(options.grammar ? { grammar: options.grammar } : {}),
        // Capture reusable prefixes at the established stable boundary.
        ...(options.snapshotAt !== undefined ? { snapshotAt: options.snapshotAt } : {}),
      });
    } finally {
      // Attempt all request-owned releases even if a destructor fails.
      disposeResources([{ dispose: () => closeAdmission?.() }, sampling, options.grammar]
        .filter((resource) => resource != null));
    }

    return {
      promptTokens: st.promptTokens,
      cachedTokens: st.cachedTokens,
      generatedTokens: st.generatedTokens,
      finishReason: st.finishReason,
      prefillMs: st.prefillMs,
      decodeMs: st.decodeMs,
      prefillTps: st.prefillMs > 0 ? ((st.promptTokens - st.cachedTokens) / st.prefillMs) * 1000 : 0,
      decodeTps: st.decodeMs > 0 && st.generatedTokens > 1 ? ((st.generatedTokens - 1) / st.decodeMs) * 1000 : 0,
      cacheTokens: [],
      ...(st.spec ? { spec: st.spec } : {}),
      ...(st.fill ? { fill: st.fill } : {}),
    };
  }

  #ensureScheduler(): MlxBatchGroup {
    if (!this.#scheduler)
      this.#scheduler = this.#binding.createBatchGroup({
        runtime: this.#runtime,
        maxBatch: this.#batch,
        stateCodecs: this.opts.stateCodecs,
        kvBudgetBytes: this.opts.kvBudgetBytes,

        // Preserve the binding-selected cache conversion policy.
        kvScheme: this.#kvBatchable() ? this.opts.kvScheme : undefined,
        promptCache: this.opts.promptCache,
        lock: { acquire: () => this.#mutex.acquire() },

        // Exclusive mutations drain current rows before acquiring the model.
        admissionHeld: () => this.#exclusiveWaiters > 0,
      });
    return this.#scheduler;
  }
}
