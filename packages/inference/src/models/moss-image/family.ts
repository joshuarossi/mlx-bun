import { L3, defineFamily } from "../family";

/** The diffusers pipeline class MOSS-Image Base and SFT ship (`model_index.json`
 * `_class_name`); the two checkpoints share every component's structure. */
const PIPELINE_CLASS = "MOSSImagePipeline";

/** MOSS-Image (OpenMOSS): a 42-block joint-attention DiT over FLUX.2 VAE
 * latents, conditioned on Qwen3.5-9B hidden states. A text-to-image pipeline,
 * opened through `openImagePipeline`, never the token loop. Exact comparisons
 * target pinned MFLUX configurations; the family retains measured fidelity
 * while full-pipeline qualification is incomplete. */
export const MOSS_IMAGE_FAMILY = defineFamily({
  graph: "moss-image",
  accepts: config => config.modelType === PIPELINE_CLASS,
  hasModelType: modelType => modelType === PIPELINE_CLASS,
  tier: "targeted",
  label: "MOSS-Image",
  loader: "safetensors",
  loop: "flow-matching",
  fidelity: L3,
  specialization: "dedicated",
  profileId: "moss-image-dedicated",
  capabilities: ["moss-image-graph"],
  generatesImages: true,
});
