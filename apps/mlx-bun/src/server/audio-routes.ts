// OpenAI-compatible speech-to-text routes (main's `src/serve/audio-routes.ts`):
//   POST /v1/audio/transcriptions   (task transcribe)
//   POST /v1/audio/translations     (task translate, English output)
//   POST /admin/transcription/unload (explicit page-out of the Whisper weights)
//   POST /v1/audio/sessions · POST /v1/audio/sessions/:id/audio ·
//   POST /v1/audio/sessions/:id/finish · DELETE /v1/audio/sessions/:id
//   (streaming dictation: chunks arrive during capture, each finished 30 s
//   window transcribes immediately, finish returns the whole transcript)
// Bodies: multipart/form-data (OpenAI: file, model, language, prompt,
// response_format, temperature, stream, timestamp_granularities[]) or JSON
// ({ file: <base64 | data: URL>, ...same fields }). Non-standard fields:
// beam_size, condition_on_previous_text, no_speech_threshold, vocabulary
// (array of hint terms fitted into the prompt budget; usage reported),
// faithful (oracle graph instead of the fast path), audio_ctx (Lab), vad /
// vad_threshold / vad_min_speech_ms / vad_trim (Silero gate: silence returns
// an empty transcript without running Whisper).
// Streaming (`stream=true`): SSE `transcript.text.delta` per segment,
// then `transcript.text.done` carrying the final body.
//
// The handler borrows the service from its host per request; it never loads
// a model or opens a socket. Without a host the group is unmounted (null).

import { formatTranscription, TRANSCRIPTION_FORMATS, toVerboseJson, type TranscriptionFormat } from "@mlx-bun/inference/transcription/format";
import type { WhisperSegment } from "@mlx-bun/inference/transcription";
import {
  TranscriptionError, type TranscriptionOutcome, type TranscriptionParams, type TranscriptionService,
} from "../engine/transcription-service";

export type AudioRoute =
  | { kind: "transcriptions"; task: "transcribe" | "translate" }
  | { kind: "unload" }
  | { kind: "session-create" }
  | { kind: "session-audio"; id: string }
  | { kind: "session-finish"; id: string }
  | { kind: "session-delete"; id: string };

export function matchAudioRoute(method: string, pathname: string): AudioRoute | null {
  switch (`${method} ${pathname}`) {
    case "POST /v1/audio/transcriptions": return { kind: "transcriptions", task: "transcribe" };
    case "POST /v1/audio/translations": return { kind: "transcriptions", task: "translate" };
    case "POST /admin/transcription/unload": return { kind: "unload" };
    case "POST /v1/audio/sessions": return { kind: "session-create" };
  }
  if (pathname.startsWith("/v1/audio/sessions/")) {
    const rest = pathname.slice("/v1/audio/sessions/".length).split("/");
    const id = decodeURIComponent(rest[0] ?? "");
    if (!id) return null;
    if (method === "POST" && rest[1] === "audio" && rest.length === 2) return { kind: "session-audio", id };
    if (method === "POST" && rest[1] === "finish" && rest.length === 2) return { kind: "session-finish", id };
    if (method === "DELETE" && rest.length === 1) return { kind: "session-delete", id };
  }
  return null;
}

/** What the route group borrows from the service the composition owns. */
export type AudioService = Pick<TranscriptionService,
  "modelId" | "resident" | "stats" | "unload" | "transcribe" | "createSession" | "session" | "decodeAudio">;

/** Everything the routes need from the host: a service (or a reason there is none). */
export interface AudioRouteHost {
  service(): Promise<AudioService | null>;
  /** Message for the 503 when no Whisper model is available. */
  unavailableMessage?: string;
}

export interface ParsedAudioRequest {
  audio: Uint8Array;
  format: TranscriptionFormat;
  stream: boolean;
  params: TranscriptionParams;
}

const segmentJson = (s: WhisperSegment) => ({ id: s.id, seek: s.seek, start: s.start, end: s.end, text: s.text, tokens: s.tokens, temperature: s.temperature, avg_logprob: s.avgLogprob, compression_ratio: s.compressionRatio, no_speech_prob: s.noSpeechProb, ...(s.words ? { words: s.words } : {}) });

function errorJson(message: string, status: number, type = "invalid_request_error"): Response {
  return Response.json({ error: { message, type } }, { status });
}

const B64_MAX = 200 * 1024 * 1024;

function decodeBase64Audio(v: unknown): Uint8Array | null {
  if (typeof v !== "string" || v.length === 0 || v.length > B64_MAX * 1.4) return null;
  const data = v.startsWith("data:") ? v.slice(v.indexOf(",") + 1) : v;
  try {
    return new Uint8Array(Buffer.from(data, "base64"));
  } catch {
    return null;
  }
}

function num(v: unknown): number | null {
  if (v === null || v === undefined || v === "") return null;
  const n = typeof v === "number" ? v : Number(v);
  return Number.isFinite(n) ? n : null;
}

function bool(v: unknown): boolean | null {
  if (typeof v === "boolean") return v;
  if (v === "true" || v === "1") return true;
  if (v === "false" || v === "0") return false;
  return null;
}

/** Decoding params shared by one-shot requests and sessions (no audio). */
function parseParams(fields: Record<string, unknown>, task: "transcribe" | "translate"): TranscriptionParams | Response {
  const language = typeof fields.language === "string" && fields.language.trim() ? fields.language.trim() : null;
  const temperature = num(fields.temperature);
  if (temperature !== null && (temperature < 0 || temperature > 1)) return errorJson("temperature must be in [0, 1]", 400);
  const beamSize = num(fields.beam_size);
  if (beamSize !== null && (!Number.isInteger(beamSize) || beamSize < 1 || beamSize > 16))
    return errorJson("beam_size must be an integer in [1, 16]", 400);
  if (temperature !== null && temperature > 0 && beamSize !== null && beamSize > 1)
    return errorJson("beam_size requires temperature 0", 400);
  const vocabulary = Array.isArray(fields.vocabulary)
    ? (fields.vocabulary as unknown[]).map(String)
    : typeof fields.vocabulary === "string" && fields.vocabulary.trim()
      ? fields.vocabulary.split(",").map(s => s.trim()).filter(Boolean)
      : undefined;
  if (vocabulary && (vocabulary.length > 8192 || vocabulary.some(t => t.length > 16384)))
    return errorJson("vocabulary: at most 8192 terms of at most 16 KiB each", 400);
  const noSpeech = num(fields.no_speech_threshold);
  const vadOn = bool(fields.vad) ?? false;
  const vadThreshold = num(fields.vad_threshold);
  if (vadThreshold !== null && (vadThreshold <= 0 || vadThreshold >= 1)) return errorJson("vad_threshold must be in (0, 1)", 400);
  const vadMinSpeech = num(fields.vad_min_speech_ms);
  const audioCtx = num(fields.audio_ctx);
  if (audioCtx !== null && (!Number.isInteger(audioCtx) || audioCtx < 64 || audioCtx > 1500))
    return errorJson("audio_ctx must be an integer in [64, 1500]", 400);
  const granularities = Array.isArray(fields.timestamp_granularities) ? (fields.timestamp_granularities as string[]) : [];
  return {
    task, language,
    prompt: typeof fields.prompt === "string" && fields.prompt.trim() ? fields.prompt : null,
    vocabulary, temperature, beamSize,
    conditionOnPreviousText: bool(fields.condition_on_previous_text) ?? true,
    ...(noSpeech !== null ? { noSpeechThreshold: noSpeech } : {}),
    withoutTimestamps: bool(fields.without_timestamps) ?? false,
    vad: vadOn ? { threshold: vadThreshold ?? undefined, minSpeechMs: vadMinSpeech ?? undefined, trim: bool(fields.vad_trim) ?? false } : null,
    wordTimestamps: granularities.includes("word"),
    faithful: bool(fields.faithful) ?? false,
    audioCtx,
  };
}

/** Parse a multipart or JSON transcription request into audio bytes + params. */
export async function parseAudioRequest(request: Request, task: "transcribe" | "translate"): Promise<ParsedAudioRequest | Response> {
  const ct = request.headers.get("content-type") ?? "";
  let fields: Record<string, unknown> = {};
  let audio: Uint8Array | null = null;
  if (ct.includes("multipart/form-data")) {
    let form: FormData;
    try { form = await request.formData(); }
    catch (e) { return errorJson(`invalid multipart body: ${(e as Error).message}`, 400); }
    const file = form.get("file");
    if (!(file instanceof Blob)) return errorJson("`file` (audio upload) is required", 400);
    audio = new Uint8Array(await file.arrayBuffer());
    for (const [k, v] of form.entries()) {
      if (k === "file") continue;
      if (k.endsWith("[]")) {
        const key = k.slice(0, -2);
        (fields[key] ??= [] as string[]);
        (fields[key] as string[]).push(String(v));
      } else fields[k] = typeof v === "string" ? v : String(v);
    }
  } else if (ct.includes("application/json")) {
    try { fields = (await request.json()) as Record<string, unknown>; }
    catch { return errorJson("invalid JSON body", 400); }
    const raw = fields.file ?? (fields.input_audio as { data?: unknown } | undefined)?.data ?? fields.audio;
    audio = decodeBase64Audio(raw);
    if (!audio) return errorJson("`file` must be base64 audio (optionally a data: URL)", 400);
  } else {
    return errorJson("content-type must be multipart/form-data or application/json", 415);
  }
  if (audio.length === 0) return errorJson("empty audio upload", 400);
  const format = (fields.response_format as string | undefined) ?? "json";
  if (!TRANSCRIPTION_FORMATS.includes(format as TranscriptionFormat))
    return errorJson(`response_format must be one of ${TRANSCRIPTION_FORMATS.join(", ")}`, 400);
  const params = parseParams(fields, task);
  if (params instanceof Response) return params;
  const stream = bool(fields.stream) ?? false;
  if (params.wordTimestamps && format !== "verbose_json" && !stream)
    return errorJson("timestamp_granularities[]=word requires response_format=verbose_json", 400);
  return { audio, format: format as TranscriptionFormat, stream, params };
}

/** Body for a finished transcription in the requested format. */
export function transcriptionResponse(outcome: TranscriptionOutcome, format: TranscriptionFormat, task: string): Response {
  const extra = {
    model: outcome.modelId,
    language: outcome.result.language,
    duration: outcome.durationSeconds,
    timings: outcome.timings,
    ...(outcome.vocabulary ? { vocabulary: outcome.vocabulary } : {}),
    ...(outcome.vad ? { vad: outcome.vad } : {}),
  };
  const headers: Record<string, string> = {
    "x-mlx-bun-language": outcome.result.language,
    "x-mlx-bun-timings": JSON.stringify(outcome.timings),
  };
  if (format === "json")
    return Response.json({ text: outcome.result.text.trim(), mlx_bun: extra }, { headers });
  if (format === "verbose_json")
    return Response.json({ ...toVerboseJson(outcome.result, outcome.durationSeconds, task), mlx_bun: extra }, { headers });
  const body = formatTranscription(outcome.result, format, outcome.durationSeconds, task);
  const type = format === "srt" ? "application/x-subrip" : format === "vtt" ? "text/vtt" : "text/plain";
  return new Response(body, { headers: { ...headers, "content-type": `${type}; charset=utf-8` } });
}

function transcriptionFailure(e: unknown): Response {
  if (e instanceof TranscriptionError) return errorJson(e.message, e.status);
  const message = (e as Error).message ?? String(e);
  if (/cancelled/.test(message)) return errorJson("request cancelled", 499);
  if (/WAV|afconvert|transcode|audio|RIFF/i.test(message)) return errorJson(`undecodable audio: ${message}`, 400);
  return errorJson(message, 500, "server_error");
}

export const UNAVAILABLE_MESSAGE =
  "no Whisper model is available — download one (mlx-bun get mlx-community/whisper-large-v3-turbo) or pass --whisper-model";

/** Without a host the group is unmounted and every audio path stays composable (null). */
export function createAudioRoutes(host?: AudioRouteHost) {
  // Per-session response format chosen at creation, consumed by finish.
  const sessionFormats = new Map<string, TranscriptionFormat>();
  return { async handle(request: Request): Promise<Response | null> {
    if (!host) return null;
    const url = new URL(request.url);
    const route = matchAudioRoute(request.method, url.pathname);
    if (!route) return null;
    const service = await host.service();
    if (!service) return errorJson(host.unavailableMessage ?? UNAVAILABLE_MESSAGE, 503, "model_unavailable");
    if (route.kind === "unload") {
      const unloaded = service.unload();
      return Response.json({ unloaded, ...service.stats });
    }
    if (route.kind === "session-create") {
      let fields: Record<string, unknown> = {};
      if ((request.headers.get("content-type") ?? "").includes("application/json")) {
        try { fields = (await request.json()) as Record<string, unknown>; }
        catch { return errorJson("invalid JSON body", 400); }
      }
      const params = parseParams(fields, fields.task === "translate" ? "translate" : "transcribe");
      if (params instanceof Response) return params;
      const format = (fields.response_format as string | undefined) ?? "json";
      if (!["json", "verbose_json"].includes(format)) return errorJson("sessions return json or verbose_json", 400);
      try {
        const session = await service.createSession(params);
        sessionFormats.set(session.id, format as TranscriptionFormat);
        return Response.json({ id: session.id, model: service.modelId, vocabulary: session.vocabulary ?? null });
      } catch (e) {
        return transcriptionFailure(e);
      }
    }
    if (route.kind === "session-audio" || route.kind === "session-finish" || route.kind === "session-delete") {
      const session = service.session(route.id);
      if (!session) return errorJson("unknown transcription session", 404);
      if (route.kind === "session-delete") {
        session.close();
        sessionFormats.delete(route.id);
        return new Response(null, { status: 204 });
      }
      if (route.kind === "session-audio") {
        const ct = request.headers.get("content-type") ?? "";
        const bytes = new Uint8Array(await request.arrayBuffer());
        if (bytes.length === 0) return errorJson("empty audio chunk", 400);
        let pcm: Float32Array;
        try {
          if (ct.startsWith("audio/pcm") || ct.startsWith("audio/l32") || ct.includes("float32")) {
            if (bytes.length % 4 !== 0) return errorJson("float32 PCM chunk length must be a multiple of 4", 400);
            pcm = new Float32Array(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength));
            const rate = Number(/rate=(\d+)/.exec(ct)?.[1] ?? 16000);
            if (rate !== 16000) return errorJson("float32 PCM chunks must be 16 kHz mono", 400);
          } else pcm = await service.decodeAudio(bytes);
        } catch (e) {
          return transcriptionFailure(e);
        }
        try {
          const r = await session.append(pcm);
          return Response.json({ id: session.id, samples: session.samples, duration: session.durationSeconds, speech: r.speech, segments: r.segments.map(segmentJson) });
        } catch (e) {
          return transcriptionFailure(e);
        }
      }
      const format = sessionFormats.get(route.id) ?? "json";
      sessionFormats.delete(route.id);
      try {
        const outcome = await session.finish();
        return transcriptionResponse(outcome, format, session.params.task ?? "transcribe");
      } catch (e) {
        return transcriptionFailure(e);
      }
    }
    const parsed = await parseAudioRequest(request, route.task);
    if (parsed instanceof Response) return parsed;
    const taskName = route.task;
    if (!parsed.stream) {
      try {
        const outcome = await service.transcribe(parsed.audio, { ...parsed.params, signal: request.signal });
        return transcriptionResponse(outcome, parsed.format, taskName);
      } catch (e) {
        return transcriptionFailure(e);
      }
    }
    // Streaming: one SSE event per finalized segment, then the final body.
    const encoder = new TextEncoder();
    const stream = new ReadableStream<Uint8Array>({
      start: async controller => {
        const send = (event: string, data: unknown) =>
          controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`));
        try {
          const outcome = await service.transcribe(parsed.audio, {
            ...parsed.params,
            signal: request.signal,
            onSegment: (s: WhisperSegment) => {
              if (s.text) send("transcript.text.delta", { delta: s.text, segment: { id: s.id, start: s.start, end: s.end } });
            },
            onProgress: (done, total) => send("transcript.progress", { done, total }),
          });
          const body = parsed.format === "verbose_json"
            ? toVerboseJson(outcome.result, outcome.durationSeconds, taskName)
            : { text: outcome.result.text.trim() };
          send("transcript.text.done", {
            ...body,
            mlx_bun: { model: outcome.modelId, language: outcome.result.language, duration: outcome.durationSeconds, timings: outcome.timings, ...(outcome.vocabulary ? { vocabulary: outcome.vocabulary } : {}) },
          });
        } catch (e) {
          send("error", { message: (e as Error).message });
        } finally {
          controller.close();
        }
      },
    });
    return new Response(stream, {
      headers: { "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive" },
    });
  } };
}
