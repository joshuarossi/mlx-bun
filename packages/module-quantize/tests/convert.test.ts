import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { CatalogEntry, JobEvent, JobRecord, JobService } from "@mlx-bun/app-core";
import { parseVerb, plainTerminal } from "@mlx-bun/app-services";
import { createQuantizeRunner as createRunner, manifest, quantizeInChild, runConvert, type ConvertDependencies } from "../src";

/** The producer with the job service's cancellation signal supplied, as the host runs it. */
const createQuantizeRunner = (...args: Parameters<typeof createRunner>) => {
  const run = createRunner(...args);
  return (emit: Parameters<typeof run>[0], config: Parameters<typeof run>[1]) => run(emit, config, new AbortController().signal);
};

/** The verb's argv through its manifest: what the host hands `runConvert`. */
const parse = (...args: string[]) => parseVerb("mlx-bun", manifest.verbs[0], args);
const plain = (text: string) => text.replace(/\x1b\[[0-9;]*m/g, "");
type ModelRecord = { repoId: string; path: string };

/** Injected owners record their call order; presentation is captured without ANSI. */
function harness(input: { token?: string | null; models?: Partial<ModelRecord>[]; downloaded?: string } = {}) {
  const lines: string[] = [], order: string[] = [], runs: { config: Record<string, unknown>; signal?: AbortSignal }[] = [];
  const downloads: { repoId: string; signal?: AbortSignal }[] = [], publishes: unknown[] = [];
  const models = (input.models ?? []) as ModelRecord[];
  const entry = (id: string, directory: string): CatalogEntry => ({ id, kind: "model", directory, bytes: 0, operations: [] });
  const deps: ConvertDependencies = {
    async quantize(config, outDir, progress, signal) {
      order.push("runner"); runs.push({ config, signal });
      progress("Module 1/2"); progress("Quantized 2 modules (4.50 bpw)");
      return { outputPath: outDir };
    },
    catalog: {
      async find(query) {
        order.push("find");
        const hit = models.find(model => model.repoId.includes(query));
        if (!hit) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
        return entry(hit.repoId, hit.path);
      },
      async download(repoId, options) {
        order.push("download"); downloads.push({ repoId, signal: options?.signal });
        options?.onProgress?.("model.safetensors", 512, 1024);
        return entry(repoId, input.downloaded ?? "/downloaded/snapshot");
      },
      canPublish() { order.push("credentials"); return input.token === undefined ? true : input.token !== null; },
      async publish(directory, request) { order.push("publish"); publishes.push({ ...request, directory }); return { url: "https://huggingface.co/org/quant" }; },
    },
    modelsDir: () => "/store/models",
    terminal: { ...plainTerminal(() => {}),
      step: text => { lines.push(`step: ${plain(text)}`); return {
        update: t => { lines.push(`update: ${plain(t)}`); }, done: t => { lines.push(`done: ${plain(t ?? text)}`); }, fail: t => { lines.push(`fail: ${plain(t ?? text)}`); } }; },
      box: rows => { lines.push(`box: ${rows.map(plain).join(" | ")}`); } },
    log: (line = "") => { lines.push(`log: ${plain(line)}`); },
  };
  return { deps, lines, order, runs, downloads, publishes };
}
function workspace() {
  const root = mkdtempSync(join(tmpdir(), "mlx-convert-")), local = join(root, "src"), out = join(root, "out");
  mkdirSync(local); writeFileSync(join(local, "config.json"), JSON.stringify({ model_type: "qwen3" }));
  return { root, local, out };
}

test("main's refusals and validation messages fire before any registry, download, or producer work", async () => {
  const cases: [string[], string][] = [
    [["--hf-path", "x", "-q", "--dtype", "int8"], '--dtype must be float16, bfloat16, float32 (got "int8")'],
    [["--hf-path", "x", "-q", "-d"], "Choose either quantize or dequantize, not both."],
    [["--hf-path", "x", "--target-bpw", "4.5", "--dequantize"], "Choose either quantize or dequantize, not both."],
    [["--hf-path", "x", "-q", "--quant-predicate", "mixed_4_6"], "--quant-predicate: not supported (mlx_lm's mixed_* recipes need 2/3/6-bit; for mixed precision use --target-bpw; see: mlx-bun help convert)"],
    [["--hf-path", "x", "--rotate-weights"], "--rotate-weights folds a rotation before quantization — pass -q or --target-bpw"],
    [["--hf-path", "x", "-q", "--q-mode", "mxfp4"], '--q-mode mxfp4: only "affine" and "trellis" are supported'],
    [["-q"], "usage: mlx-bun convert --hf-path <repo-or-path> [-q] [--q-bits N] [--q-group-size N] [--mlx-path <dir>] [--target-bpw F] [--dtype float16|bfloat16|float32] [-d]"],
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

test("an existing --mlx-path is refused before any work; the default output is named in the models directory", async () => {
  const { root, local, out } = workspace();
  try {
    const taken = harness();
    await expect(runConvert(parse("x", "-q", "--mlx-path", root), taken.deps))
      .rejects.toThrow(`Cannot save to the path ${root} as it already exists — delete it or pass a fresh --mlx-path.`);
    expect(taken.order).toEqual([]);
    const run = harness();
    await runConvert(parse(local, "-q"), run.deps);
    expect(run.runs[0]!.config).toEqual({ src_dir: local, out_dir: "/store/models/src-4bit", bits: 4, group_size: 64, mode: "affine" });
    const mixed = harness();
    await runConvert(parse(local, "--target-bpw", "4.5", "--rotate-weights"), mixed.deps);
    expect(mixed.runs[0]!.config.out_dir).toBe("/store/models/src-mixed-4.5bpw-rot42");
    expect(existsSync(out)).toBe(false);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a local model directory is used as given, never asking the catalog, and the summary follows main's layout", async () => {
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

test("a downloaded model resolves through the catalog", async () => {
  const { root, out } = workspace();
  try {
    const run = harness({ models: [{ repoId: "example/tiny", path: "/cache/snapshot" }] });
    await runConvert(parse("tiny", "-q", "--mlx-path", out), run.deps);
    expect(run.order).toEqual(["find", "runner"]);
    expect(run.runs[0]!.config.src_dir).toBe("/cache/snapshot");
    const miss = harness();
    await expect(runConvert(parse("tiny", "-q", "--mlx-path", out), miss.deps)).rejects.toThrow('no model matching "tiny" — run `mlx-bun scan`');
    expect(miss.order).toEqual(["find"]);
    expect(miss.downloads).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("an uncached org/name repo is downloaded with the signal, then converted", async () => {
  const { root, out } = workspace();
  try {
    const controller = new AbortController();
    const run = harness({ downloaded: "/hub/snapshot" });
    await runConvert(parse("--hf-path", "example/tiny", "-q", "--mlx-path", out), run.deps, controller.signal);
    expect(run.order).toEqual(["find", "download", "runner"]);
    expect(run.downloads).toEqual([{ repoId: "example/tiny", signal: controller.signal }]);
    expect(run.runs[0]).toEqual({ config: { src_dir: "/hub/snapshot", out_dir: out, bits: 4, group_size: 64, mode: "affine" }, signal: controller.signal });
    expect(run.lines.slice(0, 3)).toEqual(["step: downloading example/tiny",
      "update: example/tiny · model.safetensors · 0.00 GB / 0.00 GB (50%)", "done: example/tiny downloaded · verified"]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("aborting during the download stops before any producer work", async () => {
  const { root, out } = workspace();
  try {
    const controller = new AbortController();
    const run = harness();
    run.deps.catalog.download = async (_repoId, options) => {
      controller.abort(new Error("convert cancelled")); options!.signal!.throwIfAborted(); return {} as CatalogEntry;
    };
    await expect(runConvert(parse("example/tiny", "-q", "--mlx-path", out), run.deps, controller.signal)).rejects.toThrow("convert cancelled");
    expect(run.order).toEqual(["find"]); expect(run.runs).toEqual([]);
    expect(run.lines).toEqual(["step: downloading example/tiny", "fail: download cancelled"]);
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
    const producer = createQuantizeRunner({ find: async () => { throw new Error("unused"); } }, {
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

test("--dtype and -d reach the producer, with and without -q; without either the model is only copied", async () => {
  const { root, local, out } = workspace();
  try {
    const quantized = harness();
    await runConvert(parse(local, "-q", "--dtype", "float16", "--mlx-path", out), quantized.deps);
    expect(quantized.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, bits: 4, group_size: 64, mode: "affine", dtype: "float16" });
    const cast = harness();
    await runConvert(parse(local, "--dtype", "bfloat16", "--mlx-path", out), cast.deps);
    expect(cast.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, quantize: false, dtype: "bfloat16" });
    expect(cast.lines[0]).toBe("step: converting (casting to bfloat16)");
    expect(cast.lines.at(-1)).toContain("convert   casting to bfloat16 |  | serve it");
    const dense = harness();
    await runConvert(parse(local, "-d", "--mlx-path", out), dense.deps);
    expect(dense.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, quantize: false, dequantize: true });
    expect(dense.lines[0]).toBe("step: converting (dequantizing)");
    const both = harness();
    await runConvert(parse(local, "--dequantize", "--dtype", "float32"), both.deps);
    expect(both.runs[0]!.config).toEqual({ src_dir: local, out_dir: "/store/models/src-dense-float32", quantize: false, dequantize: true, dtype: "float32" });
    const copy = harness();
    await runConvert(parse(local), copy.deps);
    expect(copy.runs[0]!.config).toEqual({ src_dir: local, out_dir: "/store/models/src-converted", quantize: false });
    expect(copy.lines[0]).toBe("step: converting (copying)");
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("--q-mode trellis implies -q and the rotation fold, names its output, and hands the job its own snake_case config", async () => {
  const { root, local, out } = workspace();
  try {
    const kmap = join(root, "kmap.json"), hessians = join(root, "hessians"), bank = join(root, "bank");
    writeFileSync(kmap, "{}"); mkdirSync(hessians); mkdirSync(bank); writeFileSync(join(bank, "config.json"), "{}");
    const plain = harness();
    await runConvert(parse(local, "--q-mode", "trellis"), plain.deps);
    expect(plain.runs[0]!.config).toEqual({ src_dir: local, out_dir: "/store/models/src-trellis-3bit", mode: "trellis", rotation_seed: 42,
      trellis_bits: 3, trellis_down_axis: "out" });
    expect(plain.lines[0]).toContain("quantizing (packed trellis, 3-bit MLP");
    expect(plain.lines.at(-1)).toContain("transform TurboQuant rotation seed 42");
    const full = harness();
    await runConvert(parse(local, "--q-mode", "trellis", "--trellis-bits", "2", "--trellis-k-map", kmap, "--trellis-k-budget", "2.5",
      "--trellis-ldlq", hessians, "--trellis-reuse", `${bank},${bank}`, "--trellis-down-axis", "in", "--trellis-interleave",
      "--trellis-layers", "6", "--rotation-seed", "7", "--mlx-path", out), full.deps);
    expect(full.runs[0]!.config).toEqual({ src_dir: local, out_dir: out, mode: "trellis", rotation_seed: 7, trellis_bits: 2, trellis_down_axis: "in",
      trellis_k_map: kmap, trellis_k_budget: "2.5", trellis_ldlq: hessians, trellis_reuse: [bank, bank], trellis_interleave: true, trellis_layers: 6 });
    const named = harness();
    await runConvert(parse(local, "--q-mode", "trellis", "--trellis-k-map", kmap, "--rotation-seed", "9"), named.deps);
    expect(named.runs[0]!.config.out_dir).toBe("/store/models/src-trellis-mixed-rot9");
    const refusals: [string[], string][] = [
      [["--q-mode", "trellis", "--trellis-bits", "9"], '--trellis-bits must be an integer in [1, 8] (got "9")'],
      [["--q-mode", "trellis", "--trellis-down-axis", "up"], '--trellis-down-axis must be out or in (got "up")'],
      [["--q-mode", "trellis", "--trellis-layers", "0"], '--trellis-layers expects a positive integer (got "0")'],
      [["--q-mode", "trellis", "--trellis-k-map", join(root, "missing.json")], "does not exist"],
      [["--q-mode", "trellis", "--trellis-k-budget", "3.00"], "--trellis-k-budget needs --trellis-k-map"],
      [["--q-mode", "trellis", "--trellis-reuse", root], "is not a model directory"],
      [["--q-mode", "trellis", "--target-bpw", "4"], "--target-bpw does not apply to --q-mode trellis"],
      [["--q-mode", "trellis", "--q-bits", "8"], "--q-bits does not apply to --q-mode trellis"],
      [["--q-mode", "trellis", "-d"], "Choose either quantize or dequantize, not both."],
      [["-q", "--trellis-bits", "3"], "--trellis-bits needs --q-mode trellis"],
      [["-q", "--trellis-interleave"], "--trellis-interleave needs --q-mode trellis"],
    ];
    for (const [flags, message] of refusals) {
      const run = harness();
      await expect(runConvert(parse(local, ...flags), run.deps)).rejects.toThrow(message);
      expect(run.order).toEqual([]);
    }
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("the producer job routes a non-quantizing config to the conversion and validates its dtype", async () => {
  const events: unknown[] = [], converts: unknown[][] = [];
  const producer = createQuantizeRunner({ find: async () => { throw new Error("unused"); } }, {
    convert: (async (...args: unknown[]) => { converts.push(args); return { outDir: args[1], nDequantized: 3, write: { totalSize: 0 } }; }) as never,
    quantize: (async () => { throw new Error("must not quantize"); }) as never,
  });
  const result = await producer(event => events.push(event), { src_dir: "/src", out_dir: "/dst", quantize: false, dequantize: true, dtype: "float16" });
  expect(result).toEqual({ outputPath: "/dst" });
  expect(converts[0]!.slice(0, 3)).toEqual(["/src", "/dst", { dtype: "float16", dequantize: true }]);
  expect(events.at(-1)).toMatchObject({ stage: "done", message: "Dequantized 3 modules", output_dir: "/dst" });
  await expect(producer(() => {}, { src_dir: "/src", out_dir: "/dst", quantize: false, dtype: "int8" })).rejects.toThrow("dtype must be float16, bfloat16 or float32 (got int8)");
  const seen: unknown[][] = [];
  const quantizing = createQuantizeRunner({ find: async () => { throw new Error("unused"); } }, { quantize: (async (...args: unknown[]) => { seen.push(args); return { outDir: args[1], nQuantized: 1, achievedBpw: 4.5, write: { totalSize: 0 } }; }) as never });
  await quantizing(() => {}, { src_dir: "/src", out_dir: "/dst", bits: 4, group_size: 64, dtype: "float16" });
  expect(seen[0]!.slice(0, 3)).toEqual(["/src", "/dst", { bits: 4, groupSize: 64, mode: "affine", dtype: "float16" }]);
});

test("--upload-repo resolves the write token before any work and publishes only after success", async () => {
  const { root, local, out } = workspace();
  try {
    const denied = harness({ token: null });
    await expect(runConvert(parse(local, "-q", "--dtype", "float16", "--upload-repo", "org/quant", "--mlx-path", out), denied.deps))
      .rejects.toThrow("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
        "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
    expect(denied.order).toEqual(["credentials"]);
    const run = harness();
    await runConvert(parse(local, "-q", "--upload-repo", "org/quant", "--mlx-path", out), run.deps);
    expect(run.order).toEqual(["credentials", "runner", "publish"]);
    expect(run.publishes).toEqual([{ repoId: "org/quant", directory: out }]);
    expect(run.lines.slice(-2)).toEqual([`step: uploading ${out} → org/quant`, "done: uploaded https://huggingface.co/org/quant"]);
    const failed = harness();
    failed.deps.catalog.publish = async () => { throw new Error("403 forbidden"); };
    await expect(runConvert(parse(local, "-q", "--upload-repo", "org/quant", "--mlx-path", out), failed.deps))
      .rejects.toThrow(`the converted model is intact at ${out} — retry with: mlx-bun upload --path ${out} --upload-repo org/quant`);
    expect(failed.lines.at(-1)).toBe("fail: upload failed: 403 forbidden");
    expect(failed.lines.some(line => line.startsWith("box: ● convert complete"))).toBe(true);
    // Cancellation during the push reaches the publisher; the artifact stays and the retry hint prints.
    const controller = new AbortController(), reason = new Error("convert cancelled");
    const cancelled = harness();
    let observed: AbortSignal | undefined;
    cancelled.deps.catalog.publish = (_directory, request) => new Promise((_, reject) => {
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


/** A job service whose "child" is a function: it runs when the job is submitted, in the scratch directory and result path it was given. */
function fakeJobs(child: (submission: { config: Record<string, unknown>; scratchDir?: string }, control: { signal: AbortSignal }) => Promise<{ status: "done" | "failed"; error?: string; events?: JobEvent[] }>,
  cancelWork: () => Promise<void> = async () => {}) {
  const calls: string[] = [];
  let outcome: Promise<{ status: "done" | "failed"; error?: string; events?: JobEvent[] }> | undefined, submitted: Parameters<JobService["submit"]>[0] | undefined;
  const stopped = new AbortController();
  const jobs: Pick<JobService, "submit" | "get" | "events" | "cancel"> = {
    async submit(submission) {
      submitted = submission; calls.push("submit");
      outcome = child(submission, { signal: stopped.signal });
      return { id: "job_1", kind: submission.kind } as JobRecord;
    },
    async get() { const done = await outcome!; return { id: "job_1", status: done.status, error: done.error ?? null } as JobRecord; },
    async *events(_id, signal) {
      if (signal?.aborted) return;
      const race = await Promise.race([outcome!, new Promise<"aborted">(resolve => signal?.addEventListener("abort", () => resolve("aborted"), { once: true }))]);
      if (race !== "aborted") yield* race.events ?? [];
    },
    async cancel() { calls.push("cancel"); stopped.abort(); await cancelWork(); },
  };
  return { jobs, calls, submitted: () => submitted };
}
const stage = (message: string): JobEvent => ({ type: "stage", stage: "quantizing", message });

test("the owned child's result is published with one rename, its scratch directory is handed to the job, and its private root is removed", async () => {
  const { root, out } = workspace();
  try {
    const { jobs, calls, submitted } = fakeJobs(async submission => {
      // The child writes its result where the job says and leaves a probe file in its scratch directory.
      mkdirSync(String(submission.config.out_dir), { recursive: true }); writeFileSync(join(String(submission.config.out_dir), "config.json"), "{}");
      writeFileSync(join(submission.scratchDir!, "probe.bin"), "scratch");
      return { status: "done", events: [stage("Module 1/1")] };
    });
    const messages: string[] = [];
    const published = await quantizeInChild(jobs, { src_dir: "/unused", bits: 4, group_size: 64, mode: "affine" }, out, message => messages.push(message));
    expect(published).toEqual({ outputPath: out });
    expect(existsSync(join(out, "config.json"))).toBe(true);
    expect(messages).toEqual(["Module 1/1"]);
    const request = submitted()!;
    expect(request.kind).toBe("quantize");
    expect(request.config).toMatchObject({ src_dir: "/unused", bits: 4, group_size: 64, mode: "affine" });
    expect(String(request.config.out_dir)).toMatch(/\.out\.convert-[^/]+\/result$/);
    expect(request.outputPath).toBe(String(request.config.out_dir));
    expect(request.scratchDir).toMatch(/\.out\.convert-[^/]+\/tmp$/);
    expect(calls).toEqual(["submit", "cancel"]); // the job's process is joined before its root goes away
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("cancellation stops the job, waits until its process is gone before removing the owned root, and rethrows the reason", async () => {
  const { root, out } = workspace();
  const unrelated = join(root, ".out.convert-unrelated"); mkdirSync(unrelated);
  try {
    const controller = new AbortController(), reason = new Error("convert cancelled");
    const owned = () => readdirSync(root).filter(name => name.startsWith(".out.convert-") && name !== ".out.convert-unrelated");
    let rootAtJoin: string[] | undefined;
    const { jobs, calls } = fakeJobs(async submission => {
      mkdirSync(String(submission.config.out_dir), { recursive: true }); writeFileSync(join(String(submission.config.out_dir), "started"), "");
      return new Promise(() => {}); // a child that never finishes on its own
    }, async () => { await Bun.sleep(50); rootAtJoin = owned(); }); // the child takes a moment to die
    const work = quantizeInChild(jobs, { src_dir: "/unused" }, out, () => {}, controller.signal);
    const startedAt = Date.now();
    while (!owned().some(name => existsSync(join(root, name, "result", "started")))) {
      if (Date.now() - startedAt > 5_000) throw new Error("job never started"); await Bun.sleep(10);
    }
    await Bun.sleep(20); // the job is running and being followed
    controller.abort(reason);
    await expect(work).rejects.toBe(reason);
    expect(calls).toContain("cancel");
    expect(rootAtJoin).toHaveLength(1); // still there while the job was being joined
    expect(owned()).toEqual([]);
    expect(existsSync(unrelated)).toBe(true); expect(existsSync(out)).toBe(false);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a failed job reports its error, publishes nothing, and leaves no root behind; an existing destination is never overwritten", async () => {
  const { root, out } = workspace();
  try {
    const failing = fakeJobs(async () => ({ status: "failed", error: "exited 3" }));
    await expect(quantizeInChild(failing.jobs, { src_dir: "/unused" }, out, () => {})).rejects.toThrow("exited 3");
    expect(existsSync(out)).toBe(false);
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
    const hollow = fakeJobs(async () => ({ status: "done" }));
    await expect(quantizeInChild(hollow.jobs, { src_dir: "/unused" }, out, () => {})).rejects.toThrow("reported success without a result");
    const taken = fakeJobs(async submission => { mkdirSync(String(submission.config.out_dir), { recursive: true }); mkdirSync(out); return { status: "done" }; });
    await expect(quantizeInChild(taken.jobs, { src_dir: "/unused" }, out, () => {})).rejects.toThrow("already exists");
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("an abort that arrives while the job is being submitted still stops it and cleans up", async () => {
  const { root, out } = workspace();
  try {
    const controller = new AbortController(), reason = new Error("convert cancelled");
    const { jobs, calls } = fakeJobs(async () => { controller.abort(reason); return new Promise(() => {}); });
    await expect(quantizeInChild(jobs, { src_dir: "/unused" }, out, () => {}, controller.signal)).rejects.toBe(reason);
    expect(calls).toEqual(["submit", "cancel"]);
    expect(readdirSync(root).filter(name => name.startsWith(".out.convert-"))).toEqual([]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
