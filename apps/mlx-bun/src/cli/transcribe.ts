import { formatTimestamp, formatTranscription, TRANSCRIPTION_FORMATS, type TranscriptionFormat } from "@mlx-bun/inference/transcription/format";
import { nativeTranscriptionRuntime, TranscriptionService, type TranscriptionRuntime } from "../engine/transcription-service";
import { parseCommand } from "./args";
import { resolveWhisperModel } from "./model-selection";

// `mlx-bun transcribe`: one audio file → Whisper → the chosen format, no
// server. Main's handler over the engine's TranscriptionService (the same
// runtime seam serve composes), so residency, VAD, and vocabulary policy have
// one owner. Main's order is kept: the clip is read and decoded before any
// model is resolved, so a bad file never opens the registry.

export interface TranscribeArgs {
  file: string;
  /** --model, else the second positional, else --query; undefined = the first downloaded Whisper. */
  query?: string;
  language: string | null;
  task: "transcribe" | "translate";
  beamSize: number | null;
  /** undefined runs the (0, 0.2, …, 1.0) fallback ladder; --no-fallback is 0. */
  temperature?: number;
  prompt: string | null;
  withoutTimestamps: boolean;
  conditionOnPreviousText: boolean;
  vad: { threshold: number; modelPath: string | null; trim: boolean } | null;
  wordTimestamps: boolean;
  faithful: boolean;
  audioCtx: number | null;
  format: TranscriptionFormat;
  verbose: boolean;
}

function numeric(raw: string, name: string, input: { integer?: boolean; minimum?: number } = {}): number {
  const value = Number(raw);
  if (!raw.trim() || !Number.isFinite(value) || (input.integer && !Number.isSafeInteger(value)) || value < (input.minimum ?? -Infinity))
    throw new Error(`invalid --${name}: ${raw}`);
  return value;
}

export function parseTranscribeArgs(argv: string[]): TranscribeArgs {
  const parsed = parseCommand("transcribe", argv);
  const value = (name: string) => { const v = parsed.values[name]; return typeof v === "string" ? v : undefined; };
  const flag = (name: string) => parsed.values[name] === true;
  const format = (value("format") ?? "text") as TranscriptionFormat;
  if (!TRANSCRIPTION_FORMATS.includes(format)) throw new Error(`--format must be one of ${TRANSCRIPTION_FORMATS.join(", ")}`);
  const language = value("language"), beam = value("beam-size"), temperature = value("temperature"), audioCtx = value("audio-ctx");
  const threshold = value("vad-threshold");
  return {
    file: parsed.positionals[0]!,
    query: value("model") ?? parsed.positionals[1] ?? value("query"),
    language: !language || language === "auto" ? null : language,
    task: value("task") === "translate" ? "translate" : "transcribe",
    beamSize: beam !== undefined ? numeric(beam, "beam-size", { integer: true, minimum: 1 }) : null,
    ...(temperature !== undefined ? { temperature: numeric(temperature, "temperature", { minimum: 0 }) } : flag("no-fallback") ? { temperature: 0 } : {}),
    prompt: value("prompt") ?? null,
    withoutTimestamps: flag("no-timestamps"),
    conditionOnPreviousText: !flag("no-condition"),
    vad: flag("vad") ? { threshold: threshold !== undefined ? numeric(threshold, "vad-threshold", { minimum: 0 }) : 0.5,
      modelPath: value("vad-model") ?? null, trim: flag("vad-trim") } : null,
    wordTimestamps: flag("word-timestamps"),
    faithful: flag("faithful"),
    audioCtx: audioCtx !== undefined ? numeric(audioCtx, "audio-ctx", { integer: true, minimum: 1 }) : null,
    format,
    verbose: flag("verbose"),
  };
}

export interface TranscribeDependencies {
  read(path: string): Promise<Uint8Array>;
  resolveModel: typeof resolveWhisperModel;
  /** Model loading, the VAD gate, and audio decoding; undefined = real weights. */
  runtime?: TranscriptionRuntime;
  write(text: string): void;
  /** One stderr line (main's --verbose diagnostics). */
  note(line: string): void;
}
const defaults: TranscribeDependencies = {
  async read(path) {
    const file = Bun.file(path);
    if (!(await file.exists())) throw new Error(`audio file not found: ${path}`);
    return new Uint8Array(await file.arrayBuffer());
  },
  resolveModel: resolveWhisperModel,
  write: text => { process.stdout.write(text); },
  note: line => { console.error(line); },
};

export async function runTranscribe(args: TranscribeArgs, supplied: Partial<TranscribeDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const runtime = deps.runtime ?? nativeTranscriptionRuntime;
  signal?.throwIfAborted();
  const bytes = await deps.read(args.file);
  signal?.throwIfAborted();
  const samples = await runtime.decodeAudio(bytes);
  signal?.throwIfAborted();
  const durationSeconds = samples.length / 16_000;
  const model = await deps.resolveModel(args.query);
  signal?.throwIfAborted();
  // The verb owns the weights' lifetime: resident until close releases them.
  const service = new TranscriptionService({ modelDir: model.path, modelId: model.repoId, resident: true, minimumAudioSeconds: 0,
    vadModelPath: args.vad?.modelPath ?? null, log() {}, runtime });
  try {
    const outcome = await service.transcribe(samples, {
      task: args.task, language: args.language, prompt: args.prompt, beamSize: args.beamSize,
      ...(args.temperature !== undefined ? { temperature: args.temperature } : {}),
      conditionOnPreviousText: args.conditionOnPreviousText, withoutTimestamps: args.withoutTimestamps,
      wordTimestamps: args.wordTimestamps, faithful: args.faithful, audioCtx: args.audioCtx,
      // Main gated on the detector's segments but transcribed the whole clip;
      // --vad-trim is accepted and, as there, not applied.
      vad: args.vad ? { threshold: args.vad.threshold, trim: false } : null,
      onSegment: args.verbose ? s => deps.note(`[${formatTimestamp(s.start, ".")} --> ${formatTimestamp(s.end, ".")}] ${s.text.trim()}`) : undefined,
      signal,
    });
    signal?.throwIfAborted();
    if (outcome.vad) {
      if (args.verbose) deps.note(`vad: ${outcome.vad.segments.length} speech segment(s) in ${(outcome.timings.vad_ms ?? 0).toFixed(0)} ms`);
      if (!outcome.vad.speech) {
        deps.write(args.format === "text" ? "\n" : JSON.stringify({ text: "", vad: { speech: false, segments: [] } }) + "\n");
        return;
      }
    }
    if (args.verbose) {
      const elapsed = outcome.timings.transcribe_ms / 1000;
      deps.note(`${durationSeconds.toFixed(2)} s audio in ${elapsed.toFixed(3)} s (${(durationSeconds / elapsed).toFixed(1)}× realtime), language ${outcome.result.language}`);
    }
    deps.write(formatTranscription(outcome.result, args.format, durationSeconds, args.task));
  } finally { await service.close(); }
}
