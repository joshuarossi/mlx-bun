// Whisper long-form transcription — a port of mlx-whisper's transcribe.py
// seek loop (30 s windows, temperature fallback, no-speech skipping,
// timestamp-driven seeking, previous-text conditioning), restructured as a
// RESUMABLE run: `feed()` appends audio and transcribes every window that
// is already complete (≥ 30 s past the seek point); `finish()` drains the
// remainder. Batch transcription is the same run fed once, so the oracle
// parity gate covers both. Streaming caveat: a window fed early sees a
// log-mel normalized against the audio received so far (the 8-decade clamp
// is relative to the clip maximum), which can differ from the batch result
// in near-silent bins. Word timestamps live in whisper-timing.ts.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { WhisperModel } from "../../models/whisper/model";
import {
  WhisperDecodingTask, type WhisperDecodingOptions, type WhisperDecodingResult,
} from "./decode";
import {
  WHISPER_FRAMES_PER_SECOND, WHISPER_HOP, WHISPER_N_FRAMES, WHISPER_N_SAMPLES,
  WHISPER_SAMPLE_RATE, WhisperMelExtractor, padOrTrimFrames,
} from "../../input/audio/whisper-mel";
import { addWordTimestamps } from "./timing";
import { normalizeWhisperLanguage, type WhisperTokenizer } from "../../input/audio/whisper-tokenizer";

export interface WhisperSegment {
  id: number;
  seek: number;
  start: number;
  end: number;
  text: string;
  tokens: number[];
  temperature: number;
  avgLogprob: number;
  compressionRatio: number;
  noSpeechProb: number;
  words?: WhisperWord[];
}

export interface WhisperWord {
  word: string;
  start: number;
  end: number;
  probability: number;
}

export interface WhisperTranscribeOptions extends WhisperDecodingOptions {
  /** Single temperature or the fallback ladder (oracle default: 0, .2 … 1). */
  temperatures?: number[];
  compressionRatioThreshold?: number | null;
  logprobThreshold?: number | null;
  noSpeechThreshold?: number | null;
  conditionOnPreviousText?: boolean;
  initialPrompt?: string | null;
  /** [start, end, start, end, …] seconds; last end defaults to the clip end.
   *  Batch only: a run with clips never transcribes eagerly. */
  clipTimestamps?: number[];
  /** Word-level timestamps via cross-attention DTW (whisper-timing.ts);
   *  one extra faithful decoder pass per window. */
  wordTimestamps?: boolean;
  /** With wordTimestamps: skip silent gaps longer than this many seconds
   *  around a likely hallucination (transcribe.py hallucination_silence_threshold). */
  hallucinationSilenceThreshold?: number | null;
  /** Progress callback: seeked frames out of content frames. */
  onProgress?: (done: number, total: number) => void;
  /** Called with each finalized segment as the loop emits it. */
  onSegment?: (segment: WhisperSegment) => void;
  /** Checked between windows; an aborted signal throws "transcription cancelled". */
  signal?: AbortSignal;
}

export interface WhisperTranscription {
  text: string;
  segments: WhisperSegment[];
  language: string;
  /** Detected-language probabilities when language was auto-detected. */
  languageProbs?: Record<string, number>;
}

const DEFAULT_TEMPERATURES = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

export class WhisperTranscriber {
  readonly mel: WhisperMelExtractor;
  constructor(readonly model: WhisperModel, readonly tokenizer: WhisperTokenizer) {
    this.mel = new WhisperMelExtractor(model.dims.nMels);
  }

  /** Transcribe a complete 16 kHz mono float32 waveform. */
  async transcribe(samples: Float32Array, options: WhisperTranscribeOptions = {}): Promise<WhisperTranscription> {
    const run = new WhisperStreamingRun(this, options);
    await run.feed(samples);
    return run.finish();
  }

  /** Start a resumable run (see WhisperStreamingRun). */
  start(options: WhisperTranscribeOptions = {}): WhisperStreamingRun {
    return new WhisperStreamingRun(this, options);
  }

  dispose(): void {
    this.mel.dispose();
  }
}

/** A transcription in progress over audio that is still arriving. */
export class WhisperStreamingRun {
  readonly #tr: WhisperTranscriber;
  readonly #o: WhisperTranscribeOptions;
  #buf = new Float32Array(WHISPER_SAMPLE_RATE * 60);
  #len = 0;
  #seek = 0;
  #language: string | null;
  #languageProbs: Record<string, number> | undefined;
  #allTokens: number[] = [];
  #allSegments: WhisperSegment[] = [];
  #promptResetSince = 0;
  #initialPromptTokens: number[];
  #lastSpeechTimestamp = 0;
  #finished = false;
  readonly #temperatures: number[];
  readonly #crThreshold: number | null;
  readonly #lpThreshold: number | null;
  readonly #nsThreshold: number | null;
  readonly #condition: boolean;

  constructor(transcriber: WhisperTranscriber, options: WhisperTranscribeOptions) {
    this.#tr = transcriber;
    this.#o = options;
    this.#language = options.language == null ? null : normalizeWhisperLanguage(options.language);
    this.#temperatures = options.temperatures ?? (options.temperature !== undefined ? [options.temperature] : DEFAULT_TEMPERATURES);
    this.#crThreshold = options.compressionRatioThreshold === undefined ? 2.4 : options.compressionRatioThreshold;
    this.#lpThreshold = options.logprobThreshold === undefined ? -1.0 : options.logprobThreshold;
    this.#nsThreshold = options.noSpeechThreshold === undefined ? 0.6 : options.noSpeechThreshold;
    this.#condition = options.conditionOnPreviousText ?? true;
    this.#initialPromptTokens = options.initialPrompt != null ? transcriber.tokenizer.encode(" " + options.initialPrompt.trim()) : [];
    this.#allTokens.push(...this.#initialPromptTokens);
  }

  /** Samples received so far. */
  get sampleCount(): number {
    return this.#len;
  }

  /** Segments finalized so far. */
  get segments(): readonly WhisperSegment[] {
    return this.#allSegments;
  }

  /** Append audio WITHOUT transcribing yet (e.g. no speech detected so far). */
  feedSilent(samples: Float32Array): void {
    if (this.#finished) throw new Error("transcription run already finished");
    if (this.#len + samples.length > this.#buf.length) {
      const next = new Float32Array(Math.max(this.#buf.length * 2, this.#len + samples.length));
      next.set(this.#buf.subarray(0, this.#len));
      this.#buf = next;
    }
    this.#buf.set(samples, this.#len);
    this.#len += samples.length;
  }

  /** Append audio; transcribes every complete 30 s window. Returns the
   *  segments finalized by this call. */
  async feed(samples: Float32Array): Promise<WhisperSegment[]> {
    this.feedSilent(samples);
    if (this.#o.clipTimestamps) return [];
    const before = this.#allSegments.length;
    await this.#drain(false);
    return this.#allSegments.slice(before);
  }

  /** Transcribe the remaining audio and return the whole transcription. */
  async finish(): Promise<WhisperTranscription> {
    if (this.#finished) throw new Error("transcription run already finished");
    this.#finished = true;
    await this.#drain(true);
    const t = this.#tr.tokenizer;
    return {
      text: t.decodeText(this.#allTokens.slice(this.#initialPromptTokens.length)),
      segments: this.#allSegments,
      language: this.#language ?? "en",
      languageProbs: this.#languageProbs,
    };
  }

  async #drain(final: boolean): Promise<void> {
    const { model, tokenizer: t } = this.#tr;
    const samples = this.#buf.subarray(0, this.#len);
    if (samples.length <= 200) return; // below one mel frame of real audio
    const mel = this.#tr.mel.logMel(samples, WHISPER_N_SAMPLES);
    try {
      const contentFrames = mel.shape[0]! - WHISPER_N_FRAMES;
      // language detection on the first window (batch: same as the oracle)
      if (this.#language === null) {
        if (!final && contentFrames - this.#seek < WHISPER_N_FRAMES) return;
        if (!model.isMultilingual) this.#language = "en";
        else {
          const seg = padOrTrimFrames(mel, WHISPER_N_FRAMES, model.dtype);
          const seg3 = reshape3(seg);
          const probe = new WhisperDecodingTask(model, t, { ...this.#o, language: null });
          const feats = probe.encode(seg3);
          const det = probe.detectLanguage(feats);
          feats.dispose(); seg3.dispose(); seg.dispose();
          this.#language = det.code;
          this.#languageProbs = det.probs;
        }
      }
      // clip windows: batch only
      let clips: [number, number][];
      if (this.#o.clipTimestamps) {
        const pts = this.#o.clipTimestamps.map((ts) => Math.round(ts * WHISPER_FRAMES_PER_SECOND));
        if (pts.length === 0) pts.push(0);
        if (pts.length % 2 === 1) pts.push(contentFrames);
        else pts[pts.length - 1] = Math.min(contentFrames, pts[pts.length - 1]!);
        clips = [];
        for (let i = 0; i < pts.length; i += 2) clips.push([pts[i]!, pts[i + 1]!]);
        this.#seek = clips[0]![0];
      } else clips = [[0, contentFrames]];
      for (const [, clipEnd] of clips) {
        while (this.#seek < clipEnd) {
          // during feed, only windows with 30 s of audio past `seek` are final
          if (!final && contentFrames - this.#seek < WHISPER_N_FRAMES) return;
          if (this.#o.signal?.aborted) throw new Error("transcription cancelled");
          if (this.#allSegments.length > 0) await Bun.sleep(0);
          await this.#window(mel, contentFrames, clipEnd);
          this.#o.onProgress?.(Math.min(contentFrames, this.#seek), final ? contentFrames : Math.max(contentFrames, this.#seek));
        }
      }
    } finally {
      mel.dispose();
    }
  }

  #decodeWithFallback(segment: MlxArray, prompt: number[]): WhisperDecodingResult {
    const { model, tokenizer: t } = this.#tr;
    let result: WhisperDecodingResult | null = null;
    for (const temp of this.#temperatures) {
      const opts: WhisperDecodingOptions = { ...this.#o, language: this.#language, task: this.#o.task ?? "transcribe", prompt, temperature: temp };
      if (temp > 0) { opts.beamSize = null; opts.patience = null; }
      else opts.bestOf = null;
      result = new WhisperDecodingTask(model, t, opts).run(segment);
      let needsFallback = false;
      if (this.#crThreshold !== null && result.compressionRatio > this.#crThreshold) needsFallback = true;
      if (this.#lpThreshold !== null && result.avgLogprob < this.#lpThreshold) needsFallback = true;
      if (this.#nsThreshold !== null && result.noSpeechProb > this.#nsThreshold) needsFallback = false;
      if (!needsFallback) break;
    }
    return result!;
  }

  /** One window at `#seek` (transcribe.py loop body). */
  async #window(mel: MlxArray, contentFrames: number, clipEnd: number): Promise<void> {
    const { model, tokenizer: t } = this.#tr;
    const o = this.#o;
    const seek = this.#seek;
    const timeOffset = (seek * WHISPER_HOP) / WHISPER_SAMPLE_RATE;
    const segmentSize = Math.min(WHISPER_N_FRAMES, contentFrames - seek, clipEnd - seek);
    const segmentDuration = (segmentSize * WHISPER_HOP) / WHISPER_SAMPLE_RATE;
    const melSeg = mel.slice([seek, 0], [seek + segmentSize, model.dims.nMels]);
    const padded = padOrTrimFrames(melSeg, WHISPER_N_FRAMES, model.dtype);
    melSeg.dispose();
    const seg3 = reshape3(padded);
    padded.dispose();
    const prompt = this.#allTokens.slice(this.#promptResetSince);
    let result: WhisperDecodingResult;
    try {
      result = this.#decodeWithFallback(seg3, prompt);
    } catch (e) {
      seg3.dispose();
      throw e;
    }
    const tokens = result.tokens;
    if (this.#nsThreshold !== null) {
      let shouldSkip = result.noSpeechProb > this.#nsThreshold;
      if (this.#lpThreshold !== null && result.avgLogprob > this.#lpThreshold) shouldSkip = false;
      if (shouldSkip) {
        seg3.dispose();
        this.#seek += segmentSize;
        return;
      }
    }
    const previousSeek = seek;
    const current: WhisperSegment[] = [];
    const newSegment = (start: number, end: number, toks: number[]): WhisperSegment => ({
      id: 0, seek, start, end,
      text: t.decodeText(toks), tokens: toks,
      temperature: result.temperature, avgLogprob: result.avgLogprob,
      compressionRatio: result.compressionRatio, noSpeechProb: result.noSpeechProb,
    });
    const isTs = tokens.map((x) => x >= t.timestampBegin);
    const singleTimestampEnding = tokens.length >= 2 && !isTs[tokens.length - 2] && isTs[tokens.length - 1];
    const consecutive: number[] = [];
    for (let i = 0; i + 1 < tokens.length; i++) if (isTs[i] && isTs[i + 1]) consecutive.push(i + 1);
    const inputStride = WHISPER_N_FRAMES / model.dims.nAudioCtx; // 2
    const timePrecision = (inputStride * WHISPER_HOP) / WHISPER_SAMPLE_RATE; // 0.02
    if (consecutive.length > 0) {
      const slices = [...consecutive];
      if (singleTimestampEnding) slices.push(tokens.length);
      let lastSlice = 0;
      for (const cur of slices) {
        const sliced = tokens.slice(lastSlice, cur);
        const startPos = sliced[0]! - t.timestampBegin;
        const endPos = sliced[sliced.length - 1]! - t.timestampBegin;
        current.push(newSegment(timeOffset + startPos * timePrecision, timeOffset + endPos * timePrecision, sliced));
        lastSlice = cur;
      }
      if (singleTimestampEnding) this.#seek += segmentSize;
      else {
        const lastPos = tokens[lastSlice - 1]! - t.timestampBegin;
        this.#seek += lastPos * inputStride;
      }
    } else {
      let duration = segmentDuration;
      const timestamps = tokens.filter((x) => x >= t.timestampBegin);
      if (timestamps.length > 0 && timestamps[timestamps.length - 1] !== t.timestampBegin) {
        const lastPos = timestamps[timestamps.length - 1]! - t.timestampBegin;
        duration = lastPos * timePrecision;
      }
      current.push(newSegment(timeOffset, timeOffset + duration, tokens));
      this.#seek += segmentSize;
    }

    if (o.wordTimestamps) {
      this.#lastSpeechTimestamp = addWordTimestamps(current, model, t, this.#language!, seg3, segmentSize, this.#lastSpeechTimestamp);
      if (!singleTimestampEnding) {
        const lastWordEnd = lastWordEndOf(current);
        if (lastWordEnd !== null && lastWordEnd > timeOffset) this.#seek = Math.round(lastWordEnd * WHISPER_FRAMES_PER_SECOND);
      }
      const threshold = o.hallucinationSilenceThreshold ?? null;
      if (threshold !== null) {
        const windowEndTime = ((previousSeek + WHISPER_N_FRAMES) * WHISPER_HOP) / WHISPER_SAMPLE_RATE;
        if (!singleTimestampEnding) {
          const lastWordEnd = lastWordEndOf(current);
          if (lastWordEnd !== null && lastWordEnd > timeOffset) {
            const remaining = windowEndTime - lastWordEnd;
            this.#seek = remaining > threshold ? Math.round(lastWordEnd * WHISPER_FRAMES_PER_SECOND) : previousSeek + segmentSize;
          }
        }
        const first = current.find((s) => s.words && s.words.length);
        if (first && isSegmentAnomaly(first)) {
          const gap = first.start - timeOffset;
          if (gap > threshold) { this.#seek = previousSeek + Math.round(gap * WHISPER_FRAMES_PER_SECOND); seg3.dispose(); return; }
        }
        let halLastEnd = this.#lastSpeechTimestamp;
        for (let si = 0; si < current.length; si++) {
          const segment = current[si]!;
          if (!segment.words?.length) continue;
          if (isSegmentAnomaly(segment)) {
            const nextSeg = current.slice(si + 1).find((s) => s.words && s.words.length);
            const halNextStart = nextSeg ? nextSeg.words![0]!.start : timeOffset + segmentDuration;
            const silenceBefore = segment.start - halLastEnd > threshold || segment.start < threshold || segment.start - timeOffset < 2.0;
            const silenceAfter = halNextStart - segment.end > threshold || isSegmentAnomaly(nextSeg) || windowEndTime - segment.end < 2.0;
            if (silenceBefore && silenceAfter) {
              this.#seek = Math.round(Math.max(timeOffset + 1, segment.start) * WHISPER_FRAMES_PER_SECOND);
              if ((contentFrames * WHISPER_HOP) / WHISPER_SAMPLE_RATE - segment.end < threshold) this.#seek = contentFrames;
              current.splice(si);
              break;
            }
          }
          halLastEnd = segment.end;
        }
      }
      const lastWordEnd = lastWordEndOf(current);
      if (lastWordEnd !== null) this.#lastSpeechTimestamp = lastWordEnd;
    }
    seg3.dispose();
    for (const s of current) {
      if (s.start === s.end || s.text.trim() === "") { s.text = ""; s.tokens = []; s.words = []; }
    }
    for (const s of current) {
      s.id = this.#allSegments.length;
      this.#allSegments.push(s);
      o.onSegment?.(s);
    }
    for (const s of current) this.#allTokens.push(...s.tokens);
    if (!this.#condition || result.temperature > 0.5) this.#promptResetSince = this.#allTokens.length;
  }
}

/** [T, M] → [1, T, M]. */
function reshape3(a: MlxArray): MlxArray {
  const [T, M] = a.shape as [number, number];
  return ops.reshape(a, [1, T, M]);
}
export { Dtype };

const PUNCTUATION = "\"'“¿([{-\"'.。,，!！?？:：”)]}、";

function lastWordEndOf(segments: WhisperSegment[]): number | null {
  for (let i = segments.length - 1; i >= 0; i--) {
    const w = segments[i]!.words;
    if (w && w.length) return w[w.length - 1]!.end;
  }
  return segments.length ? segments[segments.length - 1]!.end : null;
}

function wordAnomalyScore(word: WhisperWord): number {
  const duration = word.end - word.start;
  let score = 0;
  if (word.probability < 0.15) score += 1;
  if (duration < 0.133) score += (0.133 - duration) * 15;
  if (duration > 2.0) score += duration - 2.0;
  return score;
}

function isSegmentAnomaly(segment: WhisperSegment | undefined): boolean {
  if (!segment || !segment.words?.length) return false;
  const words = segment.words.filter((w) => !PUNCTUATION.includes(w.word)).slice(0, 8);
  const score = words.reduce((a, w) => a + wordAnomalyScore(w), 0);
  return score >= 3 || score + 0.01 >= words.length;
}
