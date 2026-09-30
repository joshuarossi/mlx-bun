// The module as a host loads it: a valid manifest that needs jobs, storage and catalog, the fine-tune routes at their shipped
// root paths, a process job under the exclusive GPU lease, and each verb dispatched with what the host parsed.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createRegistryCatalog, createStorage, parseVerb, plainTerminal } from "@mlx-bun/app-services";
import train, { createTrainModule } from "../src";
import { manifest } from "../src/manifest";

/** The host's registry-backed catalog over an index that holds nothing: a model directory is used as given. */
const catalog = () => createRegistryCatalog({ registry: () => { throw new Error("no index in this test"); } });
const noJobs = { submit: async () => { throw new Error("no jobs here"); }, get: async () => undefined, list: async () => [], cancel: async () => {}, events: () => (async function* () {})() };

test("the manifest is valid for a host with jobs, storage and catalog, and declares the finetune job under the exclusive GPU lease", () => {
  expect(train.requires).toEqual(["jobs", "storage", "catalog"]);
  expect(checkManifests([train], { provided: ["jobs", "storage", "catalog"] })).toEqual([]);
  expect(checkManifests([train], { provided: ["jobs", "storage"] })).toEqual(['module "train": requires "catalog", which this host does not implement']);
  expect(train.jobs).toEqual([{ kind: "finetune", isolation: "process", gpu: "exclusive" }]);
  expect(train.sockets ?? []).toEqual([]);
  expect(manifest.verbs.map(verb => verb.name)).toEqual(["train", "draft", "train-watch", "fuse"]);
  // Two modules that declare the same entries (the models and datasets other modules also write) share them.
  const sharer = { ...train, id: "sharer", panel: undefined, routes: [], verbs: [], jobs: [], storage: [manifest.storage[1], manifest.storage[2]] };
  expect(checkManifests([train, sharer], { provided: ["jobs", "storage", "catalog"] })).toEqual([]);
});

test("the draft verb declares its subcommands and required action, and every verb option parses as the verb reads it", () => {
  const draft = manifest.verbs.find(verb => verb.name === "draft")!;
  expect(draft.details).toContain("regen <model> --topics <file>");
  expect(() => parseVerb("mlx-bun", draft, [])).toThrow("usage: mlx-bun draft <regen|train|calibrate|quantize> <model|drafter-dir> [options]");
  expect(parseVerb("mlx-bun", draft, ["regen", "--model", "m", "--topics", "t"])).toEqual({ values: { model: "m", topics: "t" }, positionals: ["regen"] });
  const train = manifest.verbs.find(verb => verb.name === "train")!;
  expect(parseVerb("mlx-bun", train, ["--data", "d", "--no-flash", "m"])).toEqual({ values: { data: "d", "no-flash": true }, positionals: ["m"] });
  expect(() => parseVerb("mlx-bun", train, ["--data", "d", "--serial"])).toThrow("Unknown option '--serial'");
});

test("activated, it serves its routes at their shipped paths, keeps its storage entries under the root, and runs the verbs it declares", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-train-module-"));
  const written: string[] = [], submitted: unknown[] = [];
  try {
    const services = { jobs: () => ({ ...noJobs, submit: async (submission: unknown) => { submitted.push(submission);
      return { id: "job_1", kind: "finetune", status: "queued" as const, progress: 0, message: null, outputPath: null, error: null, startedAt: "", endedAt: null }; } }),
      storage: createStorage(() => root), catalog };
    const loaded = await loadModules([createTrainModule()], { services });
    try {
      expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual(["POST /api/finetune/inspect-dataset", "POST /api/finetune/submit"]);
      expect([...loaded.verbs.keys()]).toEqual(["train", "draft", "train-watch", "fuse"]);
      expect([...loaded.jobs.keys()]).toEqual(["finetune"]);
      expect(loaded.storage.map(item => `${item.key}:${item.path}`)).toEqual(["adapters:adapters", "models:models", "datasets:datasets"]);
      // The default adapter directory is the module's `adapters` entry, resolved by the host's storage root.
      const routes = createModuleRoutes(loaded.routes);
      const response = await routes.handle(new Request("http://localhost/api/finetune/submit", { method: "POST", body: JSON.stringify({ model_dir: "/m", data_dir: "/d" }) }));
      const body = await response!.json() as { ok: boolean; job_id: string; adapter_path: string };
      expect(body).toMatchObject({ ok: true, job_id: "job_1" });
      expect(body.adapter_path.startsWith(join(root, "adapters", "adapter-"))).toBe(true);
      expect(submitted).toEqual([{ kind: "finetune", config: { model_dir: "/m", data_dir: "/d", adapter_path: body.adapter_path }, outputPath: body.adapter_path }]);
      expect(await routes.handle(new Request("http://localhost/api/finetune/merge", { method: "POST" }))).toBeNull();
      // The runner refuses an incomplete config before any native import.
      await expect(loaded.jobs.get("finetune")!.runner(() => {}, {}, new AbortController().signal)).rejects.toThrow("finetune job: missing model_dir");
      // `train` resolves the model through the catalog and prints the plan; a dry run trains nothing.
      const model = join(root, "model"), data = join(root, "data");
      mkdirSync(model); mkdirSync(data);
      writeFileSync(join(model, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 8, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2,
        intermediate_size: 16, vocab_size: 32, max_position_embeddings: 64 }));
      writeFileSync(join(data, "train.jsonl"), JSON.stringify({ prompt: "p", chosen: "c", rejected: "r" }) + "\n");
      const verb = loaded.verbs.get("train")!;
      const code = await verb.handler({ ...parseVerb("mlx-bun", verb.spec, [model, "--data", data, "--dry-run"]), signal: new AbortController().signal,
        stdout: text => { written.push(text); }, stderr: () => {}, terminal: plainTerminal(text => { written.push(text); }) });
      expect(code).toBe(0);
      const printed = written.join("");
      expect(printed).toContain("train orpo · model");
      expect(printed).toContain(`adapter    ${join(root, "adapters", "orpo-model")}`);
      expect(printed).toContain("dry run — not training.");
    } finally { await loaded.stop(); }
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("train keeps the cancellation message its interrupted runs always ended with", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-train-cancel-"));
  try {
    const loaded = await loadModules([createTrainModule()], { services: { jobs: () => noJobs, storage: createStorage(() => root), catalog } });
    try {
      const abort = new AbortController();
      abort.abort(new Error("train cancelled")); // what the host aborts every verb with
      const run = (name: string, ...argv: string[]) => { const verb = loaded.verbs.get(name)!;
        return verb.handler({ ...parseVerb("mlx-bun", verb.spec, argv), signal: abort.signal, stdout: () => {}, stderr: () => {}, terminal: plainTerminal(() => {}) }); };
      await expect(run("train", "--data", "/nonexistent")).rejects.toThrow("no train.jsonl in /nonexistent"); // validation first, as before
      const data = join(root, "data"); mkdirSync(data); writeFileSync(join(data, "train.jsonl"), "");
      await expect(run("train", "m", "--data", data)).rejects.toThrow("training cancelled");
    } finally { await loaded.stop(); }
  } finally { rmSync(root, { recursive: true, force: true }); }
});
