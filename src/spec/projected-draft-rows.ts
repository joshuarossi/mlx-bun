import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { KVCache, type Cache } from "../model/gemma4-base";
import { MlxProjectedContextRows } from "../backends/mlx/projected-context-rows";
import { captureCacheAttachment, restoreCacheAttachment } from "../backends/mlx/cache-attachment";
import { applyStateChanges, disposeResources } from "../engine/resources";
import type { PreparedStateChange } from "../contracts/resources";
import type { DraftPrefillGroup, DraftRowGroup, DraftRowCheckpoint, GroupedDraftProvider, TargetView } from "./source";

export interface ProjectedDraftMethod {
  namespace: string;
  schema: string;
  layers: number;
  tapLayers: readonly number[];
  project(hidden: MlxArray, positions: number | MlxArray): { k: MlxArray; v: MlxArray }[];
  draft(context: ReturnType<MlxProjectedContextRows["readAttention"]>, pending: readonly number[], positions: number | MlxArray, depth: number): number[][];
}

/** Provider numerics compose with shared context membership and persistence. */
class ProjectedDraftRows implements DraftPrefillGroup, DraftRowGroup {
  readonly prefillMode = "tail-split" as const;
  readonly tapLayers: readonly number[];
  readonly context: MlxProjectedContextRows;
  constructor(readonly method: ProjectedDraftMethod,
    checkpoints: readonly (DraftRowCheckpoint | null)[]) {
    this.tapLayers = method.tapLayers;
    this.context = new MlxProjectedContextRows(method.layers, { project: method.project });
    try { this.append(checkpoints); } catch (error) { this.dispose(); throw error; }
  }
  get namespace(): string { return this.method.namespace; }
  get rowCount(): number { return this.context.state.rowCount; }
  prepareAppend(checkpoints: readonly (DraftRowCheckpoint | null)[]): PreparedStateChange {
    const restored: Cache[][] = [];
    const empty = () => Array.from({ length: this.method.layers }, () => new KVCache());
    try {
      for (const checkpoint of checkpoints) restored.push(checkpoint ? restoreCacheAttachment(checkpoint.attachment, empty) : empty());
      return this.context.prepareAppend(restored);
    } finally { disposeResources(restored.flat()); }
  }
  append(checkpoints: readonly (DraftRowCheckpoint | null)[]): void {
    if (checkpoints.length) applyStateChanges([() => this.prepareAppend(checkpoints)]);
  }
  prefill(tokens: MlxArray, hidden?: MlxArray): void {
    this.context.append(hidden!, Array(this.rowCount).fill(tokens.shape[1]!)); this.materialize();
  }
  materialize(): void { this.context.materialize(); }
  filterRows(keep: readonly number[]): void { this.context.state.filterRows(keep); }
  capture(row: number): DraftRowCheckpoint {
    const caches = this.context.state.extractRow(row);
    try {
      const processedTokens = caches[0]!.offset;
      return { processedTokens, attachment: captureCacheAttachment(this.method.schema, caches, { processedTokens }) };
    } finally { disposeResources(caches); }
  }
  draft(pending: readonly number[], depth: number): number[][] {
    if (!depth) return pending.map(() => []);
    const positions = this.context.positions, donors = this.context.readAttention();
    using offsets = positions.every(position => position === positions[0]) ? null : ops.fromInt32([...positions], [pending.length]);
    try { return this.method.draft(donors, pending, offsets ?? positions[0]!, depth); }
    finally { donors.dispose(); }
  }
  commit(accepted: readonly number[], hidden: MlxArray): void {
    this.context.append(hidden, accepted.map(count => count + 1));
  }
  dispose(): void { this.context.dispose(); }
}

export function projectedDraftGroups(namespace: string, bind: (target: TargetView) => ProjectedDraftMethod): GroupedDraftProvider {
  const open = ({ target, checkpoints }: {
    target: TargetView; checkpoints: readonly (DraftRowCheckpoint | null)[];
  }) => new ProjectedDraftRows(bind(target), checkpoints);
  return { checkpointNamespace: () => namespace, open, openPrefill: open };
}
