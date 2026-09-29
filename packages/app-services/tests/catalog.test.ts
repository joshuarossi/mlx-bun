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
  expect(declaredOperations("gemma4", "org/gemma-4")).toEqual(["generate"]);
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

test("this host registers and downloads nothing", async () => {
  const catalog = createRegistryCatalog({ registry: registry([]) });
  await expect(catalog.register("/x", "model")).rejects.toThrow("does not register model outputs");
  await expect(catalog.download("org/x")).rejects.toThrow("does not download models");
});
