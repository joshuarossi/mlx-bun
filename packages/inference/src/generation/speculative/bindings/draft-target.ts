import { type Cache } from "../../../contracts/mlx/cache";
import type { MlxTokenGraph } from "../../../models/graph";
import { declaredGraph } from "../../../models/capabilities";
import type { TargetView } from "../source";

/** The ports a graph declares over its live caches for draft sources; a graph
 * that declares none is a plain target identified by itself. */
export function bindLegacyDraftTarget(model: MlxTokenGraph, caches: Cache[]): TargetView {
  return declaredGraph(model).draftTarget?.(caches) ?? Object.freeze({ identity: model });
}
