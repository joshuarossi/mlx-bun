// Model-free: argument policy, every output format over a generated WAV
// through the real service with a fake runtime, main's VAD gate and verbose
// diagnostics, cancellation, model selection, and the spawned CLI's help and
// error paths with native MLX blocked.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { WhisperSegment, WhisperTranscribeOptions } from "@mlx-bun/inference/transcription";
import type { TranscriptionRuntime, VadGate, WhisperRuntime } from "../src/engine/transcription-service";
import { help } from "../src/cli/args";
import { resolveWhisperModel } from "../src/cli/model-selection";
import { parseTranscribeArgs, runTranscribe, type TranscribeDependencies } from "../src/cli/transcribe";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const parse = (...args: string[]) => parseTranscribeArgs(args);
const USAGE = "usage: mlx-bun transcribe <audio-file> [query] [--language en] [--format text|json|verbose_json|srt|vtt]";

/** 16-bit mono PCM WAV of a 440 Hz tone at 16 kHz, generated in-test. */
function toneWav(frames: number): Uint8Array {
  const buffer = new ArrayBuffer(44 + frames * 2), view = new DataView(buffer);
  const ascii = (at: number, text: string) => { for (let i = 0; i < text.length; i++) view.setUint8(at + i, text.charCodeAt(i)); };
  ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE");
  ascii(12, "fmt "); view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true);
  view.setUint32(24, 16_000, true); view.setUint32(28, 32_000, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true);
  ascii(36, "data"); view.setUint32(40, frames * 2, true);
  for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.sin(2 * Math.PI * 440 * i / 16_000) * 16_000), true);
  return new Uint8Array(buffer);
}
/** The fake runtime's decoder: 16-bit PCM WAV → float32 with the library's scaling, no native code. */
function decodePcm16(bytes: Uint8Array): Float32Array {
  if (String.fromCharCode(...bytes.subarray(0, 4)) !== "RIFF") throw new Error("not a WAV file");
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const frames = view.getUint32(40, true) / 2;
  return Float32Array.from({ length: frames }, (_, i) => view.getInt16(44 + i * 2, true) / 32768);
}
const segment = (id: number, text: string, start: number, end: number): WhisperSegment =>
  ({ id, seek: 0, start, end, text, tokens: [id], temperature: 0, avgLogprob: -0.1, compressionRatio: 1, noSpeechProb: 0.01 });
async function waitFor(predicate: () => boolean, timeoutMs = 5000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (!predicate()) { if (Date.now() > deadline) throw new Error("timed out waiting"); await Bun.sleep(1); }
}

function harness(input: { speech?: boolean } = {}) {
  const events: string[] = [], options: WhisperTranscribeOptions[] = [], writes: string[] = [], notes: string[] = [];
  let hold: Promise<void> | null = null;
  const runtime: TranscriptionRuntime = {
    async load(dir) {
      events.push(`load ${dir}`);
      const loaded: WhisperRuntime = {
        promptTokenBudget: 223, encode: text => text.split(/\s+/).filter(Boolean).map((_, i) => i),
        async transcribe(samples, opts) {
          options.push(opts); events.push(`transcribe ${samples.length}`);
          if (hold) await hold;
          opts.signal?.throwIfAborted();
          const segments = [segment(0, " hello", 0, 1.5), segment(1, " world.", 1.5, 2.5)];
          for (const s of segments) opts.onSegment?.(s);
          return { text: " hello world.", segments, language: opts.language ?? "en" };
        },
        start() { throw new Error("transcribe never streams"); },
        dispose() { events.push("dispose"); },
      };
      return loaded;
    },
    async vad(path) {
      events.push(`vad ${path}`);
      const gate: VadGate = {
        detect: samples => ({ segments: input.speech ? [{ start: 0, end: samples.length }] : [] }),
        streamState: () => { throw new Error("unused"); }, probsStreaming: () => { throw new Error("unused"); },
        speechTimestamps: () => [], dispose: () => { events.push("vad dispose"); },
      };
      return gate;
    },
    async decodeAudio(bytes) { events.push(`decode ${bytes.length}`); return decodePcm16(bytes); },
  };
  const dir = mkdtempSync(join(tmpdir(), "mlx-transcribe-")), file = join(dir, "tone.wav");
  writeFileSync(file, toneWav(40_000)); // 2.5 s
  const deps: Partial<TranscribeDependencies> = {
    resolveModel: async query => { events.push(`resolve ${query ?? "(default)"}`); return { path: "/whisper", repoId: "org/whisper" }; },
    runtime, write: text => { writes.push(text); }, note: line => { notes.push(line); },
  };
  return { events, options, writes, notes, deps, file, dir, block(gate: Promise<void>) { hold = gate; },
    cleanup() { rmSync(dir, { recursive: true, force: true }); } };
}

test("transcribe arguments keep main's flags, defaults, model-query order, and errors", () => {
  expect(parse("clip.wav")).toEqual({ file: "clip.wav", query: undefined, language: null, task: "transcribe", beamSize: null, prompt: null,
    withoutTimestamps: false, conditionOnPreviousText: true, vad: null, wordTimestamps: false, faithful: false, audioCtx: null, format: "text", verbose: false });
  expect(parse("clip.wav", "turbo", "--query", "ignored")).toMatchObject({ query: "turbo" });
  expect(parse("clip.wav", "turbo", "--model", "/dir")).toMatchObject({ query: "/dir" });
  expect(parse("clip.wav", "--query", "q")).toMatchObject({ query: "q" });
  expect(parse("clip.wav", "--language", "auto")).toMatchObject({ language: null });
  expect(parse("clip.wav", "--language", "japanese", "--task", "translate", "--beam-size", "5", "--temperature", "0", "--prompt", "Sotto",
    "--no-timestamps", "--no-condition", "--vad", "--vad-threshold", "0.3", "--vad-model", "/vad.bin", "--vad-trim", "--word-timestamps",
    "--faithful", "--audio-ctx", "1024", "--format", "srt", "--verbose"))
    .toEqual({ file: "clip.wav", query: undefined, language: "japanese", task: "translate", beamSize: 5, temperature: 0, prompt: "Sotto",
      withoutTimestamps: true, conditionOnPreviousText: false, vad: { threshold: 0.3, modelPath: "/vad.bin", trim: true }, wordTimestamps: true,
      faithful: true, audioCtx: 1024, format: "srt", verbose: true });
  expect(parse("clip.wav", "--no-fallback")).toMatchObject({ temperature: 0 });
  expect(parse("clip.wav", "--temperature", "0.4", "--no-fallback")).toMatchObject({ temperature: 0.4 });
  expect(parse("clip.wav", "--task", "other")).toMatchObject({ task: "transcribe" });
  expect(parse("clip.wav", "--vad")).toMatchObject({ vad: { threshold: 0.5, modelPath: null, trim: false } });
  expect(() => parse()).toThrow(USAGE);
  expect(() => parse("clip.wav", "--format", "xml")).toThrow("--format must be one of json, verbose_json, text, srt, vtt");
  expect(() => parse("clip.wav", "a", "b")).toThrow("Too many arguments");
  for (const args of [["--beam-size", "0"], ["--temperature", "x"], ["--audio-ctx", "1.5"], ["--vad", "--vad-threshold", ""]])
    expect(() => parse("clip.wav", ...args)).toThrow("invalid --");
  expect(help("transcribe")).toContain("--word-timestamps");
  expect(help()).toContain("transcribe");
});

const outputs: Record<string, string> = {
  text: "hello world.\n",
  json: '{"text":"hello world."}\n',
  srt: "1\n00:00:00,000 --> 00:00:01,500\nhello\n\n2\n00:00:01,500 --> 00:00:02,500\nworld.\n\n",
  vtt: "WEBVTT\n\n00:00:00.000 --> 00:00:01.500\nhello\n\n00:00:01.500 --> 00:00:02.500\nworld.\n\n",
};
for (const [format, output] of Object.entries(outputs)) test(`transcribe decodes the WAV, loads once, prints ${format}, and releases the weights`, async () => {
  const h = harness();
  try {
    await runTranscribe(parse(h.file, "--format", format), h.deps);
    expect(h.writes).toEqual([output]);
    expect(h.notes).toEqual([]);
    expect(h.events).toEqual(["decode 80044", "resolve (default)", "load /whisper", "transcribe 40000", "dispose"]);
  } finally { h.cleanup(); }
});

test("verbose_json carries the task, the clip duration, and the openai-whisper segment fields", async () => {
  const h = harness();
  try {
    await runTranscribe(parse(h.file, "turbo", "--format", "verbose_json", "--task", "translate"), h.deps);
    expect(h.events[1]).toBe("resolve turbo");
    expect(JSON.parse(h.writes[0]!)).toEqual({ task: "translate", language: "en", duration: 2.5, text: "hello world.", segments: [
      { id: 0, seek: 0, start: 0, end: 1.5, text: " hello", tokens: [0], temperature: 0, avg_logprob: -0.1, compression_ratio: 1, no_speech_prob: 0.01 },
      { id: 1, seek: 0, start: 1.5, end: 2.5, text: " world.", tokens: [1], temperature: 0, avg_logprob: -0.1, compression_ratio: 1, no_speech_prob: 0.01 },
    ] });
  } finally { h.cleanup(); }
});

test("decoding flags reach the service with main's defaults and the fallback-ladder policy", async () => {
  const h = harness();
  try {
    await runTranscribe(parse(h.file), h.deps);
    expect(h.options[0]).toMatchObject({ task: "transcribe", language: null, initialPrompt: null, beamSize: null, conditionOnPreviousText: true,
      withoutTimestamps: false, wordTimestamps: false, fast: true, audioCtx: null });
    expect(h.options[0]).not.toHaveProperty("temperature");
    await runTranscribe(parse(h.file, "--language", "de", "--task", "translate", "--beam-size", "3", "--no-fallback", "--prompt", "Sotto",
      "--no-timestamps", "--no-condition", "--word-timestamps", "--faithful", "--audio-ctx", "1200"), h.deps);
    expect(h.options[1]).toMatchObject({ task: "translate", language: "de", initialPrompt: "Sotto", beamSize: 3, temperature: 0,
      conditionOnPreviousText: false, withoutTimestamps: true, wordTimestamps: true, fast: false, audioCtx: 1200 });
    await runTranscribe(parse(h.file, "--temperature", "0.4"), h.deps);
    expect(h.options[2]).toMatchObject({ temperature: 0.4 });
  } finally { h.cleanup(); }
});

test("--verbose reports each segment as it decodes and a realtime summary on stderr", async () => {
  const h = harness();
  try {
    await runTranscribe(parse(h.file, "--verbose"), h.deps);
    expect(h.notes.slice(0, 2)).toEqual(["[00:00:00.000 --> 00:00:01.500] hello", "[00:00:01.500 --> 00:00:02.500] world."]);
    expect(h.notes[2]).toMatch(/^2\.50 s audio in \d+\.\d{3} s \(.*× realtime\), language en$/);
    expect(h.writes).toEqual(["hello world.\n"]);
  } finally { h.cleanup(); }
});

test("the VAD gate prints an empty result without loading Whisper, transcribes the whole clip on speech, and --vad-trim stays accepted-only", async () => {
  const quiet = harness();
  try {
    await runTranscribe(parse(quiet.file, "--vad", "--vad-model", "/vad.bin", "--verbose"), quiet.deps);
    expect(quiet.writes).toEqual(["\n"]);
    expect(quiet.notes).toEqual([expect.stringMatching(/^vad: 0 speech segment\(s\) in \d+ ms$/)]);
    expect(quiet.events).toEqual(["decode 80044", "resolve (default)", "vad /vad.bin", "vad dispose"]);
  } finally { quiet.cleanup(); }
  for (const format of ["json", "srt"]) {
    const h = harness();
    try {
      await runTranscribe(parse(h.file, "--vad", "--format", format), h.deps);
      expect(h.writes).toEqual(['{"text":"","vad":{"speech":false,"segments":[]}}\n']);
    } finally { h.cleanup(); }
  }
  const voiced = harness({ speech: true });
  try {
    await runTranscribe(parse(voiced.file, "--vad", "--vad-trim", "--vad-threshold", "0.3"), voiced.deps);
    expect(voiced.writes).toEqual(["hello world.\n"]);
    expect(voiced.events).toEqual(["decode 80044", "resolve (default)", "vad null", "load /whisper", "transcribe 40000", "dispose", "vad dispose"]);
  } finally { voiced.cleanup(); }
});

test("cancellation during transcription rejects, prints nothing, and releases the weights", async () => {
  const h = harness(), abort = new AbortController(), gate = Promise.withResolvers<void>();
  try {
    h.block(gate.promise);
    const pending = runTranscribe(parse(h.file), h.deps, abort.signal);
    await waitFor(() => h.events.includes("transcribe 40000"));
    abort.abort(new Error("transcription cancelled")); gate.resolve();
    await expect(pending).rejects.toThrow("transcription cancelled");
    expect(h.writes).toEqual([]);
    expect(h.events).toEqual(["decode 80044", "resolve (default)", "load /whisper", "transcribe 40000", "dispose"]);
  } finally { h.cleanup(); }
});

test("cancellation while reading the clip never decodes, resolves, or loads", async () => {
  const h = harness(), abort = new AbortController();
  try {
    await expect(runTranscribe(parse(h.file), { ...h.deps, read: async path => {
      abort.abort(new Error("cancelled while reading")); return new Uint8Array(await Bun.file(path).arrayBuffer());
    } }, abort.signal)).rejects.toThrow("cancelled while reading");
    expect(h.events).toEqual([]);
  } finally { h.cleanup(); }
});

test("a missing or undecodable file fails before any model lookup; the file CLI preserves clips under 0.1 s", async () => {
  const h = harness();
  try {
    await expect(runTranscribe(parse("/nope/clip.wav"), h.deps)).rejects.toThrow("audio file not found: /nope/clip.wav");
    expect(h.events).toEqual([]);
    const bad = join(h.dir, "bad.bin"); writeFileSync(bad, "nope");
    await expect(runTranscribe(parse(bad), h.deps)).rejects.toThrow("not a WAV file");
    expect(h.events).toEqual(["decode 4"]);
    const short = join(h.dir, "short.wav"); writeFileSync(short, toneWav(800));
    await runTranscribe(parse(short), h.deps);
    expect(h.events.slice(1)).toEqual(["decode 1644", "resolve (default)", "load /whisper", "transcribe 800", "dispose"]);
    expect(h.writes).toEqual(["hello world.\n"]);
  } finally { h.cleanup(); }
});

test("Whisper model selection follows main's order: a config.json directory as given, a query through the registry, else the first downloaded Whisper", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-whisper-select-"));
  try {
    const snapshot = join(dir, "whisper"); mkdirSync(snapshot); writeFileSync(join(snapshot, "config.json"), "{}");
    const untouched = { resolve: async () => { throw new Error("must not resolve"); }, defaultModel: async () => { throw new Error("must not scan"); } };
    expect(await resolveWhisperModel(snapshot, untouched)).toEqual({ path: snapshot, repoId: snapshot });
    expect(await resolveWhisperModel("turbo", { ...untouched, resolve: async query => ({ m: { path: "/p", repoId: `org/${query}` } }) }))
      .toEqual({ path: "/p", repoId: "org/turbo" });
    expect(await resolveWhisperModel(undefined, { ...untouched, defaultModel: async () => ({ path: "/d", repoId: "org/default" }) }))
      .toEqual({ path: "/d", repoId: "org/default" });
    await expect(resolveWhisperModel(undefined, { ...untouched, defaultModel: async () => null }))
      .rejects.toThrow("no Whisper model downloaded — try: mlx-bun get mlx-community/whisper-large-v3-turbo");
  } finally { rmSync(dir, { recursive: true, force: true }); }
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
