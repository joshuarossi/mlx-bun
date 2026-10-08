// CPU-only checks of the storage layout: every producer's default output lands
// under MLX_BUN_HOME, and the app's readers (the adapter catalog, the model
// registry, `serve <path|name>`, the folder picker) find it there. Tensor bytes
// are zeroed stand-ins (tests/quantized-artifact.ts); loading real artifacts
// and generating from them is the opt-in native acceptance named in the README.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { loadModelConfig, quantFor } from "@mlx-bun/inference/artifacts/config";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { isSupportedModelRecord } from "@mlx-bun/inference/models/support";
import { resolveModelAuto } from "../src/cli/model-selection";
import type { AppModule, CatalogEntry, JobEvent, JobRecord } from "@mlx-bun/app-core";
import { createRegistryCatalog, createStorage, parseVerb, plainTerminal } from "@mlx-bun/app-services";
import { createAdapterHandlers, createFolderHandler, manifest as modelsManifest } from "@mlx-bun/module-models";
import { createQuantizeHandlers, createQuantizeRunner, manifest as quantizeManifest, runConvert } from "@mlx-bun/module-quantize";
import { createTrainHandlers, fuseDependencies, manifest as trainManifest, runFuse, runTrain, runTrainWatch, trainDependencies } from "@mlx-bun/module-train";
import { adapterDirFor } from "@mlx-bun/module-memory/model";
import { adapterStores, legacyAdapterDirs, mlxBunHome, modelShortName, openRegistry, storagePath } from "../src/storage/paths";
import { writeQuantizedArtifact, writeSourceModel } from "./quantized-artifact";

const AUX = ["tokenizer.json", "tokenizer_config.json", "chat_template.jinja", "generation_config.json"];
const plain = (line: string) => line.replace(/\x1b\[[0-9;]*m/g, "");
let root = "", home = "", store = "", hub = "", restoreRuntime = () => {};
const saved: Record<string, string | undefined> = {};
beforeEach(() => {
  root = mkdtempSync(join(tmpdir(), "mlx-storage-layout-"));
  home = join(root, "home"); store = join(root, "store"); hub = join(root, "hub");
  // Paths are resolved on each call: MLX_BUN_HOME from the runtime configuration,
  // HOME and the hub cache from the environment (Bun's os.homedir() keeps the startup HOME).
  for (const [key, value] of [["HOME", home], ["HF_HUB_CACHE", hub]] as const) {
    saved[key] = process.env[key]; process.env[key] = value; mkdirSync(value, { recursive: true });
  }
  restoreRuntime = configureRuntime({ MLX_BUN_HOME: store });
});
afterEach(() => {
  restoreRuntime();
  for (const [key, value] of Object.entries(saved)) if (value === undefined) delete process.env[key]; else process.env[key] = value;
  rmSync(root, { recursive: true, force: true });
});

const writeAdapter = (dir: string) => { mkdirSync(dir, { recursive: true }); writeFileSync(join(dir, "adapters.safetensors"), ""); };
async function availableAdapters(): Promise<{ id: string; path: string }[]> {
  // The adapters the app's catalog lists, from the stores it is built with.
  const catalog = createRegistryCatalog({ adapterDirs: () => adapterStores() });
  return (await catalog.list({ kind: "adapter" })).map(adapter => ({ id: adapter.id, path: adapter.directory }));
}

/** The train module's own view of the storage service: the entries its manifest declares, under MLX_BUN_HOME. */
const trainStorage = () => createStorage()({ moduleId: trainManifest.id, manifest: trainManifest } as never);
const trainVerb = (name: string, ...argv: string[]) => parseVerb("mlx-bun", trainManifest.verbs.find(verb => verb.name === name) as never, argv);
/** What the host hands a verb: a terminal that records the boxes and steps it draws. */
const recordingInvocation = (printed: string[]) => ({ stdout: (text: string) => { printed.push(...text.split("\n").filter(Boolean).map(plain)); },
  terminal: { ...plainTerminal(() => {}), step: () => ({ update() {}, done() {}, fail() {} }), box: (rows: readonly string[]) => { printed.push(...rows.map(plain)); } } });

test("the storage root follows MLX_BUN_HOME, else HOME, at call time", () => {
  expect(mlxBunHome("/h")).toBe(store);
  expect(storagePath("adapters")).toBe(join(store, "adapters"));
  expect(storagePath("kv")).toBe(join(store, "kv"));
  const unset = configureRuntime({ MLX_BUN_HOME: undefined });
  try {
    expect(mlxBunHome("/h")).toBe("/h/.mlx-bun");
    expect(storagePath("models")).toBe(join(home, ".mlx-bun", "models"));
  } finally { unset(); }
  expect(modelShortName("/c/models--org--Qwen3-4B/snapshots/abc")).toBe("Qwen3-4B");
  expect(modelShortName("org/Qwen3-4B")).toBe("Qwen3-4B");
});

test("every producer's default adapter directory is offered by /v1/adapters/available, with the legacy stores", async () => {
  const outputs: string[] = [];
  // Web fine-tune (default adapter_path).
  const finetune = createTrainHandlers({ storage: trainStorage(),
    jobs: { async submit(submission) { outputs.push(submission.outputPath!); return { id: "job_1" } as JobRecord; } } });
  await finetune.submit(new Request("http://app/api/finetune/submit", { method: "POST", body: JSON.stringify({ model_dir: "/m", data_dir: "/d" }) }));
  // Web merge (default output root).
  const artifacts = createAdapterHandlers({ catalog: createRegistryCatalog(), storage: createStorage()({ moduleId: modelsManifest.id, manifest: modelsManifest } as never),
    modelHost: { defaultFor: async () => "org/Model", acquire: async () => ({ operations: { adapters: { merge: async (request: { output: string }) => { outputs.push(request.output); return { tensors: 0 }; } } }, release() {} }) as never } });
  await artifacts["adapter-merge"]!(new Request("http://app/api/finetune/merge", { method: "POST", body: JSON.stringify({ adapter_a: "/a", adapter_b: "/b" }) }));
  // `mlx-bun train` with its real defaults (dry run: plan only).
  const data = join(root, "data"); mkdirSync(data); writeFileSync(join(data, "train.jsonl"), "");
  const logs: string[] = [];
  await runTrain(trainVerb("train", "--data", data, "--method", "sft", "--dry-run"), {
    ...trainDependencies({ catalog: createRegistryCatalog(), adaptersDir: () => trainStorage().path("adapters") }, recordingInvocation(logs)),
    resolve: async () => ({ m: { path: "/m", repoId: "org/Tiny-Model" }, picked: false }), trainingDefaults: async () => ({ maxSeqLength: 4096 }),
    inspect: async () => ({ ok: true, n_train: 1, n_valid: 0, format: "chat" }) as never, log: line => logs.push(plain(line)) });
  const train = logs.map(line => /^.*adapter\s+(\S+)/.exec(line)?.[1]).find(Boolean)!;
  expect(train).toBe(join(store, "adapters", "sft-Tiny-Model"));
  outputs.push(train);
  for (const output of outputs) { expect(output.startsWith(join(store, "adapters") + "/")).toBe(true); writeAdapter(output); }
  // The memory task model's stage adapter is read from the same store.
  writeAdapter(join(store, "adapters", "memory-chunk"));
  expect(adapterDirFor("chunk")).toBe(join(store, "adapters", "memory-chunk"));
  // Earlier versions' stores stay listed, read-only; nothing is moved.
  const legacy = legacyAdapterDirs().map((dir, index) => join(dir, `legacy-${index}`));
  for (const dir of legacy) writeAdapter(dir);
  const listed = (await availableAdapters()).map(adapter => adapter.path);
  expect(listed.sort()).toEqual([...outputs, join(store, "adapters", "memory-chunk"), ...legacy].sort());
  for (const dir of legacy) expect(existsSync(dir)).toBe(true);
});

test("a legacy store that links to the adapter store is listed once", async () => {
  writeAdapter(join(store, "adapters", "tuned"));
  const [link] = legacyAdapterDirs();
  mkdirSync(resolve(link!, ".."), { recursive: true }); symlinkSync(join(store, "adapters"), link!);
  expect((await availableAdapters()).map(adapter => adapter.id)).toEqual(["tuned"]);
});

/** The artifact is a complete model directory with the source's tokenizer and template files. */
async function expectQuantizedModel(dir: string, bits: number, groupSize: number, source: string) {
  const config = await loadModelConfig(dir);
  expect(config.quantization?.default).toEqual({ bits, groupSize, mode: "affine" });
  expect(quantFor(config.quantization, "model.layers.0.mlp.down_proj")).toEqual({ bits, groupSize, mode: "affine" });
  expect(quantFor(config.quantization, "lm_head")).toBeNull();
  for (const name of AUX) expect(readFileSync(join(dir, name), "utf8")).toBe(readFileSync(join(source, name), "utf8"));
}

test("a web quantize job writes a plain model directory that the registry, `serve` and the folder picker find", async () => {
  const source = join(root, "sources", "tiny-qwen3"); writeSourceModel(source);
  const catalog = createRegistryCatalog();
  let submitted: { config: Record<string, unknown>; outputPath?: string } | undefined;
  const routes = createQuantizeHandlers({ catalog, storage: createStorage()({ moduleId: "quantize", manifest: quantizeManifest as unknown as AppModule }),
    jobs: { submit: async submission => { submitted = submission as never; return { id: "job_1" } as JobRecord; } } });
  const post = (route: keyof typeof routes, body: unknown) => routes[route](new Request(`http://app/api/quantize/${route}`, { method: "POST", body: JSON.stringify(body) }));
  const response = await (await post("submit", { model_id: source, bits: 4, group_size: 64 })).json();
  const output = join(store, "models", "tiny-qwen3-4bit");
  expect(response).toEqual({ ok: true, job_id: "job_1", output_dir: output });
  expect(submitted!.outputPath).toBe(output);
  // The job child's producer, with the quantizer's CPU-side writers standing in for its native pass.
  const events: JobEvent[] = [];
  const result = await createQuantizeRunner(catalog, { quantize: (async (src: string, out: string, options: { bits: number; groupSize: number }) => {
    await writeQuantizedArtifact(src, out, options.bits, options.groupSize);
    return { outDir: out, nQuantized: 2, achievedBpw: 4.5 };
  }) as never })(event => events.push(event), submitted!.config, new AbortController().signal);
  expect(result).toEqual({ outputPath: output });
  await expectQuantizedModel(output, 4, 64, source);
  expect(readdirSync(hub)).toEqual([]); // the hub cache holds downloads only

  // Discovery (library and hub listings) indexes the models directory beside the hub cache.
  const registry = openRegistry();
  try {
    await registry.scan();
    const record = registry.listCanonical().find(model => model.path === output);
    expect(record).toMatchObject({ repoId: "tiny-qwen3-4bit", modelType: "qwen3", quantBits: 4, quantGroupSize: 64 });
    expect(isSupportedModelRecord(record!.modelType)).toBe(true);
  } finally { registry.close(); }
  // `serve <path>`, `serve <name>` and the web folder picker resolve the same directory under the same id.
  expect(await resolveModelAuto(output)).toMatchObject({ picked: false, m: { repoId: "tiny-qwen3-4bit", path: output } });
  expect(await resolveModelAuto("tiny-qwen3-4bit")).toMatchObject({ picked: false, m: { repoId: "tiny-qwen3-4bit", path: output } });
  const folder = createFolderHandler(catalog);
  const picked = () => folder(new Request("http://app/api/model/resolve-folder", { method: "POST", body: JSON.stringify({ folder_name: "tiny-qwen3-4bit" }) }));
  expect(await (await picked()).json()).toEqual({ ok: true, path: output, repo_id: "tiny-qwen3-4bit" });
  expect(await (await post("resolve-folder", { folder_name: "tiny-qwen3-4bit" })).json()).toEqual({ ok: true, path: output, repo_id: "tiny-qwen3-4bit" });
  // The same model and settings name the same directory, which the producer refuses to overwrite.
  expect((await (await post("submit", { model_id: source, bits: 4, group_size: 64 })).json()).output_dir).toBe(output);
  await expect(writeQuantizedArtifact(source, output, 4, 64)).rejects.toThrow("output directory already exists");
});

test("earlier quantize outputs in the hub cache (`models--local--…`) stay listed and resolvable", async () => {
  const source = join(root, "sources", "tiny-qwen3"); writeSourceModel(source);
  const repo = join(hub, "models--local--tiny-qwen3-OptiQ-4bit"), snapshot = join(repo, "snapshots", "abc");
  await writeQuantizedArtifact(source, snapshot, 4, 64);
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs", "main"), "abc");
  const registry = openRegistry();
  try {
    await registry.scan();
    expect(registry.listCanonical().map(model => [model.repoId, model.path])).toEqual([["local/tiny-qwen3-OptiQ-4bit", snapshot]]);
  } finally { registry.close(); }
  const routes = createFolderHandler(createRegistryCatalog());
  expect(await (await routes(new Request("http://app/api/model/resolve-folder", { method: "POST",
    body: JSON.stringify({ folder_name: "models--local--tiny-qwen3-OptiQ-4bit" }) }))).json())
    .toEqual({ ok: true, path: snapshot, repo_id: "local/tiny-qwen3-OptiQ-4bit" });
});

test("`convert` without --mlx-path publishes into the models directory and prints how to serve it", async () => {
  const source = join(root, "sources", "src-model"); writeSourceModel(source);
  const catalog = createRegistryCatalog();
  const printed: string[] = [];
  const quiet = { update() {}, done() {}, fail() {} };
  const convert = () => runConvert(parseVerb("mlx-bun", quantizeManifest.verbs[0] as never, [source, "-q", "--q-bits", "8", "--q-group-size", "32"]), {
    // A stand-in job child: the quantizer's CPU-side writers, into the directory the verb asks for.
    async quantize(config, outDir) { await writeQuantizedArtifact(String(config.src_dir), outDir, Number(config.bits), Number(config.group_size)); return { outputPath: outDir }; },
    catalog, modelsDir: () => storagePath("models"),
    terminal: { ...plainTerminal(() => {}), step: () => quiet, box: rows => { printed.push(...rows.map(plain)); } }, log() {},
  });
  await convert();
  const output = join(store, "models", "src-model-8bit");
  expect(printed).toContain(`model     ${output}`);
  expect(printed.some(row => row.includes(`mlx-bun serve ${output}`))).toBe(true);
  await expectQuantizedModel(output, 8, 32, source);
  expect(readdirSync(join(store, "models"))).toEqual(["src-model-8bit"]);
  expect(await resolveModelAuto(output)).toMatchObject({ picked: false, m: { repoId: "src-model-8bit", path: output, quantBits: 8 } });
  const registry = openRegistry();
  try { await registry.scan(); expect(registry.resolve("src-model-8bit").path).toBe(output); } finally { registry.close(); }
  expect((await catalog.find("src-model-8bit") as CatalogEntry).directory).toBe(output);
  // The default is refused like an explicit path once it exists.
  await expect(convert()).rejects.toThrow(`Cannot save to the path ${output} as it already exists`);
});

test("`fuse` defaults into the models directory and never overwrites that default", async () => {
  const base = join(root, "sources", "Base-Model"); writeSourceModel(base);
  const adapter = join(root, "adapter"); writeAdapter(adapter);
  const written: string[] = [], logs: string[] = [];
  const fuse = () => runFuse(trainVerb("fuse", base, "--adapter", adapter), {
    ...fuseDependencies({ catalog: createRegistryCatalog(), modelsDir: () => trainStorage().path("models") }, recordingInvocation(logs)),
    fuse: (async (_model: string, _adapter: string, out: string) => { written.push(out); writeSourceModel(out);
      return { outDir: out, fusedModules: 1, totalTensors: 3, skippedAdapterTensors: 0 }; }) as never });
  await fuse();
  const output = join(store, "models", "Base-Model-fused");
  expect(written).toEqual([output]);
  expect(logs.some(line => line.includes(`mlx-bun serve ${output}`))).toBe(true);
  const registry = openRegistry();
  try { await registry.scan(); expect(registry.resolve("Base-Model-fused").path).toBe(output); } finally { registry.close(); }
  await expect(fuse()).rejects.toThrow(`${output} already exists`);
  expect(written).toHaveLength(1);
});

test("`train-watch` without a directory follows the latest run in the adapter store", async () => {
  const older = join(store, "adapters", "sft-a"), newer = join(store, "adapters", "orpo-b");
  for (const [dir, at] of [[older, 1_000], [newer, 2_000]] as const) {
    mkdirSync(dir, { recursive: true }); writeFileSync(join(dir, "metrics.jsonl"), "");
    const { utimesSync } = await import("node:fs"); utimesSync(join(dir, "metrics.jsonl"), at, at);
  }
  const watched: string[] = [];
  const adaptersDir = () => trainStorage().path("adapters");
  await runTrainWatch(trainVerb("train-watch"), { watch: async dir => { watched.push(dir); }, adaptersDir });
  expect(watched).toEqual([newer]);
  rmSync(join(store, "adapters"), { recursive: true });
  await expect(runTrainWatch(trainVerb("train-watch"), { watch: async () => {}, adaptersDir })).rejects.toThrow("no training run found");
});
