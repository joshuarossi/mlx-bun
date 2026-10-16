// The native side of the speech model host: opening a checkpoint through the
// library's public surfaces. Every native module loads on first use, so
// composing a host touches no MLX code. A `WhisperBackend` is also the seam
// tests replace with a fake.
import type { SpeechSegment, SpeechTranscribeOptions, SpeechTranscription } from "@mlx-bun/inference/transcription";

/** A transcription in progress over audio that is still arriving. */
export interface WhisperRun {
  readonly segments: readonly SpeechSegment[];
  feedSilent(samples: Float32Array): void;
  feed(samples: Float32Array): Promise<unknown>;
  finish(): Promise<SpeechTranscription>;
}

/** A loaded speech checkpoint. Names are retained for host API compatibility. */
export interface LoadedWhisper {
  /** The prompt-token budget vocabulary hints fit into; zero when unsupported. */
  readonly promptTokenBudget: number;
  readonly residentBytes?: number;
  /** Tokenizer encoding, for fitting hints into the budget. */
  encode(text: string): number[];
  transcribe(samples: Float32Array, options: SpeechTranscribeOptions): Promise<SpeechTranscription>;
  start(options: SpeechTranscribeOptions): WhisperRun;
  /** Release the weights and hand cached buffers back to the OS. */
  dispose(): void;
}

export interface WhisperBackend {
  load(modelDir: string): Promise<LoadedWhisper>;
}

/** Real weights: the checkpoint's model and tokenizer under one transcriber. */
export const nativeWhisperBackend: WhisperBackend = {
  async load(modelDir) {
    const [{ openTranscriber }, { clearCache }] = await Promise.all([
      import("@mlx-bun/inference"), import("@mlx-bun/mlx/ffi"),
    ]);
    const transcriber = await openTranscriber(modelDir);
    return { ...transcriber, dispose() { transcriber.dispose(); clearCache(); } };
  },
};
