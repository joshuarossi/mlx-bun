import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { CatalogEntry, ModelCatalog } from "@mlx-bun/app-core";
import { createRegistryCatalog } from "@mlx-bun/app-services";
import { modelShortName, selectModel } from "../src";

const entry = (id: string, directory: string): CatalogEntry => ({ id, kind: "model", directory, bytes: 0, operations: ["generate"] });

test("a query names a directory or a downloaded model, and none asks the host for its automatic choice with the run's signal", async () => {
  const seen: unknown[] = [];
  const catalog: Pick<ModelCatalog, "find" | "pickDefault"> = {
    find: async query => { seen.push(["find", query]); return entry("org/downloaded", "/hub/downloaded"); },
    pickDefault: async options => { seen.push(["pick", options?.signal]); return entry("org/default", "/hub/default"); },
  };
  expect(await selectModel(catalog, "down")).toEqual({ m: { path: "/hub/downloaded", repoId: "org/downloaded" }, picked: false });
  const controller = new AbortController();
  expect(await selectModel(catalog, null, controller.signal)).toEqual({ m: { path: "/hub/default", repoId: "org/default" }, picked: true });
  expect(await selectModel(catalog, null)).toMatchObject({ picked: true });
  expect(seen).toEqual([["find", "down"], ["pick", controller.signal], ["pick", undefined]]);
});

test("a model directory keeps the name it always printed: a hub snapshot's repo id, else its folder, at its absolute path", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-select-model-"));
  try {
    const snapshot = join(root, "models--mlx-community--Tiny-4bit", "snapshots", "abc123"), plain = join(root, "my-model");
    for (const dir of [snapshot, plain]) { mkdirSync(dir, { recursive: true }); writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3" })); }
    // The host's own catalog: a directory with a config.json is its own id.
    const catalog = createRegistryCatalog({ registry: () => { throw new Error("a directory needs no index"); } });
    expect((await selectModel(catalog, snapshot)).m).toEqual({ path: snapshot, repoId: "mlx-community/Tiny-4bit" });
    expect((await selectModel(catalog, plain)).m).toEqual({ path: plain, repoId: "my-model" });
    const previous = process.cwd();
    process.chdir(root);
    try { expect((await selectModel(catalog, "my-model")).m).toEqual({ path: resolve("my-model"), repoId: "my-model" }); } finally { process.chdir(previous); }
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("output names come from the repo name of an id or hub snapshot path, else the directory's", () => {
  expect(modelShortName("/c/models--org--Qwen3-4B/snapshots/abc")).toBe("Qwen3-4B");
  expect(modelShortName("org/Qwen3-4B")).toBe("Qwen3-4B");
  expect(modelShortName("/models/some dir/")).toBe("somedir");
  expect(modelShortName("///")).toBe("model");
});
