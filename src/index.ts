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
export { createModel } from "./model/factory";
export { generate } from "./generate";
export { loadTokenizer } from "./tokenizer";
export { ChatTemplate } from "./chat-template";
export { fit, recommendedRepoId, skuMatrix, thisMachine } from "./fit";
export { downloadModel } from "./download";
export { Registry } from "./registry";
export { createServer, loadContext } from "./server";
