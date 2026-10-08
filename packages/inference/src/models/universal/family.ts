import { L1, defineFamily } from "../family";
import { GENERIC_MODEL_TYPES, genericArgsFor, remapModelType } from "./archs";

/** Tier-0: every architecture with a descriptor in the universal table (L1
 * only). The last family in the registry, so a targeted family always wins. */
export const UNIVERSAL_FAMILY = defineFamily({
  graph: "universal-dense",
  accepts: config => genericArgsFor(config) !== null,
  hasModelType: modelType => GENERIC_MODEL_TYPES.has(remapModelType(modelType)),
  tier: "generic",
  loader: "safetensors",
  loop: "autoregressive",
  fidelity: L1,
  specialization: "generic",
  profileId: "universal-dense",
  capabilities: ["universal-dense-graph"],
});
