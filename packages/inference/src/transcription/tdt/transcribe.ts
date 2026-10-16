import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { TdtGraph, TdtDecodeState } from "../../contracts/mlx/tdt";
import { UnsupportedTranscriptionOptionError } from "../types";
import { PhononMelExtractor } from "../../input/audio/phonon-mel";
import type {
  SpeechTranscribeOptions,
  SpeechTranscription,
  SpeechSegment,
} from "../types";
import { tdtWindowEnd, tdtWords, type TimedTdtToken } from "./segments";

function disposeState(state: TdtDecodeState): void {
  for (const a of [...state.h, ...state.c, state.control]) a.dispose();
}
function validate(options: SpeechTranscribeOptions): void {
  if (options.task === "translate")
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 supports transcription, not translation",
    );
  if (
    options.language &&
    !["en", "english", "auto"].includes(options.language.toLowerCase())
  )
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 supports English transcription",
    );
  if (options.initialPrompt?.trim())
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 prompt conditioning is unavailable",
    );
  if (options.beamSize != null && options.beamSize !== 1)
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 supports greedy decoding (beam_size 1)",
    );
  if (options.temperature != null && options.temperature !== 0)
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 supports temperature 0",
    );
  if (options.noSpeechThreshold != null)
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 does not provide a no-speech probability threshold",
    );
  if (options.audioCtx != null)
    throw new UnsupportedTranscriptionOptionError(
      "Phonon-2 does not support audio_ctx",
    );
}
/** A transducer consumer: all numerical work belongs to the supplied graph. */
export class TdtTranscriber {
  readonly #mel = new PhononMelExtractor();
  constructor(readonly graph: TdtGraph) {}
  start(options: SpeechTranscribeOptions = {}): TdtStreamingRun {
    validate(options);
    return new TdtStreamingRun(this, options);
  }
  async transcribe(
    samples: Float32Array,
    options: SpeechTranscribeOptions = {},
  ): Promise<SpeechTranscription> {
    const run = this.start(options);
    await run.feed(samples);
    return run.finish();
  }
  async decode(
    samples: Float32Array,
    offset: number,
    id: number,
    options: SpeechTranscribeOptions,
  ): Promise<SpeechSegment | null> {
    options.signal?.throwIfAborted();
    if (!samples.length || !samples.some((v) => Math.abs(v) >= 1e-4))
      return null;
    using mel = this.#mel.logMel(samples);
    using encoded = this.graph.encode(mel);
    encoded.eval();
    options.signal?.throwIfAborted();
    const frames = encoded.shape[1]!,
      tokens: TimedTdtToken[] = [];
    using maxLength = MlxArray.fromInt32(new Int32Array([frames]), [1]);
    let state = this.graph.initialState(),
      time = 0;
    try {
      while (time < frames) {
        options.signal?.throwIfAborted();
        const records: MlxArray[] = [];
        try {
          for (let i = 0; i < 16; i++) {
            const next = this.graph.advance(encoded, state, maxLength);
            disposeState(state);
            state = next.state;
            records.push(next.record);
          }
          using packed = ops.concatAxis(records, 0);
          ops.evalAll([packed, state.control, ...state.h, ...state.c]);
          const values = packed.toIntTokens();
          time = state.control.toIntTokens()[0]!;
          for (let i = 0; i < values.length; i += 3) {
            const token = values[i]!;
            if (token < 0) continue;
            const piece = this.graph.vocabulary[token]!;
            if (
              (piece.startsWith("<|") && piece.endsWith("|>")) ||
              piece === "<unk>" ||
              piece === "<pad>"
            )
              continue;
            tokens.push({
              id: token,
              piece,
              start: values[i + 1]! * this.graph.frameSeconds,
              duration: values[i + 2]! * this.graph.frameSeconds,
            });
          }
        } finally {
          for (const a of records) a.dispose();
        }
        await new Promise<void>((resolve) => setImmediate(resolve));
      }
    } finally {
      disposeState(state);
    }
    options.signal?.throwIfAborted();
    const words = tdtWords(tokens, samples.length / 16000),
      text = words.map((w) => w.word).join(" ");
    if (!text) return null;
    const result: SpeechSegment = {
      id,
      seek: Math.floor(offset * 100),
      start: offset + words[0]!.start,
      end: offset + words.at(-1)!.end,
      text,
      tokens: tokens.map((t) => t.id),
      ...(options.wordTimestamps
        ? {
            words: words.map((w) => ({
              ...w,
              start: w.start + offset,
              end: w.end + offset,
            })),
          }
        : {}),
    };
    return result;
  }
  dispose(): void {
    this.#mel.dispose();
  }
}
/** Finalizes complete utterance windows; every complete window is finalized once.
 * The caller serializes feed/finish and retains the model lease until finish. */
export class TdtStreamingRun {
  readonly segments: SpeechSegment[] = [];
  #pending = new Float32Array(0);
  #offset = 0;
  #finished = false;
  constructor(
    readonly transcriber: TdtTranscriber,
    readonly options: SpeechTranscribeOptions,
  ) {}
  feedSilent(samples: Float32Array): void {
    this.#append(samples);
  }
  #append(samples: Float32Array): void {
    if (this.#finished) throw new Error("transcription is finished");
    this.options.signal?.throwIfAborted();
    const next = new Float32Array(this.#pending.length + samples.length);
    next.set(this.#pending);
    next.set(samples, this.#pending.length);
    this.#pending = next;
  }
  async #decode(end: number): Promise<void> {
    const segment = await this.transcriber.decode(
      this.#pending.subarray(0, end),
      this.#offset,
      this.segments.length,
      this.options,
    );
    this.#pending = this.#pending.slice(end);
    this.#offset += end / 16000;
    if (segment) {
      this.segments.push(segment);
      this.options.onSegment?.(segment);
    }
    this.options.onProgress?.(
      Math.floor(this.#offset * 100),
      Math.floor((this.#offset + this.#pending.length / 16000) * 100),
    );
  }
  async feed(samples: Float32Array): Promise<SpeechSegment[]> {
    this.#append(samples);
    const from = this.segments.length;
    while (this.#pending.length > 35 * 16000)
      await this.#decode(tdtWindowEnd(this.#pending));
    return this.segments.slice(from);
  }
  async finish(): Promise<SpeechTranscription> {
    if (this.#finished) throw new Error("transcription is finished");
    this.options.signal?.throwIfAborted();
    if (this.#pending.length) await this.#decode(this.#pending.length);
    this.#finished = true;
    return {
      text: this.segments.map((s) => s.text).join(" "),
      segments: [...this.segments],
      language: "en",
    };
  }
}
