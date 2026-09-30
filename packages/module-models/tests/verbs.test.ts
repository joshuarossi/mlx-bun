import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { CatalogEntry, ModelDetails } from "@mlx-bun/app-core";
import { runGc, runGet, runLs, runScan } from "../src";
import { fakeCatalog, invoke } from "./support";

const roots: string[] = [];
const previous = process.env.HF_HUB_CACHE;
afterEach(() => {
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
  if (previous === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = previous;
});
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-models-verbs-")); roots.push(root); return root; }

const details: ModelDetails = { parameters: 4e9, quantBits: 4, quantGroupSize: 64, license: "apache-2.0", vision: true, audio: false, tools: true, kvQuant: false,
  expertsBytes: 0, sidecarBytes: 0, supportTier: "targeted", revision: "0123456789abcdef", canonical: true };
const model = (id: string, extra: Partial<CatalogEntry> = {}): CatalogEntry =>
  ({ id, kind: "model", directory: `/hub/${id}/snapshots/0123456789abcdef`, bytes: 2 * 2 ** 30, operations: ["generate"], modelType: "gemma4", details, ...extra });

test("scan reports the snapshots the catalog indexed and a failure fails its step", async () => {
  const ok = invoke("scan", []);
  expect(await runScan(ok.invocation, fakeCatalog([], { rescan: async () => 3 }))).toBe(0);
  expect(ok.console.steps).toEqual(["start:scanning the Hugging Face cache", "done:indexed 3 model snapshot(s)"]);
  const bad = invoke("scan", []);
  await expect(runScan(bad.invocation, fakeCatalog([], { rescan: async () => { throw new Error("no cache"); } }))).rejects.toThrow("no cache");
  expect(bad.console.steps).toEqual(["start:scanning the Hugging Face cache", "fail:scan failed"]);
});

test("ls lists one row per model with its capabilities and passes the filters to the catalog", async () => {
  const filters: unknown[] = [];
  const catalog = fakeCatalog([], { async list(filter) { filters.push(filter); return [model("org/gemma", { details: { ...details, quantBits: null, license: null, parameters: null, supportTier: null, tools: false } }), model("org/other")]; } });
  const run = invoke("ls", ["--vision", "--max-size", "10GB", "gem"]);
  expect(await runLs(run.invocation, catalog)).toBe(0);
  expect(filters).toEqual([{ companions: true, revisions: "canonical", vision: true, maxBytes: 10 * 2 ** 30, query: "gem" }]);
  expect(run.console.headings).toEqual(["library"]);
  expect(run.console.tables[0]).toEqual([
    ["model", "size", "params", "quant", "license", "capabilities"],
    ["org/gemma", "2.00 GB", "?", "full", "?", "unsupported (gemma4) · vision"],
    ["org/other", "2.00 GB", "4.0B", "4-bit g64", "apache-2.0", "supported (targeted) · vision · tools"],
  ]);
  expect(run.console.out.join("")).toContain("2 model(s) · mlx-bun fit <query> for a memory assessment");
  const bad = invoke("ls", ["--max-size", "big"]);
  await expect(runLs(bad.invocation, catalog)).rejects.toThrow("bad size: big");
});

test("ls --all-revisions shows each snapshot with the canonical one marked; no match says how to re-index", async () => {
  const catalog = fakeCatalog([], { list: async () => [model("org/gemma"), model("org/gemma", { directory: "/hub/x/snapshots/fedcba9876543210", details: { ...details, revision: "fedcba9876543210", canonical: false } })] });
  const run = invoke("ls", ["--all-revisions"]);
  await runLs(run.invocation, catalog);
  expect(run.console.tables[0]!.slice(1).map(row => row[1])).toEqual(["0123456789ab *", "fedcba987654"]);
  expect(run.console.out.join("")).toContain("2 snapshot(s) · * = canonical (refs/main) · superseded snapshots: `mlx-bun gc`");
  const none = invoke("ls", ["nothing"]);
  await runLs(none.invocation, fakeCatalog([], { list: async () => [] }));
  expect(none.console.out).toEqual(["no models match (try `mlx-bun scan`)\n"]);
});

test("get resolves a substring through the catalog, downloads with progress, and mentions a previous revision it left on disk", async () => {
  const hub = temporary(), repo = join(hub, "models--org--gemma");
  mkdirSync(join(repo, "snapshots/old"), { recursive: true });
  process.env.HF_HUB_CACHE = hub;
  const seen: unknown[] = [];
  const catalog = fakeCatalog([], {
    async find(query) { seen.push(`find ${query}`); return model("org/gemma"); },
    async download(id, options) { seen.push(["download", id, options?.revision]); options?.onProgress?.("model.safetensors", 2 ** 30, 2 ** 31); return model(id, { directory: join(repo, "snapshots/new") }); },
  });
  const run = invoke("get", ["gemma", "--revision", "abc"]);
  expect(await runGet(run.invocation, catalog)).toBe(0);
  expect(seen).toEqual(["find gemma", ["download", "org/gemma", "abc"]]);
  expect(run.console.steps).toEqual(["start:downloading org/gemma", "update:org/gemma · model.safetensors · 1.00 GB / 2.00 GB (50%)", "done:org/gemma downloaded · verified",
    "start:updating registry", `done:registry updated · ${join(repo, "snapshots/new")}`]);
  expect(run.console.out.join("")).toContain("previous revision kept on disk — `mlx-bun gc` reclaims ~");
  const failing = invoke("get", ["org/gemma"]);
  await expect(runGet(failing.invocation, fakeCatalog([], { download: async () => { throw new Error("HTTP 401"); } }))).rejects.toThrow("HTTP 401");
  expect(failing.console.steps.at(-1)).toBe("fail:download failed");
  const unknown = invoke("get", ["nothing"]);
  await expect(runGet(unknown.invocation, fakeCatalog([], { find: async () => { throw new Error('no model matching "nothing"'); } })))
    .rejects.toThrow(/no model matching "nothing"\nusage: mlx-bun get <org\/repo>/);
});

function syntheticCache() {
  const hub = temporary(), repo = join(hub, "models--example--tiny");
  mkdirSync(join(repo, "blobs"), { recursive: true });
  for (const [revision, bytes] of [["old", 3], ["current", 5]] as const) {
    const snapshot = join(repo, "snapshots", revision);
    mkdirSync(snapshot, { recursive: true });
    writeFileSync(join(snapshot, "config.json"), JSON.stringify({ model_type: "qwen3" }));
    writeFileSync(join(repo, "blobs", revision), new Uint8Array(bytes));
    symlinkSync(`../../blobs/${revision}`, join(snapshot, "model.safetensors"));
  }
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "current");
  process.env.HF_HUB_CACHE = hub;
  return { hub, repo };
}

test("gc previews by default, dry-run beats yes, and confirmed deletion re-indexes the catalog", async () => {
  const { repo } = syntheticCache();
  let rescans = 0;
  const catalog = fakeCatalog([], { rescan: async () => { rescans++; return 0; } });
  const preview = invoke("gc", []);
  await runGc(preview.invocation, catalog);
  expect(preview.console.tables[0]![1]).toEqual(["example/tiny", "1", "1", "0", "0.00 GB"]);
  expect(preview.console.out.join("")).toContain("nothing deleted — rerun with --yes to delete (destructive).");
  expect(existsSync(join(repo, "snapshots/old"))).toBe(true);
  await runGc(invoke("gc", ["--yes", "--dry-run"]).invocation, catalog);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(true); expect(rescans).toBe(0);
  const confirmed = invoke("gc", ["--yes"]);
  await runGc(confirmed.invocation, catalog);
  expect(existsSync(join(repo, "snapshots/old"))).toBe(false); expect(existsSync(join(repo, "snapshots/current"))).toBe(true);
  expect(confirmed.console.out.join("")).toContain("deleted 1 snapshot(s) + 1 blob(s)");
  expect(rescans).toBe(1);
  const nothing = invoke("gc", []);
  await runGc(nothing.invocation, catalog);
  expect(nothing.console.out.join("")).toContain("nothing to reclaim — every snapshot is referenced by refs/*");
});
