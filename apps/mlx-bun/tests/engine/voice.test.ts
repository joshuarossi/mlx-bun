// Opt-in with real weights: Whisper through the voice surfaces a user runs.
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_WHISPER_MODEL=<Whisper snapshot directory> \
//   [MLX_BUN_APP_TEST_MODEL=<chat model snapshot directory>] bun test tests/engine/voice.test.ts
// Speech is synthesized to a file with macOS `say` and `afconvert` (the tests
// skip without them); nothing is recorded or committed, and no audio device is
// opened. The Silero VAD gate is exercised when ggml-org/whisper-vad is in the
// caller's Hugging Face cache; spawned CLIs see it, and the openai/whisper
// tokenizer snapshots, through read-only links in their temporary HOME.
// - `transcribe` and `dictate` run as spawned CLIs under a temporary HOME;
//   dictate's microphone sidecar is replaced (MLX_BUN_MIC_CAPTURE) by a
//   stand-in that follows the sidecar protocol and streams the speech during a
//   held hotkey. A physical microphone, key tap, clipboard and typing remain
//   unverified here.
// - With MLX_BUN_APP_TEST_MODEL, a chat server with the Whisper companion:
//   discovery and the web chat's mic probe, idle unload after its timeout,
//   transcription while a chat reply streams (and chat while a transcription
//   runs) with the chat output unchanged, a streaming voice session (finished,
//   and another abandoned and deleted), the
//   unload route, and `dictate --server` against it.
// Transcript checks are word-level on clear synthetic speech, not parity.
import { afterAll, describe, expect, test } from "bun:test";
import { chmodSync, existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";
import { missingWords, speech, speechTools, wavBytes } from "../support/media";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const whisperDir = process.env.MLX_BUN_APP_TEST_WHISPER_MODEL;
const chatDir = process.env.MLX_BUN_APP_TEST_MODEL;
const LAUNCHER = join(import.meta.dir, "..", "..", "bin", "mlx-bun.mjs");
const enabled = native && !!whisperDir && speechTools;

const scratch = mkdtempSync(join(tmpdir(), "mlx-bun-voice-"));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));

const hubCache = join(process.env.HOME ?? "", ".cache", "huggingface", "hub");
/** The Silero weights file in the caller's Hugging Face cache (the default the server resolves). */
function vadModel(): string | null {
  const base = join(hubCache, "models--ggml-org--whisper-vad", "snapshots");
  if (!existsSync(base)) return null;
  for (const snapshot of readdirSync(base)) {
    const file = join(base, snapshot, "ggml-silero-v6.2.0.bin");
    if (existsSync(file)) return file;
  }
  return null;
}

/** A temporary HOME for spawned CLIs, with the snapshots they read from $HOME's cache linked in read-only. */
function cliHome(name: string): string {
  const home = join(scratch, name);
  mkdirSync(join(home, ".cache", "huggingface", "hub"), { recursive: true });
  for (const repo of ["models--openai--whisper-large-v3-turbo", "models--openai--whisper-large-v3", "models--ggml-org--whisper-vad"])
    if (existsSync(join(hubCache, repo))) symlinkSync(join(hubCache, repo), join(home, ".cache", "huggingface", "hub", repo));
  return home;
}

/** A stand-in for mlx-bun-mic-capture: ready, hold the key, stream the PCM, release, wait for stdin to close. */
function micStandIn(pcm: Float32Array): string {
  const dir = mkdtempSync(join(scratch, "mic-")), raw = join(dir, "speech.f32"), script = join(dir, "mic.sh");
  writeFileSync(raw, new Uint8Array(pcm.buffer, pcm.byteOffset, pcm.byteLength));
  writeFileSync(script, `#!/bin/sh
echo "ready stand-in" >&2
sleep 1
echo "hotkey down" >&2
sleep 0.5
cat '${raw}'
sleep 0.5
echo "hotkey up" >&2
cat > /dev/null
`);
  chmodSync(script, 0o755);
  return script;
}

async function runCli(args: string[], env: Record<string, string>) {
  const child = Bun.spawn([process.execPath, "--no-env-file", LAUNCHER, ...args], { env: { PATH: process.env.PATH ?? "", ...env }, stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
  return { stdout, stderr, code };
}

/** `dictate` until it prints a transcript line, then Ctrl-C (main exited 0). */
async function dictate(args: string[], env: Record<string, string>) {
  const child = Bun.spawn([process.execPath, "--no-env-file", LAUNCHER, "dictate", ...args],
    { env: { PATH: process.env.PATH ?? "", ...env }, stdin: "ignore", stdout: "pipe", stderr: "pipe" });
  const stderr = new Response(child.stderr).text();
  let stdout = "";
  const reader = child.stdout.getReader(), decoder = new TextDecoder();
  const deadline = setTimeout(() => child.kill("SIGKILL"), 300_000);
  try {
    while (!stdout.includes("\n")) {
      const next = await reader.read();
      if (next.done) break;
      stdout += decoder.decode(next.value, { stream: true });
    }
    child.kill("SIGINT");
    for (;;) { const next = await reader.read(); if (next.done) break; stdout += decoder.decode(next.value, { stream: true }); }
    return { stdout, stderr: await stderr, code: await child.exited };
  } finally { clearTimeout(deadline); }
}

describe.skipIf(!enabled)("voice verbs over real Whisper weights", () => {
  test("transcribe prints the synthesized words in every format and the VAD gate skips silence", async () => {
    const clip = await speech(mkdtempSync(join(scratch, "speech-")));
    const vad = vadModel(), env = { HOME: cliHome("transcribe-home") };
    const json = await runCli(["transcribe", clip.path, whisperDir!, "--language", "en", "--format", "json"], env);
    expect(json.code, json.stderr).toBe(0);
    expect(missingWords(JSON.parse(json.stdout).text)).toEqual([]);
    const srt = await runCli(["transcribe", clip.path, whisperDir!, "--language", "en", "--format", "srt"], env);
    expect(srt.code, srt.stderr).toBe(0);
    expect(srt.stdout).toContain(" --> ");
    expect(missingWords(srt.stdout)).toEqual([]);
    if (vad) {
      const silence = join(scratch, "silence.wav");
      writeFileSync(silence, wavBytes(new Float32Array(32_000)));
      const gated = await runCli(["transcribe", silence, whisperDir!, "--vad", "--vad-model", vad, "--format", "json"], env);
      expect(gated.code, gated.stderr).toBe(0);
      expect(JSON.parse(gated.stdout)).toEqual({ text: "", vad: { speech: false, segments: [] } });
      const spoken = await runCli(["transcribe", clip.path, whisperDir!, "--language", "en", "--vad", "--vad-model", vad], env);
      expect(spoken.code, spoken.stderr).toBe(0);
      expect(missingWords(spoken.stdout)).toEqual([]);
    } else console.log("[voice] no Silero VAD weights: the transcribe VAD gate is not exercised");
  }, 600_000);

  test("dictate transcribes a held-key take from the capture sidecar with the in-process service", async () => {
    const clip = await speech(mkdtempSync(join(scratch, "speech-")));
    const vad = vadModel();
    const run = await dictate([whisperDir!, ...(vad ? [] : ["--no-vad"]), "--hotkey"],
      { HOME: cliHome("dictate-home"), MLX_BUN_MIC_CAPTURE: micStandIn(clip.samples) });
    expect(run.code, run.stderr).toBe(0);
    expect(missingWords(run.stdout)).toEqual([]);
    expect(run.stderr).toContain("recording");
  }, 600_000);
});

describe.skipIf(!enabled || !chatDir)("a chat server with the Whisper companion", () => {
  test("discovery, the mic probe, idle unload, chat contention, a voice session, unload, and dictate --server", async () => {
    const root = mkdtempSync(join(scratch, "server-"));
    const clip = await speech(root);
    const vad = vadModel();
    let app: RunningApp | undefined;
    try {
      const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
      const { scanSnapshot } = await import("@mlx-bun/hub/registry");
      const model = await scanSnapshot(chatDir!, "test-chat");
      if (!model) throw new Error("Model path has no loadable checkpoint");
      const options = parseServeOptions({ values: { port: "0", "no-open": true, "max-tokens": "48", thinking: "off",
        "whisper-idle-unload": "3" }, positionals: [] });
      options.whisper = { ...options.whisper, modelDir: whisperDir!, modelId: "test-whisper" };
      options.readOnly = true;
      options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
      options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
      options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), jobsLogs: join(root, "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
      mkdirSync(options.chatPaths.cwd!);
      app = await startModelServer(model, options);
      const base = `http://127.0.0.1:${app.port}`;

      const listed = await (await fetch(`${base}/v1/models`)).json();
      expect(listed.data[0].capabilities.transcription).toBe(true);
      expect(listed.data).toContainEqual(expect.objectContaining({ id: "test-whisper", transcription: true, resident: false }));
      // The browser's hold-to-talk button reads the web chat's ready frame.
      const socket = new WebSocket(`${base.replace("http:", "ws:")}/ws/chat`);
      const ready = await new Promise<Record<string, unknown>>((resolve, reject) => {
        socket.addEventListener("message", event => { const frame = JSON.parse(String(event.data)); if (frame.type === "ready") resolve(frame); });
        socket.addEventListener("error", () => reject(new Error("web chat socket failed")));
      });
      socket.close();
      expect(ready.transcription).toBe(true);

      const chatBody = { messages: [{ role: "user", content: "Name three colors of the rainbow." }], max_tokens: 48, temperature: 0, seed: 1 };
      const chat = async () => {
        const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(chatBody) });
        expect(response.status).toBe(200);
        const body = await response.json();
        return { text: String(body.choices[0].message.content ?? ""), finish: body.choices[0].finish_reason };
      };
      const transcribe = async () => {
        const form = new FormData();
        form.set("file", new Blob([clip.bytes as Uint8Array<ArrayBuffer>], { type: "audio/wav" }), "speech.wav");
        form.set("language", "en");
        const response = await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
        expect(response.status).toBe(200);
        return await response.json() as { text: string; mlx_bun: { timings: { load_ms: number } } };
      };
      // The chat server reports the companion's residency on its /v1/models row
      // (its /health carries no transcription block; the transcription-only server's does).
      const resident = async () => ((await (await fetch(`${base}/v1/models`)).json()).data as { id: string; resident?: boolean }[])
        .find(row => row.id === "test-whisper")!.resident;
      const unload = async () => await (await fetch(`${base}/admin/transcription/unload`, { method: "POST" })).json() as
        { unloaded: boolean; resident: boolean; loads: number; unloads: number };
      const solo = await chat();
      expect(solo.text.length).toBeGreaterThan(0);

      // Idle unload: resident after a take, released only after the 3 s idle timeout.
      const first = await transcribe();
      const tookAt = performance.now();
      expect(missingWords(first.text)).toEqual([]);
      expect(first.mlx_bun.timings.load_ms).toBeGreaterThan(0);
      expect(await resident()).toBe(true);
      let released = false;
      while (performance.now() - tookAt < 15_000) {
        if (!(await resident())) { released = true; break; }
        await Bun.sleep(250);
      }
      expect(released).toBe(true);
      expect(performance.now() - tookAt).toBeGreaterThanOrEqual(2_500);
      // The idle timer did the one unload; the route finds nothing resident to release.
      expect(await unload()).toMatchObject({ unloaded: false, resident: false, loads: 1, unloads: 1 });

      // A transcription requested while a chat reply streams: both complete, the reply is unchanged.
      const stream = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ ...chatBody, stream: true }) });
      const reader = stream.body!.getReader(), decoder = new TextDecoder();
      let sse = "", pending: Promise<Awaited<ReturnType<typeof transcribe>>> | undefined;
      for (;;) {
        const next = await reader.read();
        if (next.done) break;
        sse += decoder.decode(next.value, { stream: true });
        if (!pending && sse.includes("\"content\"")) pending = transcribe();
      }
      const streamed = sse.split("\n").filter(line => line.startsWith("data: ") && line !== "data: [DONE]")
        .map(line => JSON.parse(line.slice(6))).map(chunk => chunk.choices?.[0]?.delta?.content ?? "").join("");
      expect(pending).toBeDefined();
      const during = await pending!;
      expect(streamed).toBe(solo.text);
      expect(missingWords(during.text)).toEqual([]);
      expect(during.mlx_bun.timings.load_ms).toBeGreaterThan(0);
      // A chat request admitted while a transcription runs.
      const [, alongside] = await Promise.all([transcribe(), (async () => { await Bun.sleep(50); return chat(); })()]);
      expect(alongside).toEqual(solo);

      // A streaming dictation session: 250 ms float32 chunks, then finish.
      const created = await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ language: "en", vad: !!vad }) });
      expect(created.status).toBe(200);
      const { id } = await created.json();
      for (let at = 0; at < clip.samples.length; at += 4_000) {
        const chunk = clip.samples.slice(at, at + 4_000);
        const fed = await fetch(`${base}/v1/audio/sessions/${id}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" },
          body: new Uint8Array(chunk.buffer) });
        expect(fed.status).toBe(200);
        await fed.body?.cancel();
      }
      const finished = await fetch(`${base}/v1/audio/sessions/${id}/finish`, { method: "POST" });
      expect(finished.status).toBe(200);
      expect(missingWords((await finished.json()).text)).toEqual([]);
      // Finish closes the session; an abandoned one is closed by DELETE.
      expect((await fetch(`${base}/v1/audio/sessions/${id}`, { method: "DELETE" })).status).toBe(404);
      const abandoned = (await (await fetch(`${base}/v1/audio/sessions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ language: "en" }) })).json()).id as string;
      const fedOnce = await fetch(`${base}/v1/audio/sessions/${abandoned}/audio`, { method: "POST", headers: { "content-type": "audio/pcm;rate=16000" },
        body: new Uint8Array(clip.samples.slice(0, 4_000).buffer) });
      expect(fedOnce.status).toBe(200);
      await fedOnce.body?.cancel();
      expect((await fetch(`${base}/v1/audio/sessions/${abandoned}`, { method: "DELETE" })).status).toBe(204);
      expect((await fetch(`${base}/v1/audio/sessions/${abandoned}/finish`, { method: "POST" })).status).toBe(404);

      // dictate's server backend: the same sessions, driven by the verb.
      const remote = await dictate(["--server", base, ...(vad ? [] : ["--no-vad"]), "--hotkey"],
        { HOME: cliHome("dictate-server-home"), MLX_BUN_MIC_CAPTURE: micStandIn(clip.samples) });
      expect(remote.code, remote.stderr).toBe(0);
      expect(missingWords(remote.stdout)).toEqual([]);

      expect((await unload()).resident).toBe(false);
      expect(await resident()).toBe(false);
    } finally {
      try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
    }
  }, 900_000);
});

