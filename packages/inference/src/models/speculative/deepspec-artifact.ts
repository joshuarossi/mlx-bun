// How DeepSeek's released DSpark drafter (DeepSpec) declares itself in its
// config.json. No MLX: the draft registry and quantization read it to recognize
// the checkpoint before loading anything.

/** `architectures[0]` of a DeepSpec checkpoint. */
const DEEPSPEC_ARCHITECTURE = "Gemma4DSparkModel";

export function isDeepspecArchitecture(architectures: unknown): boolean {
  return Array.isArray(architectures) && architectures[0] === DEEPSPEC_ARCHITECTURE;
}
