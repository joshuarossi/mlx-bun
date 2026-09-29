import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { clearCache } from "@mlx-bun/mlx/ffi";
import type { Cache } from "../contracts/mlx/cache";
import type { RuntimeModel } from "../models/factory";
import type { GenerateOptions } from "../generation/index";
import { bindLegacyAutoregressiveModel } from "../generation/bindings/autoregressive";
import { appendGrammarSpan } from "../generation/grammar-step";
import { makeStepSampler, type DeviceStepSampler } from "../sampling/index";
import { createKvMaintenance, type KvMaintenance } from "../state/kv-maintenance";
import { cleanupFailure, disposeResources } from "../runtime/resources";
import { snapshotGenerationPolicy } from "./request-policy";
import { MlxPrefillCohort } from "./prefill-cohort";
import { DenseKvReadError, unreadableRows } from "../state/dense-kv-reads";
import type { MlxGroupedMethod, MlxGroupMethodHost, MlxGroupMethodRequest, MlxGroupPreparation, Row } from "./batch-types";

interface RequestState {
  sampling: DeviceStepSampler;
  maintain: KvMaintenance;
  caches: Cache[];
  retain?: () => void;
  pending: MlxArray | null;
}

/** Preserve committed grammar spans while the shared scheduler interleaves
 * active requests. Graph calls remain B1: spans of different lengths are not
 * padded, split, or verified. The gateway owns each borrowed grammar matcher.
 * `denseKvReads` is the graph's requirement: the layers its attention reads as
 * plain keys and values, each an index into the graph's `cacheCount` caches.
 * It is copied once; a row whose next append would not be read plain there is
 * refused before any layer appends. */
export function bindGrammarGroupRequests(model: RuntimeModel, denseKvReads: readonly number[], cacheCount: number) {
  if (!Array.isArray(denseKvReads))
    throw new TypeError("forced grammar spans require the graph's dense KV read layers");
  const layers = Object.freeze([...denseKvReads]);
  if (layers.some(layer => !Number.isSafeInteger(layer) || layer < 0 || layer >= cacheCount) || new Set(layers).size !== layers.length)
    throw new RangeError(`dense KV read layers must be distinct layer indices below ${cacheCount}`);
  return (input: GenerateOptions): MlxGroupMethodRequest => ({
    key: "grammar-forced-span", data: snapshotGenerationPolicy(input),
    open: host => new GrammarGroup(host, model, layers),
  });
}

class GrammarGroup implements MlxGroupedMethod {
  readonly #binding;
  readonly #requests = new Map<Row, RequestState>();
  #next = 0;

  constructor(readonly host: MlxGroupMethodHost, readonly model: RuntimeModel,
    readonly denseKvReads: readonly number[]) {
    this.#binding = bindLegacyAutoregressiveModel(model);
  }

  prepare(row: Row): MlxGroupPreparation {
    const options = row.req.method!.data as GenerateOptions;
    if (!row.req.grammar || options.logprobs || (options.topLogprobs ?? 0) > 0 ||
        row.req.continuation || row.req.promptInput || options.pagedKv)
      throw new Error("forced grammar span requires an ordinary grammar request without logprobs, media, paging, or continuation");
    const sampling = makeStepSampler(options, { tokenRepresentation: "device", grammarWait: "external",
      historyUpdate: "manual", initialHistory: row.req.promptIds });
    const maintain = createKvMaintenance(options);
    this.#requests.set(row, { sampling, maintain, caches: [], pending: null });
    const target = new MlxPrefillCohort({
      model: this.model, chunkSize: this.host.prefillChunkSize,
      tailSplit: this.host.runtime.flag("MLX_BUN_PREFILL_TAIL_SPLIT", true),
      promptCache: this.host.promptCache, maintain, denseKvReads: this.denseKvReads,
      forward: (ids, caches) => Promise.resolve(this.#binding.graph.forwardHidden(ids, caches)),
      project: hidden => {
        const [, length, width] = hidden.shape as [number, number, number];
        using last = hidden.slice([0, length - 1, 0], [1, length, width]);
        return this.#binding.graph.projectLogits(last, { type: "all" });
      },
      complete: async (state, logits) => {
        const request = this.#requests.get(row)!;
        await row.req.grammar!.ready();
        row.req.signal?.throwIfAborted();
        request.pending = request.sampling.sample(logits, 0).token;
        ops.asyncEvalAll([request.pending]);
        // No publication here: the first complete grammar span must enter KV
        // before even token zero becomes visible to an output callback.
        request.caches = state.solo; state.solo = [];
        request.retain = state.retain; state.retain = undefined;
        row.sampled = 1;
        this.host.join(row);
      },
      reject: (failed, error) => {
        try { this.#close(failed); }
        catch (cleanup) { error = new AggregateError([error, cleanup], "grammar preparation cleanup failed"); }
        failed.reject(error);
      },
    });
    const preparation: MlxGroupPreparation = {
      get rows() { return target.rows; },
      get tokenWeight() { return target.tokenWeight; },
      canAdmit: false, supportsMixedWork: false,
      advance: () => target.advance(),
      dispose: () => disposeResources([target, { dispose: () => {
        if (!this.host.rows.includes(row)) this.#close(row);
      } }]),
    };
    try { target.admit(row); return preparation; }
    catch (error) { return cleanupFailure(error, () => preparation.dispose()); }
  }

  async advance(): Promise<void> {
    const live = this.host.rows.flatMap((row, index) => row.req.signal?.aborted ? [] : [index]);
    if (live.length !== this.host.rows.length) {
      const cancelled = this.host.rows.filter(row => row.req.signal?.aborted).map(row => {
        let error = row.req.signal!.reason;
        try { this.#close(row); }
        catch (cleanup) { error = new AggregateError([error, cleanup], "cancelled grammar cleanup failed"); }
        return { row, error };
      });
      // Filter membership only after every cancelled owner has closed. A
      // request must not settle while its tensors are still request-owned.
      this.host.filterRows(live);
      for (const { row, error } of cancelled) row.reject(error);
    }
    if (!this.host.rows.length) return;
    const index = this.#next % this.host.rows.length;
    const row = this.host.rows[index]!;
    this.#next = index + 1;
    try { await this.#step(row); }
    catch (error) {
      try { this.#retire(row); }
      catch (cleanup) { error = new AggregateError([error, cleanup], "grammar step cleanup failed"); }
      row.reject(error);
    }
  }

  async #step(row: Row): Promise<void> {
    const state = this.#requests.get(row)!;
    const grammar = row.req.grammar!;
    row.req.signal?.throwIfAborted();
    const current = state.pending!;
    const token = ops.itemUint32(current);
    const step = row.generated;
    let forced: number[] | null = null;
    if (step + 1 < row.req.maxTokens) {
      grammar.accept(token);
      await grammar.ready();
      if (!grammar.isTerminated) {
        forced = grammar.jumpForward(row.req.maxTokens - (step + 1));
        if (forced) await grammar.ready();
      }
    }
    let next: MlxArray | null = null;
    try {
      if (forced) {
        this.#maintain(state);
        state.sampling.commitDevice(current);
        state.sampling.commitNumbers(forced);
        const after = step + 1 + forced.length;
        await appendGrammarSpan(this.#binding.graph, state.caches, [token, ...forced],
          ids => { row.fed.push(...ids); },
          after < row.req.maxTokens && !grammar.isTerminated
            ? logits => { next = state.sampling.sample(logits, after).token; } : undefined);
      } else if (step + 1 < row.req.maxTokens && !grammar.isTerminated) {
        this.#maintain(state);
        state.sampling.commitDevice(current);
        using ids = ops.reshape(current, [1, 1]);
        using hidden = await this.#binding.graph.forwardHidden(ids, state.caches);
        using logits = this.#binding.graph.projectLogits(hidden, { type: "all" });
        next = state.sampling.sample(logits, step + 1).token;
        row.fed.push(token);
      }
      if (next) ops.asyncEvalAll([next]);
      row.req.signal?.throwIfAborted();
      current.dispose(); state.pending = null;
      row.generated++;
      let stop = row.req.eosTokenIds.includes(token);
      if (!stop) {
        stop = await this.host.publish(row, token) === false;
        if (!stop) {
          row.req.signal?.throwIfAborted();
          if ((row.generated - 1) % 256 === 0) clearCache();
          for (const id of forced ?? []) {
            row.req.signal?.throwIfAborted();
            row.generated++;
            if (await this.host.publish(row, id) === false) { stop = true; break; }
            if ((row.generated - 1) % 256 === 0) clearCache();
          }
        }
      }
      row.req.signal?.throwIfAborted();
      row.sampled = row.generated + Number(next !== null);
      if (stop || !next) {
        const unused = next; next = null; unused?.dispose();
        this.#complete(row, stop || row.generated < row.req.maxTokens ? "stop" : "length");
      } else { state.pending = next; next = null; }
    } finally { next?.dispose(); }
  }

  /** One maintenance call before the step's forward, then the graph's read
   * requirement: a row whose next append would not be read plain is refused
   * with `DenseKvReadError` before any layer appends. */
  #maintain(state: RequestState): void {
    state.maintain(state.caches);
    if (unreadableRows(state.caches, this.denseKvReads, 1).length) throw new DenseKvReadError();
  }

  #complete(row: Row, reason: "stop" | "length"): void {
    const state = this.#requests.get(row)!;
    let caches = state.caches; state.caches = [];
    let retain = state.retain; state.retain = undefined;
    const release = () => {
      const owned = caches; caches = [];
      const lease = retain; retain = undefined;
      disposeResources([...owned, { dispose: () => lease?.() }]);
    };
    try {
      // Match the direct generator: pending/sampler cleanup must succeed
      // before a final prefix can become visible to another request.
      this.#retire(row);
      row.req.signal?.throwIfAborted();
      if (this.host.promptCache && !row.fedTainted) {
        this.host.promptCache.put([...row.req.promptIds, ...row.fed], caches,
          row.cacheNamespace, retain, undefined, row.req.cacheSessionId);
        caches = []; retain = undefined;
      }
    } catch (error) { return cleanupFailure(error, release); }
    release();
    this.host.finish(row, reason);
  }

  #retire(row: Row): void {
    this.host.filterRows(this.host.rows.flatMap((other, index) => other === row ? [] : [index]));
  }

  filterRows(keep: readonly number[], _discard: boolean): void {
    const retained = new Set(keep.map(index => this.host.rows[index]!));
    const removed = this.host.rows.filter(row => !retained.has(row));
    this.#next = keep.filter(index => index < this.#next).length;
    disposeResources(removed.map(row => ({ dispose: () => this.#close(row) })));
  }

  #close(row: Row): void {
    const state = this.#requests.get(row);
    if (!state) return;
    this.#requests.delete(row);
    disposeResources([...(state.pending ? [state.pending] : []), state.sampling,
      ...state.caches, { dispose: () => state.retain?.() }]);
  }

  dispose(): void {
    disposeResources([...this.#requests.keys()].map(row => ({ dispose: () => this.#close(row) })));
  }
}
