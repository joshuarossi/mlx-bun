// Opt-in acceptance with real weights: managed quantize and fine-tune jobs
// through a real `mlx-bun serve` process over HTTP, shutdown cancelling an
// active child, restart on the same storage, spawned `train`/`convert`
// runs interrupted by SIGINT, and finished fine-tune outputs consumed as
// artifacts: mounted, merged and unmounted over HTTP, reloaded in a fresh
// process, and fused with `mlx-bun fuse` into a model that `serve` loads.
// Storage is isolated by a temporary HOME and HF_HUB_CACHE; the served model
// is the cached snapshot named by MLX_BUN_APP_TEST_MODEL, and the conversion
// cases need a cached bf16 snapshot named by MLX_BUN_APP_TEST_BF16_MODEL.
// Nothing is downloaded; training data is written here at run time.
import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join, resolve } from "node:path";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;
const bf16Dir = process.env.MLX_BUN_APP_TEST_BF16_MODEL;
const entry = resolve(import.meta.dir, "../../src/cli/main.ts");

function isolated() {
  const home = mkdtempSync(join(tmpdir(), "mlx-managed-")), hub = join(home, "hub"), data = join(home, "data");
  mkdirSync(hub); mkdirSync(data);
  const row = (i: number) => JSON.stringify({ text: `Example ${i}: the quick brown fox jumps over the lazy dog, number ${i * 7}.` }) + "\n";
  writeFileSync(join(data, "train.jsonl"), Array.from({ length: 4 }, (_, i) => row(i)).join(""));
  writeFileSync(join(data, "valid.jsonl"), Array.from({ length: 2 }, (_, i) => row(10 + i)).join(""));
  return { home, hub, data, env: { HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"), HF_HUB_CACHE: hub, HF_HUB_OFFLINE: "1", NO_COLOR: "1" },
    dispose: () => rmSync(home, { recursive: true, force: true }) };
}

/** A spawned CLI with its output collected incrementally. */
function cli(args: string[], env: Record<string, string>) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], { stdout: "pipe", stderr: "pipe", env: { ...process.env, ...env } });
  let out = "", err = "";
  const pump = async (stream: ReadableStream<Uint8Array>, sink: (text: string) => void) => {
    const reader = stream.getReader(), decoder = new TextDecoder();
    for (;;) { const { done, value } = await reader.read(); if (done) break; sink(decoder.decode(value, { stream: true })); }
  };
  const pumps = Promise.all([pump(proc.stdout, text => { out += text; }), pump(proc.stderr, text => { err += text; })]);
  const tail = () => `\n--- stdout\n${out.slice(-3000)}\n--- stderr\n${err.slice(-3000)}`;
  return {
    proc, out: () => out, err: () => err,
    async stop() {
      if (proc.exitCode === null) {
        // Let CLI owners terminate/join their managed children before escalating.
        proc.kill("SIGTERM");
        let timer: ReturnType<typeof setTimeout> | undefined;
        try {
          await Promise.race([proc.exited, new Promise<void>(resolve => {
            timer = setTimeout(resolve, 5_000);
          })]);
        } finally { clearTimeout(timer); }
        if (proc.exitCode === null) proc.kill("SIGKILL");
      }
      await proc.exited;
      await pumps;
    },
    async waitUntil(ready: () => boolean, description: string, ms: number) {
      const until = Date.now() + ms;
      while (!ready()) {
        if (proc.exitCode !== null) { await pumps; throw new Error(`exited ${proc.exitCode} before ${description}${tail()}`); }
        if (Date.now() > until) throw new Error(`timed out waiting for ${description}${tail()}`);
        await Bun.sleep(50);
      }
    },
    async waitFor(pattern: RegExp, ms: number) {
      await this.waitUntil(() => pattern.test(out), String(pattern), ms);
    },
    async exited(ms: number, expected: number) {
      let timer: ReturnType<typeof setTimeout> | undefined;
      try {
        const deadline = new Promise<never>((_, reject) => {
          timer = setTimeout(() => reject(new Error(`did not exit within ${ms} ms`)), ms);
        });
        const code = await Promise.race([proc.exited, deadline]);
        clearTimeout(timer);
        await pumps;
        if (code !== expected) throw new Error(`expected exit ${expected}, received ${code}`);
        return code;
      } catch (error) {
        await this.stop();
        throw new Error(`${error instanceof Error ? error.message : error}${tail()}`);
      } finally { clearTimeout(timer); }
    },
  };
}

async function serve(env: Record<string, string>, model = modelDir!, promptCacheGiB = "0.125") {
  const app = cli(["serve", model, "--port", "0", "--no-open", "--max-tokens", "8", "--thinking", "off", "--prompt-cache", promptCacheGiB], env);
  try {
    await app.waitFor(/App http:\/\/127\.0\.0\.1:\d+\//, 180_000);
    const base = new URL(/App (http:\/\/127\.0\.0\.1:\d+)\//.exec(app.out())![1]!);
    return { ...app, base };
  } catch (error) { await app.stop(); throw error; }
}

type Event = { type: string; step?: number; kind?: string; error?: string; [key: string]: unknown };
/** Read a job's SSE stream until the terminal frame or `until` matches. */
async function streamJob(base: URL, id: string, until: (event: Event) => boolean, ms: number): Promise<Event[]> {
  const controller = new AbortController(), timer = setTimeout(() => controller.abort(new Error("job stream timed out")), ms);
  const events: Event[] = [];
  try {
    const response = await fetch(new URL(`/api/jobs/${id}/stream`, base), { signal: controller.signal });
    const reader = response.body!.getReader(), decoder = new TextDecoder();
    let buffer = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      let boundary: number;
      while ((boundary = buffer.indexOf("\n\n")) !== -1) {
        const frame = buffer.slice(0, boundary); buffer = buffer.slice(boundary + 2);
        if (frame.startsWith("event: end")) { await reader.cancel(); return events; }
        const data = frame.split("\n").find(line => line.startsWith("data: "))?.slice(6);
        if (!data) continue;
        const event = JSON.parse(data) as Event;
        events.push(event);
        if (until(event)) { await reader.cancel(); return events; }
      }
    }
  } finally { clearTimeout(timer); }
  return events;
}
async function chat(base: URL) {
  const response = await post(base, "/v1/chat/completions", { messages: [{ role: "user", content: "Say hello." }], max_tokens: 8, temperature: 0 });
  const payload = await response.json();
  expect(response.status, JSON.stringify(payload)).toBe(200);
  expect(payload.choices).toHaveLength(1);
  expect(payload.usage.completion_tokens).toBeGreaterThan(0);
  expect(payload.choices[0].message.content.length).toBeGreaterThan(0);
}
async function generateFromArtifact(path: string, env: Record<string, string>) {
  const loaded = await serve(env, path);
  try {
    await chat(loaded.base);
    loaded.proc.kill("SIGTERM");
    expect(await loaded.exited(180_000, 0)).toBe(0);
  } finally { await loaded.stop(); }
}
/** saveAdapter writes tensors synchronously, then writes these two JSON files. */
function checkpointReady(adapter: string, step: string): boolean {
  try {
    const name = checkpointOf(adapter, step);
    if (!name) return false;
    const directory = join(adapter, "checkpoints", name);
    if (!existsSync(join(directory, "adapters.safetensors"))) return false;
    const peft = JSON.parse(readFileSync(join(directory, "adapter_config.json"), "utf8"));
    const optiq = JSON.parse(readFileSync(join(directory, "optiq_lora_config.json"), "utf8"));
    return peft.r > 0 && optiq.rank > 0 && peft.base_model_name_or_path === optiq.source_model;
  } catch (error) {
    if (error instanceof SyntaxError || (error as NodeJS.ErrnoException).code === "ENOENT") return false;
    throw error;
  }
}
const terminal = (event: Event) => event.type === "done" || event.type === "failed";
const post = (base: URL, path: string, body: unknown) => fetch(new URL(path, base), { method: "POST",
  headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
const maxStep = (metrics: string) => Math.max(0, ...readFileSync(metrics, "utf8").trim().split("\n")
  .map(line => JSON.parse(line)).filter(row => row.type === "metric" && row.kind === "train").map(row => row.step as number));
const checkpointOf = (adapter: string, step: string) =>
  readdirSync(join(adapter, "checkpoints")).find(name => name.startsWith(`step-${step}-`));
/** A one-sentence text dataset a short fine-tune learns. */
function sentenceData(root: string, name: string, sentence: string) {
  const directory = join(root, "data-" + name), row = JSON.stringify({ text: sentence }) + "\n";
  mkdirSync(directory);
  writeFileSync(join(directory, "train.jsonl"), row.repeat(4));
  writeFileSync(join(directory, "valid.jsonl"), row.repeat(2));
  return directory;
}
type TensorEntry = { dtype: string; shape: number[]; bytes(): Promise<Buffer> };
/** The tensors a safetensors header names; bytes are read on demand, without native code. */
async function safetensorsTensors(path: string, into = new Map<string, TensorEntry>()) {
  const file = Bun.file(path);
  const length = Number(Buffer.from(await file.slice(0, 8).arrayBuffer()).readBigUInt64LE(0)), start = 8 + length;
  const header = JSON.parse(await file.slice(8, start).text()) as Record<string, { dtype: string; shape: number[]; data_offsets: [number, number] }>;
  for (const [name, entry] of Object.entries(header)) {
    if (name === "__metadata__") continue;
    const [begin, end] = entry.data_offsets;
    into.set(name, { dtype: entry.dtype, shape: entry.shape, bytes: async () => Buffer.from(await file.slice(start + begin, start + end).arrayBuffer()) });
  }
  return into;
}
/** A snapshot's tensors, enumerated as the loader does: the index's shards, else the single file. */
async function snapshotTensors(directory: string) {
  const index = join(directory, "model.safetensors.index.json");
  const files = existsSync(index) ? [...new Set(Object.values(JSON.parse(readFileSync(index, "utf8")).weight_map as Record<string, string>))]
    : [existsSync(join(directory, "model.safetensors")) ? "model.safetensors" : "weights.safetensors"];
  const tensors = new Map<string, TensorEntry>();
  for (const file of files) await safetensorsTensors(join(directory, file), tensors);
  return tensors;
}

test.skipIf(!modelDir)("managed quantize and fine-tune jobs run through a real serve process, shutdown cancels an active child, and a restart resumes serving", async () => {
  const io = isolated();
  let app: Awaited<ReturnType<typeof serve>> | undefined;
  try {
    app = await serve(io.env);
    // Quantize the served snapshot into the isolated hub cache; the library sees the artifact after completion.
    const submitted = await (await post(app.base, "/api/quantize/submit", { model_id: modelDir, bits: 4, group_size: 64 })).json();
    expect(submitted.ok).toBe(true);
    const quantize = await streamJob(app.base, submitted.job_id, terminal, 300_000);
    expect(quantize.at(-1)?.type).toBe("done");
    expect(quantize.some(event => event.type === "stage")).toBe(true);
    const { job: row } = await (await fetch(new URL(`/api/jobs/${submitted.job_id}`, app.base))).json();
    expect(row.status).toBe("done");
    expect(row.output_path).toBe(submitted.output_dir);
    expect(existsSync(join(submitted.output_dir, "config.json"))).toBe(true);
    expect(readdirSync(submitted.output_dir).some(name => name.endsWith(".safetensors"))).toBe(true);
    const library = await (await fetch(new URL("/library", app.base))).json();
    expect(submitted.output_dir).toBe(join(io.home, ".mlx-bun", "models", basename(submitted.output_dir)));
    expect(library.models.some((model: { repo_id: string }) => model.repo_id === basename(submitted.output_dir))).toBe(true);
    await chat(app.base); // inference resumes after the job's lease
    await generateFromArtifact(submitted.output_dir, io.env);
    // A short fine-tune with a periodic checkpoint.
    const short = join(io.home, "adapters", "short");
    const finetune = await (await post(app.base, "/api/finetune/submit", { model_dir: modelDir, data_dir: io.data, adapter_path: short,
      method: "sft", iters: 3, max_seq_length: 128, steps_per_report: 1, steps_per_eval: 2, save_checkpoints: true, val_max_examples: 2 })).json();
    expect(finetune.ok).toBe(true);
    const trained = await streamJob(app.base, finetune.job_id, terminal, 300_000);
    expect(trained.at(-1)?.type).toBe("done");
    expect(trained.filter(event => event.type === "metric" && event.kind === "train").map(event => event.step)).toEqual([1, 2, 3]);
    for (const name of ["adapters.safetensors", "adapter_config.json", "metrics.jsonl"]) expect(existsSync(join(short, name))).toBe(true);
    expect(checkpointOf(short, "00002")).toBeDefined();
    await chat(app.base);
    // A long fine-tune cancelled by shutdown: the child is terminated after a
    // checkpoint exists, no final adapter is written, and the job row is terminal.
    const long = join(io.home, "adapters", "long");
    const longJob = await (await post(app.base, "/api/finetune/submit", { model_dir: modelDir, data_dir: io.data, adapter_path: long,
      method: "sft", iters: 400, max_seq_length: 128, steps_per_report: 1, steps_per_eval: 2, save_checkpoints: true, val_max_examples: 2 })).json();
    const progressed = await streamJob(app.base, longJob.job_id, event => event.type === "stage" && String(event.message).startsWith("checkpoint step-00002"), 300_000);
    expect(progressed.some(event => event.type === "metric" && event.step === 2)).toBe(true);
    // The checkpoint stage is emitted before its asynchronous metadata writes
    // finish. Observe both complete JSON files before testing hard shutdown.
    await app.waitUntil(() => checkpointReady(long, "00002"), "complete step-00002 checkpoint metadata", 30_000);
    const preserved = join(long, "checkpoints", checkpointOf(long, "00002")!);
    const observed = existsSync(join(long, "metrics.jsonl")) ? maxStep(join(long, "metrics.jsonl")) : 2;
    app.proc.kill("SIGTERM");
    expect(await app.exited(180_000, 0)).toBe(0);
    const { JobStore } = await import("../../src/jobs/db");
    const store = new JobStore(join(io.home, ".mlx-bun/db/jobs.sqlite"), join(io.home, ".mlx-bun/jobs"));
    try {
      const cancelled = store.get(longJob.job_id)!;
      expect(cancelled.status).toBe("failed");
      expect(store.get(finetune.job_id)!.status).toBe("done");
    } finally { store.close(); }
    expect(existsSync(join(long, "adapters.safetensors"))).toBe(false);
    const checkpoint = checkpointOf(long, "00002");
    expect(checkpoint).toBeDefined();
    expect(checkpointReady(long, "00002")).toBe(true);
    expect(maxStep(join(long, "metrics.jsonl"))).toBeLessThanOrEqual(observed + 2);
    // Restart on the same storage: the cancelled job stays terminal, serving resumes.
    app = await serve(io.env);
    const jobs = await (await fetch(new URL("/api/jobs", app.base))).json();
    expect(jobs.jobs.find((job: { id: string }) => job.id === longJob.job_id)?.status).toBe("failed");
    // A real mount loads and validates tensor names/shapes against the graph.
    // Presence in the library or on disk alone would not prove this works.
    const mountedResponse = await post(app.base, "/v1/adapters", { id: "preserved", path: preserved });
    const mounted = await mountedResponse.json();
    expect(mountedResponse.status, JSON.stringify(mounted)).toBe(200);
    expect(mounted.mounted_layers).toBeGreaterThan(0);
    const removed = await fetch(new URL("/v1/adapters/preserved", app.base), { method: "DELETE" });
    expect(removed.status).toBe(200);
    await chat(app.base);
    app.proc.kill("SIGTERM");
    expect(await app.exited(180_000, 0)).toBe(0);
    app = undefined;
  } finally {
    if (app) await app.stop();
    io.dispose();
  }
}, 900_000);

test.skipIf(!modelDir)("a spawned train run stops at its next step boundary after SIGINT, keeps its checkpoint, and writes no final adapter", async () => {
  const io = isolated();
  const adapter = join(io.home, "adapters", "cli");
  try {
    const run = cli(["train", modelDir!, "--data", io.data, "--method", "sft", "--iters", "80", "--seq", "128", "--save-every", "2", "--val-size", "2", "--adapter", adapter], io.env);
    try {
      await run.waitFor(/checkpoint step-00002/, 300_000);
      const observed = maxStep(join(adapter, "metrics.jsonl"));
      run.proc.kill("SIGINT");
      const code = await run.exited(120_000, 1);
      expect(code).toBe(1);
      expect(run.err()).toContain("training cancelled");
      expect(existsSync(join(adapter, "adapters.safetensors"))).toBe(false);
      const checkpoint = checkpointOf(adapter, "00002");
      expect(checkpoint).toBeDefined();
      expect(checkpointReady(adapter, "00002")).toBe(true);
      // Bounded progress: the step in flight completes; at most one more may have started before the signal landed.
      expect(maxStep(join(adapter, "metrics.jsonl"))).toBeLessThanOrEqual(observed + 2);
    } finally { await run.stop(); }
  } finally { io.dispose(); }
}, 600_000);

test.skipIf(!bf16Dir)("a spawned convert is interrupted during the synchronous sensitivity sweep and leaves nothing; a uniform conversion publishes a complete model", async () => {
  const io = isolated();
  try {
    const mixed = join(io.home, "mixed");
    const sweep = cli(["convert", bf16Dir!, "--target-bpw", "4.5", "--n-calibration", "2", "--mlx-path", mixed], io.env);
    try {
      // Non-TTY output omits intermediate spinner updates. The child's durable
      // job log records the real numerical stage, unlike the initial CLI banner.
      await sweep.waitUntil(() => {
        const root = readdirSync(io.home).find(name => name.startsWith(".mixed.convert-"));
        if (!root) return false;
        const logs = join(io.home, root, "jobs", "logs");
        return existsSync(logs) && readdirSync(logs).some(name => name.endsWith(".log") &&
          /"message":"(?:Sensitivity \d+\/\d+|Probing \d+ layers)/.test(readFileSync(join(logs, name), "utf8")));
      }, "the quantizer's Sensitivity or Probing stage", 300_000);
      const signalled = Date.now();
      sweep.proc.kill("SIGINT");
      expect(await sweep.exited(60_000, 1)).toBe(1);
      expect(Date.now() - signalled).toBeLessThan(60_000);
      expect(sweep.err()).toContain("convert cancelled");
    } finally { await sweep.stop(); }
    expect(existsSync(mixed)).toBe(false);
    expect(readdirSync(io.home).filter(name => name.startsWith(".mixed.convert-"))).toEqual([]);
    const uniform = join(io.home, "uniform");
    const convert = cli(["convert", bf16Dir!, "-q", "--mlx-path", uniform], io.env);
    try {
      expect(await convert.exited(900_000, 0)).toBe(0);
      expect(convert.out()).toContain("convert complete");
    } finally { await convert.stop(); }
    expect(JSON.parse(readFileSync(join(uniform, "config.json"), "utf8")).quantization).toBeDefined();
    expect(readdirSync(uniform).some(name => name.endsWith(".safetensors"))).toBe(true);
    expect(readdirSync(io.home).filter(name => name.startsWith(".uniform.convert-"))).toEqual([]);
    await generateFromArtifact(uniform, io.env);
  } finally { io.dispose(); }
}, 1_200_000);

test.skipIf(!modelDir)("finished fine-tune outputs mount, merge and unmount over HTTP, change output only for requests that select them, reload identically in a fresh process, and fuse into a model that serves", async () => {
  const io = isolated();
  const prompt = "The lighthouse keeper's secret word is";
  /** Greedy raw completion with per-token logprobs: the whole choice is compared. */
  const complete = async (base: URL, adapter?: string) => {
    const response = await post(base, "/v1/completions", { prompt, max_tokens: 8, temperature: 0, logprobs: true, ...(adapter ? { adapter } : {}) });
    const payload = await response.json();
    expect(response.status, JSON.stringify(payload)).toBe(200);
    expect(payload.usage.completion_tokens).toBeGreaterThan(0);
    expect(payload.choices[0].logprobs.content).toHaveLength(payload.usage.completion_tokens);
    return payload.choices as { text: string; logprobs: unknown; finish_reason: string }[];
  };
  const mount = async (base: URL, id: string, path: string) => {
    const response = await post(base, "/v1/adapters", { id, path });
    const mounted = await response.json();
    expect(response.status, JSON.stringify(mounted)).toBe(200);
    expect(mounted.mounted_layers).toBeGreaterThan(0);
  };
  const unmount = async (base: URL, id: string) => {
    const response = await fetch(new URL(`/v1/adapters/${id}`, base), { method: "DELETE" });
    const removed = await response.json();
    expect(response.status, JSON.stringify(removed)).toBe(200);
    expect(removed.removed_layers).toBeGreaterThan(0);
  };
  let app: Awaited<ReturnType<typeof serve>> | undefined;
  try {
    // RAM prompt cache off: every request prefills cold, so whole choices,
    // logprobs included, compare exactly across requests and processes.
    app = await serve(io.env, modelDir!, "0");
    const base = await complete(app.base);
    const train = async (name: string, sentence: string, iters: number) => {
      const adapter = join(io.home, "adapters", name);
      const submitted = await (await post(app!.base, "/api/finetune/submit", { model_dir: modelDir, data_dir: sentenceData(io.home, name, sentence),
        adapter_path: adapter, method: "sft", iters, learning_rate: 1e-3, max_seq_length: 64, steps_per_report: 1,
        save_checkpoints: false, val_max_examples: 2 })).json();
      expect(submitted.ok).toBe(true);
      const events = await streamJob(app!.base, submitted.job_id, terminal, 300_000);
      expect(events.at(-1)?.type, JSON.stringify(events.at(-1))).toBe("done");
      // The finished output, not a periodic checkpoint.
      for (const file of ["adapters.safetensors", "adapter_config.json"]) expect(existsSync(join(adapter, file))).toBe(true);
      return adapter;
    };
    const keeper = await train("keeper", `${prompt} marmalade.`, 32);
    const tide = await train("tide", "The harbor master writes down the evening tide with a brass pencil.", 8);
    expect(await complete(app.base)).toEqual(base);
    await mount(app.base, "keeper", keeper);
    const withKeeper = await complete(app.base, "keeper");
    expect(withKeeper[0]!.text).not.toBe(base[0]!.text);
    // A request that selects no adapter is untouched by the mount.
    expect(await complete(app.base)).toEqual(base);
    expect(await complete(app.base, "none")).toEqual(base);
    // Main's merge route: the two finished adapters concatenated by rank.
    const mergeResponse = await post(app.base, "/api/finetune/merge", { adapter_a: keeper, adapter_b: tide });
    const merge = await mergeResponse.json();
    expect(mergeResponse.status, JSON.stringify(merge)).toBe(200);
    expect(merge.ok).toBe(true);
    // The default output root is the app's storage policy, not this test's: it
    // only has to stay inside the isolated HOME and hold a loadable adapter.
    expect(merge.merged_path.startsWith(io.home + "/")).toBe(true);
    expect(existsSync(join(merge.merged_path, "adapters.safetensors"))).toBe(true);
    expect(merge.stats.layersMerged).toBeGreaterThan(0);
    await mount(app.base, "merged", merge.merged_path);
    const withMerged = await complete(app.base, "merged");
    expect(withMerged[0]!.text).not.toBe(base[0]!.text);
    expect(await complete(app.base, "keeper")).toEqual(withKeeper);
    expect(await complete(app.base)).toEqual(base);
    // Unmounting restores the base output exactly, and the id no longer selects.
    await unmount(app.base, "keeper");
    await unmount(app.base, "merged");
    expect((await (await fetch(new URL("/v1/adapters", app.base))).json()).adapters).toEqual([]);
    expect(await complete(app.base)).toEqual(base);
    const stale = await post(app.base, "/v1/completions", { prompt, max_tokens: 8, temperature: 0, adapter: "keeper" });
    expect(stale.status).toBe(400);
    app.proc.kill("SIGTERM");
    expect(await app.exited(180_000, 0)).toBe(0);
    app = undefined;

    // `fuse` guarantees (packages/training/src/fuse.ts): config.json and the
    // tokenizer files copied verbatim, the source quantization layout kept
    // (same tensors, dtypes and shapes), every module the adapter does not
    // touch byte-identical, and each adapter module folded into its base
    // module by dequantizing, adding the bf16 delta and re-quantizing with the
    // module's own spec. That re-quantization rounds, so the fused model is not
    // a bit-exact substitute for the mounted adapter; the check is this
    // contract plus a real `serve` load and generation, not the adapter's output.
    const fused = join(io.home, "fused");
    const fuse = cli(["fuse", modelDir!, "--adapter", keeper, "--save-path", fused], io.env);
    try { expect(await fuse.exited(900_000, 0)).toBe(0); } finally { await fuse.stop(); }
    expect(fuse.out()).toContain("fuse complete");
    for (const name of ["config.json", "tokenizer.json", "tokenizer_config.json"]) {
      if (name !== "config.json" && !existsSync(join(modelDir!, name))) continue;
      expect(readFileSync(join(fused, name)).equals(readFileSync(join(modelDir!, name))), name).toBe(true);
    }
    const source = await snapshotTensors(modelDir!), output = await snapshotTensors(fused);
    const layout = (tensors: Map<string, TensorEntry>) => [...tensors].map(([name, tensor]) => `${name} ${tensor.dtype} ${tensor.shape.join("x")}`).sort();
    expect(layout(output)).toEqual(layout(source));
    const adapterModules = [...(await safetensorsTensors(join(keeper, "adapters.safetensors"))).keys()]
      .flatMap(name => /^(.*)\.(?:lora_a|lora_A)(?:\.weight)?$/.exec(name)?.[1] ?? []);
    expect(adapterModules.length).toBeGreaterThan(0);
    const foldedModules = new Set(adapterModules.map(path => {
      const module = [path, `language_model.${path}`, path.startsWith("language_model.") ? path.slice("language_model.".length) : undefined]
        .find(candidate => candidate !== undefined && source.has(`${candidate}.weight`));
      if (!module) throw new Error(`adapter module ${path} matches no base weight`);
      return module;
    }));
    expect(foldedModules.size).toBe(adapterModules.length);
    const passthroughChanged: string[] = [], foldedChanged: string[] = [];
    for (const [name, tensor] of source) {
      const same = (await tensor.bytes()).equals(await output.get(name)!.bytes());
      const module = /^(.*)\.(?:weight|scales|biases)$/.exec(name)?.[1];
      if (module !== undefined && foldedModules.has(module)) { if (!same) foldedChanged.push(name); }
      else if (!same) passthroughChanged.push(name);
    }
    expect(passthroughChanged).toEqual([]);
    expect(foldedChanged.length).toBeGreaterThan(0);
    await generateFromArtifact(fused, io.env);

    // Reload: a fresh process mounting the same finished and merged adapters reproduces their outputs exactly.
    app = await serve(io.env, modelDir!, "0");
    expect(await complete(app.base)).toEqual(base);
    await mount(app.base, "keeper", keeper);
    await mount(app.base, "merged", merge.merged_path);
    expect(await complete(app.base, "keeper")).toEqual(withKeeper);
    expect(await complete(app.base, "merged")).toEqual(withMerged);
    await unmount(app.base, "keeper");
    await unmount(app.base, "merged");
    expect(await complete(app.base)).toEqual(base);
    app.proc.kill("SIGTERM");
    expect(await app.exited(180_000, 0)).toBe(0);
    app = undefined;
  } finally {
    if (app) await app.stop();
    io.dispose();
  }
}, 1_200_000);
