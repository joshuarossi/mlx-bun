// Opt-in with real weights: the transcription-only server over the cached
// Whisper checkpoint named by MLX_BUN_APP_TEST_WHISPER_MODEL (a snapshot
// directory, e.g. the mlx-community/whisper-large-v3-turbo cache entry).
// Runs only with MLX_BUN_TEST_NATIVE=1; loads the model natively and touches
// the GPU. The audio is synthesized here (a one-second 440 Hz tone), so no
// recording is committed. It checks the HTTP shape, residency, and the unload
// route, not transcript quality or parity.
import { expect, test } from "bun:test";
import type { RunningApp } from "../../src/cli/serve";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_WHISPER_MODEL;

/** 16-bit mono PCM WAV of a sine tone at 16 kHz. */
function toneWav(seconds: number, hz: number): Uint8Array<ArrayBuffer> {
  const rate = 16_000, frames = Math.round(seconds * rate);
  const buffer = new ArrayBuffer(44 + frames * 2);
  const view = new DataView(buffer);
  const ascii = (offset: number, text: string) => { for (let i = 0; i < text.length; i++) view.setUint8(offset + i, text.charCodeAt(i)); };
  ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE");
  ascii(12, "fmt "); view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true);
  view.setUint32(24, rate, true); view.setUint32(28, rate * 2, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true);
  ascii(36, "data"); view.setUint32(40, frames * 2, true);
  for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.sin(2 * Math.PI * hz * i / rate) * 0.3 * 32767), true);
  return new Uint8Array(buffer);
}

test.skipIf(!native || !modelDir)("the transcription-only server transcribes a generated WAV, keeps the weights per policy, and pages them out on request", async () => {
  let app: RunningApp | undefined;
  try {
    const { startTranscriptionServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir!, "test-whisper");
    if (!model) throw new Error("Whisper path has no loadable checkpoint");
    expect(model.modelType).toBe("whisper");
    // Keep the weights after the take so the unload route has something to release.
    const options = parseServeOptions({ values: { port: "0", "no-open": true, "whisper-idle-unload": "300" }, positionals: [] });
    app = await startTranscriptionServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const before = await (await fetch(`${base}/v1/models`)).json();
    expect(before.data).toEqual([expect.objectContaining({ id: "test-whisper", transcription: true, resident: false })]);

    const form = new FormData();
    form.set("file", new Blob([toneWav(1, 440)], { type: "audio/wav" }), "tone.wav");
    form.set("language", "en");
    const response = await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
    expect(response.status).toBe(200);
    const body = await response.json();
    expect(typeof body.text).toBe("string");
    expect(body.mlx_bun).toMatchObject({ model: "test-whisper", language: "en" });
    expect(body.mlx_bun.duration).toBeCloseTo(1, 2);
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    expect(body.mlx_bun.timings.transcribe_ms).toBeGreaterThan(0);
    expect(response.headers.get("x-mlx-bun-language")).toBe("en");

    const verbose = new FormData();
    verbose.set("file", new Blob([toneWav(1, 440)], { type: "audio/wav" }), "tone.wav");
    verbose.set("response_format", "verbose_json");
    const second = await (await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: verbose })).json();
    expect(second.task).toBe("transcribe");
    expect(Array.isArray(second.segments)).toBe(true);
    // Warm take: the weights stayed resident under the 300 s policy.
    expect(second.mlx_bun.timings.load_ms).toBe(0);

    const health = await (await fetch(`${base}/health`)).json();
    expect(health.transcription).toMatchObject({ resident: true, loads: 1, requests: 2, sessions: 0 });
    const unloaded = await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json();
    expect(unloaded).toMatchObject({ unloaded: true, resident: false, loads: 1, unloads: 1 });
    expect((await (await fetch(`${base}/v1/models/test-whisper`)).json()).data[0].resident).toBe(false);
    expect(await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json()).toMatchObject({ unloaded: false });
    // The next take pages the weights back in.
    const again = new FormData();
    again.set("file", new Blob([toneWav(1, 440)], { type: "audio/wav" }), "tone.wav");
    const third = await (await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: again })).json();
    expect(third.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    expect((await (await fetch(`${base}/stats`)).json()).transcription).toMatchObject({ loads: 2, requests: 3 });
  } finally {
    await app?.close();
  }
}, 300_000);
