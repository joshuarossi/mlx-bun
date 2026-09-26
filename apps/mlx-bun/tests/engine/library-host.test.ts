// Opt-in with real weights: main's library-host acceptance through the public
// `mlx-bun/engine` entry. Runs only with MLX_BUN_TEST_NATIVE=1; each case runs
// when its cached snapshot directory is named, and its worker loads the model
// natively on the GPU:
//   MLX_BUN_APP_TEST_MODEL          a chat model (e.g. the MiniCPM checkpoint):
//                                   the source CLI command, then a standalone CLI
//                                   built from the staged natives (scripts/build-binary.ts)
//                                   and passed as an explicit `command`
//   MLX_BUN_APP_TEST_WHISPER_MODEL  a Whisper checkpoint (transcription-only app)
// Each consumer runs in a child Bun process whose HOME is a temporary directory,
// with XDG_*, HF_HOME, and MLX_BUN_* settings removed (MLX_BUN_LIBMLXC is kept
// for the source command only), HF_HUB_CACHE naming the real hub cache (only
// read), and HF_HUB_OFFLINE=1, so the full app's jobs, sessions, and memory
// stores open under the temporary HOME. The real-HOME check is a names-only
// guard: the entry names two levels under the real `.mlx-bun` and
// `.cache/mlx-bun` must not change; it does not prove existing contents are
// unchanged. The consumer closes its host in `finally`; on any failure or
// timeout the test kills the consumer, waits for its worker to leave on the
// end of its stdin (the app form's behavior, covered by tests/worker-entry.test.ts),
// kills a worker that has not left, and only then removes the temporary HOME.
// It checks the host contract and routing, not generated text or parity.
import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, statSync, symlinkSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const chatModel = process.env.MLX_BUN_APP_TEST_MODEL;
const whisperModel = process.env.MLX_BUN_APP_TEST_WHISPER_MODEL;
const packageRoot = resolve(import.meta.dir, "../..");
const workspace = resolve(packageRoot, "../..");
const realHome = homedir();
const hubCache = process.env.HF_HUB_CACHE ?? (process.env.HF_HOME ? join(process.env.HF_HOME, "hub") : join(realHome, ".cache/huggingface/hub"));
const scratch = mkdtempSync(join(tmpdir(), "mlx-engine-native-"));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));

/** Entry names two levels under a HOME's app stores (names only). */
function storeNames(home: string): string[] {
  const out: string[] = [];
  for (const root of [".mlx-bun", ".cache/mlx-bun"]) {
    const top = join(home, root);
    if (!existsSync(top)) { out.push(`${root} (absent)`); continue; }
    for (const name of readdirSync(top)) {
      out.push(join(root, name));
      const path = join(top, name);
      if (statSync(path).isDirectory()) for (const child of readdirSync(path)) out.push(join(root, name, child));
    }
  }
  return out.sort();
}

/** The consumer's environment: a temporary HOME and no storage overrides. */
function isolatedEnv(home: string, extra: Record<string, string>, keepLibmlxc: boolean): Record<string, string> {
  const env: Record<string, string> = {};
  for (const [name, value] of Object.entries(process.env)) {
    if (value === undefined || name.startsWith("XDG_") || name === "HF_HOME" || name === "HF_HUB_CACHE") continue;
    if (name.startsWith("MLX_BUN_") && !(keepLibmlxc && name === "MLX_BUN_LIBMLXC")) continue;
    env[name] = value;
  }
  return { ...env, HOME: home, HF_HUB_CACHE: hubCache, HF_HUB_OFFLINE: "1", ...extra };
}

const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch (error) { return (error as { code?: string }).code !== "ESRCH"; } };
async function survivors(pids: Iterable<number>, timeoutMs: number): Promise<number[]> {
  const end = Date.now() + timeoutMs;
  let left = [...pids].filter(alive);
  while (left.length && Date.now() < end) { await Bun.sleep(250); left = left.filter(alive); }
  return left;
}

// The consumer: imports the entry through the export map, prints its worker's
// pid once serving, and prints one result line.
const consumer = `
const { openIsolatedHost, createCompletionClient } = await import("mlx-bun/engine");
const kind = process.env.ENGINE_TEST_KIND, model = process.env.ENGINE_TEST_MODEL;
const command = process.env.ENGINE_TEST_COMMAND ? JSON.parse(process.env.ENGINE_TEST_COMMAND) : undefined;
const out = {};
const get = async (host, path) => { const response = await host.forward(new Request("http://engine" + path));
  return { status: response.status, type: response.headers.get("content-type"), body: await response.json() }; };
const host = await openIsolatedHost(model, { arguments: ["--max-tokens", "64"], readyTimeoutMs: 600_000, ...(command ? { command } : {}) });
try {
  await host.ready;
  out.health = await get(host, "/health");
  console.log("WORKER " + out.health.body.pid);
  const client = createCompletionClient({ baseUrl: "http://engine/v1", host });
  if (kind === "chat" || kind === "compiled") {
    const result = await client.complete({ body: { messages: [{ role: "user", content: "Say hello." }], max_tokens: 8, temperature: 0 } });
    out.completion = { choices: result.choices.length, content: result.choices[0]?.message?.content ?? null };
  }
  if (kind === "chat") {
    out.library = await get(host, "/library");
    out.jobs = await get(host, "/api/jobs");
    // A stream that cannot finish soon: read until generated content arrives, with no terminal frame yet.
    const limit = (await get(host, "/stats")).body.admission?.enforced_context_tokens;
    const maxTokens = typeof limit === "number" ? Math.max(256, Math.min(2048, limit - 256)) : 2048;
    const abort = new AbortController();
    const streamed = await host.forward(new Request("http://engine/v1/chat/completions", { method: "POST", signal: abort.signal,
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ stream: true, max_tokens: maxTokens, temperature: 0,
        messages: [{ role: "user", content: "Count from 1 to 100000, one number per line. Do not stop early and do not write anything else." }] }) }));
    out.stream = { status: streamed.status, maxTokens };
    const reader = streamed.body.getReader(), decoder = new TextDecoder();
    let buffered = "", content = "", terminal = false;
    while (!content && !terminal) {
      const item = await reader.read();
      if (item.done) { terminal = true; break; }
      buffered += decoder.decode(item.value, { stream: true });
      for (let end; (end = buffered.indexOf("\\n\\n")) !== -1; buffered = buffered.slice(end + 2)) {
        for (const line of buffered.slice(0, end).split("\\n")) {
          if (!line.startsWith("data: ")) continue;
          if (line === "data: [DONE]") { terminal = true; continue; }
          const chunk = JSON.parse(line.slice(6));
          for (const choice of chunk.choices ?? []) { if (choice.finish_reason) terminal = true; content += choice.delta?.content ?? ""; }
        }
      }
    }
    const before = (await get(host, "/stats")).body.batch;
    out.beforeAbort = { content: content.length, terminal, active_rows: before?.active_rows, pending_rows: before?.pending_rows };
    const abortedAt = Date.now();
    abort.abort(new Error("consumer left"));
    // The consumer's stream ends (already buffered frames may still be read first).
    out.streamEnd = await (async () => {
      const end = Date.now() + 10_000;
      for (;;) {
        if (Date.now() > end) return "still open";
        try { if ((await reader.read()).done) return "done"; } catch { return "rejected"; }
      }
    })();
    let batch;
    for (const end = Date.now() + 15_000; Date.now() < end; await Bun.sleep(100)) {
      batch = (await get(host, "/stats")).body.batch;
      if (batch?.active_rows === 0 && batch?.pending_rows === 0) break;
    }
    out.afterAbort = { active_rows: batch?.active_rows, pending_rows: batch?.pending_rows, ms: Date.now() - abortedAt };
    out.servesAfterAbort = (await client.complete({ body: { messages: [{ role: "user", content: "Say yes." }], max_tokens: 4, temperature: 0 } })).choices.length;
  }
  if (kind === "whisper") {
    // One second of a 440 Hz tone, 16-bit mono PCM at 16 kHz.
    const rate = 16000, frames = rate, buffer = new ArrayBuffer(44 + frames * 2), view = new DataView(buffer);
    const ascii = (offset, text) => { for (let i = 0; i < text.length; i++) view.setUint8(offset + i, text.charCodeAt(i)); };
    ascii(0, "RIFF"); view.setUint32(4, 36 + frames * 2, true); ascii(8, "WAVE"); ascii(12, "fmt ");
    view.setUint32(16, 16, true); view.setUint16(20, 1, true); view.setUint16(22, 1, true); view.setUint32(24, rate, true);
    view.setUint32(28, rate * 2, true); view.setUint16(32, 2, true); view.setUint16(34, 16, true); ascii(36, "data"); view.setUint32(40, frames * 2, true);
    for (let i = 0; i < frames; i++) view.setInt16(44 + i * 2, Math.round(Math.sin(2 * Math.PI * 440 * i / rate) * 0.3 * 32767), true);
    const form = new FormData();
    form.append("file", new Blob([buffer], { type: "audio/wav" }), "tone.wav");
    form.append("response_format", "json");
    const response = await host.forward(new Request("http://engine/v1/audio/transcriptions", { method: "POST", body: form }));
    out.transcription = { status: response.status, body: await response.json() };
  }
} finally { await host.close(); }
out.closed = await host.forward(new Request("http://engine/health")).then(() => "served", error => error.message);
console.log("RESULT " + JSON.stringify(out));
`;

/** Runs one consumer and always cleans up: the consumer is killed and joined,
 * its workers must leave (a worker left behind is killed and fails the test),
 * and only then is the temporary HOME removed. */
/** A process's descendants, deepest last (pgrep over the live tree). */
function descendants(pid: number): number[] {
  const children = Bun.spawnSync(["pgrep", "-P", String(pid)]).stdout.toString().split(/\s+/).filter(Boolean).map(Number);
  return children.flatMap(child => [child, ...descendants(child)]);
}

async function runConsumer(kind: "chat" | "whisper" | "compiled", modelDir: string, command?: string[],
  /** Hugging Face snapshots main reads from $HOME/.cache/huggingface/hub (not HF_HUB_CACHE),
   *  linked read-only into the temporary HOME. */
  homeHub: string[] = []) {
  const home = mkdtempSync(join(scratch, "home-"));
  for (const repo of homeHub) {
    const source = join(hubCache, repo);
    if (!existsSync(source)) continue;
    mkdirSync(join(home, ".cache/huggingface/hub"), { recursive: true });
    symlinkSync(source, join(home, ".cache/huggingface/hub", repo));
  }
  const before = storeNames(realHome);
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e", consumer], { cwd: packageRoot, stdout: "pipe", stderr: "pipe",
    env: isolatedEnv(home, { ENGINE_TEST_KIND: kind, ENGINE_TEST_MODEL: modelDir, ...(command ? { ENGINE_TEST_COMMAND: JSON.stringify(command) } : {}) }, !command) });
  const workers = new Set<number>();
  let stdout = "", stderr = "";
  const collect = async (stream: ReadableStream<Uint8Array>, append: (text: string) => void) => {
    const reader = stream.getReader(), decoder = new TextDecoder();
    for (;;) { const { done, value } = await reader.read(); if (done) return; append(decoder.decode(value, { stream: true })); }
  };
  const readers = Promise.allSettled([
    collect(child.stdout, text => { stdout += text; for (const match of stdout.matchAll(/^WORKER (\d+)$/gm)) workers.add(Number(match[1])); }),
    collect(child.stderr, text => { stderr = (stderr + text).slice(-20_000); }),
  ]);
  const running = () => child.exitCode === null && child.signalCode === null;
  // The worker is the consumer's direct child: record it while the consumer lives, before it has reported ready too.
  const recordWorkers = () => {
    if (!running()) return;
    for (const pid of Bun.spawnSync(["pgrep", "-P", String(child.pid)]).stdout.toString().split(/\s+/).filter(Boolean)) workers.add(Number(pid));
  };
  const watch = setInterval(recordWorkers, 500);
  const stop = () => { if (running()) { recordWorkers(); child.kill("SIGKILL"); } };
  const deadline = setTimeout(stop, 12 * 60_000);
  let result: Record<string, any> | undefined, failure: unknown;
  try {
    const code = await child.exited;
    await Promise.race([readers, Bun.sleep(10_000)]);
    const line = stdout.split("\n").find(item => item.startsWith("RESULT "));
    if (code !== 0 || !line) throw new Error(`consumer exited ${code ?? child.signalCode}\n${stdout.slice(-20_000)}\n${stderr}`);
    result = JSON.parse(line.slice("RESULT ".length));
  } catch (error) { failure = error; }
  clearTimeout(deadline); clearInterval(watch);
  stop();
  await child.exited;
  // A worker leaves on the end of its stdin; one still alive after the app's shutdown budget is killed.
  const left = await survivors(workers, 180_000);
  for (const pid of left) { try { process.kill(pid, "SIGKILL"); } catch { /* gone */ } }
  // Never delete a HOME a worker may still be using: every tracked worker must be gone first.
  const remaining = await survivors(left, 10_000);
  if (remaining.length)
    throw new Error(`workers ${remaining.join(", ")} outlived their consumer; kept ${home}` + (failure ? `\nconsumer failure: ${failure}` : ""));
  const homeStores = storeNames(home);
  rmSync(home, { recursive: true, force: true });
  if (failure) throw failure;
  expect({ workers: workers.size > 0, left }).toEqual({ workers: true, left: [] });
  expect(storeNames(realHome)).toEqual(before);
  return { homeStores, result: result! };
}

test.skipIf(!native || !chatModel)("openIsolatedHost serves the full app to a native-free consumer: completion, library, jobs, an aborted stream, and close", async () => {
  const { homeStores, result } = await runConsumer("chat", chatModel!);
  expect(result.health).toMatchObject({ status: 200, body: { status: "ok" } });
  expect(result.completion.choices).toBe(1);
  expect(result.library.status).toBe(200);
  expect(result.library.type).toContain("application/json");
  expect(result.jobs).toMatchObject({ status: 200, body: { ok: true, jobs: [] } });
  expect(result.stream.status).toBe(200);
  // Before the abort: generated content, no finish_reason or [DONE], and the row admitted in the batch.
  expect(result.beforeAbort.content).toBeGreaterThan(0);
  expect(result.beforeAbort.terminal).toBe(false);
  expect(result.beforeAbort.active_rows).toBeGreaterThan(0);
  // After it: the consumer's stream ends, /stats reports an empty batch within 15 s, and the next completion succeeds.
  expect(result.streamEnd).not.toBe("still open");
  expect(result.afterAbort).toMatchObject({ active_rows: 0, pending_rows: 0 });
  expect(result.afterAbort.ms).toBeLessThan(15_000);
  expect(result.servesAfterAbort).toBe(1);
  expect(result.closed).toBe("engine host is closed");
  // The app's jobs store opened under the temporary HOME.
  expect(homeStores).toContain(".cache/mlx-bun/jobs.sqlite");
}, 20 * 60_000);

test.skipIf(!native || !chatModel)("openIsolatedHost runs a standalone CLI built from the staged natives as an explicit command", async () => {
  const bundle = join(scratch, "bundle");
  const build = Bun.spawn([process.execPath, join(workspace, "scripts/build-binary.ts"), bundle], { cwd: workspace, stdout: "pipe", stderr: "pipe" });
  // The wrapper runs `bun build --compile` as its own child, which shares its
  // output pipes: track the whole tree, and on timeout or failure stop and
  // join every descendant before reading the pipes or touching the scratch.
  const tree = new Set<number>();
  const track = () => { for (const pid of descendants(build.pid)) tree.add(pid); };
  const watch = setInterval(track, 250);
  const stopBuild = () => {
    track();
    for (const pid of [...tree].reverse()) { try { process.kill(pid, "SIGKILL"); } catch { /* gone */ } }
    build.kill("SIGKILL");
  };
  const timer = setTimeout(stopBuild, 10 * 60_000);
  let stdout = "", stderr = "";
  const readers = Promise.allSettled([new Response(build.stdout).text().then(text => { stdout = text; }),
    new Response(build.stderr).text().then(text => { stderr = text; })]);
  let code: number | null = null;
  try { code = await build.exited; }
  finally {
    clearTimeout(timer); clearInterval(watch);
    stopBuild();
    await build.exited;
    const left = await survivors(tree, 10_000);
    if (left.length) throw new Error(`the standalone build left processes running: ${left.join(", ")}`);
    await Promise.race([readers, Bun.sleep(10_000)]);
  }
  if (code !== 0) throw new Error(`standalone build failed (${code ?? build.signalCode})\n${stdout}\n${stderr}`);
  const executable = join(bundle, "mlx-bun");
  expect(existsSync(executable)).toBe(true);
  const { result } = await runConsumer("compiled", chatModel!, [executable]);
  expect(result.health).toMatchObject({ status: 200, body: { status: "ok" } });
  expect(result.completion.choices).toBe(1);
  expect(result.closed).toBe("engine host is closed");
}, 30 * 60_000);

test.skipIf(!native || !whisperModel)("openIsolatedHost serves a Whisper checkpoint as the transcription-only app and transcribes a WAV through forward", async () => {
  const { result } = await runConsumer("whisper", whisperModel!, undefined,
    ["models--openai--whisper-large-v3-turbo", "models--openai--whisper-large-v3", "models--ggml-org--whisper-vad"]);
  expect(result.health.status).toBe(200);
  expect(result.transcription.status, JSON.stringify(result.transcription.body)).toBe(200);
  expect(typeof result.transcription.body.text).toBe("string");
  expect(result.transcription.body.mlx_bun.duration).toBeGreaterThan(0);
  expect(result.closed).toBe("engine host is closed");
}, 20 * 60_000);
