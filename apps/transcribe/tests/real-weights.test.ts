// Opt-in with real weights: the transcription-only host over the cached Whisper
// checkpoint named by MLX_BUN_APP_TEST_WHISPER_MODEL (a snapshot directory, e.g.
// the mlx-community/whisper-large-v3-turbo cache entry). Runs only with
// MLX_BUN_TEST_NATIVE=1; loads the model natively and touches the GPU. Audio is
// synthesized here (a 440 Hz tone, and speech from macOS `say` when present),
// so no recording is committed. It checks the HTTP shape, residency and the
// transcript's words, not parity: `apps/mlx-bun/tests/engine/transcription.test.ts`
// runs the same requests through the app.
import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { startTranscribeServer } from "../src/cli/serve";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const whisperDir = process.env.MLX_BUN_APP_TEST_WHISPER_MODEL;
const speechTools = Bun.which("say") !== null && Bun.which("afconvert") !== null;

function toneWav(seconds: number, hz: number): Uint8Array<ArrayBuffer> {
  const rate = 16_000, frames = Math.round(seconds * rate), buffer = new ArrayBuffer(44 + frames * 2), view = new DataView(buffer);
  const ascii = (offset: number, text: string) => { for (let i = 0; i < text.length; i++) view.setUint8(offset + i, text.charCodeAt(i)); };
  ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE"); ascii(12, "fmt "); view.setUint32(16, 16, true); view.setUint16(20, 1, true);
  view.setUint16(22, 1, true); view.setUint32(24, rate, true); view.setUint32(28, rate * 2, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true);
  ascii(36, "data"); view.setUint32(40, frames * 2, true);
  for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.sin(2 * Math.PI * hz * i / rate) * 0.3 * 32767), true);
  return new Uint8Array(buffer);
}

test.skipIf(!native || !whisperDir)("the transcription-only host transcribes a synthesized tone and speech on real weights, keeps them per policy, and pages them out on request", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-transcribe-real-"));
  const running = await startTranscribeServer({ port: 0, query: whisperDir!, idleUnloadSec: 300 });
  const base = `http://127.0.0.1:${running.port}`;
  const send = async (clip: Uint8Array<ArrayBuffer>, fields: Record<string, string> = {}) => {
    const form = new FormData();
    form.set("file", new Blob([clip], { type: "audio/wav" }), "clip.wav");
    form.set("language", "en");
    for (const [key, value] of Object.entries(fields)) form.set(key, value);
    return await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
  };
  try {
    expect((await (await fetch(`${base}/v1/models`)).json()).data).toEqual([expect.objectContaining({ id: running.modelId, transcription: true, resident: false })]);
    const tone = await send(toneWav(1, 440));
    expect(tone.status).toBe(200);
    const body = await tone.json();
    expect(typeof body.text).toBe("string");
    expect(body.mlx_bun).toMatchObject({ model: running.modelId, language: "en" });
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    if (speechTools) {
      const aiff = join(dir, "speech.aiff"), wav = join(dir, "speech.wav");
      for (const command of [["say", "-o", aiff, "The quick brown fox jumps over the lazy dog."], ["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1", aiff, wav]])
        expect(Bun.spawnSync(command, { stdout: "ignore", stderr: "pipe" }).exitCode).toBe(0);
      const spoken = await send(new Uint8Array(readFileSync(wav)), { response_format: "verbose_json" });
      const verbose = await spoken.json();
      const heard = new Set(String(verbose.text).toLowerCase().replace(/[^a-z\s]/g, " ").split(/\s+/).filter(Boolean));
      expect(["quick", "brown", "fox", "lazy", "dog"].filter(word => !heard.has(word))).toEqual([]);
      expect(verbose.task).toBe("transcribe");
      expect(verbose.mlx_bun.timings.load_ms).toBe(0); // warm under the 300 s policy
    }
    const health = await (await fetch(`${base}/health`)).json();
    expect(health.transcription).toMatchObject({ resident: true, loads: 1, sessions: 0, idle_unload_sec: 300 });
    expect(await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json()).toMatchObject({ unloaded: true, resident: false, loads: 1, unloads: 1 });
    expect(await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json()).toMatchObject({ unloaded: false });
  } finally { await running.close(); rmSync(dir, { recursive: true, force: true }); }
}, 600_000);
