import type { MlxArray } from "@mlx-bun/mlx/array";
import type { GenerateOptions } from "../generation/index";
import { denoisingRequestOptions } from "../generation/denoising";
import { openDenoisingRun, type DenoisingRun, type DiffusionGenOptions, type DiffusionGenResult } from "../generation/diffusion";
import type { MlxDenoisingBinding } from "../generation/bindings/denoising";
import { cleanupFailure, disposeResources } from "../runtime/resources";
import { snapshotGenerationPolicy } from "./request-policy";
import type { MlxGroupedMethod, MlxGroupMethodHost, MlxGroupMethodRequest, MlxGroupPreparation, Row } from "./batch-types";

interface RequestState {
  readonly run: DenoisingRun;
  readonly adapters: string[];
  readonly maxTokens: number;
  result?: DiffusionGenResult;
  /** performance.now() when the final unit returned the result. */
  computedAt?: number;
}

/** Interleaved shared denoising: each row keeps its own canvas, feedback,
 * encoder state and key sequence, and advances by one bounded unit at a time
 * in round-robin order. Graph calls stay single-row; canvases are not stacked. */
export function bindDenoisingGroupRequests<State>(
  binding: MlxDenoisingBinding<State>,
  policy: (options: GenerateOptions) => DiffusionGenOptions = denoisingRequestOptions,
) {
  return (input: GenerateOptions): MlxGroupMethodRequest => {
    const options = snapshotGenerationPolicy(input);
    return {
      key: JSON.stringify(["denoising", binding.graph.descriptor.id]),
      data: options,
      open: host => new DenoisingGroup(host, binding, policy),
    };
  };
}

class DenoisingGroup<State> implements MlxGroupedMethod {
  readonly #requests = new Map<Row, RequestState>();
  /** One immutable base-weight table shared by this group's rows. Rows borrow
   * it; the group releases it after the last row's run has closed. */
  #table: MlxArray | null = null;
  #tableUsers = 0;
  #next = 0;

  constructor(readonly host: MlxGroupMethodHost, readonly binding: MlxDenoisingBinding<State>,
    readonly policy: (options: GenerateOptions) => DiffusionGenOptions) {}

  prepare(first: Row): MlxGroupPreparation {
    let row: Row | null = first;
    const preparation: MlxGroupPreparation = {
      get rows() { return row ? [row] : []; },
      canAdmit: false,
      supportsMixedWork: false,
      get tokenWeight() { return row?.promptTokens ?? 0; },
      // The whole prompt prefill and first canvas draw form one unit.
      advance: async () => {
        const current = row!;
        if (current.req.signal?.aborted) throw current.req.signal.reason;
        this.#advanceRun(this.#requests.get(current)!);
        row = null;
        this.host.join(current);
        return true;
      },
      dispose: () => {
        if (row && !this.host.rows.includes(row)) this.#close(row);
        row = null;
      },
    };
    try { this.#open(first); return preparation; }
    catch (error) { return cleanupFailure(error, () => preparation.dispose()); }
  }

  async advance(): Promise<void> {
    const rows = this.host.rows;
    const live = rows.flatMap((row, index) => row.req.signal?.aborted ? [] : [index]);
    if (live.length !== rows.length) {
      for (const row of rows) if (row.req.signal?.aborted) row.reject(row.req.signal.reason);
      this.host.filterRows(live);
    }
    if (!this.host.rows.length) return;
    const index = this.#next % this.host.rows.length;
    const row = this.host.rows[index]!;
    const state = this.#requests.get(row)!;
    try {
      if (!state.result) this.#advanceRun(state);
    } catch (error) {
      this.#retire(index);
      row.reject(error);
      return;
    }
    this.#next = index + 1;
    if (state.result) await this.#publish(row, index, state);
  }

  filterRows(keep: readonly number[], _discard: boolean): void {
    const rows = this.host.rows;
    const retained = new Set(keep.map(index => rows[index]!));
    for (const row of rows) if (!retained.has(row)) this.#close(row);
    this.#next = keep.filter(index => index < this.#next).length;
  }

  dispose(): void {
    disposeResources([...this.#requests.keys()].map(row => ({ dispose: () => this.#close(row) })));
  }

  /** Image pixels stay borrowed from the request owner. Only the row's first
   * unit reads them; the owner releases them after the row has settled. */
  #open(row: Row): void {
    const options = row.req.method!.data as GenerateOptions;
    const denoise = this.policy(options);
    const table = this.#acquireTable();
    let run: DenoisingRun;
    try { run = openDenoisingRun(this.binding.graph, row.req.promptIds, { ...denoise, embedWeight: table }); }
    catch (error) { return cleanupFailure(error, () => this.#releaseTable()); }
    this.#requests.set(row, { run, maxTokens: denoise.maxTokens,
      adapters: options.adapters?.length ? [...options.adapters] : [] });
  }

  #advanceRun(state: RequestState): void {
    const result = this.#unit(state);
    if (!result) return;
    state.result = result;
    state.computedAt = performance.now();
  }

  /** One synchronous unit with only this row's adapters active. Units never
   * await, so no other row can observe them. */
  #unit(state: RequestState): DiffusionGenResult | undefined {
    const adapters = this.binding.adapters;
    if (!adapters) return state.run.advance();
    const previous = adapters.active;
    adapters.active = state.adapters;
    try { return state.run.advance(); }
    finally { adapters.active = previous; }
  }

  /** Publish the finished result only; no canvas token leaves before it. */
  async #publish(row: Row, index: number, state: RequestState): Promise<void> {
    try {
      for (const token of state.result!.tokens) {
        row.generated++; row.sampled++;
        if (await this.host.publish(row, token) === false) break;
      }
    } catch (error) {
      this.#retire(index);
      row.reject(error);
      return;
    }
    // The whole result exists before its first token is published. Report the
    // work from admission to the final unit as decode time, as the serial
    // method did, excluding output delivery.
    row.decodeSpan = { start: row.admittedAt, end: state.computedAt! };
    this.host.finish(row, row.generated >= state.maxTokens ? "length" : "stop");
    this.#retire(index);
  }

  #retire(index: number): void {
    this.host.filterRows(this.host.rows.flatMap((_row, position) => position === index ? [] : [position]));
  }

  /** The run's cleanup completes before the shared table can be released. */
  #close(row: Row): void {
    const state = this.#requests.get(row);
    if (!state) return;
    this.#requests.delete(row);
    disposeResources([{ dispose: () => state.run.close() }, { dispose: () => this.#releaseTable() }]);
  }

  #acquireTable(): MlxArray {
    this.#table ??= this.binding.graph.dequantEmbedWeight();
    this.#tableUsers++;
    return this.#table;
  }

  #releaseTable(): void {
    if (--this.#tableUsers > 0) return;
    const table = this.#table;
    this.#table = null;
    table?.dispose();
  }
}
