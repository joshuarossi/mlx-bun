// Opt-in with real weights: the transcription-only server on real speech, with
// expected transcripts taken from the mlx-whisper oracle instead of written here.
//   MLX_BUN_TEST_NATIVE=1 \
//   MLX_BUN_APP_TEST_WHISPER_MODEL=<mlx-community/whisper-large-v3-turbo snapshot> \
//   MLX_BUN_TEST_WHISPER_AUDIO=<dir with speech-fox.wav, jfk.wav, chirp-1s6.wav> \
//   MLX_BUN_TEST_WHISPER_REFERENCE=<dir holding the oracle's whisper.json> \
//   MLX_BUN_TEST_WHISPER_REFERENCE_SHA256=<that whisper.json's SHA-256> \
//   bun test tests/engine/transcription-parity.test.ts
// The reference is the unchanged producer at main 02d723a
// (scripts/oracle/gen-whisper-golden.py, run in the mlx-whisper environment);
// the same clips and options are compared bit for bit in the inference package's
// whisper-parity test. Here the HTTP surface must return the oracle's text for
// the same audio: multipart and JSON requests, beam search with vocabulary, SRT,
// translation, event streaming, streaming sessions with the Silero VAD gate
// (ggml-org/whisper-vad in the Hugging Face cache), and the error path. Without
// the audio and reference variables the file skips; setting only some fails.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const names = ["MLX_BUN_APP_TEST_WHISPER_MODEL", "MLX_BUN_TEST_WHISPER_AUDIO", "MLX_BUN_TEST_WHISPER_REFERENCE",
  "MLX_BUN_TEST_WHISPER_REFERENCE_SHA256"] as const;
const set = names.filter(name => process.env[name]?.trim());
if (native && set.length > 0 && set.length < names.length)
  throw new Error(`transcription parity needs all of ${names.join(", ")}; missing: ${names.filter(n => !set.includes(n)).join(", ")}`);
const enabled = native && set.length === names.length;
const [modelDir, audioDir, referenceDir, referenceSha] = names.map(name => process.env[name] ?? "") as [string, string, string, string];

interface OracleCase { clip: string; name: string; text: string }
const cases: OracleCase[] = [];
if (enabled) {
  const bytes = readFileSync(join(referenceDir!, "whisper.json"));
  if (createHash("sha256").update(bytes).digest("hex") !== referenceSha) throw new Error("the oracle manifest differs from its pin");
  cases.push(...(JSON.parse(bytes.toString("utf8")) as { cases: OracleCase[] }).cases);
}
const oracleText = (clip: string, name: string) => cases.find(c => c.clip === clip && c.name === name)!.text.trim();

describe.skipIf(!enabled)("the transcription-only server returns the oracle's transcripts", () => {
  let app: RunningApp;
  let base = "";
  const audio = (name: string) => join(audioDir, name);
  const fox = () => audio("speech-fox.wav");
  const jfk = () => audio("jfk.wav");
  const post = (path: string, fields: Record<string, string>, file = fox()) => {
    const form = new FormData();
    form.set("file", new Blob([readFileSync(file)], { type: "audio/wav" }), "clip.wav");
    for (const [key, value] of Object.entries(fields)) form.set(key, value);
    return fetch(`${base}${path}`, { method: "POST", body: form });
  };
  const hasVad = () => existsSync(join(process.env.HOME ?? "", ".cache", "huggingface", "hub", "models--ggml-org--whisper-vad"));

  beforeAll(async () => {
    const { startTranscriptionServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir, "mlx-community/whisper-large-v3-turbo");
    if (!model) throw new Error("the Whisper path has no loadable checkpoint");
    // Keep the weights after a take so the unload route has something to release.
    app = await startTranscriptionServer(model, parseServeOptions({ values: { port: "0", "no-open": true, "whisper-idle-unload": "300" }, positionals: [] }));
    base = `http://127.0.0.1:${app.port}`;
  }, 120_000);
  afterAll(async () => { await app?.close(); });

  test("multipart json loads on the first request, matches the oracle, and stays resident", async () => {
    const before = await (await fetch(`${base}/v1/models`)).json();
    expect(before.data[0]).toMatchObject({ id: "mlx-community/whisper-large-v3-turbo", transcription: true, resident: false });
    const res = await post("/v1/audio/transcriptions", { language: "en", temperature: "0" });
    expect(res.status).toBe(200);
    const body = await res.json() as { text: string; mlx_bun: { language: string; timings: { load_ms: number } } };
    expect(body.text.trim()).toBe(oracleText("fox", "greedy-en"));
    expect(body.mlx_bun.language).toBe("en");
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    const again = await (await post("/v1/audio/transcriptions", { language: "en", temperature: "0" })).json() as typeof body;
    expect(again.text).toBe(body.text);
    expect(again.mlx_bun.timings.load_ms).toBe(0);
    const models = await (await fetch(`${base}/v1/models`)).json();
    expect(models.data[0]).toMatchObject({ transcription: true, resident: true });
  }, 600_000);

  test("unload pages the weights out and the next request pages them back in", async () => {
    const unloaded = await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json();
    expect(unloaded).toMatchObject({ unloaded: true });
    const res = await post("/v1/audio/transcriptions", { language: "en", temperature: "0", response_format: "verbose_json" });
    const body = await res.json() as { text: string; segments: { start: number; end: number }[]; mlx_bun: { timings: { load_ms: number } } };
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    expect(body.text.trim()).toBe(oracleText("fox", "greedy-en"));
    expect(body.segments.length).toBeGreaterThan(0);
    console.log(`[transcription] page-in after unload: ${body.mlx_bun.timings.load_ms.toFixed(0)} ms`);
  }, 600_000);

  test("auto language, beam search with vocabulary, srt, translation and event streaming on jfk", async () => {
    const auto = await (await post("/v1/audio/transcriptions", { temperature: "0" }, jfk())).json() as { text: string; mlx_bun: { language: string } };
    expect(auto.text.trim()).toBe(oracleText("jfk", "greedy-auto"));
    expect(auto.mlx_bun.language).toBe("en");

    const beam = await fetch(`${base}/v1/audio/transcriptions`, {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ file: readFileSync(jfk()).toString("base64"), language: "en", temperature: 0, beam_size: 5, vocabulary: ["Sotto", "SwiftUI", "Metal"] }),
    });
    const beamBody = await beam.json() as { text: string; mlx_bun: { vocabulary: { included: string[]; token_budget: number; token_count: number } } };
    expect(beamBody.text.trim()).toBe(oracleText("jfk", "greedy-auto"));
    expect(beamBody.mlx_bun.vocabulary).toMatchObject({ included: ["Sotto", "SwiftUI", "Metal"], token_budget: 223 });
    expect(beamBody.mlx_bun.vocabulary.token_count).toBeGreaterThan(0);

    const srt = await (await post("/v1/audio/transcriptions", { language: "en", temperature: "0", response_format: "srt" }, jfk())).text();
    expect(srt).toStartWith("1\n00:00:00,000 --> 00:00:");
    expect(srt).toContain(oracleText("jfk", "greedy-auto").slice(0, 20));
    const translated = await (await post("/v1/audio/translations", { temperature: "0" }, jfk())).json() as { text: string };
    expect(translated.text.trim()).toBe(oracleText("jfk", "translate-en"));

    const stream = await post("/v1/audio/transcriptions", { language: "en", temperature: "0", stream: "true" }, jfk());
    expect(stream.headers.get("content-type")).toBe("text/event-stream");
    const events = (await stream.text()).split("\n\n").filter(Boolean).map(chunk => chunk.split("\n")[0]!.slice(7));
    expect(events[0]).toBe("transcript.text.delta");
    expect(events.at(-1)).toBe("transcript.text.done");
  }, 600_000);

  test.skipIf(!hasVad())("a streaming session takes float32 chunks, gates on the VAD and finishes with the oracle's text", async () => {
    const wav = new Uint8Array(readFileSync(jfk()));
    const { decodeWav } = await import("@mlx-bun/inference/input/audio");
    const pcm = decodeWav(wav).samples;
    const create = await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ language: "en", temperature: 0, vad: true }) });
    expect(create.status).toBe(200);
    const { id } = await create.json() as { id: string };
    let last: { speech: boolean } | null = null;
    for (let at = 0; at < pcm.length; at += 16_000) {
      const chunk = pcm.subarray(at, Math.min(pcm.length, at + 16_000));
      const response = await fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" }, body: new Uint8Array(chunk.slice().buffer as ArrayBuffer) });
      expect(response.status).toBe(200);
      last = await response.json() as typeof last;
    }
    expect(last!.speech).toBe(true);
    const finished = await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" });
    expect(finished.status).toBe(200);
    const body = await finished.json() as { text: string; mlx_bun: { vad: { speech: boolean } } };
    expect(body.text.trim()).toBe(oracleText("jfk", "greedy-auto"));
    expect(body.mlx_bun.vad.speech).toBe(true);
    expect((await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" })).status).toBe(404);
  }, 600_000);

  test.skipIf(!hasVad())("a session of only silence never runs Whisper, and the one-shot gate skips a non-speech clip", async () => {
    const { id } = await (await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ vad: true }) })).json() as { id: string };
    await fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" }, body: new Uint8Array(new ArrayBuffer(16_000 * 4 * 2)) });
    const silent = await (await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" })).json() as { text: string; mlx_bun: { vad: { speech: boolean }; timings: { transcribe_ms: number } } };
    expect(silent.text).toBe("");
    expect(silent.mlx_bun.vad.speech).toBe(false);
    expect(silent.mlx_bun.timings.transcribe_ms).toBe(0);
    const gated = await (await post("/v1/audio/transcriptions", { vad: "true" }, audio("chirp-1s6.wav"))).json() as { text: string; mlx_bun: { vad: { speech: boolean } } };
    expect(gated.text).toBe("");
    expect(gated.mlx_bun.vad.speech).toBe(false);
  }, 600_000);

  test("bad audio is a 400, not a crash", async () => {
    const form = new FormData();
    form.set("file", new Blob([new Uint8Array(100)], { type: "audio/wav" }), "junk.wav");
    expect((await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form })).status).toBe(400);
  });
});
