// Model-free: /v1/audio/* dispatch, request parsing (multipart + JSON),
// response formats, streaming SSE, sessions, the unavailable/unload paths,
// and the transcription-only discovery routes, against fake services.
import { describe, expect, test } from "bun:test";
import type { WhisperSegment, WhisperTranscription } from "@mlx-bun/inference/transcription";
import { createAudioRoutes, matchAudioRoute, parseAudioRequest, type AudioService } from "../../src/server/audio-routes";
import { createTranscriptionServerRoutes } from "../../src/server/transcription-server";
import { pendingRoute } from "../../src/server/start";
import { TranscriptionService, type TranscriptionOutcome, type TranscriptionParams, type TranscriptionRuntime } from "../../src/engine/transcription-service";

const WAV = (() => {
  const frames = 3200;
  const buf = new ArrayBuffer(44 + frames * 2);
  const v = new DataView(buf);
  const wr = (o: number, s: string) => { for (let i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); };
  wr(0, "RIFF"); v.setUint32(4, 36 + frames * 2, true); wr(8, "WAVE");
  wr(12, "fmt "); v.setUint32(16, 16, true); v.setUint16(20, 1, true); v.setUint16(22, 1, true);
  v.setUint32(24, 16_000, true); v.setUint32(28, 32_000, true); v.setUint16(32, 2, true); v.setUint16(34, 16, true);
  wr(36, "data"); v.setUint32(40, frames * 2, true);
  return new Uint8Array(buf);
})();

const RESULT: WhisperTranscription = {
  text: " hello world.",
  language: "en",
  segments: [
    { id: 0, seek: 0, start: 0, end: 1.5, text: " hello", tokens: [1], temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0.01 },
    { id: 1, seek: 0, start: 1.5, end: 2.5, text: " world.", tokens: [2], temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0.01 },
  ],
};

function fakeService(record: TranscriptionParams[] = []): AudioService {
  let resident = false;
  return {
    modelId: "fake/whisper",
    get resident() { return resident; },
    get stats() { return { resident, loads: 0, unloads: 0, requests: record.length, last_load_ms: 0, idle_unload_sec: 300 }; },
    unload: () => { const was = resident; resident = false; return was; },
    session: () => null,
    createSession: () => { throw new Error("not in this fake"); },
    decodeAudio: async bytes => new Float32Array(bytes.length),
    async transcribe(_audio: Uint8Array | Float32Array, params: TranscriptionParams): Promise<TranscriptionOutcome> {
      record.push(params);
      resident = true;
      for (const s of RESULT.segments) params.onSegment?.(s);
      params.onProgress?.(300, 300);
      return {
        result: RESULT, durationSeconds: 2.5, modelId: "fake/whisper",
        timings: { load_ms: 12, transcribe_ms: 34, total_ms: 50 },
        ...(params.vocabulary ? { vocabulary: { included: params.vocabulary, omitted: [], token_count: 3, token_budget: 223 } } : {}),
      };
    },
  };
}

const post = (path: string, init: RequestInit = {}) => new Request(`http://localhost${path}`, { method: "POST", ...init });
const json = (path: string, body: unknown) => post(path, { headers: { "content-type": "application/json" }, body: JSON.stringify(body) });

function multipart(fields: Record<string, string | string[]>, file = WAV, path = "/v1/audio/transcriptions"): Request {
  const form = new FormData();
  form.set("file", new Blob([file], { type: "audio/wav" }), "clip.wav");
  for (const [k, v] of Object.entries(fields)) {
    if (Array.isArray(v)) for (const x of v) form.append(`${k}[]`, x);
    else form.set(k, v);
  }
  return post(path, { body: form });
}

describe("audio route dispatch", () => {
  test("matches the OpenAI audio routes and the unload admin route", () => {
    expect(matchAudioRoute("POST", "/v1/audio/transcriptions")).toEqual({ kind: "transcriptions", task: "transcribe" });
    expect(matchAudioRoute("POST", "/v1/audio/translations")).toEqual({ kind: "transcriptions", task: "translate" });
    expect(matchAudioRoute("POST", "/admin/transcription/unload")).toEqual({ kind: "unload" });
    expect(matchAudioRoute("POST", "/v1/audio/sessions")).toEqual({ kind: "session-create" });
    expect(matchAudioRoute("POST", "/v1/audio/sessions/abc/audio")).toEqual({ kind: "session-audio", id: "abc" });
    expect(matchAudioRoute("POST", "/v1/audio/sessions/abc/finish")).toEqual({ kind: "session-finish", id: "abc" });
    expect(matchAudioRoute("DELETE", "/v1/audio/sessions/a%2Fb")).toEqual({ kind: "session-delete", id: "a/b" });
    expect(matchAudioRoute("GET", "/v1/audio/sessions/abc/audio")).toBeNull();
    expect(matchAudioRoute("POST", "/v1/audio/sessions/abc/other")).toBeNull();
    expect(matchAudioRoute("GET", "/v1/audio/transcriptions")).toBeNull();
    expect(matchAudioRoute("POST", "/v1/audio/speech")).toBeNull();
  });

  test("the audio surface is owned: no migration placeholder remains and an unmounted group stays composable", async () => {
    for (const path of ["/v1/audio/transcriptions", "/v1/audio/translations", "/v1/audio/sessions", "/v1/audio/sessions/x/audio",
      "/v1/audio/sessions/x/finish", "/admin/transcription/unload"]) expect(pendingRoute(path)).toBe(false);
    // Memory synthesis is owned by its composition now, so it is no placeholder either.
    expect(pendingRoute("/v1/memory/synthesize")).toBe(false);
    for (const path of ["/admin/lease", "/admin/drain", "/engine"]) expect(pendingRoute(path)).toBe(true);
    const unmounted = createAudioRoutes();
    expect(await unmounted.handle(multipart({}))).toBeNull();
    expect(await unmounted.handle(post("/admin/transcription/unload"))).toBeNull();
    expect(await createAudioRoutes({ service: async () => fakeService() }).handle(new Request("http://localhost/v1/models"))).toBeNull();
  });

  test("session routes 404 on unknown ids", async () => {
    const routes = createAudioRoutes({ service: async () => fakeService() });
    expect((await routes.handle(post("/v1/audio/sessions/nope/finish")))!.status).toBe(404);
    expect((await routes.handle(post("/v1/audio/sessions/nope/audio", { body: new Uint8Array(4) })))!.status).toBe(404);
    expect((await routes.handle(new Request("http://localhost/v1/audio/sessions/nope", { method: "DELETE" })))!.status).toBe(404);
  });

  test("503 with a get hint when no Whisper model is available; the host may word it", async () => {
    const res = await createAudioRoutes({ service: async () => null }).handle(multipart({}));
    expect(res!.status).toBe(503);
    const body = await res!.json() as { error: { message: string; type: string } };
    expect(body.error.type).toBe("model_unavailable");
    expect(body.error.message).toContain("mlx-bun get");
    const custom = await createAudioRoutes({ service: async () => null, unavailableMessage: "custom" }).handle(post("/admin/transcription/unload"));
    expect((await custom!.json()).error.message).toBe("custom");
  });
});

describe("audio request parsing", () => {
  test("multipart: file + fields, array fields, defaults", async () => {
    const parsed = await parseAudioRequest(multipart({ language: "en", prompt: "Sotto", beam_size: "5", vocabulary: "a, b", timestamp_granularities: ["segment"] }), "transcribe");
    if (parsed instanceof Response) throw new Error(await parsed.text());
    expect(parsed.audio.length).toBe(WAV.length);
    expect(parsed.format).toBe("json");
    expect(parsed.stream).toBe(false);
    expect(parsed.params).toMatchObject({ task: "transcribe", language: "en", prompt: "Sotto", beamSize: 5, vocabulary: ["a", "b"], conditionOnPreviousText: true, wordTimestamps: false, faithful: false, audioCtx: null });
  });

  test("vad and lab fields", async () => {
    const parsed = await parseAudioRequest(multipart({ vad: "true", vad_threshold: "0.6", vad_min_speech_ms: "120", vad_trim: "1", faithful: "true", audio_ctx: "1024", no_speech_threshold: "0.7" }), "transcribe");
    if (parsed instanceof Response) throw new Error(await parsed.text());
    expect(parsed.params.vad).toEqual({ threshold: 0.6, minSpeechMs: 120, trim: true });
    expect(parsed.params).toMatchObject({ faithful: true, audioCtx: 1024, noSpeechThreshold: 0.7 });
    const off = await parseAudioRequest(multipart({}), "transcribe");
    if (off instanceof Response) throw new Error(await off.text());
    expect(off.params.vad).toBeNull();
    expect(off.params).not.toHaveProperty("noSpeechThreshold");
    expect(((await parseAudioRequest(multipart({ vad: "true", vad_threshold: "1.5" }), "transcribe")) as Response).status).toBe(400);
    expect(((await parseAudioRequest(multipart({ audio_ctx: "32" }), "transcribe")) as Response).status).toBe(400);
  });

  test("JSON: base64 file, data URL, input_audio alias", async () => {
    const b64 = Buffer.from(WAV).toString("base64");
    for (const body of [{ file: b64 }, { file: `data:audio/wav;base64,${b64}` }, { input_audio: { data: b64 } }, { audio: b64 }]) {
      const parsed = await parseAudioRequest(json("/v1/audio/transcriptions", { ...body, response_format: "text", vocabulary: ["x"], stream: true }), "translate");
      if (parsed instanceof Response) throw new Error(await parsed.text());
      expect(parsed.audio.length).toBe(WAV.length);
      expect(parsed.format).toBe("text");
      expect(parsed.stream).toBe(true);
      expect(parsed.params.task).toBe("translate");
      expect(parsed.params.vocabulary).toEqual(["x"]);
    }
  });

  test("rejects bad formats, temperatures, beam sizes, missing file, wrong content-type", async () => {
    const bad = async (req: Request, status: number, fragment: string) => {
      const r = await parseAudioRequest(req, "transcribe");
      expect(r).toBeInstanceOf(Response);
      expect((r as Response).status).toBe(status);
      expect(await (r as Response).text()).toContain(fragment);
    };
    await bad(multipart({ response_format: "xml" }), 400, "response_format");
    await bad(multipart({ temperature: "3" }), 400, "temperature");
    await bad(multipart({ beam_size: "0" }), 400, "beam_size");
    await bad(multipart({ beam_size: "5", temperature: "0.5" }), 400, "beam_size requires temperature 0");
    await bad(multipart({ timestamp_granularities: ["word"] }), 400, "verbose_json");
    await bad(multipart({}, new Uint8Array(0)), 400, "empty audio");
    const noFile = new FormData(); noFile.set("language", "en");
    await bad(post("/x", { body: noFile }), 400, "`file`");
    await bad(post("/x", { headers: { "content-type": "text/plain" }, body: "x" }), 415, "content-type");
    await bad(post("/x", { headers: { "content-type": "application/json" }, body: "{" }), 400, "invalid JSON");
    await bad(json("/x", { file: 5 }), 400, "`file` must be base64");
  });
});

describe("audio route responses", () => {
  test("json + mlx_bun block, text, srt, vtt, verbose_json, and word timestamps", async () => {
    const seen: TranscriptionParams[] = [];
    const routes = createAudioRoutes({ service: async () => fakeService(seen) });
    const json = await routes.handle(multipart({ vocabulary: "Sotto" }));
    const jb = await json!.json() as { text: string; mlx_bun: { language: string; timings: { load_ms: number }; vocabulary: { included: string[] } } };
    expect(jb.text).toBe("hello world.");
    expect(jb.mlx_bun.language).toBe("en");
    expect(jb.mlx_bun.timings.load_ms).toBe(12);
    expect(jb.mlx_bun.vocabulary.included).toEqual(["Sotto"]);
    expect(json!.headers.get("x-mlx-bun-language")).toBe("en");
    expect(JSON.parse(json!.headers.get("x-mlx-bun-timings")!)).toEqual({ load_ms: 12, transcribe_ms: 34, total_ms: 50 });
    expect(seen[0]!.vocabulary).toEqual(["Sotto"]);
    expect(seen[0]!.signal).toBeInstanceOf(AbortSignal);

    const text = await routes.handle(multipart({ response_format: "text" }));
    expect(await text!.text()).toBe("hello world.\n");
    expect(text!.headers.get("content-type")).toBe("text/plain; charset=utf-8");
    const srt = await routes.handle(multipart({ response_format: "srt" }));
    expect(await srt!.text()).toBe("1\n00:00:00,000 --> 00:00:01,500\nhello\n\n2\n00:00:01,500 --> 00:00:02,500\nworld.\n\n");
    expect(srt!.headers.get("content-type")).toBe("application/x-subrip; charset=utf-8");
    const vtt = await routes.handle(multipart({ response_format: "vtt" }));
    expect(await vtt!.text()).toStartWith("WEBVTT\n\n00:00:00.000 --> 00:00:01.500\nhello\n\n");
    expect(vtt!.headers.get("content-type")).toBe("text/vtt; charset=utf-8");
    const verbose = await routes.handle(multipart({ response_format: "verbose_json", timestamp_granularities: ["word"] }, WAV, "/v1/audio/translations"));
    const vb = await verbose!.json() as { task: string; duration: number; text: string; segments: { id: number; avg_logprob: number }[]; mlx_bun: { model: string } };
    expect(vb.task).toBe("translate");
    expect(vb.duration).toBe(2.5); expect(vb.text).toBe("hello world.");
    expect(vb.segments.map(s => s.id)).toEqual([0, 1]);
    expect(vb.mlx_bun.model).toBe("fake/whisper");
    expect(seen.at(-1)).toMatchObject({ task: "translate", wordTimestamps: true });
  });

  test("streaming: one delta per segment, progress, then done", async () => {
    const res = await createAudioRoutes({ service: async () => fakeService() }).handle(multipart({ stream: "true" }));
    expect(res!.headers.get("content-type")).toBe("text/event-stream");
    const body = await res!.text();
    const events = body.split("\n\n").filter(Boolean).map(chunk => {
      const [ev, data] = chunk.split("\n");
      return { event: ev!.slice(7), data: JSON.parse(data!.slice(6)) as Record<string, unknown> };
    });
    expect(events.map(e => e.event)).toEqual(["transcript.text.delta", "transcript.text.delta", "transcript.progress", "transcript.text.done"]);
    expect(events[0]!.data.delta).toBe(" hello");
    expect((events[3]!.data as { text: string }).text).toBe("hello world.");
    expect((events[3]!.data as { mlx_bun: { model: string } }).mlx_bun.model).toBe("fake/whisper");
  });

  test("service failures map to their statuses: typed errors, cancellation, undecodable audio, and 500", async () => {
    const failing = (error: Error): AudioService => ({ ...fakeService(), async transcribe() { throw error; } });
    const status = async (error: Error) => {
      const response = await createAudioRoutes({ service: async () => failing(error) }).handle(multipart({}));
      return [response!.status, (await response!.json()).error] as const;
    };
    const { TranscriptionError } = await import("../../src/engine/transcription-service");
    expect(await status(new TranscriptionError("audio is shorter than 0.1 s", 400))).toEqual([400, { message: "audio is shorter than 0.1 s", type: "invalid_request_error" }]);
    expect((await status(new Error("transcription cancelled")))[0]).toBe(499);
    expect(await status(new Error("bad RIFF header"))).toEqual([400, { message: "undecodable audio: bad RIFF header", type: "invalid_request_error" }]);
    expect(await status(new Error("boom"))).toEqual([500, { message: "boom", type: "server_error" }]);
  });

  test("unload reports residency", async () => {
    const routes = createAudioRoutes({ service: async () => fakeService() });
    const svc = fakeService();
    const owned = createAudioRoutes({ service: async () => svc });
    await owned.handle(multipart({}));
    expect(await (await owned.handle(post("/admin/transcription/unload")))!.json()).toMatchObject({ unloaded: true, resident: false, idle_unload_sec: 300 });
    expect(await (await owned.handle(post("/admin/transcription/unload")))!.json()).toMatchObject({ unloaded: false });
    expect((await routes.handle(post("/admin/transcription/unload")))!.status).toBe(200);
  });
});

/** The real service over a fake runtime: sessions exercise the service's own lifecycle. */
function sessionService(beforeLoad?: () => Promise<void>) {
  const runtime: TranscriptionRuntime = {
    async load() {
      await beforeLoad?.();
      return {
        promptTokenBudget: 223, encode: text => text.split(/\s+/).filter(Boolean).map((_, index) => index),
        transcribe: async () => RESULT,
        start(options) {
          const segments: WhisperSegment[] = []; let fed = 0;
          return { get segments() { return segments; },
            feedSilent(samples: Float32Array) { fed += samples.length; },
            async feed(samples: Float32Array) { fed += samples.length; segments.push({ ...RESULT.segments[segments.length % 2]!, id: segments.length }); },
            async finish() { return { text: ` fed ${fed}`, segments, language: options.language ?? "en" }; } };
        },
        dispose() {},
      };
    },
    vad() { throw new Error("no vad in this test"); },
    async decodeAudio(bytes) { return new Float32Array(bytes.length / 2); },
  };
  return new TranscriptionService({ modelDir: "/w", modelId: "org/whisper", runtime, log() {}, idleUnloadSec: 0 });
}

describe("streaming sessions", () => {
  test("an aborted session-create request never registers an unreachable session or retains its weights", async () => {
    const loading = Promise.withResolvers<void>(), release = Promise.withResolvers<void>();
    const service = sessionService(async () => { loading.resolve(); await release.promise; });
    const routes = createAudioRoutes({ service: async () => service });
    const controller = new AbortController();
    const request = post("/v1/audio/sessions", { signal: controller.signal });
    const response = routes.handle(request);
    try {
      await loading.promise;
      controller.abort(new DOMException("cancelled", "AbortError"));
      release.resolve();
      expect((await response)!.status).toBe(499);
      expect(service.sessionCount).toBe(0);
      expect(service.resident).toBe(false);
      expect(service.stats.unloads).toBe(1);
    } finally {
      release.resolve();
      await response;
      await service.close();
    }
  });

  test("create, append float32 or container chunks, finish in the chosen format, and delete", async () => {
    const service = sessionService();
    const routes = createAudioRoutes({ service: async () => service });
    const created = await routes.handle(json("/v1/audio/sessions", { language: "en", response_format: "verbose_json", vocabulary: ["Sotto"] }));
    expect(created!.status).toBe(200);
    const { id, model, vocabulary } = await created!.json();
    expect(model).toBe("org/whisper"); expect(vocabulary.included).toEqual(["Sotto"]);
    expect(service.resident).toBe(true);
    const pcm = new Float32Array(1600);
    const chunk = await routes.handle(post(`/v1/audio/sessions/${id}/audio`, { headers: { "content-type": "audio/pcm;rate=16000" }, body: pcm }));
    expect(await chunk!.json()).toMatchObject({ id, samples: 1600, duration: 0.1, speech: false, segments: [expect.objectContaining({ id: 0, avg_logprob: -0.1 })] });
    const wav = await routes.handle(post(`/v1/audio/sessions/${id}/audio`, { headers: { "content-type": "audio/wav" }, body: WAV }));
    expect((await wav!.json()).samples).toBe(1600 + WAV.length / 2);
    expect((await routes.handle(post(`/v1/audio/sessions/${id}/audio`, { headers: { "content-type": "audio/pcm;rate=16000" }, body: new Uint8Array(6) })))!.status).toBe(400);
    expect((await routes.handle(post(`/v1/audio/sessions/${id}/audio`, { headers: { "content-type": "audio/pcm;rate=44100" }, body: pcm })))!.status).toBe(400);
    expect((await routes.handle(post(`/v1/audio/sessions/${id}/audio`, { body: new Uint8Array(0) })))!.status).toBe(400);
    const finished = await routes.handle(post(`/v1/audio/sessions/${id}/finish`));
    const body = await finished!.json();
    expect(body).toMatchObject({ task: "transcribe", text: `fed ${1600 + WAV.length / 2}`, mlx_bun: { model: "org/whisper", vocabulary: { included: ["Sotto"] } } });
    expect(body.segments).toHaveLength(2);
    expect((await routes.handle(post(`/v1/audio/sessions/${id}/finish`)))!.status).toBe(404);
    // The default policy released the weights once the last session closed.
    expect(service.resident).toBe(false); expect(service.sessionCount).toBe(0);
    const other = (await (await routes.handle(post("/v1/audio/sessions")))!.json()).id;
    expect((await routes.handle(new Request(`http://localhost/v1/audio/sessions/${other}`, { method: "DELETE" })))!.status).toBe(204);
    expect(service.sessionCount).toBe(0);
    expect((await routes.handle(json("/v1/audio/sessions", { response_format: "srt" })))!.status).toBe(400);
    expect((await routes.handle(post("/v1/audio/sessions", { headers: { "content-type": "application/json" }, body: "{" })))!.status).toBe(400);
    service.close();
  });
});

describe("transcription-only discovery", () => {
  test("health, stats, the API index, and /v1/models describe the Whisper checkpoint alone", async () => {
    let resident = false;
    const routes = createTranscriptionServerRoutes({ modelId: "org/whisper", get resident() { return resident; }, sessionCount: 2,
      stats: { resident: false, loads: 1, unloads: 1, requests: 3, last_load_ms: 250, idle_unload_sec: 0 } }, { startedAt: 5_000 });
    const get = (path: string) => routes.handle(new Request(`http://localhost${path}`));
    expect(await (await get("/health"))!.json()).toEqual({ status: "ok", transcription: { resident: false, loads: 1, unloads: 1, requests: 3, last_load_ms: 250, idle_unload_sec: 0, sessions: 2 } });
    expect(await (await get("/stats"))!.json()).toMatchObject({ model: "org/whisper", transcription: { requests: 3 }, uptime_s: expect.any(Number) });
    const index = await (await get("/v1"))!.json();
    expect(index).toMatchObject({ name: "mlx-bun", model: "org/whisper", mode: "transcription" });
    expect(index.endpoints).toContain("POST /v1/audio/transcriptions");
    expect(index.endpoints).not.toContain("POST /v1/chat/completions");
    resident = true;
    const models = await (await get("/v1/models"))!.json();
    expect(models).toEqual({ object: "list", data: [{ id: "org/whisper", object: "model", created: 5, owned_by: "mlx-bun", transcription: true, resident: true,
      capabilities: { transcription: true, translation: true, chat_completions: false } }] });
    expect((await (await get("/v1/models/org/whisper"))!.json()).data).toHaveLength(1);
    expect((await (await get("/v1/models/other"))!.json()).data).toEqual([]);
    expect(await get("/v1/chat/completions")).toBeNull();
    expect(await routes.handle(new Request("http://localhost/health", { method: "POST" }))).toBeNull();
  });
});
