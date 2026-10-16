import type { OpenedTranscriber } from "./transcription/types";
export type { OpenedTranscriber } from "./transcription/types";
// Common library entry points. Specialized components have explicit subpath imports.
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


/** Load a local speech artifact through its registered graph. The returned
 * transcriber owns the graph, frontend and tokenizer and must be disposed. */
export async function openTranscriber(modelDir: string): Promise<OpenedTranscriber> {
  const { openTranscriptionGraph } = await import("./models/factory");
  const { WhisperTranscriber, TdtTranscriber, UnsupportedTranscriptionOptionError } = await import("./transcription");
  return openTranscriptionGraph<OpenedTranscriber>(modelDir, {
    async encoderDecoder(model) {
      const { loadWhisperTokenizer } = await import("./input/audio/whisper-tokenizer");
      const tokenizer = await loadWhisperTokenizer(modelDir, model.dims.nVocab), transcriber = new WhisperTranscriber(model, tokenizer);
      return { promptTokenBudget: Math.floor(model.dims.nTextCtx / 2) - 1, encode: (text: string) => tokenizer.encode(text),
        transcribe: transcriber.transcribe.bind(transcriber), start: transcriber.start.bind(transcriber),
        dispose() { transcriber.dispose(); model.dispose(); } };
    },
    async transducer(model) {
      const transcriber = new TdtTranscriber(model);
      return { promptTokenBudget: 0, residentBytes: model.weightsBytes, encode(text: string): number[] {
        if (text.trim()) throw new UnsupportedTranscriptionOptionError("This transcriber does not support vocabulary prompts"); return [];
      }, transcribe: transcriber.transcribe.bind(transcriber), start: transcriber.start.bind(transcriber),
        dispose() { transcriber.dispose(); model.dispose(); } };
    },
  });
}
