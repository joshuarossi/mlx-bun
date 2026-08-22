// Public library surface (the npm "." export). What is re-exported here
// is the semver contract — everything else under src/ is internal and may
// change without notice. Mirrors the README "Library" example plus the
// pieces a consumer needs around it.
//
// NOTE: library consumers bypass the CLI's first-run step, so call
// ensureNativeRuntime() once before constructing a model on a machine
// that may not have the MLX runtime yet (no-op when already present).

export { ensureNativeRuntime, nativeRuntimeDir } from "./native-pack";
export { loadModelConfig } from "./config";
export { Weights } from "./weights";
export { Gemma4Model } from "./model/gemma4";
export { MiniCPM5Model } from "./model/minicpm5";
export {
  createModel,
  openGlm52RuntimeModel,
  openModel,
  type Glm52RuntimeOpenOptions,
  type RuntimeModel,
} from "./model/factory";
export { Qwen3Model } from "./model/qwen3";
export { configFingerprint } from "./model/fingerprint";
export {
  BUILTIN_ARTIFACT_PROFILES,
  ENGINE_CAPABILITIES,
  externalArtifactFingerprint,
  resolveModelProfile,
  type ArtifactModelProfile,
  type EngineCapability,
  type FidelityTarget,
  type FidelityTier,
  type GenerationLoop,
  type ModelArtifactIdentity,
  type ModelExecutionComposition,
  type ModelGraph,
  type ModelLoader,
  type ModelProfile,
  type ModelSpecialization,
  type ResolveModelProfileOptions,
  type ResolvedModelProfile,
} from "./model/profile";
export { generate } from "./generate";
export { loadTokenizer } from "./tokenizer";
export { embedOne, embedMany, isEmbeddingModel, withInstruction, type EmbedResult } from "./embed";
export { ChatTemplate } from "./chat-template";
export { chooseAutoModel, COEXIST_FRACTION, DEFAULT_REPO_ID, fit, largestRecommendedRepoId, recommendedRepoId, skuMatrix, thisMachine } from "./fit";
export { downloadModel } from "./download";
export { Registry } from "./registry";
export {
  createServer,
  loadContext,
  type LoadContextOptions,
  type ServerContext,
  type ServerOptions,
} from "./server";
