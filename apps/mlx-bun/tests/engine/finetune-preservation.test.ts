// Opt-in preservation of fine-tuning against pre-refactor main, for any model
// family and training path main's fine-tune producer ran (SFT/DPO/ORPO, batch
// and accumulation, segmented backward, prefix sharing, flash/fused/chunked
// heads, gradient checkpointing, dropout, rsLoRA, LoRA+, rank scaling,
// checkpoints, warm start). Nothing is committed: each reference is a JSON file
// made outside the repository,
//   { "submit": <the snake_case record main's finetuneRunner received>,
//     "fused_path"?: <main's `fuse` output for submit.adapter_path> }
// where submit.adapter_path holds main's finished adapter directory. In a
// checkout of main 02d723a, with the same staged native bundle as this tree
// (MLX_BUN_LIBMLXC), the same artifact, data and settings:
//   REF=<ref.json> bun -e 'const r = await Bun.file(process.env.REF).json();
//     await (await import("./src/train/job.ts")).finetuneRunner(() => {}, r.submit)'
//   bun src/cli.ts fuse <submit.model_dir> --adapter <submit.adapter_path> --save-path <fused_path>
// Then here, from apps/mlx-bun:
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_FINETUNE_REFERENCES=<ref.json>[:<ref.json>...] \
//     bun test tests/engine/finetune-preservation.test.ts
// Each reference runs the app's fine-tune producer (the one `train` and the
// finetune job use) with the same record into a temporary adapter directory,
// then requires main's exact training record: every train/val metric value
// (loss, gradient norm, learning rate, accuracy, margin, counts; timing,
// throughput, memory, progress and messages excluded), both config files,
// every adapter tensor's bytes, each checkpoint, and metrics.json without its
// wall time and peak memory. A fresh load of the base model then mounts both
// adapters: full-sequence logits must match byte for byte and differ from the
// base. With fused_path, the library's fuse (the `fuse` verb's operation) of
// the new adapter must reproduce main's fused snapshot file for file. This is
// migration preservation, not an independent training oracle; it loads models
// natively and trains on the GPU.
import { describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, relative } from "node:path";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const referenceFiles = (process.env.MLX_BUN_APP_TEST_FINETUNE_REFERENCES ?? "").split(":").filter(Boolean);
if (referenceFiles.length && !native)
  throw new Error("MLX_BUN_APP_TEST_FINETUNE_REFERENCES is set but MLX_BUN_TEST_NATIVE=1 is not; refusing to skip a requested comparison");

interface Reference {
  file: string;
  submit: Record<string, unknown> & { model_dir: string; data_dir: string; adapter_path: string };
  fusedPath?: string;
}

function readReference(file: string): Reference {
  const raw = JSON.parse(readFileSync(file, "utf8")) as { submit?: Record<string, unknown>; fused_path?: unknown };
  const submit = raw.submit;
  if (!submit || typeof submit !== "object") throw new Error(`${file}: expected { "submit": {...} }`);
  for (const name of ["model_dir", "data_dir", "adapter_path"])
    if (typeof submit[name] !== "string" || !submit[name]) throw new Error(`${file}: submit.${name} is required`);
  const main = submit.adapter_path as string;
  for (const name of ["adapters.safetensors", "optiq_lora_config.json", "adapter_config.json", "metrics.jsonl"])
    if (!existsSync(join(main, name))) throw new Error(`${file}: main's adapter directory ${main} has no ${name}`);
  if (raw.fused_path !== undefined && (typeof raw.fused_path !== "string" || !existsSync(join(raw.fused_path, "config.json"))))
    throw new Error(`${file}: fused_path must name main's fused snapshot directory`);
  return { file, submit: submit as Reference["submit"], ...(typeof raw.fused_path === "string" ? { fusedPath: raw.fused_path } : {}) };
}
// Validate every reference before any native import or training starts.
const references = native ? referenceFiles.map(readReference) : [];

const METRIC_FIELDS = ["kind", "step", "loss", "grad_norm", "learning_rate", "accuracy", "margin",
  "n_correct", "n_total", "val_rows_used", "val_rows_skipped"];
const META_FIELDS = ["method", "model", "iters", "learning_rate", "max_seq_length", "batch_size", "rank", "scale",
  "orpo_lambda", "sft_scope"];
const PROBE = "Hello from a small model.";

const json = (path: string) => JSON.parse(readFileSync(path, "utf8")) as unknown;
const sha = (bytes: Uint8Array) => new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
const pick = (record: Record<string, unknown>, fields: string[]) =>
  Object.fromEntries(fields.filter(field => record[field] !== undefined).map(field => [field, record[field]]));

/** The trainer's append-only record without timing, throughput, memory, progress or messages. */
function trainingRecord(dir: string) {
  const lines = readFileSync(join(dir, "metrics.jsonl"), "utf8").split("\n").filter(line => line.trim())
    .map(line => JSON.parse(line) as Record<string, unknown>);
  return {
    meta: lines.filter(line => line.type === "meta").map(line => pick(line, META_FIELDS)),
    metrics: lines.filter(line => line.type === "metric").map(line => pick(line, METRIC_FIELDS)),
  };
}

/** metrics.json (save_checkpoints) without wall time and peak memory; checkpoint paths relative to the adapter. */
function runRecord(dir: string): unknown {
  const file = join(dir, "metrics.json");
  if (!existsSync(file)) return null;
  const { wallSeconds: _wall, peakGb: _peak, ...rest } = json(file) as Record<string, unknown>;
  return JSON.parse(JSON.stringify(rest).split(dir).join("<adapter>"));
}

async function tensorDigests(file: string) {
  const { loadAdapterTensors } = await import("@mlx-bun/inference/adapters");
  const tensors = loadAdapterTensors(file);
  try {
    return [...tensors].sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0)
      .map(([name, tensor]) => ({ name, dtype: tensor.dtype, shape: [...tensor.shape], sha256: sha(tensor.rawBytes()) }));
  } finally { for (const tensor of tensors.values()) tensor.dispose(); }
}

async function expectSameAdapter(candidate: string, main: string) {
  expect(await tensorDigests(join(candidate, "adapters.safetensors"))).toEqual(await tensorDigests(join(main, "adapters.safetensors")));
  for (const name of ["optiq_lora_config.json", "adapter_config.json"])
    expect(json(join(candidate, name)), name).toEqual(json(join(main, name)));
}

const checkpointNames = (dir: string) => existsSync(join(dir, "checkpoints")) ? readdirSync(join(dir, "checkpoints")).sort() : [];

async function fileDigest(path: string): Promise<string> {
  const hasher = new Bun.CryptoHasher("sha256");
  for await (const chunk of Bun.file(path).stream()) hasher.update(chunk);
  return hasher.digest("hex");
}

async function treeDigest(root: string): Promise<Record<string, string>> {
  const out: Record<string, string> = {};
  const walk = async (dir: string) => {
    for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name < b.name ? -1 : 1)) {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) await walk(path);
      else out[relative(root, path)] = await fileDigest(path);
    }
  };
  await walk(root);
  return out;
}

/** Full-sequence logits of a probe on a fresh base graph: base, then each mounted adapter alone. */
async function reloadLogits(modelDir: string, adapters: Record<string, string>): Promise<Record<string, Uint8Array>> {
  const [{ loadModelConfig, Weights }, { createModel }, { loadTokenizer }, { AdapterManager }, { trainForward }, { MlxArray }] =
    await Promise.all([import("@mlx-bun/inference/artifacts"), import("@mlx-bun/inference/models"),
      import("@mlx-bun/inference/input"), import("@mlx-bun/inference/adapters"), import("@mlx-bun/inference/scoring"),
      import("@mlx-bun/mlx/array")]);
  const config = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);
  try {
    const model = createModel(weights, config);
    const manager = new AdapterManager(model);
    const tokenizer = await loadTokenizer(modelDir);
    const ids = tokenizer.encode(PROBE).slice(0, 8);
    const input = MlxArray.fromInt32(Int32Array.from(ids), [1, ids.length]);
    try {
      for (const [id, dir] of Object.entries(adapters)) expect((await manager.mount(id, dir)).mountedLayers).toBeGreaterThan(0);
      const logits = (active: string[]) => {
        model.loraState.active = active;
        const out = trainForward(model, input);
        try { return out.rawBytes(); } finally { out.dispose(); }
      };
      const result: Record<string, Uint8Array> = { base: logits([]) };
      for (const id of Object.keys(adapters)) result[id] = logits([id]);
      return result;
    } finally {
      model.loraState.active = [];
      for (const id of Object.keys(adapters)) manager.unmount(id);
      input.dispose();
      if ("dispose" in model && typeof model.dispose === "function") model.dispose();
    }
  } finally { weights.dispose(); }
}

if (!references.length) test.skip("fine-tuning preserves main's training record (needs MLX_BUN_APP_TEST_FINETUNE_REFERENCES)", () => {});

describe("fine-tuning preserves main's training record", () => {
  for (const reference of references) {
    const { submit } = reference;
    test(`${reference.file}: ${String(submit.method ?? "sft")} on ${submit.model_dir}`, async () => {
      const root = mkdtempSync(join(tmpdir(), "mlx-finetune-preservation-"));
      const candidate = join(root, "adapter");
      try {
        const { createFinetuneRunner } = await import("../../src/finetune/job");
        const result = await createFinetuneRunner()(() => {}, { ...submit, adapter_path: candidate });
        expect(result).toEqual({ outputPath: candidate });

        const main = submit.adapter_path;
        const record = trainingRecord(candidate);
        expect(record.metrics.length).toBeGreaterThan(0);
        expect(record).toEqual(trainingRecord(main));
        await expectSameAdapter(candidate, main);
        expect(checkpointNames(candidate)).toEqual(checkpointNames(main));
        for (const name of checkpointNames(main))
          await expectSameAdapter(join(candidate, "checkpoints", name), join(main, "checkpoints", name));
        expect(runRecord(candidate)).toEqual(runRecord(main));

        const logits = await reloadLogits(submit.model_dir, { candidate, main });
        expect(Buffer.compare(logits.candidate!, logits.main!)).toBe(0);
        expect(Buffer.compare(logits.candidate!, logits.base!)).not.toBe(0);

        if (reference.fusedPath) {
          const { fuseAdapter } = await import("@mlx-bun/training");
          const fused = join(root, "fused");
          const stats = await fuseAdapter(submit.model_dir, candidate, fused);
          expect(stats.fusedModules).toBeGreaterThan(0);
          expect(await treeDigest(fused)).toEqual(await treeDigest(reference.fusedPath));
        }
      } finally { rmSync(root, { recursive: true, force: true }); }
    }, 7_200_000);
  }
});
