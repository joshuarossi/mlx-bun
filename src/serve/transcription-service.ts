// Transcription service: owns a Whisper model's residency and runs
// transcriptions one at a time.
//
// Residency (the sotto ask — fast to page in, not always resident): the
// model loads on the first request and is DISPOSED right after each take
// by default (`idleUnloadSec` > 0 keeps it for that long; `resident` pins it). Weights are mmap'd safetensors, so
// a reload after unload reads from the OS page cache (~0.25 s for the 1.6 GB
// fp16 large-v3-turbo on an M1 Max, measured 2026-09-15) — the GPU memory
// is what an idle server gives back. Timings are reported per response.
//
// Concurrency: requests queue FIFO here; inside the full server every run is
// additionally wrapped in the generation gateway's exclusive lock (`exclusive`)
// so decoding never overlaps chat generation on the GPU.

import { decodeBytesWithAudioToolbox } from "../audio/audiotoolbox";
import { decodeWav, resampleTo16k } from "../audio/decode";
import { isRiffWave } from "../audio/transcode";
import { loadWhisperTokenizer, type WhisperTokenizer } from "../audio/whisper-tokenizer";
import {
  WhisperTranscriber, type WhisperSegment, type WhisperStreamingRun, type WhisperTranscription,
} from "../audio/whisper-transcribe";
import { SileroVad as SileroVadClass, type VadStreamState } from "../audio/silero-vad";
import { clearCache } from "../mlx/ffi";
import { openWhisperModel } from "../model/factory";
import { SileroVad, type SpeechTimestampOptions, type VadSegment } from "../audio/silero-vad";
import type { WhisperModel } from "../model/whisper";

export interface TranscriptionParams {
  task?: "transcribe" | "translate";
  /** ISO code / name; null or "auto" detects. */
  language?: string | null;
  prompt?: string | null;
  /** Recognition hints fitted into the prompt-token budget (sotto). */
  vocabulary?: string[];
  temperature?: number | null;
  beamSize?: number | null;
  conditionOnPreviousText?: boolean;
  noSpeechThreshold?: number | null;
  withoutTimestamps?: boolean;
  /** Silero VAD gate: when no speech is detected the transcript is empty and
   *  Whisper never runs. `trim` crops the clip to the detected speech span
   *  (plus padding) before Whisper. */
  vad?: { threshold?: number; minSpeechMs?: number; trim?: boolean } | null;
  /** Word-level timestamps (verbose_json `words`). */
  wordTimestamps?: boolean;
  /** Force the faithful oracle graph (default: the fast path). */
  faithful?: boolean;
  /** Lab: encoder context truncation (positions, ≤ 1500). */
  audioCtx?: number | null;
  onSegment?: (segment: WhisperSegment) => void;
  onProgress?: (done: number, total: number) => void;
  signal?: AbortSignal;
}

export interface VocabularyUsage {
  included: string[];
  omitted: string[];
  token_count: number;
  token_budget: number;
}

export interface TranscriptionOutcome {
  result: WhisperTranscription;
  durationSeconds: number;
  modelId: string;
  timings: { load_ms: number; transcribe_ms: number; total_ms: number; vad_ms?: number };
  vocabulary?: VocabularyUsage;
  vad?: { speech: boolean; segments: { start: number; end: number }[]; trimmed?: { start: number; end: number } };
}

export interface TranscriptionServiceOptions {
  modelDir: string;
  modelId: string;
  /** Seconds idle before the model is disposed. Default 0 = release right
   *  after each take, so the chat model gets the memory back before it
   *  prefills the transcript (a cold take costs ~150 ms more than a warm one
   *  on the M1 Max: 40 ms page-in + graph re-trace). */
  idleUnloadSec?: number;
  /** Never dispose (sotto-style always-resident); overrides idleUnloadSec. */
  resident?: boolean;
  /** Wraps each run (the full server passes gateway.runExclusive). */
  exclusive?: <T>(fn: () => Promise<T>, signal?: AbortSignal) => Promise<T>;
  /** Explicit Silero ggml path (default: the HF cache copy of ggml-org/whisper-vad). */
  vadModelPath?: string | null;
  log?: (line: string) => void;
}

interface Loaded {
  model: WhisperModel;
  tokenizer: WhisperTokenizer;
  transcriber: WhisperTranscriber;
}

export class TranscriptionService {
  readonly modelDir: string;
  readonly modelId: string;
  readonly idleUnloadSec: number;
  readonly resident_: boolean;
  #loaded: Loaded | null = null;
  #loading: Promise<Loaded> | null = null;
  #idleTimer: ReturnType<typeof setTimeout> | null = null;
  #queue: Promise<unknown> = Promise.resolve();
  #active = 0;
  #loads = 0;
  #unloads = 0;
  #requests = 0;
  #lastLoadMs = 0;
  readonly #exclusive: <T>(fn: () => Promise<T>, signal?: AbortSignal) => Promise<T>;
  readonly #log: (line: string) => void;
  readonly #vadModelPath: string | null;
  #vad: SileroVad | null = null;

  constructor(opts: TranscriptionServiceOptions) {
    this.modelDir = opts.modelDir;
    this.modelId = opts.modelId;
    this.idleUnloadSec = Math.max(0, opts.idleUnloadSec ?? 0);
    this.resident_ = opts.resident ?? false;
    this.#exclusive = opts.exclusive ?? ((fn) => fn());
    this.#log = opts.log ?? ((line) => console.log(line));
    this.#vadModelPath = opts.vadModelPath ?? null;
  }

  /** The Silero gate, loaded on first use (≈1 MB, stays resident). */
  vad(): SileroVad {
    return this.#vad ??= SileroVad.load(this.#vadModelPath);
  }

  get resident(): boolean {
    return this.#loaded !== null;
  }

  get stats(): { resident: boolean; loads: number; unloads: number; requests: number; last_load_ms: number; idle_unload_sec: number | null } {
    return {
      resident: this.resident, loads: this.#loads, unloads: this.#unloads, requests: this.#requests,
      last_load_ms: this.#lastLoadMs, idle_unload_sec: this.resident_ ? null : this.idleUnloadSec,
    };
  }

  /** Load (or reuse) the model; returns the load time for this call. */
  async ensureLoaded(): Promise<{ loadMs: number; loaded: Loaded }> {
    if (this.#loaded) return { loadMs: 0, loaded: this.#loaded };
    if (!this.#loading) {
      this.#loading = (async () => {
        const t0 = performance.now();
        const { model } = await openWhisperModel(this.modelDir);
        try {
          const tokenizer = await loadWhisperTokenizer(this.modelDir, model.dims.nVocab);
          const transcriber = new WhisperTranscriber(model, tokenizer);
          this.#loaded = { model, tokenizer, transcriber };
          this.#loads++;
          this.#lastLoadMs = performance.now() - t0;
          this.#log(`[transcription] ${this.modelId} loaded in ${this.#lastLoadMs.toFixed(0)} ms`);
          return this.#loaded;
        } catch (error) {
          model.dispose();
          throw error;
        }
      })().finally(() => { this.#loading = null; });
    }
    const t0 = performance.now();
    const loaded = await this.#loading;
    return { loadMs: performance.now() - t0, loaded };
  }

  /** Dispose the model (GPU memory returns; the next request reloads). */
  unload(): boolean {
    if (this.#idleTimer) { clearTimeout(this.#idleTimer); this.#idleTimer = null; }
    if (!this.#loaded || this.#active > 0) return false;
    this.#loaded.transcriber.dispose();
    this.#loaded.model.dispose();
    this.#loaded = null;
    this.#unloads++;
    // Disposing frees the arrays but MLX's allocator keeps the buffers in
    // its cache (measured 2.7 GB after unload); hand them back to the OS.
    clearCache();
    this.#log(`[transcription] ${this.modelId} unloaded (idle)`);
    return true;
  }

  #armIdleTimer(): void {
    if (this.#idleTimer) clearTimeout(this.#idleTimer);
    this.#idleTimer = null;
    if (this.resident_) return;
    if (this.idleUnloadSec <= 0) { if (this.#active === 0 && this.#sessions.size === 0) this.unload(); return; }
    this.#idleTimer = setTimeout(() => { this.#idleTimer = null; this.unload(); }, this.idleUnloadSec * 1000);
    this.#idleTimer.unref?.();
  }

  /** Decode to 16 kHz mono float32: WAV through the exact PCM parser
   *  (oracle scaling), everything else in-process via AudioToolbox
   *  (3.7 ms for an 11 s mp3 vs 72 ms through the afconvert subprocess). */
  static async decodeAudio(bytes: Uint8Array): Promise<Float32Array> {
    if (isRiffWave(bytes)) {
      const wav = decodeWav(bytes);
      return resampleTo16k(wav.samples, wav.sampleRate);
    }
    return decodeBytesWithAudioToolbox(bytes);
  }

  /** Fit vocabulary terms into the prompt budget (n_text_ctx/2 − 1 tokens),
   *  ", "-joined in order, whole terms only — sotto's helper semantics. */
  static fitVocabulary(tokenizer: WhisperTokenizer, budget: number, base: string, terms: string[]): { prompt: string; usage: VocabularyUsage } {
    const included: string[] = [];
    const omitted: string[] = [];
    let prompt = base.trim();
    let tokenCount = tokenizer.encode(" " + prompt).length;
    if (!prompt) tokenCount = 0;
    for (const term of terms) {
      const candidate = prompt ? `${prompt}, ${term}` : term;
      const n = tokenizer.encode(" " + candidate.trim()).length;
      if (n > budget) { omitted.push(term); continue; }
      included.push(term);
      prompt = candidate;
      tokenCount = n;
    }
    return { prompt, usage: { included, omitted, token_count: tokenCount, token_budget: budget } };
  }

  async transcribe(audio: Uint8Array | Float32Array, params: TranscriptionParams = {}): Promise<TranscriptionOutcome> {
    const run = async (): Promise<TranscriptionOutcome> => {
      const t0 = performance.now();
      this.#requests++;
      if (this.#idleTimer) { clearTimeout(this.#idleTimer); this.#idleTimer = null; }
      this.#active++;
      try {
        let samples = audio instanceof Float32Array ? audio : await TranscriptionService.decodeAudio(audio);
        if (samples.length < 1600) throw new TranscriptionError("audio is shorter than 0.1 s", 400);
        let vadInfo: TranscriptionOutcome["vad"];
        let vadMs = 0;
        if (params.vad) {
          const tv = performance.now();
          const vadOpts: SpeechTimestampOptions = { threshold: params.vad.threshold ?? 0.5, minSpeechDurationMs: params.vad.minSpeechMs ?? 250 };
          const { segments } = this.vad().detect(samples, vadOpts);
          vadMs = performance.now() - tv;
          vadInfo = { speech: segments.length > 0, segments: segments.map((s: VadSegment) => ({ start: s.start / 16_000, end: s.end / 16_000 })) };
          if (segments.length === 0) {
            return {
              result: { text: "", segments: [], language: params.language && params.language !== "auto" ? params.language : "en" },
              durationSeconds: samples.length / 16_000, modelId: this.modelId,
              timings: { load_ms: 0, transcribe_ms: 0, total_ms: performance.now() - t0, vad_ms: vadMs }, vad: vadInfo,
            };
          }
          if (params.vad.trim) {
            const pad = 16_000 * 0.5;
            const start = Math.max(0, Math.floor(segments[0]!.start - pad));
            const end = Math.min(samples.length, Math.ceil(segments[segments.length - 1]!.end + pad));
            samples = samples.subarray(start, end);
            vadInfo.trimmed = { start: start / 16_000, end: end / 16_000 };
          }
        }
        const { loadMs, loaded } = await this.ensureLoaded();
        const budget = Math.floor(loaded.model.dims.nTextCtx / 2) - 1;
        let prompt = params.prompt ?? null;
        let vocabulary: VocabularyUsage | undefined;
        if (params.vocabulary && params.vocabulary.length) {
          const fit = TranscriptionService.fitVocabulary(loaded.tokenizer, budget, prompt ?? "", params.vocabulary);
          prompt = fit.prompt || null;
          vocabulary = fit.usage;
        }
        const language = params.language == null || params.language === "auto" ? null : params.language;
        const t1 = performance.now();
        const result = await this.#exclusive(() => loaded.transcriber.transcribe(samples, {
          task: params.task ?? "transcribe",
          language,
          initialPrompt: prompt,
          beamSize: params.beamSize ?? null,
          ...(params.temperature != null ? { temperature: params.temperature } : {}),
          conditionOnPreviousText: params.conditionOnPreviousText ?? true,
          ...(params.noSpeechThreshold !== undefined ? { noSpeechThreshold: params.noSpeechThreshold } : {}),
          withoutTimestamps: params.withoutTimestamps ?? false,
          wordTimestamps: params.wordTimestamps ?? false,
          fast: !params.faithful,
          audioCtx: params.audioCtx ?? null,
          onSegment: params.onSegment,
          onProgress: params.onProgress,
          signal: params.signal,
        }), params.signal);
        const t2 = performance.now();
        if (vadInfo?.trimmed) {
          const off = vadInfo.trimmed.start;
          for (const seg of result.segments) {
            seg.start += off; seg.end += off;
            for (const w of seg.words ?? []) { w.start += off; w.end += off; }
          }
        }
        return {
          result,
          durationSeconds: samples.length / 16_000,
          modelId: this.modelId,
          timings: { load_ms: loadMs, transcribe_ms: t2 - t1, total_ms: t2 - t0, ...(params.vad ? { vad_ms: vadMs } : {}) },
          vocabulary,
          vad: vadInfo,
        };
      } finally {
        this.#active--;
        this.#armIdleTimer();
      }
    };
    const next = this.#queue.then(run, run);
    this.#queue = next.catch(() => undefined);
    return next;
  }

  // --- streaming sessions -----------------------------------------------------
  // Audio arrives while it is being recorded; every completed 30 s window
  // is transcribed under the exclusive lock as soon as it exists, so the
  // latency at finish() is one window regardless of take length.

  readonly #sessions = new Map<string, TranscriptionSession>();

  get sessionCount(): number {
    return this.#sessions.size;
  }

  async createSession(params: TranscriptionParams = {}): Promise<TranscriptionSession> {
    if (this.#sessions.size >= 64) throw new TranscriptionError("too many open transcription sessions", 429);
    const { loaded } = await this.ensureLoaded();
    if (this.#idleTimer) { clearTimeout(this.#idleTimer); this.#idleTimer = null; }
    const id = crypto.randomUUID();
    const budget = Math.floor(loaded.model.dims.nTextCtx / 2) - 1;
    let prompt = params.prompt ?? null;
    let vocabulary: VocabularyUsage | undefined;
    if (params.vocabulary?.length) {
      const fit = TranscriptionService.fitVocabulary(loaded.tokenizer, budget, prompt ?? "", params.vocabulary);
      prompt = fit.prompt || null;
      vocabulary = fit.usage;
    }
    const language = params.language == null || params.language === "auto" ? null : params.language;
    const run = loaded.transcriber.start({
      task: params.task ?? "transcribe", language, initialPrompt: prompt,
      beamSize: params.beamSize ?? null,
      ...(params.temperature != null ? { temperature: params.temperature } : {}),
      conditionOnPreviousText: params.conditionOnPreviousText ?? true,
      ...(params.noSpeechThreshold !== undefined ? { noSpeechThreshold: params.noSpeechThreshold } : {}),
      withoutTimestamps: params.withoutTimestamps ?? false,
      wordTimestamps: params.wordTimestamps ?? false,
      fast: !params.faithful,
    });
    const session = new TranscriptionSession(id, this, run, params, vocabulary, params.vad ? this.vad() : null);
    this.#sessions.set(id, session);
    this.#active++;
    return session;
  }

  session(id: string): TranscriptionSession | null {
    return this.#sessions.get(id) ?? null;
  }

  /** @internal called by the session when it closes. */
  releaseSession(id: string): void {
    if (this.#sessions.delete(id)) {
      this.#active--;
      this.#requests++;
      this.#armIdleTimer();
    }
  }

  /** @internal window work runs under the host's exclusive lock, FIFO with requests. */
  runExclusiveQueued<T>(fn: () => Promise<T>, signal?: AbortSignal): Promise<T> {
    const next = this.#queue.then(() => this.#exclusive(fn, signal), () => this.#exclusive(fn, signal));
    this.#queue = next.catch(() => undefined);
    return next;
  }

  dispose(): void {
    for (const s of this.#sessions.values()) s.close();
    if (this.#idleTimer) clearTimeout(this.#idleTimer);
    this.#idleTimer = null;
    if (this.#loaded) {
      this.#loaded.transcriber.dispose();
      this.#loaded.model.dispose();
      this.#loaded = null;
    }
    this.#vad?.dispose();
    this.#vad = null;
    clearCache();
  }
}

export class TranscriptionError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
  }
}

/** Registry lookup for the default Whisper checkpoint (first downloaded
 *  `whisper` record) — null when none is on disk. */
export async function defaultWhisperRecord(): Promise<{ path: string; repoId: string } | null> {
  const { Registry } = await import("../registry");
  const reg = new Registry();
  try {
    if (reg.list().length === 0) await reg.scan();
    const hit = reg.listCanonical().find((r) => r.modelType === "whisper");
    return hit ? { path: hit.path, repoId: hit.repoId } : null;
  } catch {
    return null;
  } finally {
    reg.close();
  }
}

/** One live dictation: append PCM, windows transcribe eagerly, finish. */
export class TranscriptionSession {
  readonly createdAt = Date.now();
  #samples = 0;
  #closed = false;
  #speech = false;
  #vadState: VadStreamState | null;
  #vadProbs: number[] = [];
  #pendingSamples: Float32Array[] = [];
  #pendingLen = 0;
  #feeding: Promise<void> = Promise.resolve();
  #feedError: Error | null = null;
  readonly #vad: SileroVadClass | null;

  constructor(
    readonly id: string, readonly service: TranscriptionService, readonly run: WhisperStreamingRun,
    readonly params: TranscriptionParams, readonly vocabulary: VocabularyUsage | undefined, vad: SileroVadClass | null,
  ) {
    this.#vad = vad;
    this.#vadState = vad ? SileroVadClass.streamState() : null;
  }

  get samples(): number { return this.#samples; }
  get durationSeconds(): number { return this.#samples / 16_000; }
  get closed(): boolean { return this.#closed; }
  get speechDetected(): boolean { return this.#speech; }

  /** Append 16 kHz mono float32 PCM. Returns the segments finalized so far. */
  append(pcm: Float32Array): Promise<{ segments: WhisperSegment[]; speech: boolean }> {
    if (this.#closed) throw new TranscriptionError("session is closed", 409);
    this.#samples += pcm.length;
    // streaming VAD in whole 512-sample chunks; the remainder waits
    if (this.#vad && this.#vadState) {
      this.#pendingSamples.push(pcm);
      this.#pendingLen += pcm.length;
      const whole = this.#pendingLen - (this.#pendingLen % 512);
      if (whole > 0) {
        const buf = new Float32Array(this.#pendingLen);
        let o = 0;
        for (const p of this.#pendingSamples) { buf.set(p, o); o += p.length; }
        const probs = this.#vad.probsStreaming(buf.subarray(0, whole), this.#vadState);
        for (const p of probs) { this.#vadProbs.push(p); if (p >= (this.params.vad?.threshold ?? 0.5)) this.#speech = true; }
        const rest = buf.subarray(whole);
        this.#pendingSamples = rest.length ? [rest.slice()] : [];
        this.#pendingLen = rest.length;
      }
    }
    // serialize feeds; window work takes the exclusive lock
    const work = async () => {
      if (this.#vad && !this.#speech) { await this.run.feedSilent(pcm); return; }
      await this.service.runExclusiveQueued(() => this.run.feed(pcm));
    };
    this.#feeding = this.#feeding.then(work, work).catch((e) => { this.#feedError = e as Error; });
    return this.#feeding.then(() => {
      if (this.#feedError) throw this.#feedError;
      return { segments: [...this.run.segments], speech: this.#speech };
    });
  }

  /** Transcribe the remainder and close. */
  async finish(): Promise<TranscriptionOutcome> {
    if (this.#closed) throw new TranscriptionError("session is closed", 409);
    const t0 = performance.now();
    await this.#feeding;
    if (this.#feedError) { this.close(); throw this.#feedError; }
    try {
      let vad: TranscriptionOutcome["vad"];
      if (this.#vad && this.#vadState) {
        if (this.#pendingLen > 0) {
          const buf = new Float32Array(this.#pendingLen);
          let o = 0;
          for (const p of this.#pendingSamples) { buf.set(p, o); o += p.length; }
          for (const p of this.#vad.probsStreaming(buf, this.#vadState)) { this.#vadProbs.push(p); if (p >= (this.params.vad?.threshold ?? 0.5)) this.#speech = true; }
        }
        const segs = SileroVadClass.speechTimestamps(Float32Array.from(this.#vadProbs), this.#samples, { threshold: this.params.vad?.threshold ?? 0.5, minSpeechDurationMs: this.params.vad?.minSpeechMs ?? 250 });
        vad = { speech: segs.length > 0, segments: segs.map((x) => ({ start: x.start / 16_000, end: x.end / 16_000 })) };
        if (segs.length === 0) {
          return {
            result: { text: "", segments: [], language: this.params.language && this.params.language !== "auto" ? this.params.language : "en" },
            durationSeconds: this.durationSeconds, modelId: this.service.modelId,
            timings: { load_ms: 0, transcribe_ms: 0, total_ms: performance.now() - t0 }, vad, vocabulary: this.vocabulary,
          };
        }
      }
      const result = await this.service.runExclusiveQueued(() => this.run.finish());
      const t1 = performance.now();
      return {
        result, durationSeconds: this.durationSeconds, modelId: this.service.modelId,
        timings: { load_ms: 0, transcribe_ms: t1 - t0, total_ms: t1 - t0 }, vocabulary: this.vocabulary, vad,
      };
    } finally {
      this.close();
    }
  }

  close(): void {
    if (this.#closed) return;
    this.#closed = true;
    this.service.releaseSession(this.id);
  }
}
