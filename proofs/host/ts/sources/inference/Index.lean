import host.ts.Source
namespace Host.Ts.Sources.Inference.Index
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/index.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Common library entry points. Specialized components have explicit subpath imports.
export { loadModelConfig } from "./artifacts/config";
export { Weights } from "./artifacts/weights";
export { createModel, openModel, openGlm52RuntimeModel } from "./models/factory";
export type { RuntimeModel, ModelOpenOptions, Glm52RuntimeOpenOptions } from "./models/factory";
export { resolveComposition } from "./models/composition";
export type { CompositionRequest } from "./models/composition";
export type { Composition } from "./contracts/portable/composition";
export { ModelImplementationRegistry } from "./models/implementation";
export { loadTokenizer } from "./input/tokenizer";
export type { LoadedTokenizer } from "./input/tokenizer";
export { ChatTemplate } from "./input/chat-template";
export { generate, bindGeneration } from "./generation/generate";
export { generateAutoregressive } from "./generation/autoregressive";
export { generateDenoising } from "./generation/denoising";
export { Generation } from "./generation/result";
export type { GenerateOptions, GenerateStats, GeneratedToken } from "./generation/types";
export { embedOne, embedMany, embeddingTerminatorId, isEmbeddingModel, withInstruction } from "./embeddings/text";
export type { EmbedResult, EmbeddingGraph } from "./embeddings/text";
export { AdapterManager } from "./adapters/manager";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Index
