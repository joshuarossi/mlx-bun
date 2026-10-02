// The native side of the Whisper model host: opening a checkpoint through the
// library's public surfaces. Every native module loads on first use, so
// composing a host touches no MLX code. A `WhisperBackend` is also the seam
// tests replace with a fake.
import type { WhisperSegment, WhisperTranscribeOptions, WhisperTranscription } from "@mlx-bun/inference/transcription";

/** A transcription in progress over audio that is still arriving. */
export interface WhisperRun {
  readonly segments: readonly WhisperSegment[];
  feedSilent(samples: Float32Array): void;
  feed(samples: Float32Array): Promise<unknown>;
  finish(): Promise<WhisperTranscription>;
}

/** A loaded Whisper checkpoint. */
export interface LoadedWhisper {
  /** floor(n_text_ctx / 2) - 1: the prompt-token budget vocabulary hints fit into. */
  readonly promptTokenBudget: number;
  /** Tokenizer encoding, for fitting hints into the budget. */
  encode(text: string): number[];
  transcribe(samples: Float32Array, options: WhisperTranscribeOptions): Promise<WhisperTranscription>;
  start(options: WhisperTranscribeOptions): WhisperRun;
  /** Release the weights and hand cached buffers back to the OS. */
  dispose(): void;
}

export interface WhisperBackend {
  load(modelDir: string): Promise<LoadedWhisper>;
}

/** Real weights: the checkpoint's model and tokenizer under one transcriber. */
export const nativeWhisperBackend: WhisperBackend = {
  async load(modelDir) {
    const [{ openWhisperModel }, { loadWhisperTokenizer }, { WhisperTranscriber }, { clearCache }] = await Promise.all([
      import("@mlx-bun/inference/models"), import("@mlx-bun/inference/input/audio"),
      import("@mlx-bun/inference/transcription"), import("@mlx-bun/mlx/ffi"),
    ]);
    const { model } = await openWhisperModel(modelDir);
    let transcriber: InstanceType<typeof WhisperTranscriber>;
    try {
      const tokenizer = await loadWhisperTokenizer(modelDir, model.dims.nVocab);
      transcriber = new WhisperTranscriber(model, tokenizer);
    } catch (error) {
      model.dispose();
      throw error;
    }
    return {
      promptTokenBudget: Math.floor(model.dims.nTextCtx / 2) - 1,
      encode: text => transcriber.tokenizer.encode(text),
      transcribe: (samples, options) => transcriber.transcribe(samples, options),
      start: options => transcriber.start(options),
      dispose() {
        transcriber.dispose();
        model.dispose();
        // Disposing frees the arrays but MLX's allocator keeps the buffers in
        // its cache; hand them back to the OS.
        clearCache();
      },
    };
  },
};
