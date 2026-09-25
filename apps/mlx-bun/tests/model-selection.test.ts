import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { chooseAutoModel, DEFAULT_REPO_ID, resolveModelAuto, STARTER_REPO_ID, type ModelSelectionDependencies } from "../src/cli/model-selection";

const model = (repoId: string, sizeBytes = 100, modelType = "qwen3") => ({ repoId, sizeBytes, modelType, path: `/${repoId}` }) as ModelRecord;
function selection(initial: ModelRecord[]) {
  let records = initial, closes = 0, scans = 0;
  const downloads: string[] = [], assessed: string[] = [];
  const dependencies: ModelSelectionDependencies = {
    registry: () => ({ list: () => records, resolve: query => { const found = records.find(m => m.repoId.includes(query)); if (!found) throw new Error("not found"); return found; },
      scan: async () => { scans++; return records.length; }, close: () => { closes++; } }),
    scanSnapshot: async () => { throw new Error("unexpected path scan"); },
    download: async repo => { downloads.push(repo); records = [...records, model(repo)]; return `/${repo}`; },
    machine: () => ({ name: "test", ramBytes: 1000, bandwidthGBs: 100 }),
    assess: async m => { assessed.push(m.repoId); return { full: true, coexist: true }; }, log() {},
  };
  return { dependencies, downloads, assessed, closes: () => closes, scans: () => scans };
}

test("automatic selection prefers e4b at full fit, then the largest coexist fit, then full fit", () => {
  const preferred = model(DEFAULT_REPO_ID, 200), large = model("large", 300), small = model("small", 100);
  const candidates = [small, large, preferred];
  expect(chooseAutoModel(candidates, DEFAULT_REPO_ID, () => true, m => m === small)).toBe(preferred);
  expect(chooseAutoModel(candidates, DEFAULT_REPO_ID, m => m !== preferred, m => m === small)).toBe(small);
  expect(chooseAutoModel(candidates, DEFAULT_REPO_ID, m => m !== preferred, () => false)).toBe(large);
  expect(chooseAutoModel(candidates, DEFAULT_REPO_ID, () => false, () => false)).toBeUndefined();
  expect(candidates).toEqual([small, large, preferred]);
});

test("explicit cached queries bypass fit advice and downloads and close the registry", async () => {
  const selected = model("explicit-too-large"), run = selection([selected]);
  const result = await resolveModelAuto("too-large", { ...run.dependencies, assess: async () => { throw new Error("must not assess"); } });
  expect(result).toEqual({ m: selected, picked: false }); expect(run.downloads).toEqual([]); expect(run.closes()).toBe(1);
});

test("automatic selection assesses only supported models and does not download when one is cached", async () => {
  const supported = model("supported"), run = selection([model("unsupported", 1000, "not-a-model"), supported]);
  expect((await resolveModelAuto(null, run.dependencies)).m).toBe(supported);
  expect(run.assessed).toEqual(["supported"]); expect(run.downloads).toEqual([]); expect(run.closes()).toBe(1);
});

test("an empty supported cache gets the starter, then returns the recommended model for the caller to fetch", async () => {
  const run = selection([]);
  const signals: (AbortSignal | undefined)[] = [];
  const controller = new AbortController();
  const result = await resolveModelAuto(null, { ...run.dependencies, download: async (repo, options) => {
    signals.push(options?.signal); return run.dependencies.download(repo, options);
  } }, controller.signal);
  expect(result.m.repoId).toBe(STARTER_REPO_ID); expect(result.picked).toBe(true);
  expect(result.recommended).toBe(DEFAULT_REPO_ID);
  expect(run.downloads).toEqual([STARTER_REPO_ID]);
  expect(signals).toEqual([controller.signal]);
  expect(run.closes()).toBe(1);
});

test("a cancelled selection rejects with the signal's reason before or during the starter download", async () => {
  const run = selection([]);
  const reason = new Error("startup cancelled by signal");
  await expect(resolveModelAuto(null, run.dependencies, AbortSignal.abort(reason))).rejects.toBe(reason);
  expect(run.downloads).toEqual([]); expect(run.closes()).toBe(1);
  const controller = new AbortController();
  const cancelled = selection([]);
  await expect(resolveModelAuto(null, { ...cancelled.dependencies, download: (_repo, options) => new Promise((_, reject) => {
    options!.signal!.addEventListener("abort", () => reject(options!.signal!.reason), { once: true });
    controller.abort(reason);
  }) }, controller.signal)).rejects.toBe(reason);
  expect(cancelled.closes()).toBe(1);
});

test("starter failure closes the registry and never starts the background download", async () => {
  const run = selection([]), calls: string[] = [];
  await expect(resolveModelAuto(null, { ...run.dependencies, download: async repo => { calls.push(repo); throw new Error("offline"); } })).rejects.toThrow("offline");
  expect(calls).toEqual([STARTER_REPO_ID]); expect(run.closes()).toBe(1);
});

test("no automatic fit reports explicit selection as the escape hatch and closes the registry", async () => {
  const run = selection([model("large")]);
  await expect(resolveModelAuto(null, { ...run.dependencies, assess: async () => ({ full: false, coexist: false }) })).rejects.toThrow("pick one explicitly");
  expect(run.closes()).toBe(1); expect(run.downloads).toEqual([]);
});

test("a local model directory bypasses registry and fit; missing weights report the path", async () => {
  const directory = mkdtempSync(join(tmpdir(), "mlx-selection-"));
  writeFileSync(join(directory, "config.json"), "{}");
  try {
    const selected = model("local");
    const dependencies = { registry: () => { throw new Error("must not open registry"); },
      scanSnapshot: async (path: string) => { expect(path).toBe(directory); return selected; } };
    expect(await resolveModelAuto(directory, dependencies)).toEqual({ m: selected, picked: false });
    await expect(resolveModelAuto(directory, { ...dependencies, scanSnapshot: async () => null })).rejects.toThrow("no weights");
  } finally { rmSync(directory, { recursive: true, force: true }); }
});
