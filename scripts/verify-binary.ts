import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { chmod, mkdir, mkdtemp, readFile, readlink, realpath, rename, rm, stat, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { buildBinary, compileApp } from "./build-binary";
import { NATIVE_DIR as MLX_DIR, resolveLibmlxc } from "../packages/mlx/src/native";
import { NATIVE_DIR as INFERENCE_DIR, resolveInferenceNative } from "../packages/inference/src/runtime/native";

if (process.argv.includes("--help")) {
  console.log("Usage: bun scripts/verify-binary.ts [--model CACHED_DIRECTORY]\nBuild, relocate, and exercise the app bundle. Default: CPU only.\n--model additionally runs real GPU inference through the relocated product server; uses cached weights and isolated temporary storage.");
  process.exit(0);
}
const args = process.argv.slice(2);
if (args.length && (args.length !== 2 || args[0] !== "--model" || !args[1]))
  throw new Error("Usage: bun scripts/verify-binary.ts [--model CACHED_DIRECTORY]");
const model = args[1] ? await realpath(args[1]) : undefined;
if (model && (!(await stat(model)).isDirectory() || !existsSync(join(model, "config.json"))))
  throw new Error("--model requires an existing cached model directory with config.json");

async function bounded<T>(work: Promise<T>, milliseconds: number, label: string): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([work, new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error(`${label} timed out`)), milliseconds);
    })]);
  } finally { clearTimeout(timer); }
}

async function verifyModel(executable: string, cachedModel: string, scratch: string, environment: NodeJS.ProcessEnv) {
  const home = join(scratch, "server-home"), hub = join(home, ".cache/huggingface/hub");
  const repo = join(hub, "models--bundle-check--model");
  await mkdir(join(repo, "snapshots"), { recursive: true });
  await mkdir(join(repo, "refs"));
  await symlink(cachedModel, join(repo, "snapshots/local"));
  await writeFile(join(repo, "refs/main"), "local");
  // Only the subprocess sees these isolated locations. Do not inherit overrides
  // that could send jobs, credentials, memory or chat storage to the user's files.
  const env: NodeJS.ProcessEnv = { ...environment };
  for (const key of Object.keys(env)) if (/^(MLX_BUN_|HF_|HUGGING_FACE_|PI_|XDG_)/.test(key)) delete env[key];
  Object.assign(env, { HOME: home, HF_HOME: join(home, ".cache/huggingface"), HF_HUB_CACHE: hub, HF_HUB_OFFLINE: "1",
    XDG_CACHE_HOME: join(home, ".cache"), XDG_CONFIG_HOME: join(home, ".config"),
    XDG_DATA_HOME: join(home, ".local/share"), PI_CODING_AGENT_DIR: join(home, ".pi/agent"),
    TMPDIR: scratch, NO_COLOR: "1" });
  const child = Bun.spawn([executable, "serve", "--model", "bundle-check/model", "--port", "0",
    "--no-open", "--batch", "1", "--max-tokens", "8", "--prompt-cache", "0.125"],
    { cwd: scratch, env, stdout: "pipe", stderr: "pipe" });
  let output = "", errors = "", announce!: (url: string) => void;
  const announced = new Promise<string>(resolve => { announce = resolve; });
  async function collect(stream: ReadableStream<Uint8Array>, stdout: boolean) {
    const reader = stream.getReader(), decoder = new TextDecoder();
    try {
      while (true) {
        const part = await reader.read(); if (part.done) break;
        const text = decoder.decode(part.value, { stream: true });
        if (stdout) {
          output = (output + text).slice(-20000);
          const address = output.match(/API (http:\/\/127\.0\.0\.1:\d+)\/v1/);
          if (address) announce(address[1]!);
        } else errors = (errors + text).slice(-20000);
      }
    } finally { reader.releaseLock(); }
  }
  const readers = Promise.allSettled([collect(child.stdout, true), collect(child.stderr, false)]);
  let failure: unknown;
  try {
    const base = await bounded(Promise.race([announced, child.exited.then(code => {
      throw new Error(`server exited before readiness (${code})`);
    })]), 120000, "compiled server startup");
    const request = (path: string, options: RequestInit = {}) => fetch(new URL(path, base), {
      ...options, signal: AbortSignal.timeout(120000),
    });
    for (const path of ["/", "/assets/app.js", "/assets/hljs.js", "/assets/hljs.css", "/assets/icon.svg", "/manifest.webmanifest", "/sw.js"]) {
      const response = await request(path); assert.equal(response.status, 200, path);
      assert((await response.text()).length > 0, path);
    }
    const stats = await request("/stats"); assert.equal(stats.status, 200);
    const counters = await stats.json(); assert.equal(counters.server.model, "bundle-check/model");
    assert.equal(counters.batch.configured, 1); assert(counters.prompt_cache && counters.response_store);
    const fit = await request("/fit"); assert.equal(fit.status, 200);
    const report = await fit.json(); assert(report.machine && Number.isFinite(report.report.weights_bytes));
    const completion = await request("/v1/chat/completions", { method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [{ role: "user", content: "Say hello in one sentence." }], temperature: 0, max_tokens: 8 }) });
    assert.equal(completion.status, 200, await completion.clone().text());
    const result = await completion.json(); assert.equal(result.choices?.length, 1);
    assert(result.usage?.completion_tokens > 0);
    child.kill("SIGTERM");
    assert.equal(await bounded(child.exited, 30000, "compiled server shutdown"), 0);
  } catch (error) {
    failure = error;
  } finally {
    if (child.exitCode === null && child.signalCode === null) child.kill("SIGKILL");
    try {
      await bounded(child.exited, 10000, "compiled server kill/join");
      for (const result of await bounded(readers, 10000, "compiled server output drain"))
        if (result.status === "rejected") throw result.reason;
    } catch (error) {
      failure = failure ? new AggregateError([failure, error], "verification and cleanup failed") : error;
    }
  }
  if (failure) throw new Error(`Compiled model verification failed: ${failure instanceof Error ? failure.message : String(failure)}\n${output}\n${errors}`, { cause: failure });
  console.log("Actual relocated server: embedded web, stats, fit, chat completion and clean SIGTERM passed.");
}
const root = resolve(import.meta.dir, ".."), temporary = await mkdtemp(join(tmpdir(), "mlx-bundle-"));
try {
  const override = process.env.MLX_BUN_LIBMLXC;
  try {
    delete process.env.MLX_BUN_LIBMLXC;
    assert.equal(resolveLibmlxc(), join(MLX_DIR, "libmlxc.dylib"), "source execution uses its package native directory");
    process.env.MLX_BUN_LIBMLXC = "/explicit/override.dylib";
    assert.equal(resolveLibmlxc(), "/explicit/override.dylib");
    assert.equal(resolveInferenceNative("mlx-bun-frame-extract"), join(INFERENCE_DIR, "mlx-bun-frame-extract"));
  } finally {
    if (override === undefined) delete process.env.MLX_BUN_LIBMLXC; else process.env.MLX_BUN_LIBMLXC = override;
  }
  const original = join(temporary, "built"), relocated = join(temporary, "relocated"), scratch = join(temporary, "data");
  await mkdir(scratch);
  await buildBinary(original);
  await compileApp(join(root, "apps/mlx-bun/tests/compiled-consumer.ts"), join(original, "verify-consumer"));
  await rename(original, relocated);
  assert(!existsSync(original), "original bundle must be unavailable after relocation");
  const notices = await readFile(join(relocated, "THIRD_PARTY_NOTICES.md"), "utf8");
  for (const name of ["mlx", "inference"]) {
    const source = await readFile(join(root, "packages", name, "THIRD_PARTY_NOTICES.md"), "utf8");
    assert(source.trim().length > 0, `${name} source notices must not be empty`);
    assert(notices.includes(source), `relocated bundle must retain the complete ${name} notices`);
  }
  const env = { ...process.env, MLX_BUN_LIBMLXC: "", MLX_BUN_EXPERT_IO_DYLIB: "", MLX_BUN_FRAME_EXTRACT: "", MLX_BUN_MIC_CAPTURE: "" };
  async function run(command: string[], environment: NodeJS.ProcessEnv = env): Promise<string> {
    const child = Bun.spawn(command, { cwd: scratch, env: environment, stdout: "pipe", stderr: "pipe" });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    assert.equal(code, 0, `${command[0]} failed: ${out}\n${err}`);
    return out;
  }
  const executable = join(relocated, "mlx-bun");
  assert((await run([executable, "--version"])).startsWith("mlx-bun "));
  assert((await run([executable, "--help"])).includes("Usage: mlx-bun"));
  console.log(await run([join(relocated, "verify-consumer"), scratch]));
  // Exercise the same real binaries through the installer's directory and
  // command symlinks. The curl stub supplies our local archive, never a network.
  const installHome = join(temporary, "install home"), transport = join(temporary, "transport");
  await mkdir(installHome); await mkdir(transport);
  const archive = join(temporary, "bundle.tar.gz");
  await run(["tar", "-czf", archive, "-C", relocated, "."]);
  const curl = join(transport, "curl");
  await writeFile(curl, `#!/bin/sh
set -eu
while [ "$#" -gt 0 ]; do
  if [ "$1" = -o ]; then shift; output="$1"; fi
  shift
done
cp "$MLX_BUN_TEST_ARCHIVE" "$output"
`);
  await chmod(curl, 0o755);
  const version = JSON.parse(await readFile(join(root, "apps/mlx-bun/package.json"), "utf8")).version;
  const installEnvironment = { ...env, HOME: installHome,
    PATH: `${transport}:${process.env.PATH}`, MLX_BUN_INSTALL_DIR: join(installHome, ".mlx-bun"),
    MLX_BUN_VERSION: `v${version}`, MLX_BUN_TEST_ARCHIVE: archive };
  await run(["/bin/sh", join(root, "scripts/install.sh")], installEnvironment);
  assert.equal(await run([join(installHome, ".local/bin/mlx-bun"), "--version"]), `mlx-bun ${version}\n`);
  const installedScratch = join(temporary, "installed consumer"); await mkdir(installedScratch);
  console.log(await run([join(installHome, ".mlx-bun/app-install/current/verify-consumer"), installedScratch]));
  const previous = await readlink(join(installHome, ".mlx-bun/app-install/current"));
  await run(["/bin/sh", join(root, "scripts/install.sh")], installEnvironment);
  // Managed jobs from a process started before the upgrade still use its old
  // canonical executable. Exercise that retained bundle's actual reentry.
  const previousScratch = join(temporary, "previous consumer"); await mkdir(previousScratch);
  console.log(await run([join(installHome, ".mlx-bun/app-install", previous, "verify-consumer"), previousScratch]));
  console.log("Local installer: actual compiled app, assets and managed child passed through installed symlinks (CPU only).");
  if (model) await verifyModel(executable, model, scratch, env);
} finally { await rm(temporary, { recursive: true, force: true }); }
