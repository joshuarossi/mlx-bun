// Transcription service: request admission, the Silero speech gate, vocabulary
// hints and streaming sessions over a Whisper model the host leases. Main's
// `02d723a:src/serve/transcription-service.ts`, with residency (lazy load,
// idle unload, pinning, the exclusive lock) behind the `modelHost` service so
// the policy is the host's and testable without weights.
//
// Each take leases the model for exactly as long as it runs, and the host
// decides when the weights are released: `load_ms` in a response is non-zero
// exactly when the request paged them in.
//
// Concurrency: requests queue FIFO here, and every decode call runs under the
// host's execution lock inside the lease's operation, so decoding never
// overlaps generation on the GPU.

import type {
  ModelHost, ModelHostError, ModelLease, TranscribeOptions, Transcript, TranscriptSegment, TranscriptionOperation, TranscriptionRun,
} from "@mlx-bun/app-core";
import type { SpeechTimestampOptions, VadSegment, VadStreamState } from "@mlx-bun/inference/transcription";

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
  onSegment?: (segment: TranscriptSegment) => void;
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
  result: Transcript;
  durationSeconds: number;
  modelId: string;
  timings: { load_ms: number; transcribe_ms: number; total_ms: number; vad_ms?: number };
  vocabulary?: VocabularyUsage;
  vad?: { speech: boolean; segments: { start: number; end: number }[]; trimmed?: { start: number; end: number } };
}

/** The Silero gate (about 1 MB, stays resident once loaded). */
export interface VadGate {
  detect(samples: Float32Array, options: SpeechTimestampOptions): { segments: VadSegment[] };
  streamState(): VadStreamState;
  probsStreaming(samples: Float32Array, state: VadStreamState): Float32Array;
  speechTimestamps(probs: Float32Array, audioLengthSamples: number, options: SpeechTimestampOptions): VadSegment[];
  dispose(): void;
}

/** What the service needs besides the model: the speech gate and audio decoding. Tests supply a fake. */
export interface MediaRuntime {
  vad(modelPath: string | null): Promise<VadGate>;
  /** 16 kHz mono float32 from an uploaded container. */
  decodeAudio(bytes: Uint8Array): Promise<Float32Array>;
}

/** The library's decoders. Every native module loads on first use, so composing a service touches no MLX code. */
export const nativeMedia: MediaRuntime = {
  async vad(modelPath) {
    const { SileroVad } = await import("@mlx-bun/inference/transcription");
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
  /** The host's model service: leases, residency and the execution lock. */
  models: Pick<ModelHost, "acquire" | "defaultFor" | "resident" | "stats" | "unload">;
  /** The checkpoint to lease; default: the host's default for `transcribe`, resolved on first use. */
  modelId?: string;
  /** HTTP admission defaults to 0.1 s; the file CLI accepts shorter clips. */
  minimumAudioSeconds?: number;
  /** Seconds the model stays loaded after each take, overriding the host's policy. */
  keepAliveSec?: number;
  /** Explicit Silero ggml path (default: the HF cache copy of ggml-org/whisper-vad). */
  vadModelPath?: string | null;
  /** The speech gate and audio decoding; tests supply a fake. */
  media?: MediaRuntime;
  /** Monotonic milliseconds for the reported timings. */
  now?: () => number;
}

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

const closedError = () => new TranscriptionError("transcription service is closed", 503);

/** A lease held across a stretch of work; `loadMs` is what acquiring it cost. */
export interface ModelHold { readonly loadMs: number; release(): void }

export class TranscriptionService {
  #modelId: string | undefined;
  #resolving: Promise<string | null> | null = null;
  #queue: Promise<unknown> = Promise.resolve();
  #requests = 0;
  #closed = false;
  #vad: Promise<VadGate> | null = null;
  #vadGate: VadGate | null = null;
  /** Aborted by close(): every take and session signal is composed with it. */
  readonly #shutdown = new AbortController();
  /** Takes and session creations still running; close() joins them. */
  readonly #inflight = new Set<Promise<unknown>>();
  #closing: Promise<void> | null = null;
  readonly #sessions = new Map<string, TranscriptionSession>();
  readonly #models: TranscriptionServiceOptions["models"];
  readonly #vadModelPath: string | null;
  readonly #media: MediaRuntime;
  readonly #keepAliveSec: number | undefined;
  readonly #now: () => number;
  readonly #minimumAudioSeconds: number;

  constructor(options: TranscriptionServiceOptions) {
    this.#models = options.models;
    this.#modelId = options.modelId;
    this.#minimumAudioSeconds = options.minimumAudioSeconds ?? 0.1;
    if (!Number.isFinite(this.#minimumAudioSeconds) || this.#minimumAudioSeconds < 0)
      throw new Error("invalid minimum audio duration");
    this.#keepAliveSec = options.keepAliveSec;
    this.#vadModelPath = options.vadModelPath ?? null;
    this.#media = options.media ?? nativeMedia;
    this.#now = options.now ?? (() => performance.now());
  }

  /** The checkpoint this service leases, resolved once (as in main, a model downloaded later needs a restart); null when the host has none. */
  resolveModel(): Promise<string | null> {
    if (this.#modelId !== undefined) return Promise.resolve(this.#modelId);
    return this.#resolving ??= this.#models.defaultFor("transcribe").then(id => { this.#modelId = id; return id ?? null; });
  }

  /** The resolved checkpoint id; only meaningful after `resolveModel()` returned one. */
  get modelId(): string { return this.#modelId ?? ""; }

  /** The caller's signal composed with service shutdown. */
  #ownedSignal(signal?: AbortSignal): AbortSignal {
    return signal ? AbortSignal.any([signal, this.#shutdown.signal]) : this.#shutdown.signal;
  }

  #track<T>(work: Promise<T>): Promise<T> {
    this.#inflight.add(work);
    work.finally(() => { this.#inflight.delete(work); }).catch(() => {});
    return work;
  }

  /** The Silero gate, loaded on first use; a gate arriving after close is released. */
  vad(): Promise<VadGate> {
    return this.#vad ??= this.#media.vad(this.#vadModelPath).then(gate => {
      if (this.#closed) { gate.dispose(); throw closedError(); }
      this.#vadGate = gate;
      return gate;
    }, error => { this.#vad = null; throw error; });
  }

  /** Weights are loaded right now. */
  get resident(): boolean {
    return this.#modelId !== undefined && this.#models.stats(this.#modelId).resident;
  }

  get stats(): TranscriptionStats {
    const model = this.#modelId === undefined ? undefined : this.#models.stats(this.#modelId);
    return {
      resident: model?.resident ?? false, loads: model?.loads ?? 0, unloads: model?.unloads ?? 0, requests: this.#requests,
      last_load_ms: model?.lastLoadMs ?? 0, idle_unload_sec: model ? model.idleUnloadSec : null,
    };
  }

  get sessionCount(): number {
    return this.#sessions.size;
  }

  decodeAudio(bytes: Uint8Array): Promise<Float32Array> {
    return this.#media.decodeAudio(bytes);
  }

  /** Lease the model, loading it if it is not resident. The host's failures become HTTP-shaped ones. */
  async lease(signal?: AbortSignal): Promise<ModelHold & { readonly transcription: TranscriptionOperation }> {
    if (this.#closed) throw closedError();
    const id = await this.resolveModel();
    if (id === null) throw new TranscriptionError("no Whisper model is available", 503);
    let lease: ModelLease;
    try {
      lease = await this.#models.acquire(id, { need: ["transcribe"], ...(this.#keepAliveSec !== undefined ? { keepAliveSec: this.#keepAliveSec } : {}),
        ...(signal ? { signal } : {}) });
    } catch (error) {
      if ((error as Partial<ModelHostError>).code === "closed") throw closedError();
      throw error;
    }
    if (this.#closed) { lease.release(); throw closedError(); }
    const transcription = lease.operations.transcribe;
    if (!transcription) { lease.release(); throw new Error(`${id} did not provide the transcribe operation`); }
    return { loadMs: lease.loadMs, transcription, release: () => lease.release() };
  }

  /** Release the model now (GPU memory returns; the next request reloads).
   *  False while a take or session is using it, or when it is not loaded. */
  async unload(): Promise<boolean> {
    const id = await this.resolveModel();
    if (id === null || !this.#models.resident().some(model => model.id === id)) return false;
    try { await this.#models.unload(id); } catch { return false; }
    return !this.#models.resident().some(model => model.id === id);
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

  #decodingOptions(model: TranscriptionOperation, params: TranscriptionParams): { options: TranscribeOptions; vocabulary: VocabularyUsage | undefined } {
    let prompt = params.prompt ?? null;
    let vocabulary: VocabularyUsage | undefined;
    if (params.vocabulary?.length) {
      const fit = TranscriptionService.fitVocabulary(text => model.encode(text), model.promptTokenBudget, prompt ?? "", params.vocabulary);
      prompt = fit.prompt || null;
      vocabulary = fit.usage;
    }
    return { vocabulary, options: {
      task: params.task ?? "transcribe",
      language: params.language ?? null,
      prompt,
      beamSize: params.beamSize ?? null,
      ...(params.temperature != null ? { temperature: params.temperature } : {}),
      conditionOnPreviousText: params.conditionOnPreviousText ?? true,
      ...(params.noSpeechThreshold !== undefined ? { noSpeechThreshold: params.noSpeechThreshold } : {}),
      withoutTimestamps: params.withoutTimestamps ?? false,
      wordTimestamps: params.wordTimestamps ?? false,
      faithful: params.faithful ?? false,
      audioCtx: params.audioCtx ?? null,
    } };
  }

  async transcribe(audio: Uint8Array | Float32Array, params: TranscriptionParams = {}): Promise<TranscriptionOutcome> {
    if (this.#closed) throw closedError();
    const signal = this.#ownedSignal(params.signal);
    const run = async (): Promise<TranscriptionOutcome> => {
      if (this.#closed) throw closedError();
      signal.throwIfAborted();
      const t0 = this.#now();
      this.#requests++;
      let samples = audio instanceof Float32Array ? audio : await this.#media.decodeAudio(audio);
      signal.throwIfAborted();
      if (samples.length < this.#minimumAudioSeconds * 16_000)
        throw new TranscriptionError(`audio is shorter than ${this.#minimumAudioSeconds} s`, 400);
      let vadInfo: TranscriptionOutcome["vad"];
      let vadMs = 0;
      const modelId = await this.resolveModel();
      if (params.vad) {
        const tv = this.#now();
        const vadOptions: SpeechTimestampOptions = { threshold: params.vad.threshold ?? 0.5, minSpeechDurationMs: params.vad.minSpeechMs ?? 250 };
        const { segments } = (await this.vad()).detect(samples, vadOptions);
        vadMs = this.#now() - tv;
        vadInfo = { speech: segments.length > 0, segments: segments.map(s => ({ start: s.start / 16_000, end: s.end / 16_000 })) };
        if (segments.length === 0) {
          return {
            result: { text: "", segments: [], language: params.language && params.language !== "auto" ? params.language : "en" },
            durationSeconds: samples.length / 16_000, modelId: modelId ?? "",
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
      const held = await this.lease(signal);
      try {
        const { options, vocabulary } = this.#decodingOptions(held.transcription, params);
        const t1 = this.#now();
        const result = await held.transcription.transcribe(samples, {
          ...options, onSegment: params.onSegment, onProgress: params.onProgress, signal,
        });
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
          timings: { load_ms: held.loadMs, transcribe_ms: t2 - t1, total_ms: t2 - t0, ...(params.vad ? { vad_ms: vadMs } : {}) },
          vocabulary,
          vad: vadInfo,
        };
      } finally { held.release(); }
    };
    const next = this.#queue.then(run, run);
    this.#queue = next.catch(() => undefined);
    return this.#track(next);
  }

  // --- streaming sessions -----------------------------------------------------
  // Audio arrives while it is being recorded; every completed 30 s window
  // is transcribed under the exclusive lock as soon as it exists, so the
  // latency at finish() is one window regardless of take length.

  async createSession(params: TranscriptionParams = {}): Promise<TranscriptionSession> {
    params.signal?.throwIfAborted();
    if (this.#closed) throw closedError();
    if (this.#sessions.size >= 64) throw new TranscriptionError("too many open transcription sessions", 429);
    return this.#track(this.#createSession({ ...params, signal: this.#ownedSignal(params.signal) }));
  }

  async #createSession(params: TranscriptionParams & { signal: AbortSignal }): Promise<TranscriptionSession> {
    // The lease is the session's for its whole life: the host neither unloads
    // nor idles the weights while it is held. It is rechecked after the VAD
    // boundary because a cached gate resolves without its arrival check.
    const held = await this.lease(params.signal);
    try {
      const gate = params.vad ? await this.vad() : null;
      if (this.#closed) throw closedError();
      params.signal.throwIfAborted();
      const id = crypto.randomUUID();
      const { options, vocabulary } = this.#decodingOptions(held.transcription, params);
      const session = new TranscriptionSession(id, this, held.transcription.start({ ...options, signal: params.signal }), params, vocabulary, gate, held, this.#now);
      this.#sessions.set(id, session);
      return session;
    } catch (error) {
      held.release();
      throw error;
    }
  }

  session(id: string): TranscriptionSession | null {
    return this.#sessions.get(id) ?? null;
  }

  /** @internal called by the session when it closes; its lease is already back with the host. */
  releaseSession(id: string): void {
    if (this.#sessions.delete(id)) this.#requests++;
  }

  /** @internal window work runs FIFO with requests; the decode call takes the host's lock. */
  runQueued<T>(fn: () => Promise<T>): Promise<T> {
    const next = this.#queue.then(fn, fn);
    this.#queue = next.catch(() => undefined);
    return next;
  }

  /** Stop admission, cancel pending work, join every session, take, creation
   *  and load in flight, then release the speech gate. The host releases the
   *  weights. Idempotent (later calls return the same promise); with nothing in
   *  flight the release happens synchronously. */
  close(): Promise<void> {
    if (this.#closing) return this.#closing;
    this.#closed = true;
    this.#shutdown.abort(closedError());
    // Idle sessions release synchronously inside close(); busy ones are joined.
    const sessionCloses = [...this.#sessions.values()].map(session => session.close());
    const joins: Promise<unknown>[] = [...this.#inflight];
    const release = () => {
      this.#vadGate?.dispose();
      this.#vadGate = null;
      this.#vad = null;
    };
    if (this.#sessions.size === 0 && joins.length === 0) { release(); return this.#closing = Promise.resolve(); }
    return this.#closing = Promise.allSettled([...sessionCloses, ...joins]).then(() => { release(); });
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
  #finishing: Promise<unknown> | null = null;
  #closing: Promise<void> | null = null;
  #released = false;
  #feeds = 0;
  /** Aborted by close(): pending feeds and the finish are skipped, running work is joined. */
  readonly #abort = new AbortController();
  readonly #signal: AbortSignal;
  readonly #vad: VadGate | null;
  readonly #now: () => number;

  constructor(
    readonly id: string, readonly service: TranscriptionService, readonly run: TranscriptionRun,
    readonly params: TranscriptionParams, readonly vocabulary: VocabularyUsage | undefined, vad: VadGate | null,
    readonly lease: ModelHold, now: () => number = () => performance.now(),
  ) {
    this.#vad = vad;
    this.#vadState = vad ? vad.streamState() : null;
    this.#now = now;
    this.#signal = params.signal ? AbortSignal.any([params.signal, this.#abort.signal]) : this.#abort.signal;
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
  append(pcm: Float32Array): Promise<{ segments: TranscriptSegment[]; speech: boolean }> {
    this.#signal.throwIfAborted();
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
    // serialize feeds; window work runs under the host's execution lock
    const work = async () => {
      try {
        this.#signal.throwIfAborted();
        if (this.#vad && !this.#speech) { this.run.feedSilent(pcm); return; }
        // Re-check at the head of the queue: a close() while queued skips the feed.
        await this.service.runQueued(() => { this.#signal.throwIfAborted(); return this.run.feed(pcm, this.#signal); });
      } finally { this.#feeds--; }
    };
    this.#feeds++;
    this.#feeding = this.#feeding.then(work, work).catch(error => { this.#feedError = error as Error; });
    return this.#feeding.then(() => {
      if (this.#feedError) throw this.#feedError;
      return { segments: [...this.run.segments], speech: this.#speech };
    });
  }

  /** Transcribe the remainder and close. A concurrent close() joins this. */
  async finish(): Promise<TranscriptionOutcome> {
    this.#signal.throwIfAborted();
    if (this.#closed) throw new TranscriptionError("session is closed", 409);
    const work = this.#finish();
    this.#finishing = work.catch(() => undefined);
    return work;
  }

  async #finish(): Promise<TranscriptionOutcome> {
    const t0 = this.#now();
    await this.#feeding;
    if (this.#feedError) { this.#release(); throw this.#feedError; }
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
      const result = await this.service.runQueued(() => { this.#signal.throwIfAborted(); return this.run.finish(this.#signal); });
      const t1 = this.#now();
      return {
        result, durationSeconds: this.durationSeconds, modelId: this.service.modelId,
        timings: { load_ms: 0, transcribe_ms: t1 - t0, total_ms: t1 - t0 }, vocabulary: this.vocabulary, vad,
      };
    } finally {
      this.#release();
    }
  }

  /** Give the model back to the host exactly once; no admission afterwards. */
  #release(): void {
    this.#closed = true;
    if (this.#released) return;
    this.#released = true;
    this.lease.release();
    this.service.releaseSession(this.id);
  }

  /** Stop admission, skip pending feeds, join the feed or finish in flight,
   *  then release the model lease. Idempotent. */
  close(): Promise<void> {
    if (this.#closing) return this.#closing;
    this.#closed = true;
    this.#abort.abort(new TranscriptionError("session is closed", 409));
    if (this.#feeds === 0 && !this.#finishing) { this.#release(); return this.#closing = Promise.resolve(); }
    return this.#closing = (async () => {
      await this.#feeding;
      if (this.#finishing) await this.#finishing;
      this.#release();
    })();
  }
}
