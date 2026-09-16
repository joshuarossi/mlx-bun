// Transcription-only server end to end (needs the Whisper snapshot +
// tokenizer; skips otherwise): multipart + JSON requests, formats, streaming,
// idle page-out via /admin/transcription/unload and the page-in timing the
// next request reports.

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { decodeWav } from "../../src/audio/decode";
import type { Server } from "bun";
import { resolveWhisperTokenizerDir } from "../../src/audio/whisper-tokenizer";
import { createTranscriptionServer } from "../../src/serve/transcription-server";
import type { TranscriptionService } from "../../src/serve/transcription-service";
import { SNAPSHOT_WHISPER } from "../support/paths";

const FOX = `${import.meta.dir}/../../fixtures/audio/speech-fox.wav`;
const JFK = `${process.env.HOME}/Code/sotto/vendor/whisper.cpp/samples/jfk.wav`;
const ready = existsSync(`${SNAPSHOT_WHISPER}/config.json`) && resolveWhisperTokenizerDir(SNAPSHOT_WHISPER, 51866) !== null;

describe.skipIf(!ready)("transcription-only server", () => {
  let server: Server<unknown>;
  let service: TranscriptionService;
  let base = "";
  beforeAll(async () => {
    ({ server, service } = await createTranscriptionServer({
      modelDir: SNAPSHOT_WHISPER, modelId: "mlx-community/whisper-large-v3-turbo", port: 0, resident: true,
    }));
    base = `http://localhost:${server.port}`;
  });
  afterAll(() => { service.dispose(); server.stop(true); });

  const post = (path: string, fields: Record<string, string>, file = FOX) => {
    const form = new FormData();
    form.set("file", new Blob([readFileSync(file)], { type: "audio/wav" }), "clip.wav");
    for (const [k, v] of Object.entries(fields)) form.set(k, v);
    return fetch(`${base}${path}`, { method: "POST", body: form });
  };

  test("multipart json: loads on first request, reports timings", async () => {
    expect(service.resident).toBe(false);
    const res = await post("/v1/audio/transcriptions", { language: "en", temperature: "0" });
    expect(res.status).toBe(200);
    const body = await res.json() as { text: string; mlx_bun: { language: string; timings: { load_ms: number; transcribe_ms: number } } };
    expect(body.text.toLowerCase()).toContain("quick brown fox");
    expect(body.mlx_bun.language).toBe("en");
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    expect(service.resident).toBe(true);
    const again = await (await post("/v1/audio/transcriptions", { language: "en", temperature: "0" })).json() as typeof body;
    expect(again.mlx_bun.timings.load_ms).toBe(0);
  });

  test("models + health advertise the model and residency", async () => {
    const models = await (await fetch(`${base}/v1/models`)).json() as { data: { id: string; transcription: boolean; resident: boolean }[] };
    expect(models.data[0]).toMatchObject({ id: "mlx-community/whisper-large-v3-turbo", transcription: true, resident: true });
    const health = await (await fetch(`${base}/health`)).json() as { status: string; transcription: { resident: boolean } };
    expect(health.status).toBe("ok");
  });

  test("unload pages out; the next request pages back in", async () => {
    const r = await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json() as { unloaded: boolean; resident: boolean };
    expect(r).toMatchObject({ unloaded: true, resident: false });
    expect(service.resident).toBe(false);
    const res = await post("/v1/audio/transcriptions", { language: "en", temperature: "0", response_format: "verbose_json" });
    const body = await res.json() as { segments: { start: number; end: number }[]; mlx_bun: { timings: { load_ms: number } } };
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    expect(body.segments.length).toBeGreaterThan(0);
    console.log(`page-in after unload: ${body.mlx_bun.timings.load_ms.toFixed(0)} ms`);
  });

  test.skipIf(!existsSync(JFK))("beam search + vocabulary via JSON, srt, translations, streaming", async () => {
    const b64 = readFileSync(JFK).toString("base64");
    const res = await fetch(`${base}/v1/audio/transcriptions`, {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ file: b64, language: "en", temperature: 0, beam_size: 5, vocabulary: ["Sotto", "SwiftUI", "Metal"] }),
    });
    const body = await res.json() as { text: string; mlx_bun: { vocabulary: { included: string[]; token_budget: number; token_count: number } } };
    expect(body.text).toBe("And so, my fellow Americans, ask not what your country can do for you, ask what you can do for your country.");
    expect(body.mlx_bun.vocabulary).toMatchObject({ included: ["Sotto", "SwiftUI", "Metal"], token_budget: 223 });
    expect(body.mlx_bun.vocabulary.token_count).toBeGreaterThan(0);

    const srt = await (await post("/v1/audio/transcriptions", { language: "en", temperature: "0", response_format: "srt" }, JFK)).text();
    expect(srt).toStartWith("1\n00:00:00,000 --> 00:00:");
    const tr = await (await post("/v1/audio/translations", { temperature: "0" }, JFK)).json() as { text: string };
    expect(tr.text).toContain("fellow Americans");

    const stream = await post("/v1/audio/transcriptions", { language: "en", temperature: "0", stream: "true" }, JFK);
    expect(stream.headers.get("content-type")).toBe("text/event-stream");
    const events = (await stream.text()).split("\n\n").filter(Boolean).map((c) => c.split("\n")[0]!.slice(7));
    expect(events[0]).toBe("transcript.text.delta");
    expect(events.at(-1)).toBe("transcript.text.done");
  });

  test.skipIf(!existsSync(JFK))("streaming session: float32 chunks, eager windows, finish", async () => {
    const pcm = decodeWav(new Uint8Array(readFileSync(JFK))).samples;
    const create = await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ language: "en", temperature: 0, vad: true }) });
    expect(create.status).toBe(200);
    const { id } = await create.json() as { id: string };
    let last: { speech: boolean; segments: unknown[] } | null = null;
    for (let o = 0; o < pcm.length; o += 16_000) {
      const chunk = pcm.subarray(o, Math.min(pcm.length, o + 16_000));
      const r = await fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" }, body: new Uint8Array(chunk.slice().buffer as ArrayBuffer) });
      expect(r.status).toBe(200);
      last = await r.json() as typeof last;
    }
    expect(last!.speech).toBe(true);
    const fin = await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" });
    expect(fin.status).toBe(200);
    const body = await fin.json() as { text: string; mlx_bun: { vad: { speech: boolean; segments: unknown[] } } };
    expect(body.text).toBe("And so, my fellow Americans, ask not what your country can do for you, ask what you can do for your country.");
    expect(body.mlx_bun.vad.speech).toBe(true);
    expect((await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" })).status).toBe(404);
  });

  test("streaming session with only silence never runs Whisper", async () => {
    const { id } = await (await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ vad: true }) })).json() as { id: string };
    const silence = new Uint8Array(new ArrayBuffer(16_000 * 4 * 2)); // 2 s of float32 zeros
    await fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" }, body: silence });
    const body = await (await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" })).json() as { text: string; mlx_bun: { vad: { speech: boolean }; timings: { transcribe_ms: number } } };
    expect(body.text).toBe("");
    expect(body.mlx_bun.vad.speech).toBe(false);
    expect(body.mlx_bun.timings.transcribe_ms).toBe(0);
  });

  test("one-shot vad gate on a non-speech clip", async () => {
    const res = await post("/v1/audio/transcriptions", { vad: "true" }, `${import.meta.dir}/../../fixtures/audio/chirp-1s6.wav`);
    const body = await res.json() as { text: string; mlx_bun: { vad: { speech: boolean } } };
    expect(body.text).toBe("");
    expect(body.mlx_bun.vad.speech).toBe(false);
  });

  test("bad audio is a 400, not a crash", async () => {
    const form = new FormData();
    form.set("file", new Blob([new Uint8Array(100)], { type: "audio/wav" }), "junk.wav");
    const res = await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
    expect(res.status).toBe(400);
  });
});
