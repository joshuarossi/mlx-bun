import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
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
