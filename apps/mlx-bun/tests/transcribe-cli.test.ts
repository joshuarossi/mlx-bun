// The spawned CLI answers the module's `transcribe` verb: help, usage, a missing
// file and a bad format, with native MLX blocked. The verb's behavior over a
// fake runtime is the module's (`packages/module-transcription/tests`).
import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { help } from "../src/cli/args";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const USAGE = "usage: mlx-bun transcribe <audio-file> [query] [--language en] [--format text|json|verbose_json|srt|vtt]";

test("the command list and help include the installed module's verb", () => {
  expect(help("transcribe")).toContain("--word-timestamps");
  expect(help("transcribe")).toContain("Usage: mlx-bun transcribe <audio-file> [query] [options]");
  expect(help()).toMatch(/\n  transcribe +Speech-to-text from an audio file/);
  expect(help()).toMatch(/\n  dictate +Push-to-talk/);
  expect(help("dictate")).toContain("--hotkey");
});

async function cli(...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    env: { ...process.env, HF_HUB_CACHE: "/nonexistent/hub", HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI answers transcribe help, usage, a missing file, and a bad format with native MLX blocked", async () => {
  const helpRun = await cli("transcribe", "--help");
  expect(helpRun.code).toBe(0); expect(helpRun.err).toBe("");
  expect(helpRun.out).toContain("Usage: mlx-bun transcribe <audio-file> [query] [options]");
  for (const flag of ["--language", "--format", "--vad", "--word-timestamps", "--verbose"]) expect(helpRun.out).toContain(flag);
  const usage = await cli("transcribe");
  expect(usage).toEqual({ out: "", err: `${USAGE}\n`, code: 1 });
  const missing = await cli("transcribe", "/nonexistent/clip.wav");
  expect(missing).toEqual({ out: "", err: "audio file not found: /nonexistent/clip.wav\n", code: 1 });
  const format = await cli("transcribe", "/nonexistent/clip.wav", "--format", "xml");
  expect(format).toEqual({ out: "", err: "--format must be one of json, verbose_json, text, srt, vtt\n", code: 1 });
});

test("transcribe prints only the transcript: the model host's lifecycle lines stay off stdout", async () => {
  const app = new URL("../", import.meta.url).pathname, dir = mkdtempSync(join(tmpdir(), "mlx-transcribe-stdout-"));
  // The host library as this app resolves it (the workspace, or the installed package under verify-packages).
  const lib = dirname(realpathSync(Bun.resolveSync("@mlx-bun/app-services", app))) + "/";
  try {
    const whisper = join(dir, "whisper"); mkdirSync(whisper); writeFileSync(join(whisper, "config.json"), JSON.stringify({ model_type: "whisper" }));
    const clip = join(dir, "clip.wav"); writeFileSync(clip, new Uint8Array(64));
    // The real verb over the real model host, with only the Whisper backend and the audio decoder faked.
    const script = `
      import { mock } from "bun:test";
      const app = ${JSON.stringify(app)}, lib = ${JSON.stringify(lib)};
      mock.module(lib + "whisper-backend.ts", () => ({ nativeWhisperBackend: { async load() { return { promptTokenBudget: 3, encode: () => [],
        async transcribe(samples, options) { return { text: " hello world.", segments: [], language: options.language ?? "en" }; },
        start() { throw new Error("no sessions"); }, dispose() {} }; } } }));
      mock.module("@mlx-bun/inference/input/audio", () => ({ isRiffWave: () => true, decodeWav: () => ({ samples: new Float32Array(16000), sampleRate: 16000 }), resampleTo16k: samples => samples }));
      const { runInstalledVerb } = await import(app + "src/cli/module-verbs.ts");
      process.exitCode = await runInstalledVerb("transcribe", [${JSON.stringify(clip)}, ${JSON.stringify(whisper)}, "--format", "json"]);
    `;
    const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app, env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    expect({ out, err, code }).toEqual({ out: '{"text":"hello world."}\n', err: "", code: 0 });
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
