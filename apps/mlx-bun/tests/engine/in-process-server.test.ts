// Opt-in with real weights: the public `mlx-bun/server` entry over a real
// loaded context. Runs only with MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_APP_TEST_MODEL naming a cached chat snapshot directory (e.g. the
// MiniCPM checkpoint the HTTP smoke uses); it never downloads and loads the
// model natively on the GPU. The consumer runs in a child Bun process whose
// HOME is temporary, with XDG_*, HF_HOME, and MLX_BUN_* settings removed
// (MLX_BUN_LIBMLXC is kept), HF_HUB_CACHE naming the real hub cache (only
// read), and HF_HUB_OFFLINE=1, so every default store opens under the temporary
// HOME; the real-HOME check is names-only. It checks the entry's contract
// (supplied binding and prompt builder on the real engine, the full app,
// shutdown evidence, a borrowed context reused), not parity or speed.
import { expect, test } from "bun:test";
import { existsSync, mkdtempSync, readdirSync, rmSync, statSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;
const packageRoot = resolve(import.meta.dir, "../..");
const realHome = homedir();
const hubCache = process.env.HF_HUB_CACHE ?? (process.env.HF_HOME ? join(process.env.HF_HOME, "hub") : join(realHome, ".cache/huggingface/hub"));

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

const consumer = `
const { createServer, loadContext } = await import("mlx-bun/server");
// The default numerics and prompts, wrapped by the caller: the supplied pair must be what serves.
const { modelServingBinding } = await import(${JSON.stringify(join(packageRoot, "src/engine/model-serving.ts"))});
const { modelPromptBuilder } = await import(${JSON.stringify(join(packageRoot, "src/server/prompt-builder.ts"))});
const out = {}, root = process.env.SERVER_TEST_ROOT;
const context = await loadContext(process.env.SERVER_TEST_MODEL, "test-model");
const base = await modelServingBinding(context);
let plans = 0, built = 0;
const gateway = Object.create(base.gateway);
gateway.plan = (...args) => { plans++; return base.gateway.plan(...args); };
const binding = { ...base, stateCompatibility: "caller-" + base.stateCompatibility, gateway,
  diagnostics: () => ({ ...base.diagnostics(), caller_binding: { plans } }) };
const defaultPrompt = modelPromptBuilder(context);
const buildPrompt = (...args) => { built++; return defaultPrompt(...args); };
const post = (url, path, body, signal) => fetch(url + path, { method: "POST", signal, headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
const hello = { messages: [{ role: "user", content: "Say hello in one sentence." }], max_tokens: 8, temperature: 0 };
let server = await createServer(context, 0, { hostname: "127.0.0.1", binding, buildPrompt, capacity: 2,
  cache: { promptCacheBytes: 0.125 * 2 ** 30, ssdCacheDir: root + "/ssd" }, artifact: { path: process.env.SERVER_TEST_MODEL } });
try {
  const url = "http://127.0.0.1:" + server.port;
  const first = await (await post(url, "/v1/chat/completions", hello)).json();
  out.completion = { content: first.choices?.[0]?.message?.content ?? null, plans, built };
  const stats = await (await fetch(url + "/stats")).json();
  out.stats = { owner: stats.server.owner, model: stats.server.model, caller: stats.caller_binding, ssd: stats.ssd_cache?.dir === root + "/ssd" };
  const page = await fetch(url + "/");
  out.page = { status: page.status, type: page.headers.get("content-type") }; await page.arrayBuffer();
  out.jobs = await (await fetch(url + "/api/jobs")).json();
  // Pi web chat answers on /ws/chat with its ready frame.
  out.socket = await new Promise(resolve => {
    const socket = new WebSocket(url.replace("http:", "ws:") + "/ws/chat");
    const done = value => { clearTimeout(timer); socket.close(); resolve(value); };
    const timer = setTimeout(() => done("timeout"), 60_000);
    socket.addEventListener("message", event => { const frame = JSON.parse(event.data); if (frame.type === "ready" || frame.type === "error") done(frame.type); });
    socket.addEventListener("error", () => done("error"));
  });
  out.flush = await server.flush();
  // A long stream is running when close starts: the deadline reports it, releases nothing, and the drain waits for it.
  const streamed = await post(url, "/v1/chat/completions", { stream: true, max_tokens: 2048, temperature: 0,
    messages: [{ role: "user", content: "Count from 1 to 100000, one number per line. Do not stop early." }] });
  const reader = streamed.body.getReader();
  out.streamed = { status: streamed.status, first: !(await reader.read()).done };
  const timed = await server.close({ timeoutMs: 20 });
  out.timed = { stopped: timed.stopped, timedOut: timed.timedOut, durable: timed.durability.durable };
  await reader.cancel();
  const closed = await server.close({ timeoutMs: Infinity });
  out.closed = { stopped: closed.stopped, timedOut: closed.timedOut, durable: closed.durability.durable,
    pendingSpills: closed.durability.pendingSpills, failedSpills: closed.durability.failedSpills };
  out.refused = await fetch(url + "/health").then(() => "served", () => "refused");
  // The borrowed context serves a second server with the default binding: the same greedy reply.
  server = await createServer(context, 0, { hostname: "127.0.0.1" });
  const again = await (await post("http://127.0.0.1:" + server.port, "/v1/chat/completions", hello)).json();
  out.second = { same: again.choices?.[0]?.message?.content === out.completion.content };
  out.secondClosed = (await server.close()).stopped;
} finally {
  await server.close({ timeoutMs: Infinity }).catch(() => {});
  context.dispose();
}
console.log("RESULT " + JSON.stringify(out));
`;

test.skipIf(!native || !modelDir)("the in-process server entry serves a real context through a caller binding and reuses it after close", async () => {
  const scratch = mkdtempSync(join(tmpdir(), "mlx-server-native-"));
  const home = join(scratch, "home");
  const env: Record<string, string> = {};
  for (const [name, value] of Object.entries(process.env)) {
    if (value === undefined || name.startsWith("XDG_") || name === "HF_HOME" || name === "HF_HUB_CACHE") continue;
    if (name.startsWith("MLX_BUN_") && name !== "MLX_BUN_LIBMLXC") continue;
    env[name] = value;
  }
  const before = storeNames(realHome);
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e", consumer], { cwd: packageRoot, stdout: "pipe", stderr: "pipe",
    env: { ...env, HOME: home, HF_HUB_CACHE: hubCache, HF_HUB_OFFLINE: "1", SERVER_TEST_MODEL: modelDir!, SERVER_TEST_ROOT: scratch } });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 170_000);
  try {
    const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
    const line = stdout.split("\n").find(text => text.startsWith("RESULT "));
    if (code !== 0 || !line) throw new Error(`consumer exited ${code}\n${stdout}\n${stderr}`);
    const out = JSON.parse(line.slice(7));
    expect(out.completion.content.trim().length).toBeGreaterThan(0);
    expect(out.completion.plans).toBeGreaterThan(0);
    expect(out.completion.built).toBeGreaterThan(0);
    expect({ ...out.stats, caller: undefined }).toEqual({ owner: "embedded", model: "test-model", caller: undefined, ssd: true });
    expect(out.stats.caller.plans).toBeGreaterThan(0);
    expect(out.page).toEqual({ status: 200, type: "text/html; charset=utf-8" });
    expect(out.jobs).toEqual({ ok: true, jobs: [] });
    expect(out.socket).toBe("ready");
    expect(out.flush.durable).toBe(true);
    expect(out.streamed).toEqual({ status: 200, first: true });
    expect(out.timed).toEqual({ stopped: false, timedOut: true, durable: false });
    expect(out.closed).toEqual({ stopped: true, timedOut: false, durable: true, pendingSpills: 0, failedSpills: 0 });
    expect(out.refused).toBe("refused");
    expect(out.second).toEqual({ same: true });
    expect(out.secondClosed).toBe(true);
    expect(storeNames(realHome)).toEqual(before);
  } finally {
    clearTimeout(deadline);
    rmSync(scratch, { recursive: true, force: true });
  }
}, 180_000);
