import {captureSpeculativeOptions, speculativePrefixNamespace} from "../../spec/cache-identity";
import type { RuntimeModel } from "../../model/factory";
import type { GenerateOptions } from "../../generate";
import type { DraftProvider, DraftRowGroup, DraftPrefillGroup, DraftRowCheckpoint } from "../../spec/source";
import { makeSampler, makeStepSampler, readStepExtras, type NumberStepSampler, type Sampler } from "../../sampler";
import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { clearCache } from "../../mlx/ffi";
import { applyStateChanges, cleanupFailure, disposeResources } from "../../engine/resources";
import { cloneKvCaches } from "../../kv-store";
import type { Cache } from "../../model/gemma4-base";
import { targetCacheLayout } from "./cache-layout";
import { MlxStateRows } from "./state-rows";
import { bindSpeculativeTargetModel, type MlxSpeculativeTargetBinding } from "./speculative";
import { bindLegacyDraftTarget } from "./draft-target";
import { bindRowCacheRollback } from "./rollback";
import { createKvMaintenance } from "./kv-maintenance";
import { disposeAttachments, type CheckpointAttachment } from "./checkpoint-state";
import { advanceSpeculativeOutputs } from "./speculative-round";
import { MlxPrefillRows, type MlxPrefillState } from "./prefill-rows";
import type { MlxForwardWork } from "./mixed-iteration";
import type { MlxGroupMethodHost, MlxGroupMethodRequest, MlxGroupPreparation, MlxGroupedMethod, Row } from "./batch-group";

interface RequestState {
  sampling: NumberStepSampler;
  draftSampling: Sampler;
  retain?: () => void;
  namespace: string;
  prefixLength: number;
  /** Generated inputs retained by committed target/draft rounds. The pending
   * correction is excluded until a later round actually processes it. */
  processed?: number[];
}

/** Binding owns graph/layout selection. The executor receives only the method
 * key and lifecycle; sampling, checkpoints and numerical state remain ports. */
export function bindSpeculativeGroupRequests(model: RuntimeModel, provider: Pick<DraftProvider, "id" | "grouped">, depth: number) {
  const binding = bindSpeculativeTargetModel(model);
  return (input: GenerateOptions): MlxGroupMethodRequest => {
    const options = captureSpeculativeOptions(input);
    return {
      key: JSON.stringify(["speculative", provider.id, depth, options.kvBits ?? null,
        options.kvGroupSize ?? 64, options.quantizedKvStart ?? null, options.turboQuant ?? null,
        ...(options.kvConfig?.length ? [options.kvConfig] : [])]),
      data: options,
      open: host => new SpeculativeGroup(host, model, provider, binding, depth),
    };
  };
}

class SpeculativeGroup implements MlxGroupedMethod {
  #target: MlxStateRows<ReturnType<typeof targetCacheLayout>> | null = null;
  #draft: DraftRowGroup | null = null;
  readonly #requests = new Map<Row, RequestState>();
  #steps = 0;

  constructor(readonly host: MlxGroupMethodHost, readonly model: RuntimeModel,
    readonly provider: Pick<DraftProvider, "id" | "grouped">, readonly binding: MlxSpeculativeTargetBinding, readonly depth: number) {}

  get runningTokens(): number {
    const rows = this.host.rows;
    if (!rows.length) return 0;
    // Target verification consumes the pending token and the draft candidates.
    return rows.length * (1 + Math.min(this.depth, Math.max(...rows.map(row => row.req.maxTokens - row.generated))));
  }

  prepare(first: Row): MlxGroupPreparation {
    const method = this;
    const options = first.req.method!.data as GenerateOptions;
    const maintain = createKvMaintenance(options);
    interface Preparation extends MlxPrefillState {
      request: RequestState;
      end: number;
      chunkSize: number;
      pendingPrompt: boolean;
      boundary: number;
      transferred: boolean;
      closed: boolean;
    }
    interface Ready {
      row: Row;
      request: RequestState;
      caches: Cache[];
      draft: DraftRowCheckpoint;
      retain?: () => void;
      transferred: boolean;
    }
    let prefix: DraftPrefillGroup | undefined;
    let context: MlxArray | null = null;
    const ready: Ready[] = [];
    const closeReady = (state: Ready) => {
      const caches = state.caches.splice(0), attachments = [state.draft.attachment];
      const release = state.retain; state.retain = undefined;
      disposeResources([...caches, { dispose: () => disposeAttachments(attachments) },
        { dispose: () => release?.() }, ...(!state.transferred ? [state.request.sampling] : [])]);
    };
    const capture = (state: Preparation, snapshot: () => Cache[], index: number) => {
      let caches: Cache[] = [], attachments: CheckpointAttachment[] = [];
      try {
        caches = snapshot(); attachments.push(prefix!.capture(index).attachment);
        method.host.promptCache!.put(state.row.req.promptIds.slice(0, state.pos), caches,
          state.request.namespace, undefined, attachments, state.row.req.cacheSessionId);
        caches = []; attachments = [];
      } finally { disposeResources([...caches, { dispose: () => disposeAttachments(attachments) }]); }
    };
    const target = new MlxPrefillRows<Preparation>({
      maintain,
      open(row) {
        const options = row.req.method!.data as GenerateOptions;
        row.spec = { drafted: 0, accepted: 0, targetCalls: 0, rejected: 0, rounds: 0,
          acceptanceLengths: [], tokensPerForward: 0, forwardsSaved: 0, draftedByPos: [], acceptedByPos: [] };
        const sampler = makeSampler(options);
        const request: RequestState = { draftSampling: sampler, namespace: "", prefixLength: 0,
          processed: method.host.promptCache ? [] : undefined,
          sampling: makeStepSampler(options, { tokenRepresentation: "number", grammarWait: "before-sample",
            historyUpdate: "after-sample", initialHistory: row.req.promptIds, acceptGrammar: true,
            eosTokenIds: row.req.eosTokenIds, captureSelectedLogprob: options.logprobs === true,
            captureTopLogprobs: options.topLogprobs }) };
        let caches: Cache[] = [], retained: (() => void) | undefined;
        let appended = false;
        const previous = prefix?.rowCount ?? 0;
        try {
          caches = method.binding.makeCache();
          prefix ??= method.provider.grouped!.openPrefill({ target: bindLegacyDraftTarget(method.model, caches), checkpoints: [] });
          const prompt = row.req.promptIds;
          const pendingPrompt = prefix.prefillMode !== "full" && method.binding.prefillTailSplit && prompt.length > 1;
          request.prefixLength = prompt.length - Number(pendingPrompt);
          request.namespace = speculativePrefixNamespace(prefix.namespace, row.cacheNamespace ?? "", options);
          const hit = method.host.promptCache?.take(prompt, request.namespace, row.req.cacheSessionId);
          if (hit) {
            try {
              disposeResources(caches); caches = hit.caches.splice(0);
              retained = hit.retain; hit.retain = undefined;
              prefix.append([{ processedTokens: hit.tokens.length, attachment: hit.attachments![0]! }]);
              appended = true;
              // Target membership later releases backing leases after its own
              // copies resolve. Settle companion copies under the same lease.
              if (retained) prefix.materialize();
              row.cachedTokens = hit.tokens.length;
            } finally { disposeResources([...hit.caches, { dispose: () => disposeAttachments(hit.attachments) },
              { dispose: () => hit.retain?.() }]); }
          } else { prefix.append([null]); appended = true; }
          return { row, request, solo: caches, retain: retained, pos: row.cachedTokens,
            end: request.prefixLength, pendingPrompt, transferred: false, closed: false,
            chunkSize: options.prefillChunkSize ?? row.req.prefillChunkSize ?? method.host.prefillChunkSize,
            boundary: method.host.promptCache ? Math.min(row.req.snapshotAt ?? prompt.length, prompt.length - 1) : -1 };
        } catch (error) {
          return cleanupFailure(error, () => disposeResources([
            { dispose: () => { if (appended) prefix!.filterRows(Array.from({ length: previous }, (_, i) => i)); } },
            ...caches, request.sampling, { dispose: () => retained?.() },
          ]));
        }
      },
      plan(state) {
        const end = Math.min(state.pos + state.chunkSize, state.end, state.boundary > state.pos ? state.boundary : Infinity);
        return { start: state.pos, end, kind: end === state.end ? "final" : "drain",
          snapshot: end === state.boundary && end > state.row.cachedTokens, batchYield: true, maintain: true };
      },
      async forward(ids, caches, _states, work) {
        const taps = prefix!.tapLayers;
        const output = await method.binding.forward(ids, caches, taps.length ? [...taps] : undefined, work);
        context = output.ctxML;
        return output.hidden;
      },
      afterForward(ids, _caches, _states, hidden) {
        // Tapped providers consume their captured layers; assistant drafting
        // consumes the true target hidden. Other providers ignore context.
        const captured = context; context = null;
        try {
          const pending = prefix!.prefill(ids, captured ?? hidden);
          if (pending) return pending.finally(() => captured?.dispose());
        } catch (error) { captured?.dispose(); throw error; }
        captured?.dispose();
      },
      project(hidden, _caches, completed) {
        if (completed.every(state => state.pendingPrompt)) return null;
        using last = hidden.slice([0, hidden.shape[1]! - 1, 0], [hidden.shape[0]!, hidden.shape[1]!, hidden.shape[2]!]);
        return method.binding.projectLogits(last);
      },
      checkpoint: capture,
      async complete(state, logits, index) {
        const row = state.row;
        row.spec!.targetCalls++;
        if (state.pendingPrompt) { row.current = row.req.promptIds[state.end]!; row.generated = row.sampled = 0; }
        else {
          using scores = ops.reshape(logits!, [1, logits!.shape.at(-1)!]);
          const sampled = await state.request.sampling.sample(scores, 0);
          row.current = sampled.token; row.generated = row.sampled = 1;
          if (row.req.eosTokenIds.includes(row.current)) {
            if (method.host.promptCache) capture(state, () => cloneKvCaches(state.solo), index);
            disposeResources(state.solo.splice(0)); state.retain?.(); state.retain = undefined;
            method.host.finish(row, "stop"); return;
          }
          const more = await method.host.publish(row, row.current, readStepExtras(sampled.extras));
          if (more === false || row.req.grammar?.isTerminated || row.generated >= row.req.maxTokens) {
            if (method.host.promptCache && !row.req.signal?.aborted) capture(state, () => cloneKvCaches(state.solo), index);
            disposeResources(state.solo.splice(0)); state.retain?.(); state.retain = undefined;
            method.host.finish(row, more === false || row.req.grammar?.isTerminated ? "stop" : "length"); return;
          }
        }
        ready.push({ row, request: state.request, caches: state.solo, retain: state.retain,
          draft: prefix!.capture(index), transferred: false });
        state.transferred = true;
      },
      reject(row, error) { row.reject(error); },
      close(state) {
        if (state.closed) return;
        state.closed = true;
        if (!state.transferred) state.request.sampling.dispose();
      },
      filterRows(keep) { prefix!.filterRows(keep); },
      dispose() {
        const held = [prefix, context].filter(value => value != null);
        prefix = undefined; context = null; disposeResources(held);
      },
    });
    const preparation: MlxGroupPreparation = {
      get rows() { return [...target.rows, ...ready.map(state => state.row)]; },
      get canAdmit() { return target.canAdmit; },
      get tokenWeight() { return target.tokenWeight + ready.reduce((sum, state) => sum + state.row.promptTokens - state.row.cachedTokens, 0); },
      admit: row => target.admit(row),
      advance: async work => {
        // Publication returns to scheduling before prepared state joins active
        // decode. This preserves the first-output flush boundary at every B.
        if (ready.length) {
          while (ready.length) {
            const state = ready[0]!;
            try {
              if (state.row.req.signal?.aborted) {
                state.row.reject(state.row.req.signal.reason);
                continue;
              }
              maintain.prepareBatch?.(state.caches);
              this.#target ??= new MlxStateRows(state.caches.map(targetCacheLayout));
              this.#draft ??= this.provider.grouped!.open({ target: bindLegacyDraftTarget(this.model, this.#target.caches),
                checkpoints: [], sampling: { sample: (lp, steps) => this.#sampleDraftRows(lp, steps) },
                constraints: { propose: async (row, maxTokens) => this.host.rows[row]!.req.grammar?.proposeTokens(maxTokens) ?? [] } });
              applyStateChanges([() => this.#target!.prepareAppend(state.caches),
                () => this.#draft!.prepareAppend([state.draft]), () => ({ commit: () => {
                  state.request.retain = state.retain; state.retain = undefined;
                  this.#requests.set(state.row, state.request); state.transferred = true;
                  this.host.join(state.row);
                }, dispose() {} })]);
            } finally { ready.shift(); closeReady(state); }
          }
          return target.rows.length === 0;
        }
        const done = await target.advance(work);
        return done && ready.length === 0;
      },
      dispose() {
        const held = ready.splice(0);
        disposeResources([target, ...held.map(state => ({ dispose: () => closeReady(state) }))]);
      },
    };
    try { target.admit(first); return preparation; }
    catch (error) { return cleanupFailure(error, () => preparation.dispose()); }
  }

  #sampleDraftRows(logprobs: MlxArray, steps: readonly number[]): MlxArray {
    const tokens: MlxArray[] = [];
    try {
      for (let row = 0; row < this.host.rows.length; row++) {
        using scores = logprobs.slice([row, 0], [row + 1, logprobs.shape[1]!]);
        tokens.push(this.#requests.get(this.host.rows[row]!)!.draftSampling(scores, steps[row]!));
      }
      return ops.concatAxis(tokens, 0);
    } finally { disposeResources(tokens); }
  }

  async advance(work?: MlxForwardWork): Promise<void> {
    const active = [...this.host.rows];
    const live = active.flatMap((row, index) => row.req.signal?.aborted ? [] : [index]);
    if (live.length !== active.length) {
      for (const row of active) if (row.req.signal?.aborted) row.reject(row.req.signal.reason);
      this.host.filterRows(live);
    }
    const rows = [...this.host.rows];
    if (!rows.length) return;
    const depth = Math.min(this.depth, Math.max(...rows.map(row => row.req.maxTokens - row.generated)));
    const halted = new Set<Row>();
    const pin = this.binding.pinVerify?.();
    try {
      const completed = await advanceSpeculativeOutputs(rows.map(row => ({ pending: row.current,
        step: row.sampled, remaining: row.req.maxTokens - row.generated, eosTokenIds: row.req.eosTokenIds,
        sampling: this.#requests.get(row)!.sampling, grammarDone: () => row.req.grammar?.isTerminated === true,
        output: { commit: async (ids, metadata) => {
          row.generated++;
          const more = await this.host.publish(row, ids[0]!, metadata?.[0]);
          if (more === false) { halted.add(row); return false; }
        } },
      })), depth, this.#draft!, {
        transaction: bindRowCacheRollback(this.#target!.caches, rows.length),
        forward: async ids => {
          const taps = this.#draft!.tapLayers;
          const result = await this.binding.forward(ids, this.#target!.caches, taps.length ? [...taps] : undefined,
            work ? (tokens, caches, options) => work(tokens, caches, { ...options, preserveTokenGeometry: true }) : undefined);
          const context = result.ctxML ?? result.hidden;
          try { return { logits: this.binding.projectLogits(result.hidden), context }; }
          catch (error) { context.dispose(); throw error; }
          finally { if (result.ctxML) result.hidden.dispose(); }
        },
      });
      const keep: number[] = [];
      for (let index = 0; index < rows.length; index++) {
        const row = rows[index]!, output = completed.outputs[index]!, round = completed.rounds[index]!;
        const request = this.#requests.get(row)!;
        if (output.kind !== "failed" && output.kind !== "cancelled")
          request.processed?.push(row.current, ...round.drafts.slice(0, output.accepted));
        const stats = row.spec!;
        stats.drafted += round.drafts.length;
        stats.accepted += round.acceptance.accepted;
        stats.rejected = stats.drafted - stats.accepted;
        stats.rounds!++; stats.targetCalls++;
        stats.acceptanceLengths!.push(round.acceptance.accepted);
        for (let p = 0; p < round.drafts.length; p++) stats.draftedByPos![p] = (stats.draftedByPos![p] ?? 0) + 1;
        for (let p = 0; p < round.acceptance.accepted; p++) stats.acceptedByPos![p] = (stats.acceptedByPos![p] ?? 0) + 1;
        row.sampled += round.acceptance.emitted.length + Number(round.acceptance.sawEos);
        // A consumer may stop inside a verified burst before its terminal EOS.
        if (output.kind === "stop" && !halted.has(row) && round.acceptance.sawEos &&
          output.generated === round.acceptance.emitted.length && row.generated < row.req.maxTokens)
          row.generated++;
        stats.tokensPerForward = row.generated / stats.rounds!;
        stats.forwardsSaved = Math.max(0, row.generated - 1 - stats.rounds!);
        if (output.kind === "continue") { row.current = output.pending; keep.push(index); }
        else if (output.kind === "failed") row.reject(output.error);
        else if (output.kind === "cancelled") row.reject(row.req.signal?.reason ?? new Error(output.reason));
        else {
          if (!row.req.signal?.aborted) this.#publishCheckpoint(row, index, request);
          this.host.finish(row, output.kind);
        }
      }
      if (keep.length !== rows.length) this.host.filterRows(keep);
      if (++this.#steps % 256 === 0) clearCache();
    } finally { pin?.close(); }
  }

  /** The method aligns token coverage and captures its state. The cache owns
   * RAM retention and eventual SSD persistence; no storage work is awaited. */
  #publishCheckpoint(row: Row, index: number, request: RequestState): void {
    if (!this.host.promptCache || !request.processed) return;
    let target: Cache[] = [], attachments: CheckpointAttachment[] = [];
    try {
      target = this.#target!.extractRow(index);
      attachments.push(this.#draft!.capture(index).attachment);
      this.host.promptCache.put([...row.req.promptIds.slice(0, request.prefixLength), ...request.processed], target,
        request.namespace, undefined, attachments, row.req.cacheSessionId);
      target = []; attachments = [];
    } finally { disposeResources([...target, { dispose: () => disposeAttachments(attachments) }]); }
  }

  filterRows(keep: readonly number[], _discard: boolean): void {
    this.#target?.filterRows(keep); this.#draft?.filterRows(keep);
    const retained = new Set(keep.map(index => this.host.rows[index]!));
    const releases: { dispose(): void }[] = [];
    for (const [row, request] of this.#requests) if (!retained.has(row)) {
      this.#requests.delete(row);
      releases.push(request.sampling, { dispose: () => request.retain?.() });
    }
    disposeResources(releases);
  }

  dispose(): void {
    const resources = [...(this.#target ? [this.#target] : []), ...(this.#draft ? [this.#draft] : []),
      ...[...this.#requests.values()].flatMap(request => [request.sampling, { dispose: () => request.retain?.() }])];
    this.#target = null; this.#draft = null; this.#requests.clear();
    disposeResources(resources);
  }
}
