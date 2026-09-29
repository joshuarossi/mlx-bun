// The transcription-only host with no other module installed: it builds its
// command list from the one manifest, serves the audio routes and discovery
// over a real listener with a fake Whisper backend, and stops cleanly. The
// module's own behavior is `packages/module-transcription/tests`.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { CatalogEntry, ModelCatalog } from "@mlx-bun/app-core";
import type { LoadedWhisper, WhisperBackend } from "@mlx-bun/app-services";
import { createTranscriptionModule, manifest } from "@mlx-bun/module-transcription";
import { installedModules, manifests } from "../src/modules";
import { startTranscribeServer } from "../src/cli/serve";

const entry = (id: string, directory: string, operations: CatalogEntry["operations"] = ["transcribe"]): CatalogEntry => ({ id, kind: "model", directory, bytes: 1, operations });
function catalog(entries: CatalogEntry[]): ModelCatalog {
  return {
    list: async () => entries, resolve: async id => entries.find(item => item.id === id),
    find: async query => entries.find(item => item.id === query) ?? (() => { throw new Error(`no model matching "${query}"`); })(),
    estimate: async () => undefined, locate: async () => undefined, register: async () => { throw new Error("unused"); }, download: async () => { throw new Error("unused"); },
    pickDefault: async () => { throw new Error("unused"); }, canPublish: () => false, publish: async () => { throw new Error("unused"); },
  };
}

/** A fake Whisper checkpoint that records its lifecycle. */
function fakeBackend(events: string[]): WhisperBackend {
  return { async load(dir) {
    events.push(`load ${dir}`); await Bun.sleep(2);
    const loaded: LoadedWhisper = {
      promptTokenBudget: 3, encode: () => [],
      async transcribe(samples, options) {
        events.push(`transcribe ${samples.length} ${options.language}`);
        return { text: " hello from a tone", language: options.language ?? "en", segments: [{ id: 0, seek: 0, start: 0, end: 1, text: " hello from a tone", tokens: [1],
          temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0 }] };
      },
      start() { throw new Error("no sessions in this test"); },
      dispose() { events.push(`dispose ${dir}`); },
    };
    return loaded;
  } };
}

/** 16-bit mono PCM WAV of a 440 Hz tone. */
function toneWav(seconds: number): Uint8Array<ArrayBuffer> {
  const frames = Math.round(seconds * 16_000), buffer = new ArrayBuffer(44 + frames * 2), view = new DataView(buffer);
  const ascii = (at: number, text: string) => { for (let i = 0; i < text.length; i++) view.setUint8(at + i, text.charCodeAt(i)); };
  ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE"); ascii(12, "fmt "); view.setUint32(16, 16, true); view.setUint16(20, 1, true);
  view.setUint16(22, 1, true); view.setUint32(24, 16_000, true); view.setUint32(28, 32_000, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true);
  ascii(36, "data"); view.setUint32(40, frames * 2, true);
  for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.sin(2 * Math.PI * 440 * i / 16_000) * 9830), true);
  return new Uint8Array(buffer);
}
/** The decoder without the native library: 16-bit PCM WAV to float32. */
const media = { async decodeAudio(bytes: Uint8Array) { const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  return Float32Array.from({ length: (bytes.length - 44) / 2 }, (_, i) => view.getInt16(44 + i * 2, true) / 32768); },
  async vad(): Promise<never> { throw new Error("no gate in this test"); } };
const modules = async () => [createTranscriptionModule({ media })];

test("the host installs exactly the transcription module and its manifest declares what the host serves", async () => {
  expect(manifests.map(item => item.id)).toEqual(["transcription"]);
  expect((await installedModules()).map(item => item.id)).toEqual(["transcription"]);
  expect((await installedModules())[0]!.requires).toEqual(["modelHost", "catalog"]);
});

test("it serves the module's routes and the discovery surfaces over a real listener and releases the weights on close", async () => {
  const events: string[] = [];
  const running = await startTranscribeServer({ port: 0, idleUnloadSec: 300, catalog: catalog([entry("mlx-community/whisper-tiny", "/cache/whisper")]),
    backend: fakeBackend(events), modules });
  const base = `http://127.0.0.1:${running.port}`;
  try {
    expect(running.modelId).toBe("mlx-community/whisper-tiny");
    expect(events).toEqual([]); // loads on the first request
    const models = await (await fetch(`${base}/v1/models`)).json();
    expect(models.data).toEqual([expect.objectContaining({ id: "mlx-community/whisper-tiny", transcription: true, resident: false })]);
    const send = async (path: string) => {
      const form = new FormData();
      form.set("file", new Blob([toneWav(1)], { type: "audio/wav" }), "tone.wav"); form.set("language", "en");
      return await fetch(base + path, { method: "POST", body: form });
    };
    const first = await send("/v1/audio/transcriptions");
    expect(first.status).toBe(200);
    const body = await first.json();
    expect(body.text).toBe("hello from a tone");
    expect(body.mlx_bun).toMatchObject({ model: "mlx-community/whisper-tiny", language: "en", duration: 1 });
    expect(body.mlx_bun.timings.load_ms).toBeGreaterThan(0);
    const second = await (await send("/v1/audio/translations")).json();
    expect(second.mlx_bun.timings.load_ms).toBe(0); // warm under the 300 s policy
    expect(events).toEqual(["load /cache/whisper", "transcribe 16000 en", "transcribe 16000 en"]);
    const health = await (await fetch(`${base}/health`)).json();
    expect(health.transcription).toMatchObject({ resident: true, loads: 1, unloads: 0, requests: 2, sessions: 0, idle_unload_sec: 300 });
    const index = await (await fetch(`${base}/v1`)).json();
    expect(index).toMatchObject({ name: "mlx-bun-transcribe", mode: "transcription", model: "mlx-community/whisper-tiny" });
    expect(index.endpoints).toEqual([...manifest.routes.map(route => `${route.method} ${route.path}`), "GET /v1/models", "GET /health", "GET /stats"]);
    const unloaded = await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json();
    expect(unloaded).toMatchObject({ unloaded: true, resident: false, loads: 1, unloads: 1, requests: 2, idle_unload_sec: 300 });
    // Nothing but the audio routes and discovery: no chat, no web app, no other module's routes.
    for (const [method, path] of [["POST", "/v1/chat/completions"], ["GET", "/"], ["GET", "/api/hub/local"], ["GET", "/ws/chat"]] as const)
      expect((await fetch(base + path, { method })).status).toBe(404);
    await send("/v1/audio/transcriptions");
    expect(events.filter(event => event.startsWith("load"))).toHaveLength(2);
  } finally { await running.close(); }
  expect(events.at(-1)).toBe("dispose /cache/whisper");
  await running.close();
  expect(events.filter(event => event.startsWith("dispose"))).toHaveLength(2);
  await expect(fetch(`${base}/health`)).rejects.toThrow();
});

test("--preload loads before listening, --whisper-resident keeps the weights, and a query resolves through the catalog", async () => {
  const events: string[] = [];
  const running = await startTranscribeServer({ port: 0, query: "tiny", resident: true, preload: true, catalog: { ...catalog([entry("org/whisper-tiny", "/w/tiny")]),
    find: async query => entry(`org/whisper-${query}`, "/w/tiny") }, backend: fakeBackend(events), modules });
  try {
    expect(events).toEqual(["load /w/tiny"]);
    const health = await (await fetch(`http://127.0.0.1:${running.port}/health`)).json();
    expect(health.transcription).toMatchObject({ resident: true, loads: 1, idle_unload_sec: null });
  } finally { await running.close(); }
  expect(events).toEqual(["load /w/tiny", "dispose /w/tiny"]);
});

test("a host with no Whisper model, or a query that is not one, refuses to start and holds nothing", async () => {
  await expect(startTranscribeServer({ port: 0, catalog: catalog([entry("org/chat", "/c", ["generate"])]), modules }))
    .rejects.toThrow("no Whisper model downloaded — try: mlx-bun get mlx-community/whisper-large-v3-turbo");
  await expect(startTranscribeServer({ port: 0, query: "org/chat", catalog: catalog([entry("org/chat", "/c", ["generate"])]), modules }))
    .rejects.toThrow("org/chat is not a speech-to-text model");
  const events: string[] = [];
  await expect(startTranscribeServer({ port: 0, preload: true, catalog: catalog([entry("org/w", "/w")]), modules,
    backend: { async load(dir) { events.push(`load ${dir}`); throw new Error("no tokenizer"); } } })).rejects.toThrow("no tokenizer");
  expect(events).toEqual(["load /w"]);
});

const cli = resolve(import.meta.dir, "../bin/mlx-bun-transcribe.mjs");
async function run(...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", cli, ...args], {
    env: { ...process.env, HF_HUB_CACHE: "/nonexistent/hub", HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" }, stdout: "pipe", stderr: "pipe" });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the launcher answers help, version, the module's verbs and errors with native MLX blocked", async () => {
  const overview = await run("--help");
  expect(overview.code).toBe(0);
  for (const verb of ["serve", "transcribe", "dictate"]) expect(overview.out).toMatch(new RegExp(`\\n  ${verb} +\\S`));
  expect(overview.out).not.toMatch(/\n  (generate|train|memory|convert) /);
  expect((await run("--version")).out).toMatch(/^mlx-bun-transcribe \d/);
  const verbHelp = await run("transcribe", "--help");
  expect(verbHelp.out).toContain("Usage: mlx-bun-transcribe transcribe <audio-file> [query] [options]");
  expect(verbHelp.out).toContain("--word-timestamps");
  expect((await run("dictate", "--help")).out).toContain("--hotkey");
  expect((await run("serve", "--help")).out).toContain("--whisper-idle-unload");
  expect(await run("bogus")).toEqual({ out: "", err: "Unknown command: bogus. Use mlx-bun-transcribe --help.\n", code: 1 });
  expect(await run("transcribe")).toEqual({ out: "", err: "usage: mlx-bun transcribe <audio-file> [query] [--language en] [--format text|json|verbose_json|srt|vtt]\n", code: 1 });
  expect(await run("transcribe", "/nonexistent/clip.wav")).toEqual({ out: "", err: "audio file not found: /nonexistent/clip.wav\n", code: 1 });
  expect(await run("serve", "--port", "x")).toEqual({ out: "", err: "invalid --port: x\n", code: 1 });
});

test("the transcribe verb prints only the transcript: the model host's lifecycle lines stay off stdout", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-transcribe-stdout-"));
  try {
    const whisper = join(dir, "whisper"); mkdirSync(whisper); writeFileSync(join(whisper, "config.json"), JSON.stringify({ model_type: "whisper" }));
    const clip = join(dir, "clip.wav"); writeFileSync(clip, new Uint8Array(64));
    const lib = resolve(import.meta.dir, "../../../packages/app-services/src/"), main = resolve(import.meta.dir, "../src/cli/main.ts");
    // The real host and verb over the real model host, with only the Whisper backend and the audio decoder faked.
    const script = `
      import { mock } from "bun:test";
      mock.module(${JSON.stringify(lib + "/whisper-backend.ts")}, () => ({ nativeWhisperBackend: { async load() { return { promptTokenBudget: 3, encode: () => [],
        async transcribe(samples, options) { return { text: " hello world.", segments: [], language: options.language ?? "en" }; },
        start() { throw new Error("no sessions"); }, dispose() {} }; } } }));
      mock.module("@mlx-bun/inference/input/audio", () => ({ isRiffWave: () => true, decodeWav: () => ({ samples: new Float32Array(16000), sampleRate: 16000 }), resampleTo16k: samples => samples }));
      process.argv = [process.argv[0], ${JSON.stringify(main)}, "transcribe", ${JSON.stringify(clip)}, ${JSON.stringify(whisper)}, "--format", "json"];
      await import(${JSON.stringify(main)});
    `;
    const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: resolve(import.meta.dir, ".."), env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    expect({ out, err, code }).toEqual({ out: '{"text":"hello world."}\n', err: "", code: 0 });
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
