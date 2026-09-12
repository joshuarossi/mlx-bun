import { projectedDraftGroups } from "./projected-draft-rows";
import type { GroupedDraftProvider, TargetView } from "./source";
import type { DeepspecDrafter } from "./dspark/deepspec-module";

/** Existing pairing requirements are checked once when the provider opens. */
export function bindDeepspecTarget(target: TargetView, drafter: Pick<DeepspecDrafter, "cfg">): void {
  if (!target.gemmaTaps) throw new Error("DeepSpec drafter requires a Gemma4 target");
  const layers = drafter.cfg.num_target_layers;
  if (target.gemmaTaps.layerCount !== layers) throw new Error(
    `DeepSpec drafter was trained for a ${layers}-layer target; ` +
    `this model has ${target.gemmaTaps.layerCount} layers — wrong (target, drafter) pairing`);
}

export function deepspecGroups(drafter: DeepspecDrafter, namespace: string): GroupedDraftProvider {
  return projectedDraftGroups(namespace, target => {
    bindDeepspecTarget(target, drafter);
    return {
      namespace, schema: "deepspec-context-v1",
      layers: drafter.cfg.num_hidden_layers, tapLayers: drafter.tapLayers,
      project(hidden, positions) {
        using projected = drafter.projectContext(hidden);
        return drafter.projectContextKVRows(projected, positions);
      },
      draft(context, pending, positions, depth) {
        return drafter.draftRows(context, pending, positions).tokens.map(row => row.slice(0, depth));
      },
    };
  });
}
