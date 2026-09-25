import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createQuantizeRunner } from "../src/quantize/job";
import { parseConvertArgs, runConvert, type ConvertDependencies } from "../src/cli/convert";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const parse = (...args: string[]) => parseConvertArgs(args);
const plain = (text: string) => text.replace(/\x1b\[[0-9;]*m/g, "");

/** Injected owners record their call order; presentation is captured without ANSI. */
function harness(input: { token?: string | null; models?: Partial<ModelRecord>[]; downloaded?: string } = {}) {
  const lines: string[] = [], order: string[] = [], runs: { config: Record<string, unknown>; signal?: AbortSignal }[] = [];
  const downloads: { repoId: string; signal?: AbortSignal }[] = [], publishes: unknown[] = [];
  const models = (input.models ?? []) as ModelRecord[];
  let scanned = false, closed = 0;
  const registry = {
    list: () => (scanned ? models : []),
    async scan() { scanned = true; order.push("scan"); return models.length; },
    resolve(query: string) {
      const hit = models.find(model => model.repoId.includes(query));
      if (!hit) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
      return hit;
    },
    close() { closed++; },
  };
  const deps: ConvertDependencies = {
    async quantize(config, outDir, progress, signal) {
      order.push("runner"); runs.push({ config, signal });
      progress("Module 1/2"); progress("Quantized 2 modules (4.50 bpw)");
      return { outputPath: outDir };
    },
    async download(repoId, options) {
      order.push("download"); downloads.push({ repoId, signal: options.signal });
      options.onProgress("model.safetensors", 512, 1024);
      return input.downloaded ?? "/downloaded/snapshot";
    },
    registry: () => { order.push("registry"); return registry; },
    credentials: () => ({ get() { order.push("credentials"); return input.token === undefined ? "hf_token" : input.token; } }),
    async publish(request) { order.push("publish"); publishes.push(request); return { url: "https://huggingface.co/org/quant" }; },
    step: text => { lines.push(`step: ${plain(text)}`); return {
      update: t => { lines.push(`update: ${plain(t)}`); }, done: t => { lines.push(`done: ${plain(t ?? text)}`); }, fail: t => { lines.push(`fail: ${plain(t ?? text)}`); } }; },
    box: rows => { lines.push(`box: ${rows.map(plain).join(" | ")}`); },
    log: (line = "") => { lines.push(`log: ${plain(line)}`); },
  };
  return { deps, lines, order, runs, downloads, publishes, closed: () => closed };
}
function workspace() {
  const root = mkdtempSync(join(tmpdir(), "mlx-convert-")), local = join(root, "src"), out = join(root, "out");
  mkdirSync(local); writeFileSync(join(local, "config.json"), JSON.stringify({ model_type: "qwen3" }));
  return { root, local, out };
}

test("main's refusals and validation messages fire before any registry, download, or producer work", async () => {
  const cases: [string[], string][] = [
    [["--hf-path", "x", "-q", "--dtype", "float16"], "--dtype: not supported (mixed precision: --target-bpw; see: mlx-bun help convert)"],
    [["--hf-path", "x", "-q", "-d"], "--dequantize: not supported (mixed precision: --target-bpw; see: mlx-bun help convert)"],
    [["--hf-path", "x", "-q", "--dequantize"], "--dequantize: not supported"],
    [["--hf-path", "x", "-q", "--quant-predicate", "mixed_4_6"], "--quant-predicate: not supported"],
    [["--hf-path", "x", "-q", "--dtype", "f", "--quant-predicate", "p"], "--dtype, --quant-predicate: not supported"],
    [["--hf-path", "x", "-q", "--q-mode", "mxfp4"], '--q-mode mxfp4: only "affine" is supported'],
    [["-q"], "usage: mlx-bun convert --hf-path <repo-or-path> -q [--q-bits N] [--q-group-size N] [--mlx-path <dir>] [--target-bpw F]"],
    [["--hf-path", "x"], "plain (non-quantizing) conversion is not supported yet — pass -q or --target-bpw"],
    [["--model", "x"], "pass -q or --target-bpw"],
    [["x", "--target-bpw", "abc"], '--target-bpw expects a positive number (got "abc")'],
    [["x", "--target-bpw", "0"], '--target-bpw expects a positive number (got "0")'],
    [["x", "-q", "--q-bits", "3"], '--q-bits must be 4 or 8 (got "3")'],
    [["x", "-q", "--q-group-size", "128"], '--q-group-size must be 32 or 64 (got "128")'],
    [["x", "-q", "--candidate-bits", "4,9"], '--candidate-bits expects a comma list of integers in [2, 8] (got "4,9")'],
    [["x", "-q", "--rotate-weights", "--rotation-seed", "not-an-integer"], '--rotation-seed expects an integer (got "not-an-integer")'],
    [["x", "-q", "--rotation-seed", "1.5"], '--rotation-seed expects an integer (got "1.5")'],
  ];
  for (const [args, expected] of cases) {
    const run = harness();
    await expect(runConvert(parse(...args), run.deps)).rejects.toThrow(expected);
    expect(run.order).toEqual([]);
  }
  expect(() => parse("--hf-path", "x", "-q", "--upload-repo")).toThrow("--upload-repo expects a repo id (org/name)");
  expect(() => parse("--hf-path", "x", "--upload-repo", "-q")).toThrow("--upload-repo expects a repo id (org/name)");
  expect(() => parse("x", "-q", "--serial")).toThrow();
  expect(() => parse("x", "y", "-q")).toThrow("Too many arguments for convert");
  const aborted = harness();
  await expect(runConvert(parse("example/tiny", "-q"), aborted.deps, AbortSignal.abort(new Error("convert cancelled")))).rejects.toThrow("convert cancelled");
  expect(aborted.order).toEqual([]);
});

test("an existing --mlx-path is refused before any work; the default output is mlx_model", async () => {
  const { root, local, out } = workspace();
  try {
    const taken = harness();
    await expect(runConvert(parse("x", "-q", "--mlx-path", root), taken.deps))
      .rejects.toThrow(`Cannot save to the path ${root} as it already exists — delete it or pass a fresh --mlx-path.`);
    expect(taken.order).toEqual([]);
    const run = harness();
    await runConvert(parse(local, "-q"), run.deps);
    expect(run.runs[0]!.config).toEqual({ src_dir: local, out_dir: "mlx_model", bits: 4, group_size: 64, mode: "affine" });
    expect(existsSync(out)).toBe(false);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a local model directory is used as given, never opening the registry, and the summary follows main's layout", async () => {
  const { root, local, out } = workspace();
  try {
    const run = harness();
    await runConvert(parse(local, "-q", "--q-bits", "8", "--q-group-size", "32", "--mlx-path", out), run.deps);
    expect(run.order).toEqual(["runner"]);
    expect(run.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, bits: 8, group_size: 32, mode: "affine" });
    expect(run.lines).toEqual(["step: quantizing (8-bit, group 32)", "update: Module 1/2", "update: Quantized 2 modules (4.50 bpw)",
      "done: Quantized 2 modules (4.50 bpw)", "log: ",
      `box: ● convert complete |  | source    ${local} | model     ${out} | quant     8-bit g32 affine |  | serve it   mlx-bun serve ${out}`]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a downloaded model resolves through the registry, scanning an empty index first and closing it", async () => {
  const { root, out } = workspace();
  try {
    const run = harness({ models: [{ repoId: "example/tiny", path: "/cache/snapshot" }] });
    await runConvert(parse("tiny", "-q", "--mlx-path", out), run.deps);
    expect(run.order).toEqual(["registry", "scan", "runner"]);
    expect(run.runs[0]!.config.src_dir).toBe("/cache/snapshot");
    expect(run.closed()).toBe(1);
    const miss = harness();
    await expect(runConvert(parse("tiny", "-q", "--mlx-path", out), miss.deps)).rejects.toThrow('no model matching "tiny" — run `mlx-bun scan`');
    expect(miss.order).toEqual(["registry", "scan"]);
    expect(miss.downloads).toEqual([]); expect(miss.closed()).toBe(1);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("an uncached org/name repo is downloaded with the signal, re-indexed, then converted", async () => {
  const { root, out } = workspace();
  try {
    const controller = new AbortController();
    const run = harness({ downloaded: "/hub/snapshot" });
    await runConvert(parse("--hf-path", "example/tiny", "-q", "--mlx-path", out), run.deps, controller.signal);
    expect(run.order).toEqual(["registry", "scan", "download", "scan", "runner"]);
    expect(run.downloads).toEqual([{ repoId: "example/tiny", signal: controller.signal }]);
    expect(run.runs[0]).toEqual({ config: { src_dir: "/hub/snapshot", out_dir: out, bits: 4, group_size: 64, mode: "affine" }, signal: controller.signal });
    expect(run.lines.slice(0, 3)).toEqual(["step: downloading example/tiny",
      "update: example/tiny · model.safetensors · 0.00 GB / 0.00 GB (50%)", "done: example/tiny downloaded · verified"]);
    expect(run.closed()).toBe(1);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("aborting during the download stops before any producer work and closes the registry", async () => {
  const { root, out } = workspace();
  try {
    const controller = new AbortController();
    const run = harness();
    run.deps.download = async (_repoId, { signal }) => {
      controller.abort(new Error("convert cancelled")); signal!.throwIfAborted(); return "unreachable";
    };
    await expect(runConvert(parse("example/tiny", "-q", "--mlx-path", out), run.deps, controller.signal)).rejects.toThrow("convert cancelled");
    expect(run.order).toEqual(["registry", "scan"]); expect(run.runs).toEqual([]);
    expect(run.lines).toEqual(["step: downloading example/tiny", "fail: download cancelled"]);
    expect(run.closed()).toBe(1);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("mixed precision and rotation flags reach the producer as the web job's config, which maps them to main's options", async () => {
  const { root, local, out } = workspace();
  try {
    const mixed = [local, "--target-bpw", "4.5", "--candidate-bits", "2, 4,8", "--calibration-mix", "data.jsonl", "--n-calibration", "4",
      "--rotate-weights", "--rotation-seed", "7", "--q-group-size", "32", "--mlx-path", out];
    const run = harness();
    await runConvert(parse(...mixed), run.deps);
    expect(run.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, bits: 4, group_size: 32, mode: "affine", target_bpw: 4.5,
      candidate_bits: [2, 4, 8], calibration_mix: "data.jsonl", n_calibration: 4, rotate_weights: true, rotation_seed: 7 });
    expect(run.lines[0]).toBe("step: quantizing (mixed, target 4.5 bpw — sensitivity sweep, ~minutes)");
    expect(run.lines.at(-1)).toContain("quant     mixed (target 4.5 bpw) | transform TurboQuant rotation seed 7");

    const calls: unknown[][] = [], transform = { id: "rotation" };
    const producer = createQuantizeRunner({
      quantize: (async (...args: unknown[]) => { calls.push(args); return { outDir: args[1], nQuantized: 3, achievedBpw: 4.4, write: { totalSize: 0 } }; }) as never,
      rotation: ((options: unknown) => { expect(options).toEqual({ seed: 7 }); return transform; }) as never,
    });
    const through = (config: Record<string, unknown>, outDir: string, progress: (message: string) => void) =>
      producer(event => { if (event.type === "stage" && event.message) progress(event.message); }, config).then(result => ({ outputPath: result?.outputPath ?? outDir }));
    const real = harness(); real.deps.quantize = through;
    await runConvert(parse(...mixed), real.deps);
    expect(calls[0]!.slice(0, 3)).toEqual([local, out, { bits: 4, groupSize: 32, mode: "affine", targetBpw: 4.5, candidateBits: [2, 4, 8],
      calibrationMix: "data.jsonl", nCalibration: 4, weightTransform: transform }]);
    expect(real.lines).toContain("done: Quantized 3 modules (4.40 bpw)");
    const uniform = harness(); uniform.deps.quantize = through;
    await runConvert(parse(local, "-q", "--q-bits", "8", "--mlx-path", out), uniform.deps);
    expect(calls[1]!.slice(0, 3)).toEqual([local, out, { bits: 8, groupSize: 64, mode: "affine" }]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("--upload-repo resolves the write token before any work and publishes only after success", async () => {
  const { root, local, out } = workspace();
  try {
    const denied = harness({ token: null });
    await expect(runConvert(parse(local, "-q", "--dtype", "f", "--upload-repo", "org/quant", "--mlx-path", out), denied.deps))
      .rejects.toThrow("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
        "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
    expect(denied.order).toEqual(["credentials"]);
    const run = harness();
    await runConvert(parse(local, "-q", "--upload-repo", "org/quant", "--mlx-path", out), run.deps);
    expect(run.order).toEqual(["credentials", "runner", "publish"]);
    expect(run.publishes).toEqual([{ kind: "quantize", repoId: "org/quant", sourcePath: out }]);
    expect(run.lines.slice(-2)).toEqual([`step: uploading ${out} → org/quant`, "done: uploaded https://huggingface.co/org/quant"]);
    const failed = harness();
    failed.deps.publish = async () => { throw new Error("403 forbidden"); };
    await expect(runConvert(parse(local, "-q", "--upload-repo", "org/quant", "--mlx-path", out), failed.deps))
      .rejects.toThrow(`the converted model is intact at ${out} — retry with: mlx-bun upload --path ${out} --upload-repo org/quant`);
    expect(failed.lines.at(-1)).toBe("fail: upload failed: 403 forbidden");
    expect(failed.lines.some(line => line.startsWith("box: ● convert complete"))).toBe(true);
    // Cancellation during the push reaches the publisher; the artifact stays and the retry hint prints.
    const controller = new AbortController(), reason = new Error("convert cancelled");
    const cancelled = harness();
    let observed: AbortSignal | undefined;
    cancelled.deps.publish = (request) => new Promise((_, reject) => {
      observed = request.signal;
      request.signal!.addEventListener("abort", () => reject(request.signal!.reason), { once: true });
      controller.abort(reason);
    });
    await expect(runConvert(parse(local, "-q", "--upload-repo", "org/quant", "--mlx-path", `${out}-cancel`), cancelled.deps, controller.signal))
      .rejects.toBe(reason);
    expect(observed).toBe(controller.signal);
    expect(cancelled.lines.some(line => line.startsWith("box: ● convert complete"))).toBe(true);
    expect(cancelled.lines.slice(-2)).toEqual(["fail: upload cancelled", "log: " +
      `the converted model is intact at ${out}-cancel — retry with: mlx-bun upload --path ${out}-cancel --upload-repo org/quant`]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("cancellation during quantization reaches the producer owner, prints the cancelled step, and publishes nothing", async () => {
  const { root, local, out } = workspace();
  try {
    const controller = new AbortController();
    const run = harness();
    let observed: AbortSignal | undefined;
    run.deps.quantize = (_config, _out, progress, signal) => new Promise((_, reject) => {
      observed = signal; progress("Module 1/3");
      signal!.addEventListener("abort", () => reject(signal!.reason), { once: true });
      controller.abort(new Error("convert cancelled"));
    });
    await expect(runConvert(parse(local, "-q", "--mlx-path", out), run.deps, controller.signal)).rejects.toThrow("convert cancelled");
    expect(observed).toBe(controller.signal);
    expect(run.lines).toEqual(["step: quantizing (4-bit, group 64)", "update: Module 1/3", "fail: convert cancelled"]);
    expect(existsSync(out)).toBe(false); expect(run.publishes).toEqual([]);
    const broken = harness();
    broken.deps.quantize = async () => { throw new Error("weights unreadable"); };
    await expect(runConvert(parse(local, "-q", "--mlx-path", out), broken.deps)).rejects.toThrow("weights unreadable");
    expect(broken.lines.at(-1)).toBe("fail: convert failed");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

const dbModule = resolve(import.meta.dir, "../src/jobs/db.ts");
/** A child script standing in for the quantize producer; `options` reach it through the job runner's spawn. */
const childSpawn = (script: string) => ((command: string[], options: Parameters<typeof Bun.spawn>[1]) =>
  Bun.spawn([process.execPath, "-e", script], { ...options, env: { ...options?.env, JOB_ID: command[2] } })) as unknown as typeof Bun.spawn;

test("the child owner publishes only a complete result and removes its private root afterwards", async () => {
  const { root, out } = workspace();
  const { quantizeInChild } = await import("../src/cli/convert");
  try {
    // The child writes its result where the job says, marks the job done like the real entry, and leaves a temp file under TMPDIR.
    const spawn = childSpawn(`
      const fs = require("node:fs"); const { JobStore } = require(${JSON.stringify(dbModule)});
      const store = new JobStore(process.env.MLX_BUN_JOBS_DB, process.env.MLX_BUN_JOBS_DIR);
      const row = store.get(process.env.JOB_ID); const config = JSON.parse(row.config_json);
      fs.mkdirSync(config.out_dir, { recursive: true }); fs.writeFileSync(config.out_dir + "/config.json", "{}");
      fs.writeFileSync(process.env.TMPDIR + "/probe.bin", "scratch");
      fs.appendFileSync(row.log_path, JSON.stringify({ type: "stage", stage: "quantizing", message: "Module 1/1" }) + "\\n");
      store.setOutputPath(row.id, config.out_dir); store.setStatus(row.id, "done", { endedAt: "now" }); store.close();`);
    const messages: string[] = [];
    const published = await quantizeInChild({ src_dir: "/unused", bits: 4, group_size: 64, mode: "affine" }, out, message => messages.push(message), undefined, { spawn });
    expect(published).toEqual({ outputPath: out });
    expect(existsSync(join(out, "config.json"))).toBe(true);
    expect(messages).toEqual(["Module 1/1"]);
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("cancellation terminates a child that ignores SIGTERM, joins it, and removes only the owned root", async () => {
  const { root, out } = workspace();
  const { quantizeInChild } = await import("../src/cli/convert");
  const unrelated = join(root, ".out.convert-unrelated"); mkdirSync(unrelated);
  try {
    const controller = new AbortController(), reason = new Error("convert cancelled");
    let child: Bun.Subprocess | undefined;
    const spawn = ((command: string[], options: Parameters<typeof Bun.spawn>[1]) => child = Bun.spawn([process.execPath, "-e", `
      const fs = require("node:fs"); const { JobStore } = require(${JSON.stringify(dbModule)});
      const store = new JobStore(process.env.MLX_BUN_JOBS_DB, process.env.MLX_BUN_JOBS_DIR);
      const config = JSON.parse(store.get(process.env.JOB_ID).config_json); store.close();
      fs.mkdirSync(config.out_dir, { recursive: true }); fs.writeFileSync(process.env.TMPDIR + "/probe.bin", "scratch");
      process.on("SIGTERM", () => {}); fs.writeFileSync(config.out_dir + "/started", "");
      setInterval(() => {}, 1000);`], { ...options, env: { ...options?.env, JOB_ID: command[2] } })) as unknown as typeof Bun.spawn;
    const work = quantizeInChild({ src_dir: "/unused", bits: 4, group_size: 64, mode: "affine" }, out, () => {}, controller.signal, { spawn });
    const owned = async () => readdirSync(root).filter(name => name.startsWith(".out.convert-") && name !== ".out.convert-unrelated");
    const startedAt = Date.now();
    while (!(await owned()).some(name => existsSync(join(root, name, "result", "started")))) {
      if (Date.now() - startedAt > 5_000) throw new Error("child never started"); await Bun.sleep(10);
    }
    const abortedAt = Date.now();
    controller.abort(reason);
    await expect(work).rejects.toBe(reason);
    expect(Date.now() - abortedAt).toBeLessThan(10_000);
    expect(child!.exitCode !== null || child!.signalCode !== null).toBe(true);
    expect(await owned()).toEqual([]);
    expect(existsSync(unrelated)).toBe(true); expect(existsSync(out)).toBe(false);
  } finally { rmSync(root, { recursive: true, force: true }); }
}, 20_000);

test("a failed child and the real job entry without native MLX both fail cleanly and leave no root behind", async () => {
  const { root, out } = workspace();
  const { quantizeInChild } = await import("../src/cli/convert");
  try {
    await expect(quantizeInChild({ src_dir: "/unused" }, out, () => {}, undefined, { spawn: childSpawn("process.exit(3)") })).rejects.toThrow("exited 3");
    // The real job entry over the real store and log paths, with native MLX blocked in the child's own
    // environment regardless of the runner's, so the job fails for that reason wherever it runs.
    const blocked = ((command: string[], options: Parameters<typeof Bun.spawn>[1]) =>
      Bun.spawn(command, { ...options, env: { ...options?.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" } })) as unknown as typeof Bun.spawn;
    await expect(quantizeInChild({ src_dir: root, bits: 4, group_size: 64, mode: "affine" }, out, () => {}, undefined, { spawn: blocked })).rejects.toThrow(/native|libmlxc|dlopen/);
    expect(existsSync(out)).toBe(false);
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

async function cli(home: string, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    cwd: home, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, HOME: home, HF_HUB_CACHE: join(home, "hub"), HF_HUB_OFFLINE: "1", HF_TOKEN: "", NO_COLOR: "1",
      MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI renders help, refuses usage errors with main's messages, and fails cleanly without native MLX", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-convert-cli-"));
  try {
    const overview = await cli(home, "--help");
    expect(overview.code).toBe(0); expect(overview.out).toContain("convert  Quantize an HF model");
    const help = await cli(home, "convert", "--help");
    expect(help.code).toBe(0); expect(help.err).toBe("");
    for (const marker of ["Usage: mlx-bun convert [repo-or-path] [options]", "-q, --quantize", "-d, --dequantize", "--hf-path <value>",
      "--mlx-path <value>", "--target-bpw <value>", "--rotate-weights", "--upload-repo <value>", "--q-mode <value>"]) expect(help.out).toContain(marker);
    expect((await cli(home, "help", "convert")).out).toContain("--target-bpw");
    const local = join(home, "src"); mkdirSync(local); writeFileSync(join(local, "config.json"), JSON.stringify({ model_type: "qwen3" }));
    const taken = join(home, "taken"); mkdirSync(taken);
    const refusals: [string[], string][] = [
      [["convert"], "usage: mlx-bun convert --hf-path <repo-or-path> -q"],
      [["convert", "--hf-path", "x"], "pass -q or --target-bpw"],
      [["convert", "--hf-path", "x", "-q", "--dtype", "float16"], "--dtype: not supported"],
      [["convert", "--hf-path", "x", "-q", "-d"], "--dequantize: not supported"],
      [["convert", "--hf-path", "x", "-q", "--quant-predicate", "mixed_4_6"], "--quant-predicate: not supported"],
      [["convert", "--hf-path", "x", "-q", "--q-mode", "mxfp4"], 'only "affine" is supported'],
      [["convert", "--hf-path", "x", "-q", "--upload-repo"], "--upload-repo expects a repo id (org/name)"],
      [["convert", "--hf-path", "x", "-q", "--q-bits", "3"], "--q-bits must be 4 or 8"],
      [["convert", "--hf-path", "x", "-q", "--q-group-size", "128"], "--q-group-size must be 32 or 64"],
      [["convert", "--hf-path", "x", "-q", "--rotate-weights", "--rotation-seed", "not-an-integer"], "--rotation-seed expects an integer"],
      [["convert", "--hf-path", "x", "-q", "--mlx-path", taken], "already exists"],
      [["convert", local, "-q", "--upload-repo", "org/quant"], "needs a Hugging Face WRITE token"],
      [["convert", "x", "-q", "--serial"], "--serial"],
    ];
    for (const [args, message] of refusals) {
      const result = await cli(home, ...args);
      expect(result.code).toBe(1); expect(result.err).toContain(message);
    }
    expect(existsSync(join(home, ".cache/mlx-bun/registry.sqlite"))).toBe(false);
    const missing = await cli(home, "convert", "tiny", "-q");
    expect(missing.code).toBe(1); expect(missing.err).toContain('no model matching "tiny"');
    const failed = await cli(home, "convert", local, "-q");
    expect(failed.code).toBe(1); expect(failed.out).toContain("convert failed"); expect(failed.err).not.toBe("");
    expect(existsSync(join(home, "mlx_model"))).toBe(false);
  } finally { rmSync(home, { recursive: true, force: true }); }
});
