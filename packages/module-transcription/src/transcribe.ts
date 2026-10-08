import type { CliInvocation, CoreServices } from "@mlx-bun/app-core";
import { formatTimestamp, formatTranscription, TRANSCRIPTION_FORMATS, type TranscriptionFormat } from "@mlx-bun/inference/transcription/format";
import { nativeMedia, TranscriptionService, type MediaRuntime } from "./service";

// The `transcribe` verb: one audio file → Whisper → the chosen format, no
// server. Main's handler over the same TranscriptionService the routes use, so
// VAD and vocabulary policy have one owner and the host owns residency. Main's
// order is kept: the clip is read and decoded before any model is resolved, so
// a bad file never opens the registry.

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

function numeric(value: number, name: string, input: { integer?: boolean; minimum?: number } = {}): number {
  if (!Number.isFinite(value) || (input.integer && !Number.isSafeInteger(value)) || value < (input.minimum ?? -Infinity))
    throw new Error(`invalid --${name}: ${value}`);
  return value;
}

/** The verb's arguments from what the host parsed against the manifest. */
export function parseTranscribeArgs(invocation: Pick<CliInvocation, "values" | "positionals">): TranscribeArgs {
  const { values, positionals } = invocation;
  const value = (name: string) => { const v = values[name]; return typeof v === "string" ? v : undefined; };
  const number = (name: string) => { const v = values[name]; return typeof v === "number" ? v : undefined; };
  const flag = (name: string) => values[name] === true;
  const format = (value("format") ?? "text") as TranscriptionFormat;
  if (!TRANSCRIPTION_FORMATS.includes(format)) throw new Error(`--format must be one of ${TRANSCRIPTION_FORMATS.join(", ")}`);
  const language = value("language"), beam = number("beam-size"), temperature = number("temperature"), audioCtx = number("audio-ctx");
  const threshold = number("vad-threshold");
  return {
    file: positionals[0]!,
    query: value("model") ?? positionals[1] ?? value("query"),
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

export type VoiceServices = Pick<CoreServices, "modelHost" | "catalog">;

/** The checkpoint for `transcribe` and `dictate`, main's order: a query names it (a model directory is used as given, else the registry resolves it), and nothing falls back to the host's default with main's `get` hint when none is on disk. */
export async function resolveWhisperModel(services: VoiceServices, query: string | undefined): Promise<string> {
  if (query) return (await services.catalog.find(query)).id;
  const id = await services.modelHost.defaultFor("transcribe");
  if (!id) throw new Error("no Whisper model downloaded — try: mlx-bun get mlx-community/whisper-large-v3-turbo");
  return id;
}

export interface TranscribeDependencies {
  read(path: string): Promise<Uint8Array>;
  /** The checkpoint id for the verb's query; default: `resolveWhisperModel` over the host's services. */
  resolveModel?(query: string | undefined): Promise<string>;
  /** The VAD gate and audio decoding; undefined = the library's. */
  media?: MediaRuntime;
  write(text: string): void;
  /** One stderr line (main's --verbose diagnostics). */
  note(line: string): void;
}
const defaults: Pick<TranscribeDependencies, "read" | "write" | "note"> = {
  async read(path) {
    const file = Bun.file(path);
    if (!(await file.exists())) throw new Error(`audio file not found: ${path}`);
    return new Uint8Array(await file.arrayBuffer());
  },
  write: text => { process.stdout.write(text); },
  note: line => { console.error(line); },
};

export async function runTranscribe(services: VoiceServices, args: TranscribeArgs, supplied: Partial<TranscribeDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const media = deps.media ?? nativeMedia;
  signal?.throwIfAborted();
  const bytes = await deps.read(args.file);
  signal?.throwIfAborted();
  const samples = await media.decodeAudio(bytes);
  signal?.throwIfAborted();
  const durationSeconds = samples.length / 16_000;
  const modelId = await (deps.resolveModel ?? (query => resolveWhisperModel(services, query)))(args.query);
  signal?.throwIfAborted();
  // The verb owns the weights' lifetime: released right after the take, whatever the host's idle policy.
  const service = new TranscriptionService({ models: services.modelHost, modelId, minimumAudioSeconds: 0, keepAliveSec: 0,
    vadModelPath: args.vad?.modelPath ?? null, media });
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
