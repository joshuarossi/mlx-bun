// Transcription service: owns a Whisper checkpoint's residency and runs
// transcriptions one at a time. Main's `src/serve/transcription-service.ts`,
// with model loading behind an injected runtime so residency policy is
// testable without weights.
//
// Residency: the model loads on the first request and is released right
// after each take by default (`idleUnloadSec` > 0 keeps it for that long;
// `resident` pins it). Weights are mmap'd safetensors, so a reload after
// unload reads from the OS page cache; the GPU memory is what an idle server
// gives back. Timings are reported per response (`load_ms` is non-zero
// exactly when the request paged the weights in).
//
// Concurrency: requests queue FIFO here; inside the full server every run is
// additionally wrapped in the generation gateway's exclusive lock
// (`exclusive`) so decoding never overlaps chat generation on the GPU.

import type { WhisperSegment, WhisperTranscribeOptions, WhisperTranscription } from "@mlx-bun/inference/transcription";
import type { SpeechTimestampOptions, VadSegment, VadStreamState } from "@mlx-bun/inference/models/audio/silero-vad";

export interface TranscriptionParams {
  task?: "transcribe" | "translate";
  /** ISO code / name; null or "auto" detects. */
  language?: string | null;
  prompt?: string | null;
  /** Recognition hints fitted into the prompt-token budget. */
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
  /** Lab: encoder context truncation (positions, <= 1500). */
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

/** A transcription in progress over audio that is still arriving. */
export interface WhisperRun {
  readonly segments: readonly WhisperSegment[];
  /** Append audio without transcribing (no speech seen yet). */
  feedSilent(samples: Float32Array): void;
  /** Append audio; every complete 30 s window transcribes. */
  feed(samples: Float32Array): Promise<unknown>;
  /** Transcribe the remainder; the run is finished afterwards. */
  finish(): Promise<WhisperTranscription>;
}

/** A loaded Whisper checkpoint: what the service needs from the library. */
export interface WhisperRuntime {
  /** floor(n_text_ctx / 2) - 1: the prompt-token budget vocabulary hints fit into. */
  readonly promptTokenBudget: number;
  /** Tokenizer encoding, for fitting hints into the budget. */
  encode(text: string): number[];
  transcribe(samples: Float32Array, options: WhisperTranscribeOptions): Promise<WhisperTranscription>;
  start(options: WhisperTranscribeOptions): WhisperRun;
  /** Release the weights and hand cached buffers back to the OS. */
  dispose(): void;
}

/** The Silero gate (about 1 MB, stays resident once loaded). */
export interface VadGate {
  detect(samples: Float32Array, options: SpeechTimestampOptions): { segments: VadSegment[] };
  streamState(): VadStreamState;
  probsStreaming(samples: Float32Array, state: VadStreamState): Float32Array;
  speechTimestamps(probs: Float32Array, audioLengthSamples: number, options: SpeechTimestampOptions): VadSegment[];
  dispose(): void;
}

/** Everything native the service touches; the default opens real weights. */
export interface TranscriptionRuntime {
  load(modelDir: string): Promise<WhisperRuntime>;
  vad(modelPath: string | null): Promise<VadGate>;
  /** 16 kHz mono float32 from an uploaded container. */
  decodeAudio(bytes: Uint8Array): Promise<Float32Array>;
}

/** Real weights through the library's public surfaces. Every native module
 * loads on first use, so composing a service touches no MLX code. */
export const nativeTranscriptionRuntime: TranscriptionRuntime = {
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
  async vad(modelPath) {
    const { SileroVad } = await import("@mlx-bun/inference/models/audio/silero-vad");
    const gate = SileroVad.load(modelPath);
    return {
      detect: (samples, options) => gate.detect(samples, options),
      streamState: () => SileroVad.streamState(),
      probsStreaming: (samples, state) => gate.probsStreaming(samples, state),
      speechTimestamps: (probs, length, options) => SileroVad.speechTimestamps(probs, length, options),
      dispose: () => gate.dispose(),
    };
  },
  /** WAV through the exact PCM parser (oracle scaling), everything else
   *  in-process via AudioToolbox. */
  async decodeAudio(bytes) {
    const { isRiffWave, decodeWav, resampleTo16k, decodeBytesWithAudioToolbox } = await import("@mlx-bun/inference/input/audio");
    if (isRiffWave(bytes)) {
      const wav = decodeWav(bytes);
      return resampleTo16k(wav.samples, wav.sampleRate);
    }
    return decodeBytesWithAudioToolbox(bytes);
  },
};

export interface TranscriptionServiceOptions {
  modelDir: string;
  modelId: string;
  /** Seconds idle before the model is released. Default 0 = release right
   *  after each take, so the chat model has the memory back before it
   *  prefills the transcript. */
  idleUnloadSec?: number;
  /** Never release (always resident); overrides idleUnloadSec. */
  resident?: boolean;
  /** Wraps each run (the full server passes the gateway's exclusive lock). */
  exclusive?: <T>(fn: () => Promise<T>, signal?: AbortSignal) => Promise<T>;
  /** Explicit Silero ggml path (default: the HF cache copy of ggml-org/whisper-vad). */
  vadModelPath?: string | null;
  log?: (line: string) => void;
  /** Model loading and audio decoding; tests supply a fake. */
  runtime?: TranscriptionRuntime;
  /** Idle-unload scheduling; tests supply a fake clock. */
  timers?: { setTimeout(fn: () => void, ms: number): unknown; clearTimeout(handle: unknown): void };
  /** Monotonic milliseconds for the reported timings. */
  now?: () => number;
}

const realTimers: NonNullable<TranscriptionServiceOptions["timers"]> = {
  setTimeout(fn, ms) { const handle = setTimeout(fn, ms); handle.unref?.(); return handle; },
  clearTimeout(handle) { clearTimeout(handle as ReturnType<typeof setTimeout>); },
};

export class TranscriptionError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
  }
}

export interface TranscriptionStats {
  resident: boolean;
  loads: number;
  unloads: number;
  requests: number;
  last_load_ms: number;
  /** null when the weights are pinned resident. */
  idle_unload_sec: number | null;
}

export class TranscriptionService {
  readonly modelDir: string;
  readonly modelId: string;
  readonly idleUnloadSec: number;
  /** The `--whisper-resident` policy (distinct from `resident`, the live state). */
  readonly pinned: boolean;
  #loaded: WhisperRuntime | null = null;
  #loading: Promise<WhisperRuntime> | null = null;
  #idleTimer: unknown = null;
  #queue: Promise<unknown> = Promise.resolve();
  #active = 0;
  #loads = 0;
  #unloads = 0;
  #requests = 0;
  #lastLoadMs = 0;
  #closed = false;
  #vad: Promise<VadGate> | null = null;
  #vadGate: VadGate | null = null;
  readonly #sessions = new Map<string, TranscriptionSession>();
  readonly #exclusive: <T>(fn: () => Promise<T>, signal?: AbortSignal) => Promise<T>;
  readonly #log: (line: string) => void;
  readonly #vadModelPath: string | null;
  readonly #runtime: TranscriptionRuntime;
  readonly #timers: NonNullable<TranscriptionServiceOptions["timers"]>;
  readonly #now: () => number;

  constructor(options: TranscriptionServiceOptions) {
    this.modelDir = options.modelDir;
    this.modelId = options.modelId;
    this.idleUnloadSec = Math.max(0, options.idleUnloadSec ?? 0);
    this.pinned = options.resident ?? false;
    this.#exclusive = options.exclusive ?? (fn => fn());
    this.#log = options.log ?? (line => console.log(line));
    this.#vadModelPath = options.vadModelPath ?? null;
    this.#runtime = options.runtime ?? nativeTranscriptionRuntime;
    this.#timers = options.timers ?? realTimers;
    this.#now = options.now ?? (() => performance.now());
  }

  /** The Silero gate, loaded on first use; a gate arriving after close is released. */
  vad(): Promise<VadGate> {
    return this.#vad ??= this.#runtime.vad(this.#vadModelPath).then(gate => {
      if (this.#closed) { gate.dispose(); throw new TranscriptionError("transcription service is closed", 503); }
      this.#vadGate = gate;
      return gate;
    }, error => { this.#vad = null; throw error; });
  }

  /** Weights are loaded right now. */
  get resident(): boolean {
    return this.#loaded !== null;
  }

  get stats(): TranscriptionStats {
    return {
      resident: this.resident, loads: this.#loads, unloads: this.#unloads, requests: this.#requests,
      last_load_ms: this.#lastLoadMs, idle_unload_sec: this.pinned ? null : this.idleUnloadSec,
    };
  }

  get sessionCount(): number {
    return this.#sessions.size;
  }

  decodeAudio(bytes: Uint8Array): Promise<Float32Array> {
    return this.#runtime.decodeAudio(bytes);
  }

  /** Load (or reuse) the model; returns the load time for this call. */
  async ensureLoaded(): Promise<{ loadMs: number; loaded: WhisperRuntime }> {
    if (this.#closed) throw new TranscriptionError("transcription service is closed", 503);
    if (this.#loaded) return { loadMs: 0, loaded: this.#loaded };
    if (!this.#loading) {
      this.#loading = (async () => {
        const t0 = this.#now();
        const loaded = await this.#runtime.load(this.modelDir);
        if (this.#closed) { loaded.dispose(); throw new TranscriptionError("transcription service is closed", 503); }
        this.#loaded = loaded;
        this.#loads++;
        this.#lastLoadMs = this.#now() - t0;
        this.#log(`[transcription] ${this.modelId} loaded in ${this.#lastLoadMs.toFixed(0)} ms`);
        return loaded;
      })().finally(() => { this.#loading = null; });
    }
    const t0 = this.#now();
    const loaded = await this.#loading;
    return { loadMs: this.#now() - t0, loaded };
  }

  /** Release the model (GPU memory returns; the next request reloads).
   *  False while a take or session is using it. */
  unload(): boolean {
    this.#cancelIdleTimer();
    if (!this.#loaded || this.#active > 0) return false;
    this.#loaded.dispose();
    this.#loaded = null;
    this.#unloads++;
    this.#log(`[transcription] ${this.modelId} unloaded (idle)`);
    return true;
  }

  #cancelIdleTimer(): void {
    if (this.#idleTimer !== null) this.#timers.clearTimeout(this.#idleTimer);
    this.#idleTimer = null;
  }

  #armIdleTimer(): void {
    this.#cancelIdleTimer();
    if (this.pinned || this.#closed) return;
    if (this.idleUnloadSec <= 0) { if (this.#active === 0 && this.#sessions.size === 0) this.unload(); return; }
    this.#idleTimer = this.#timers.setTimeout(() => { this.#idleTimer = null; this.unload(); }, this.idleUnloadSec * 1000);
  }

  /** Fit vocabulary terms into the prompt budget, ", "-joined in order,
   *  whole terms only. */
  static fitVocabulary(encode: (text: string) => number[], budget: number, base: string, terms: string[]): { prompt: string; usage: VocabularyUsage } {
    const included: string[] = [];
    const omitted: string[] = [];
    let prompt = base.trim();
    let tokenCount = prompt ? encode(" " + prompt).length : 0;
    for (const term of terms) {
      const candidate = prompt ? `${prompt}, ${term}` : term;
      const n = encode(" " + candidate.trim()).length;
      if (n > budget) { omitted.push(term); continue; }
      included.push(term);
      prompt = candidate;
      tokenCount = n;
    }
    return { prompt, usage: { included, omitted, token_count: tokenCount, token_budget: budget } };
  }

  #decodingOptions(loaded: WhisperRuntime, params: TranscriptionParams): { options: WhisperTranscribeOptions; vocabulary: VocabularyUsage | undefined } {
    let prompt = params.prompt ?? null;
    let vocabulary: VocabularyUsage | undefined;
    if (params.vocabulary?.length) {
      const fit = TranscriptionService.fitVocabulary(text => loaded.encode(text), loaded.promptTokenBudget, prompt ?? "", params.vocabulary);
      prompt = fit.prompt || null;
      vocabulary = fit.usage;
    }
    const language = params.language == null || params.language === "auto" ? null : params.language;
    return { vocabulary, options: {
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
    } };
  }

  async transcribe(audio: Uint8Array | Float32Array, params: TranscriptionParams = {}): Promise<TranscriptionOutcome> {
    const run = async (): Promise<TranscriptionOutcome> => {
      const t0 = this.#now();
      this.#requests++;
      this.#cancelIdleTimer();
      this.#active++;
      try {
        let samples = audio instanceof Float32Array ? audio : await this.#runtime.decodeAudio(audio);
        if (samples.length < 1600) throw new TranscriptionError("audio is shorter than 0.1 s", 400);
        let vadInfo: TranscriptionOutcome["vad"];
        let vadMs = 0;
        if (params.vad) {
          const tv = this.#now();
          const vadOptions: SpeechTimestampOptions = { threshold: params.vad.threshold ?? 0.5, minSpeechDurationMs: params.vad.minSpeechMs ?? 250 };
          const { segments } = (await this.vad()).detect(samples, vadOptions);
          vadMs = this.#now() - tv;
          vadInfo = { speech: segments.length > 0, segments: segments.map(s => ({ start: s.start / 16_000, end: s.end / 16_000 })) };
          if (segments.length === 0) {
            return {
              result: { text: "", segments: [], language: params.language && params.language !== "auto" ? params.language : "en" },
              durationSeconds: samples.length / 16_000, modelId: this.modelId,
              timings: { load_ms: 0, transcribe_ms: 0, total_ms: this.#now() - t0, vad_ms: vadMs }, vad: vadInfo,
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
        const { options, vocabulary } = this.#decodingOptions(loaded, params);
        const t1 = this.#now();
        const result = await this.#exclusive(() => loaded.transcribe(samples, {
          ...options, onSegment: params.onSegment, onProgress: params.onProgress, signal: params.signal,
        }), params.signal);
        const t2 = this.#now();
        if (vadInfo?.trimmed) {
          const offset = vadInfo.trimmed.start;
          for (const segment of result.segments) {
            segment.start += offset; segment.end += offset;
            for (const word of segment.words ?? []) { word.start += offset; word.end += offset; }
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

  async createSession(params: TranscriptionParams = {}): Promise<TranscriptionSession> {
    if (this.#closed) throw new TranscriptionError("transcription service is closed", 503);
    if (this.#sessions.size >= 64) throw new TranscriptionError("too many open transcription sessions", 429);
    const { loaded } = await this.ensureLoaded();
    // Reserve the weights before suspending again: unload() and the idle
    // policy refuse while #active > 0, and close() is rechecked after the
    // VAD boundary because a cached gate resolves without its arrival check.
    this.#cancelIdleTimer();
    this.#active++;
    try {
      const gate = params.vad ? await this.vad() : null;
      if (this.#closed) throw new TranscriptionError("transcription service is closed", 503);
      const id = crypto.randomUUID();
      const { options, vocabulary } = this.#decodingOptions(loaded, params);
      const session = new TranscriptionSession(id, this, loaded.start(options), params, vocabulary, gate, this.#now);
      this.#sessions.set(id, session);
      return session;
    } catch (error) {
      this.#active--;
      this.#armIdleTimer();
      throw error;
    }
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

  /** Close every session, cancel the idle timer, and release the weights and
   *  the VAD gate. Idempotent; a load still in flight is released on arrival. */
  close(): void {
    if (this.#closed) return;
    this.#closed = true;
    for (const session of this.#sessions.values()) session.close();
    this.#cancelIdleTimer();
    if (this.#loaded) {
      this.#loaded.dispose();
      this.#loaded = null;
    }
    this.#vadGate?.dispose();
    this.#vadGate = null;
    this.#vad = null;
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
  readonly #vad: VadGate | null;
  readonly #now: () => number;

  constructor(
    readonly id: string, readonly service: TranscriptionService, readonly run: WhisperRun,
    readonly params: TranscriptionParams, readonly vocabulary: VocabularyUsage | undefined, vad: VadGate | null,
    now: () => number = () => performance.now(),
  ) {
    this.#vad = vad;
    this.#vadState = vad ? vad.streamState() : null;
    this.#now = now;
  }

  get samples(): number { return this.#samples; }
  get durationSeconds(): number { return this.#samples / 16_000; }
  get closed(): boolean { return this.#closed; }
  get speechDetected(): boolean { return this.#speech; }

  #pendingBuffer(): Float32Array {
    const buffer = new Float32Array(this.#pendingLen);
    let offset = 0;
    for (const part of this.#pendingSamples) { buffer.set(part, offset); offset += part.length; }
    return buffer;
  }

  #pushProbs(probs: Float32Array): void {
    for (const p of probs) { this.#vadProbs.push(p); if (p >= (this.params.vad?.threshold ?? 0.5)) this.#speech = true; }
  }

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
        const buffer = this.#pendingBuffer();
        this.#pushProbs(this.#vad.probsStreaming(buffer.subarray(0, whole), this.#vadState));
        const rest = buffer.subarray(whole);
        this.#pendingSamples = rest.length ? [rest.slice()] : [];
        this.#pendingLen = rest.length;
      }
    }
    // serialize feeds; window work takes the exclusive lock
    const work = async () => {
      if (this.#vad && !this.#speech) { this.run.feedSilent(pcm); return; }
      await this.service.runExclusiveQueued(() => this.run.feed(pcm));
    };
    this.#feeding = this.#feeding.then(work, work).catch(error => { this.#feedError = error as Error; });
    return this.#feeding.then(() => {
      if (this.#feedError) throw this.#feedError;
      return { segments: [...this.run.segments], speech: this.#speech };
    });
  }

  /** Transcribe the remainder and close. */
  async finish(): Promise<TranscriptionOutcome> {
    if (this.#closed) throw new TranscriptionError("session is closed", 409);
    const t0 = this.#now();
    await this.#feeding;
    if (this.#feedError) { this.close(); throw this.#feedError; }
    try {
      let vad: TranscriptionOutcome["vad"];
      if (this.#vad && this.#vadState) {
        if (this.#pendingLen > 0) this.#pushProbs(this.#vad.probsStreaming(this.#pendingBuffer(), this.#vadState));
        const segments = this.#vad.speechTimestamps(Float32Array.from(this.#vadProbs), this.#samples,
          { threshold: this.params.vad?.threshold ?? 0.5, minSpeechDurationMs: this.params.vad?.minSpeechMs ?? 250 });
        vad = { speech: segments.length > 0, segments: segments.map(s => ({ start: s.start / 16_000, end: s.end / 16_000 })) };
        if (segments.length === 0) {
          return {
            result: { text: "", segments: [], language: this.params.language && this.params.language !== "auto" ? this.params.language : "en" },
            durationSeconds: this.durationSeconds, modelId: this.service.modelId,
            timings: { load_ms: 0, transcribe_ms: 0, total_ms: this.#now() - t0 }, vad, vocabulary: this.vocabulary,
          };
        }
      }
      const result = await this.service.runExclusiveQueued(() => this.run.finish());
      const t1 = this.#now();
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
