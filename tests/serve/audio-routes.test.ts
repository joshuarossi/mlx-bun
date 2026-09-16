// Model-free: /v1/audio/* dispatch, request parsing (multipart + JSON),
// response formats, streaming SSE, and the unavailable/unload paths — all
// against a fake TranscriptionService.

import { describe, expect, test } from "bun:test";
import { handleAudioRoute, matchAudioRoute, parseAudioRequest } from "../../src/serve/audio-routes";
import type { TranscriptionOutcome, TranscriptionParams, TranscriptionService } from "../../src/serve/transcription-service";
import type { WhisperTranscription } from "../../src/audio/whisper-transcribe";

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

function fakeService(record: TranscriptionParams[] = []): TranscriptionService {
  let resident = false;
  const svc = {
    modelId: "fake/whisper",
    get resident() { return resident; },
    get stats() { return { resident, loads: 0, unloads: 0, requests: record.length, last_load_ms: 0, idle_unload_sec: 300 }; },
    unload: () => { const was = resident; resident = false; return was; },
    session: () => null,
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
  return svc as unknown as TranscriptionService;
}

const url = (p: string) => new URL(`http://localhost${p}`);

function multipart(fields: Record<string, string | string[]>, file = WAV): Request {
  const form = new FormData();
  form.set("file", new Blob([file], { type: "audio/wav" }), "clip.wav");
  for (const [k, v] of Object.entries(fields)) {
    if (Array.isArray(v)) for (const x of v) form.append(`${k}[]`, x);
    else form.set(k, v);
  }
  return new Request("http://localhost/v1/audio/transcriptions", { method: "POST", body: form });
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

  test("session routes 404 on unknown ids", async () => {
    const svc = fakeService();
    const host = { service: async () => svc };
    const res = await handleAudioRoute(url("/v1/audio/sessions/nope/finish"), new Request("http://localhost/v1/audio/sessions/nope/finish", { method: "POST" }), host);
    expect(res!.status).toBe(404);
  });

  test("503 with a get hint when no Whisper model is available", async () => {
    const res = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({}), { service: async () => null });
    expect(res!.status).toBe(503);
    const body = await res!.json() as { error: { message: string; type: string } };
    expect(body.error.type).toBe("model_unavailable");
    expect(body.error.message).toContain("mlx-bun get");
  });
});

describe("audio request parsing", () => {
  test("multipart: file + fields, array fields, defaults", async () => {
    const parsed = await parseAudioRequest(multipart({ language: "en", prompt: "Sotto", beam_size: "5", vocabulary: "a, b", timestamp_granularities: ["segment"] }), "transcribe");
    if (parsed instanceof Response) throw new Error(await parsed.text());
    expect(parsed.audio.length).toBe(WAV.length);
    expect(parsed.format).toBe("json");
    expect(parsed.stream).toBe(false);
    expect(parsed.params).toMatchObject({ task: "transcribe", language: "en", prompt: "Sotto", beamSize: 5, vocabulary: ["a", "b"], conditionOnPreviousText: true });
  });

  test("vad fields", async () => {
    const parsed = await parseAudioRequest(multipart({ vad: "true", vad_threshold: "0.6", vad_min_speech_ms: "120", vad_trim: "1" }), "transcribe");
    if (parsed instanceof Response) throw new Error(await parsed.text());
    expect(parsed.params.vad).toEqual({ threshold: 0.6, minSpeechMs: 120, trim: true });
    const off = await parseAudioRequest(multipart({}), "transcribe");
    if (off instanceof Response) throw new Error(await off.text());
    expect(off.params.vad).toBeNull();
    const bad = await parseAudioRequest(multipart({ vad: "true", vad_threshold: "1.5" }), "transcribe");
    expect((bad as Response).status).toBe(400);
  });

  test("JSON: base64 file, data URL, input_audio alias", async () => {
    const b64 = Buffer.from(WAV).toString("base64");
    for (const body of [{ file: b64 }, { file: `data:audio/wav;base64,${b64}` }, { input_audio: { data: b64 } }]) {
      const req = new Request("http://localhost/v1/audio/transcriptions", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ ...body, response_format: "text", vocabulary: ["x"], stream: true }) });
      const parsed = await parseAudioRequest(req, "translate");
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
    const noFile = new FormData(); noFile.set("language", "en");
    await bad(new Request("http://localhost/x", { method: "POST", body: noFile }), 400, "`file`");
    await bad(new Request("http://localhost/x", { method: "POST", headers: { "content-type": "text/plain" }, body: "x" }), 415, "content-type");
    await bad(new Request("http://localhost/x", { method: "POST", headers: { "content-type": "application/json" }, body: "{" }), 400, "invalid JSON");
  });
});

describe("audio route responses", () => {
  test("json + mlx_bun block, text, srt, vtt, verbose_json", async () => {
    const seen: TranscriptionParams[] = [];
    const host = { service: async () => fakeService(seen) };
    const json = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({ vocabulary: "Sotto" }), host);
    const jb = await json!.json() as { text: string; mlx_bun: { language: string; timings: { load_ms: number }; vocabulary: { included: string[] } } };
    expect(jb.text).toBe("hello world.");
    expect(jb.mlx_bun.language).toBe("en");
    expect(jb.mlx_bun.timings.load_ms).toBe(12);
    expect(jb.mlx_bun.vocabulary.included).toEqual(["Sotto"]);
    expect(json!.headers.get("x-mlx-bun-language")).toBe("en");
    expect(seen[0]!.vocabulary).toEqual(["Sotto"]);

    const text = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({ response_format: "text" }), host);
    expect(await text!.text()).toBe("hello world.\n");
    const srt = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({ response_format: "srt" }), host);
    expect(await srt!.text()).toBe("1\n00:00:00,000 --> 00:00:01,500\nhello\n\n2\n00:00:01,500 --> 00:00:02,500\nworld.\n\n");
    const vtt = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({ response_format: "vtt" }), host);
    expect(await vtt!.text()).toStartWith("WEBVTT\n\n00:00:00.000 --> 00:00:01.500\nhello\n\n");
    const verbose = await handleAudioRoute(url("/v1/audio/translations"), multipart({ response_format: "verbose_json" }), host);
    const vb = await verbose!.json() as { task: string; duration: number; segments: { id: number; avg_logprob: number }[] };
    expect(vb.task).toBe("translate");
    expect(vb.duration).toBe(2.5);
    expect(vb.segments.map((s) => s.id)).toEqual([0, 1]);
    expect(seen.at(-1)!.task).toBe("translate");
  });

  test("streaming: one delta per segment, progress, then done", async () => {
    const res = await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({ stream: "true" }), { service: async () => fakeService() });
    expect(res!.headers.get("content-type")).toBe("text/event-stream");
    const body = await res!.text();
    const events = body.split("\n\n").filter(Boolean).map((chunk) => {
      const [ev, data] = chunk.split("\n");
      return { event: ev!.slice(7), data: JSON.parse(data!.slice(6)) as Record<string, unknown> };
    });
    expect(events.map((e) => e.event)).toEqual(["transcript.text.delta", "transcript.text.delta", "transcript.progress", "transcript.text.done"]);
    expect(events[0]!.data.delta).toBe(" hello");
    expect((events[3]!.data as { text: string }).text).toBe("hello world.");
  });

  test("unload reports residency", async () => {
    const svc = fakeService();
    const host = { service: async () => svc };
    await handleAudioRoute(url("/v1/audio/transcriptions"), multipart({}), host);
    const r1 = await handleAudioRoute(url("/admin/transcription/unload"), new Request("http://localhost/admin/transcription/unload", { method: "POST" }), host);
    expect(await r1!.json()).toMatchObject({ unloaded: true, resident: false });
    const r2 = await handleAudioRoute(url("/admin/transcription/unload"), new Request("http://localhost/admin/transcription/unload", { method: "POST" }), host);
    expect(await r2!.json()).toMatchObject({ unloaded: false });
  });
});
