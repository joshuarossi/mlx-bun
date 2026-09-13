import type { GenerateOptions } from "../../generate";
import type { RuntimeModel } from "../../model/factory";
import type { Cache } from "../../model/gemma4-base";
import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { clearCache } from "../../mlx/ffi";
import { makeStepSampler, type DeviceStepSampler } from "../../sampler";
import type { FillSession, Proposal } from "../../fill/fill-session";
import { disposeResources, cleanupFailure, withResource } from "../../engine/resources";
import { snapshotGenerationPolicy } from "./request-policy";
import { MlxPrefillCohort } from "./prefill-cohort";
import { MlxStateRows } from "./state-rows";
import { targetCacheLayout } from "./cache-layout";
import { leaseCacheStates } from "./state-views";
import { createKvMaintenance, type KvMaintenance } from "./kv-maintenance";
import { bindLegacyAutoregressiveModel, supportsCommittedAppendCache, type MlxAutoregressiveBinding, type MlxTokenAppend } from "./autoregressive";
import { appendHiddenRows } from "./fill-append";
import type { MlxForwardWork } from "./mixed-iteration";
import type { MlxGroupedMethod, MlxGroupMethodHost, MlxGroupMethodRequest,
  MlxGroupPreparation, Row } from "./batch-group";

interface RequestState {
  sampling: DeviceStepSampler;
  fill: FillSession;
  proposal?: { value: Proposal; emitted: number };
}

/** Strict continuations share preparation, row layouts and queueing with other
 * methods. Sampled tokens remain pipelined; committed tokens bypass sampling.
 * This binding is qualified independently before serving advertises it. */
export function bindFillGroupRequests(model: RuntimeModel) {
  return (input: GenerateOptions): MlxGroupMethodRequest => {
    const options = snapshotGenerationPolicy(input);
    return {
      key: JSON.stringify(["fill", options.kvBits ?? null, options.kvGroupSize ?? 64,
        options.quantizedKvStart ?? null, options.turboQuant ?? null, options.kvConfig ?? null]),
      data: options,
      open: host => new FillGroup(host, model, options),
    };
  };
}

class FillGroup implements MlxGroupedMethod {
  readonly #binding: MlxAutoregressiveBinding;
  readonly #maintain: KvMaintenance;
  readonly #append: MlxTokenAppend | null | undefined;
  readonly #requests = new Map<Row, RequestState>();
  #target: MlxStateRows | null = null;
  #pending: MlxArray | null = null;
  #known: boolean[] = [];
  #real: boolean[] = [];
  #steps = 0;

  constructor(readonly host: MlxGroupMethodHost, readonly model: RuntimeModel, options: GenerateOptions) {
    this.#binding = bindLegacyAutoregressiveModel(model);
    this.#maintain = createKvMaintenance(options);
    const append = this.#binding.createAppend?.({ hasAdapters: !!this.#binding.adapters?.active.length, pagedKv: false });
    this.#append = supportsCommittedAppendCache(append, options) ? append : null;
  }

  get runningTokens(): number { return this.host.rows.length * Math.max(1, this.#burstLength()); }

  #burstLength(): number {
    const rows = this.host.rows;
    if (!rows.length || !this.#pending || this.#known.some(known => !known) ||
        (this.#append?.maxChunkSize(this.#target!.caches, rows.length) ?? 1) <= 1) return 0;
    return Math.min(...rows.map(row => {
      const proposal = this.#requests.get(row)!.proposal;
      return proposal ? proposal.value.ids.length - proposal.emitted : 0;
    }));
  }

  prepare(first: Row): MlxGroupPreparation {
    const ready: { row: Row; caches: Cache[]; retain?: () => void }[] = [];
    const target = new MlxPrefillCohort({
      model: this.model, chunkSize: this.host.prefillChunkSize,
      tailSplit: this.host.runtime.flag("MLX_BUN_PREFILL_TAIL_SPLIT", true),
      promptCache: this.host.promptCache, maintain: this.#maintain,
      forward: async (ids, caches) => this.#binding.graph.forwardHidden(ids, caches),
      project: hidden => this.#binding.graph.projectLogits(hidden, { type: "all" }),
      complete: async (state, logits) => {
        const row = state.row;
        const request = this.#requests.get(row)!;
        using scores = ops.reshape(logits, [1, logits.shape.at(-1)!]);
        using token = request.sampling.sample(scores, 0).token;
        row.generated = row.sampled = 1;
        try {
          const reason = await this.#emit(row, token.toIntTokens()[0]!, false);
          this.#maintain(state.solo);
          if (reason) {
            this.#put(row, state.solo, state.retain);
            state.solo = []; state.retain = undefined;
            this.#closeRequest(row); this.host.finish(row, reason);
          } else {
            ready.push({ row, caches: state.solo, retain: state.retain });
          }
        } catch (error) { this.#closeRequest(row); throw error; }
      },
      reject: (row, error) => { this.#closeRequest(row); row.reject(error); },
    });
    const admit = (row: Row) => {
      const options = row.req.method!.data as GenerateOptions;
      const request: RequestState = { fill: options.fill!,
        sampling: makeStepSampler(options, { tokenRepresentation: "device", grammarWait: "external",
          historyUpdate: "manual", initialHistory: row.req.promptIds }) };
      row.fill = request.fill.stats;
      this.#requests.set(row, request);
      try { target.admit(row); }
      catch (error) { this.#closeRequest(row); throw error; }
    };
    const preparation: MlxGroupPreparation = {
      get rows() { return [...target.rows, ...ready.map(state => state.row)]; },
      get canAdmit() { return target.canAdmit; },
      get tokenWeight() { return target.tokenWeight + ready.reduce((sum, state) => sum + state.row.promptTokens - state.row.cachedTokens, 0); },
      admit,
      advance: async work => {
        if (!ready.length) {
          const done = await target.advance(work);
          return done && !ready.length;
        }
        // Flush before membership changes. Prepared output was already
        // published on the preceding scheduler iteration.
        await this.#flush();
        while (ready.length) {
          const state = ready.shift()!;
          try {
            if (state.row.req.signal?.aborted) {
              this.#closeRequest(state.row); state.row.reject(state.row.req.signal.reason); continue;
            }
            this.#maintain.prepareBatch?.(state.caches);
            this.#target ??= new MlxStateRows(state.caches.map(targetCacheLayout));
            this.#target.append(state.caches);
            // Copies must settle before releasing a restored SSD lease.
            if (state.retain) withResource(leaseCacheStates(this.#target.caches), arrays => ops.evalAll([...arrays]));
            this.host.join(state.row);
          } finally { disposeResources([...state.caches, { dispose: () => state.retain?.() }]); }
        }
        return !target.rows.length;
      },
      dispose: () => {
        const rows = preparation.rows;
        disposeResources([target, ...ready.splice(0).flatMap(state => [...state.caches,
          { dispose: () => state.retain?.() }]), { dispose: () => {
          for (const row of rows) if (!this.host.rows.includes(row)) this.#closeRequest(row);
        } }]);
      },
    };
    try { admit(first); return preparation; }
    catch (error) { return cleanupFailure(error, () => preparation.dispose()); }
  }

  async advance(work?: MlxForwardWork): Promise<void> {
    const live = this.host.rows.flatMap((row, index) => row.req.signal?.aborted ? [] : [index]);
    if (live.length !== this.host.rows.length) {
      for (const row of this.host.rows) if (row.req.signal?.aborted) row.reject(row.req.signal.reason);
      this.host.filterRows(live);
    }
    const rows = [...this.host.rows], B = rows.length;
    if (!B) return;
    const burst = this.#burstLength();
    if (!work && burst > 1) { await this.#appendKnown(burst); return; }
    const previous = this.#pending, known = this.#known, real = this.#real;
    const anyLive = rows.some(row => row.sampled < row.req.maxTokens);
    let next: MlxArray | null = null;
    const nextKnown: boolean[] = [], nextReal: boolean[] = [];
    if (anyLive) {
      using input = previous ? ops.reshape(previous, [B, 1]) : ops.fromInt32(rows.map(row => row.current), [B, 1]);
      using hidden = await (work ? work(input, this.#target!.caches) : this.#binding.graph.forwardHidden(input, this.#target!.caches));
      const selected = rows.map((row, index) => {
        const request = this.#requests.get(row)!;
        // The next selected token is not committed until it becomes input.
        // Discarding a speculative sample for an assert cannot pollute history.
        if (request.sampling.needsHistory) {
          using current = input.slice([index, 0], [index + 1, 1]);
          request.sampling.commitDevice(current);
        }
        const value = request.proposal?.value.ids[request.proposal.emitted + Number(!!previous && known[index])];
        nextKnown.push(value !== undefined); nextReal.push(row.sampled < row.req.maxTokens);
        return value;
      });
      const needScores = rows.some((_row, index) => nextReal[index] && !nextKnown[index]);
      using logits = needScores ? this.#binding.graph.projectLogits(hidden, { type: "last" }) : null;
      const tokens: MlxArray[] = [];
      try {
        for (let index = 0; index < B; index++) {
          const row = rows[index]!;
          if (!nextReal[index]) { tokens.push(ops.fromInt32([0], [1])); continue; }
          if (nextKnown[index]) tokens.push(ops.fromInt32([selected[index]!], [1]));
          else {
            using slice = logits!.slice([index, 0, 0], [index + 1, 1, logits!.shape[2]!]);
            using scores = ops.reshape(slice, [1, slice.shape[2]!]);
            tokens.push(this.#requests.get(row)!.sampling.sample(scores, row.sampled).token);
          }
          row.sampled++;
        }
        next = ops.concatAxis(tokens, 0);
        // Constant known tokens have no dependency on the model graph.
        // Submit state explicitly when the vocabulary projection is omitted.
        if (needScores) ops.asyncEvalAll([next]);
        else withResource(leaseCacheStates(this.#target!.caches), state => ops.asyncEvalAll([next!, hidden, ...state]));
      } catch (error) { next?.dispose(); next = null; throw error; }
      finally { disposeResources(tokens); }
    }
    this.#pending = next; this.#known = nextKnown; this.#real = nextReal;
    if (previous) {
      let values: number[];
      try { values = previous.toIntTokens(); } finally { previous.dispose(); }
      if (anyLive) for (let index = 0; index < B; index++) {
        if (real[index]) rows[index]!.fed.push(values[index]!);
        else rows[index]!.fedTainted = true;
      }
      await this.#emitRows(values, known);
    } else if (anyLive) for (const row of rows) row.fed.push(row.current);
    if (++this.#steps % 256 === 0) clearCache();
  }

  /** Multi-position arithmetic is model-owned. Wider cohorts whose model
   * declares one position keep the pipelined single-position implementation. */
  async #appendKnown(length: number): Promise<void> {
    const rows = [...this.host.rows], B = rows.length;
    const spans = new Map(rows.map(row => {
      const proposal = this.#requests.get(row)!.proposal!;
      return [row, proposal.value.ids.slice(proposal.emitted, proposal.emitted + length)] as const;
    }));
    using input = ops.fromInt32(rows.flatMap(row => spans.get(row)!), [B, length]);
    using hidden = await appendHiddenRows(this.#append!.forwardHidden.bind(this.#append), this.#target!.caches, input,
      (caches, count) => Math.min(this.#append!.maxChunkSize(caches, count),
        this.#maintain.maxAppendTokens?.(caches) ?? Infinity,
        ...rows.map(row => this.#requests.get(row)!.fill.appendChunkSize || Infinity)));
    const nextKnown: boolean[] = [], nextReal: boolean[] = [];
    const selected = rows.map(row => {
      const request = this.#requests.get(row)!, proposal = request.proposal!;
      request.sampling.commitNumbers(spans.get(row)!);
      row.fed.push(...spans.get(row)!);
      const next = proposal.value.ids[proposal.emitted + length];
      const real = row.generated + length < row.req.maxTokens;
      nextKnown.push(next !== undefined); nextReal.push(real);
      row.sampled = row.generated + length + Number(real);
      return next;
    });
    const needScores = rows.some((_row, index) => nextReal[index] && !nextKnown[index]);
    using logits = needScores ? this.#binding.graph.projectLogits(hidden, { type: "last" }) : null;
    const tokens: MlxArray[] = [];
    let next: MlxArray | null = null;
    try {
      for (const [index, row] of rows.entries()) {
        if (!nextReal[index] || nextKnown[index]) tokens.push(ops.fromInt32([selected[index] ?? 0], [1]));
        else {
          using slice = logits!.slice([index, 0, 0], [index + 1, 1, logits!.shape[2]!]);
          using scores = ops.reshape(slice, [1, slice.shape[2]!]);
          tokens.push(this.#requests.get(row)!.sampling.sample(scores, row.generated + length).token);
        }
      }
      next = ops.concatAxis(tokens, 0);
      if (needScores) ops.asyncEvalAll([next]);
      else withResource(leaseCacheStates(this.#target!.caches), state => ops.asyncEvalAll([hidden, ...state]));
      this.#pending!.dispose(); this.#pending = next; next = null;
      this.#known = nextKnown; this.#real = nextReal;
    } finally { next?.dispose(); disposeResources(tokens); }
    for (let column = 0; column < length && this.host.rows.length; column++) {
      const active = [...this.host.rows];
      await this.#emitRows(active.map(row => spans.get(row)![column]!), active.map(() => true));
    }
    if (++this.#steps % 256 === 0) clearCache();
  }

  async #emit(row: Row, token: number, known: boolean): Promise<"stop" | "length" | undefined> {
    row.req.signal?.throwIfAborted();
    const request = this.#requests.get(row)!;
    if (row.req.eosTokenIds.includes(token)) return "stop";
    // Account a known token even when the consumer stops on this token.
    if (known) {
      const proposal = request.proposal!;
      if (++proposal.emitted === proposal.value.ids.length) {
        request.fill.commit(proposal.value, proposal.emitted); request.proposal = undefined;
      }
    }
    if (!known) {
      const proposal = request.fill.push(token, row.req.maxTokens - row.generated);
      if (proposal) {
        if (proposal.policy === "assert" && proposal.origin !== "echo") request.proposal = { value: proposal, emitted: 0 };
        else request.fill.commit(proposal, 0);
      }
    }
    const more = await this.host.publish(row, token);
    if (more === false) return "stop";
    if (row.generated >= row.req.maxTokens) return "length";
    row.current = token;
  }

  async #emitRows(values: number[], known: readonly boolean[]): Promise<void> {
    const rows = [...this.host.rows], keep: number[] = [];
    const replacement = new Map<number, number>();
    for (let index = 0; index < rows.length; index++) {
      const row = rows[index]!;
      row.generated++;
      try {
        const reason = await this.#emit(row, values[index]!, known[index] ?? false);
        if (reason) {
          this.#put(row, this.#target!.extractRow(index));
          this.#settleProposal(row); this.host.finish(row, reason);
        } else {
          keep.push(index);
          const request = this.#requests.get(row)!;
          if (!known[index] && request.proposal && this.#pending) {
            replacement.set(index, request.proposal.value.ids[0]!);
            request.fill.noteWastedSample(); this.#known[index] = true;
          }
        }
      } catch (error) { row.reject(error); }
    }
    if (replacement.size) {
      const parts: MlxArray[] = [];
      try {
        for (let index = 0; index < rows.length; index++) parts.push(replacement.has(index)
          ? ops.fromInt32([replacement.get(index)!], [1]) : this.#pending!.slice([index], [index + 1]));
        const next = ops.concatAxis(parts, 0); this.#pending!.dispose(); this.#pending = next;
      } finally { disposeResources(parts); }
    }
    if (keep.length !== rows.length) this.host.filterRows(keep);
  }

  async #flush(): Promise<void> {
    const pending = this.#pending, known = this.#known;
    if (!pending) return;
    this.#pending = null; this.#known = []; this.#real = [];
    let values: number[];
    try { values = pending.toIntTokens(); } finally { pending.dispose(); }
    await this.#emitRows(values, known);
  }

  #put(row: Row, caches: Cache[], retain?: () => void): void {
    try {
      if (this.host.promptCache && !row.fedTainted && !row.req.signal?.aborted) {
        this.host.promptCache.put([...row.req.promptIds, ...row.fed], caches,
          row.cacheNamespace, retain, undefined, row.req.cacheSessionId);
        caches = []; retain = undefined;
      }
    } finally { disposeResources([...caches, { dispose: () => retain?.() }]); }
  }

  #settleProposal(row: Row): void {
    const request = this.#requests.get(row);
    if (request?.proposal) {
      const proposal = request.proposal; request.proposal = undefined;
      request.fill.commit(proposal.value, proposal.emitted);
    }
  }
  #closeRequest(row: Row): void {
    this.#settleProposal(row);
    const request = this.#requests.get(row); this.#requests.delete(row); request?.sampling.dispose();
  }
  filterRows(keep: readonly number[], _discard: boolean): void {
    if (this.#pending) {
      using indices = ops.fromInt32([...keep], [keep.length]);
      const next = keep.length ? ops.takeAxis(this.#pending, indices, 0) : null;
      this.#pending.dispose(); this.#pending = next;
    }
    this.#known = keep.map(index => this.#known[index]!); this.#real = keep.map(index => this.#real[index]!);
    this.#target?.filterRows(keep);
    const retained = new Set(keep.map(index => this.host.rows[index]!));
    for (const row of this.host.rows) if (!retained.has(row)) this.#closeRequest(row);
  }
  dispose(): void {
    const pending = this.#pending, target = this.#target;
    this.#pending = null; this.#target = null;
    disposeResources([...(pending ? [pending] : []), ...(target ? [target] : []),
      { dispose: () => { for (const row of this.#requests.keys()) this.#closeRequest(row); } }]);
  }
}
