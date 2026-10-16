import type {
  SpeechSegment,
  SpeechTranscription,
} from "../contracts/portable/transcription";
import type { WhisperTranscribeOptions } from "./whisper/transcribe";
export type {
  SpeechWord,
  SpeechSegment,
  SpeechTranscription,
} from "../contracts/portable/transcription";
export type SpeechTranscribeOptions = Omit<
  WhisperTranscribeOptions,
  "onSegment"
> & { onSegment?: (segment: SpeechSegment) => void };
export interface SpeechRun {
  readonly segments: readonly SpeechSegment[];
  feedSilent(samples: Float32Array): void;
  feed(samples: Float32Array): Promise<unknown>;
  finish(): Promise<SpeechTranscription>;
}
export interface OpenedTranscriber {
  readonly promptTokenBudget: number;
  readonly residentBytes?: number;
  encode(text: string): number[];
  transcribe(
    samples: Float32Array,
    options?: SpeechTranscribeOptions,
  ): Promise<SpeechTranscription>;
  start(options?: SpeechTranscribeOptions): SpeechRun;
  dispose(): void;
}

/** A valid request field the selected speech backend cannot implement. */
export class UnsupportedTranscriptionOptionError extends Error {
  readonly code = "unsupported_transcription_option";
}
