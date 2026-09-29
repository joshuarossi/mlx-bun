import { L2, configuredMoe, defineFamily } from "../family";
import { GEMMA_MEDIA_TOKENS, GEMMA_TRAINING_DEFAULTS } from "../gemma4/family";

/** DiffusionGemma (model_type `diffusion_gemma`): block/masked-diffusion canvas
 * model. Non-autoregressive, routed through the diffusion engine, not the AR loop. */
export const DIFFUSION_GEMMA_FAMILY = defineFamily({
  graph: "diffusion-gemma",
  accepts: config => config.modelType === "diffusion_gemma",
  hasModelType: modelType => modelType === "diffusion_gemma",
  tier: "targeted",
  label: "diffusion_gemma",
  loader: "safetensors",
  loop: "diffusion",
  fidelity: L2,
  specialization: "dedicated",
  profileId: "diffusion-gemma-dedicated",
  capabilities: ["diffusion-gemma-graph"],
  moe: configuredMoe,
  trainingDefaults: GEMMA_TRAINING_DEFAULTS,
  mediaTokens: GEMMA_MEDIA_TOKENS,
});
