import { L1_WHISPER, defineFamily } from "../family";

/** Whisper (model_type `whisper`, mlx-whisper ModelDimensions config):
 * encoder-decoder speech recognition, audio in and text out. Routed through the
 * transcription engine, never the chat loop. */
export const WHISPER_FAMILY = defineFamily({
  graph: "whisper",
  accepts: config => config.modelType === "whisper" && typeof config.raw.n_audio_ctx === "number",
  hasModelType: modelType => modelType === "whisper",
  tier: "targeted",
  label: "whisper",
  loader: "safetensors",
  loop: "encoder-decoder",
  fidelity: L1_WHISPER,
  specialization: "dedicated",
  profileId: "whisper-dedicated",
  capabilities: ["whisper-graph"],
  transcribes: true,
});
