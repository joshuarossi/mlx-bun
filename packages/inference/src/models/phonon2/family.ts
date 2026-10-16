import { defineFamily, L3 } from "../family";
/** Fermion's five-value Parakeet artifact. An independent transducer graph,
 * served through transcription, with measured Metal numerical acceptance. */
export const PHONON2_FAMILY = defineFamily({
  graph: "phonon2",
  accepts: (config) => config.modelType === "parakeet_tdt_five_value",
  hasModelType: (modelType) => modelType === "parakeet_tdt_five_value",
  tier: "targeted",
  label: "Phonon-2",
  loader: "fermion",
  loop: "encoder-decoder",
  fidelity: L3,
  specialization: "dedicated",
  profileId: "phonon2-metal",
  capabilities: ["fermion", "tdt-graph"],
  transcribes: true,
});
