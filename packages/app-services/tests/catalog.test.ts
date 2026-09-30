import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { createRegistryCatalog, declaredOperations } from "../src";

const record = (repoId: string, modelType: string, extra: Partial<ModelRecord> = {}) =>
  ({ repoId, modelType, path: `/hub/${repoId}`, sizeBytes: 1000, ...extra }) as ModelRecord;

/** A registry over fixed rows: `resolve` matches a substring, as the real one does. */
function registry(rows: ModelRecord[], events: string[] = []) {
  return () => ({
    list: () => { events.push("list"); return rows; },
    listCanonical: () => rows,
    resolve: (query: string) => {
      const matches = rows.filter(row => row.repoId.includes(query));
      if (matches.length !== 1) throw new Error(matches.length ? `"${query}" is ambiguous` : `no model matching "${query}" — run \`mlx-bun scan\``);
      return matches[0]!;
    },
    scan: async () => { events.push("scan"); return { added: 0, removed: 0, total: rows.length } as never; },
    close: () => { events.push("close"); },
  });
}

test("models declare operations from their type, never from a family name", () => {
  expect(declaredOperations("whisper")).toEqual(["transcribe"]);
  expect(declaredOperations("gemma4")).toEqual(["generate"]);
  expect(declaredOperations("qwen3")).toEqual(["generate", "embed"]);
  expect(declaredOperations("nonsense")).toEqual([]);
});

test("list, resolve, find and estimate read the index; an empty index is scanned once and every handle closes", async () => {
  const events: string[] = [];
  const rows = [record("org/whisper-turbo", "whisper"), record("org/qwen3", "qwen3")];
  const catalog = createRegistryCatalog({ registry: registry([], events) });
  expect(await catalog.list()).toEqual([]);
  expect(events).toEqual(["list", "scan", "close"]);
  const full = createRegistryCatalog({ registry: registry(rows) });
  expect((await full.list()).map(entry => [entry.id, entry.operations])).toEqual([["org/whisper-turbo", ["transcribe"]], ["org/qwen3", ["generate", "embed"]]]);
  expect(await full.list({ kind: "adapter" })).toEqual([]);
  expect((await full.resolve("org/qwen3"))?.directory).toBe("/hub/org/qwen3");
  expect(await full.resolve("qwen3")).toBeUndefined(); // exact ids only
  expect((await full.find("turbo")).id).toBe("org/whisper-turbo");
  await expect(full.find("nope")).rejects.toThrow('no model matching "nope"');
  expect(await full.estimate("org/qwen3")).toEqual({ residentBytes: 1000 });
  expect(await full.estimate("missing")).toBeUndefined();
});

test("a directory with a config.json is used as given: its path is its id and its model_type says what it does", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-catalog-"));
  try {
    const whisper = join(dir, "whisper"); mkdirSync(whisper); writeFileSync(join(whisper, "config.json"), JSON.stringify({ model_type: "whisper" }));
    const broken = join(dir, "broken"); mkdirSync(broken); writeFileSync(join(broken, "config.json"), "{");
    const catalog = createRegistryCatalog({ registry: () => { throw new Error("a directory needs no registry"); } });
    expect(await catalog.find(whisper)).toEqual({ id: whisper, kind: "model", directory: whisper, bytes: 0, operations: ["transcribe"] });
    expect((await catalog.find(broken)).operations).toEqual([]);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("this host registers, downloads and publishes nothing unless it supplies the hub side", async () => {
  const catalog = createRegistryCatalog({ registry: registry([]) });
  await expect(catalog.register("/x", "model")).rejects.toThrow("does not register model outputs");
  await expect(catalog.download("org/x")).rejects.toThrow("does not download models");
  await expect(catalog.publish("/x", { repoId: "org/x" })).rejects.toThrow("does not publish models");
  expect(catalog.canPublish()).toBe(false);
});

test("a download fetches through the host's hub, re-indexes, and answers with the indexed entry; publishing passes through", async () => {
  const events: string[] = [];
  const fetched = record("org/tiny", "qwen3", { path: "/hub/snapshot" });
  const catalog = createRegistryCatalog({ registry: registry([fetched], events), hub: {
    download: async (id, options) => { events.push(`download ${id}`); options.onProgress?.("model.safetensors", 1, 2); return "/hub/snapshot"; },
    canPublish: () => true, publish: async (directory, request) => ({ url: `https://hub/${request.repoId}#${directory}` }) } });
  const progress: unknown[][] = [];
  const entry = await catalog.download("org/tiny", { onProgress: (...args) => { progress.push(args); } });
  expect(events.indexOf("download org/tiny")).toBeLessThan(events.lastIndexOf("scan"));
  expect(progress).toEqual([["model.safetensors", 1, 2]]);
  expect(entry).toMatchObject({ id: "org/tiny", directory: "/hub/snapshot", modelType: "qwen3", operations: ["generate", "embed"] });
  expect(catalog.canPublish()).toBe(true);
  expect(await catalog.publish("/out", { repoId: "org/quant" })).toEqual({ url: "https://hub/org/quant#/out" });
});

test("the host's automatic model choice is answered with the indexed entry; without one the catalog makes none", async () => {
  const chosen = record("org/tiny", "qwen3", { path: "/hub/snapshot" });
  const signals: (AbortSignal | undefined)[] = [];
  const catalog = createRegistryCatalog({ registry: registry([chosen]), hub: {
    pickDefault: async signal => { signals.push(signal); return { id: "org/tiny", directory: "/hub/snapshot" }; } } });
  const controller = new AbortController();
  expect(await catalog.pickDefault({ signal: controller.signal })).toMatchObject({ id: "org/tiny", directory: "/hub/snapshot", modelType: "qwen3", operations: ["generate", "embed"] });
  expect(signals).toEqual([controller.signal]);
  // A choice the index does not list yet still names its directory.
  const unindexed = createRegistryCatalog({ registry: registry([]), hub: { pickDefault: async () => ({ id: "org/new", directory: "/hub/new" }) } });
  expect(await unindexed.pickDefault()).toEqual({ id: "org/new", kind: "model", directory: "/hub/new", bytes: 0, operations: [] });
  await expect(createRegistryCatalog({ registry: registry([]) }).pickDefault()).rejects.toThrow("does not choose a default model");
});

test("a picked folder is located in the hub cache, the app's models directory, or the index, and never elsewhere", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-locate-")), previous = process.env.HF_HUB_CACHE;
  try {
    const hub = join(dir, "hub"), models = join(dir, "models");
    process.env.HF_HUB_CACHE = hub;
    const config = (path: string) => { mkdirSync(path, { recursive: true }); writeFileSync(join(path, "config.json"), "{}"); };
    const repo = join(hub, "models--example--model");
    config(join(repo, "snapshots", "aabb")); mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs", "main"), "aabb");
    config(join(models, "my-4bit")); config(join(hub, "plain"));
    const indexed = record("indexed/model", "qwen3", { path: "/elsewhere/cafe" });
    const catalog = createRegistryCatalog({ registry: registry([indexed]), modelsRoot: () => models });
    expect(await catalog.locate({ name: "models--example--model" })).toEqual({ directory: join(repo, "snapshots", "aabb"), id: "example/model" });
    expect(await catalog.locate({ name: "aabb" })).toEqual({ directory: join(repo, "snapshots", "aabb"), id: "example/model" });
    expect(await catalog.locate({ name: "config.json", relPath: "picked/aabb/config.json" })).toEqual({ directory: join(repo, "snapshots", "aabb"), id: "example/model" });
    expect(await catalog.locate({ name: "plain" })).toEqual({ directory: join(hub, "plain") });
    expect(await catalog.locate({ name: "my-4bit" })).toEqual({ directory: join(models, "my-4bit"), id: "my-4bit" });
    expect(await catalog.locate({ name: "/a/b/model" })).toEqual({ directory: "/elsewhere/cafe", id: "indexed/model", type: "qwen3" });
    expect(await catalog.locate({ name: "cafe" })).toEqual({ directory: "/elsewhere/cafe", id: "indexed/model", type: "qwen3" });
    expect(await catalog.locate({ name: "nothing-here" })).toBeUndefined();
    expect(await catalog.locate({})).toBeUndefined();
  } finally { if (previous === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = previous; rmSync(dir, { recursive: true, force: true }); }
});

const indexed = (repoId: string, path: string, extra: Partial<ModelRecord> = {}) => record(repoId, "gemma4", { path, paramCount: 4e9, quantBits: 4, quantGroupSize: 64, license: "gemma",
  expertsBytes: 10, sidecarBytes: 20, hasVisionSidecar: true, visionConfigType: "gemma4_vision", hasAudioConfig: true, hasAudioTower: false, hasToolTemplate: true, hasKvConfig: false, ...extra });

test("an entry carries what the index knows of the model: capabilities, quantization, sizes, support tier and the snapshot it is", async () => {
  const rows = [indexed("org/gemma", "/hub/models--org--gemma/snapshots/abc123")];
  const [entry] = await createRegistryCatalog({ registry: registry(rows) }).list();
  expect(entry!.details).toEqual({ parameters: 4e9, quantBits: 4, quantGroupSize: 64, license: "gemma", vision: true, audio: false, tools: true, kvQuant: false,
    expertsBytes: 10, sidecarBytes: 20, supportTier: "targeted", revision: "abc123", canonical: true });
  const plain = (await createRegistryCatalog({ registry: registry([record("org/plain", "qwen3", { path: "/models/plain" })]) }).list())[0]!;
  expect(plain.details).toMatchObject({ vision: false, audio: false, quantBits: null, license: null, expertsBytes: 0 });
  expect("revision" in plain.details!).toBe(false);
});

test("listing filters reach the index, companions are hidden unless asked for, every snapshot can be listed with the canonical one marked, and a refresh re-indexes first", async () => {
  const events: string[] = [];
  const filters: unknown[] = [];
  const canonical = indexed("org/gemma", "/hub/models--org--gemma/snapshots/new"), old = indexed("org/gemma", "/hub/models--org--gemma/snapshots/old");
  const drafter = record("org/drafter", "gemma4_assistant", { path: "/hub/drafter" });
  const catalog = createRegistryCatalog({ registry: () => ({
    list: (filter?: unknown) => { filters.push(["list", filter]); return [canonical, old, drafter]; },
    listCanonical: (filter?: unknown) => { filters.push(["canonical", filter]); return [canonical, drafter]; },
    resolve: () => { throw new Error("unused"); }, scan: async () => { events.push("scan"); return 0; }, close: () => {} }) });
  expect((await catalog.list()).map(entry => entry.id)).toEqual(["org/gemma"]);
  expect((await catalog.list({ companions: true })).map(entry => entry.id)).toEqual(["org/gemma", "org/drafter"]);
  const snapshots = await catalog.list({ revisions: "snapshots", vision: true, maxBytes: 5000, query: "gem" });
  expect(snapshots.map(entry => [entry.details!.revision, entry.details!.canonical])).toEqual([["new", true], ["old", false]]);
  expect(filters.at(-2)).toEqual(["canonical", { vision: true, maxBytes: 5000, query: "gem" }]);
  expect(filters.at(-1)).toEqual(["list", { vision: true, maxBytes: 5000, query: "gem" }]);
  expect(events).toEqual([]);
  await catalog.list({ refresh: true });
  expect(events).toEqual(["scan"]);
});

test("a re-index and a download announce that the catalog changed; a download passes its revision through; downloads that outlive the caller belong to the host's transfers", async () => {
  const published: unknown[] = [], fetched: unknown[] = [];
  const rows = [indexed("org/tiny", "/hub/snapshot")];
  const transfers: string[] = [];
  const withScan = () => ({ ...registry(rows)(), scan: async () => 3 });
  const catalog = createRegistryCatalog({ registry: withScan as never, events: { publish: event => { published.push(event); } },
    hub: { download: async (id, options) => { fetched.push([id, options.revision]); return "/hub/snapshot"; },
      transfers: { start: id => { transfers.push(id); }, snapshot: () => [{ repoId: "org/tiny", state: "active", currentFile: null, receivedBytes: 1, totalBytes: 2 }] } } });
  expect(await catalog.rescan()).toBe(3);
  await catalog.download("org/tiny", { revision: "abc" });
  expect(fetched).toEqual([["org/tiny", "abc"]]);
  expect(published.map(event => (event as { type: string }).type)).toEqual(["catalog.changed", "catalog.changed"]);
  catalog.startDownload("org/tiny");
  expect(transfers).toEqual(["org/tiny"]);
  expect(catalog.downloads()).toEqual([{ repoId: "org/tiny", state: "active", currentFile: null, receivedBytes: 1, totalBytes: 2 }]);
  const bare = createRegistryCatalog({ registry: registry([]) });
  expect(() => bare.startDownload("org/x")).toThrow("this host does not download models");
  try { bare.startDownload("org/x"); } catch (error) { expect((error as { code: string }).code).toBe("not-supported"); }
  // Without a host's transfers the rows are the hub library's own tracker.
  expect(Array.isArray(bare.downloads())).toBe(true);
});

test("adapters are listed from the stores in order, once per directory, with their rank, scale, base model and weights size", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-catalog-adapters-"));
  try {
    const store = join(dir, "adapters"), legacy = join(dir, "legacy");
    const adapter = (root: string, id: string, config: object, bytes: number) => {
      mkdirSync(join(root, id), { recursive: true });
      writeFileSync(join(root, id, "adapters.safetensors"), new Uint8Array(bytes));
      writeFileSync(join(root, id, "adapter_config.json"), JSON.stringify(config));
    };
    adapter(store, "sft", { lora_parameters: { scale: 2, rank: 8 }, base_model_name_or_path: "/x/models--org--Base/snapshots/abc" }, 64);
    adapter(legacy, "old", { r: 4, lora_alpha: 8 }, 32);
    mkdirSync(join(store, "not-an-adapter"));
    symlinkSync(store, join(dir, "alias"));
    const catalog = createRegistryCatalog({ adapterDirs: () => [store, join(dir, "alias"), legacy, join(dir, "missing")] });
    const adapters = await catalog.list({ kind: "adapter" });
    expect(adapters.map(entry => ({ id: entry.id, kind: entry.kind, bytes: entry.bytes, base: entry.base, adapter: entry.adapter, operations: entry.operations }))).toEqual([
      { id: "sft", kind: "adapter", bytes: 64, base: "org/Base", adapter: { rank: 8, scale: 2 }, operations: [] },
      { id: "old", kind: "adapter", bytes: 32, base: undefined, adapter: { rank: 4, scale: 2 }, operations: [] },
    ]);
    expect(adapters[0]!.directory).toBe(join(store, "sft"));
    expect(await createRegistryCatalog().list({ kind: "adapter" })).toEqual([]);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
