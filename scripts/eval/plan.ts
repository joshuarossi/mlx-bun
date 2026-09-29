// Evaluation plan: the tasks, model artifact, datasets, MLX library and
// verifier image both servers are evaluated with, pinned by content before
// any server starts and verified again at the start and end of every run.
// Metadata only: nothing here loads MLX, a model or Python.
import { existsSync, readFileSync } from "node:fs";
import { basename, isAbsolute, join, resolve } from "node:path";
import { artifactFiles, describeModel, nativeFiles, sha256, type FileRecord, type ModelSpec } from "../bench/plan";
import { diskGb } from "./scoring";
import { CAPABILITY, parseTasks, SMOKETEST, TASKS, type TaskId } from "./tasks";

export interface DatasetPin { sha256: string; rows: number; source: string }
/** Main's evaluation data by content. Main read these from
 * ~/.cache/mlx-bun/eval-data: `gsm8k` comes from main's
 * scripts/oracle/export-datasets.py (openai/gsm8k, config main, split test);
 * the `*_optiq_frozen` sets (main's default for every task) are mlx-optiq's own
 * evaluation draws, captured once and produced by no tracked script. */
export const DATASETS: Readonly<Record<string, DatasetPin>> = {
  gsm8k_optiq_frozen: { sha256: "6bdb627a663caf5a6fff2d74ace7818223b788f76db2f789f7d4a0bdfe194e73", rows: 1000,
    source: "mlx-optiq's GSM8K draw of openai/gsm8k (main, test)" },
  gsm8k: { sha256: "752adc99f23132275139f1f7be57126b08735a55daf0c56859ee6df70abafbac", rows: 1319,
    source: "openai/gsm8k config main split test, exported by main's scripts/oracle/export-datasets.py" },
  mmlu_optiq_frozen: { sha256: "210ef853fecdc22aa45e925063a5d67468dea8f10d89388ed55beaa162ac8ead", rows: 969,
    source: "mlx-optiq's stratified MMLU draw of cais/mmlu (all, test)" },
  mmlu_optiq_dev: { sha256: "147bce5b06a81d81f7351ca1d227a596e21a92948c3390b2de49f4b149d87868", rows: 285,
    source: "mlx-optiq's MMLU 5-shot exemplars, cais/mmlu (all, dev)" },
  ifeval_optiq_frozen: { sha256: "70094fb2c1dd6141b61f5d6b0da51a61e97329921985ae44bb6dcf2973d36078", rows: 541,
    source: "mlx-optiq's IFEval set, google/IFEval (train)" },
  bfcl_optiq_frozen: { sha256: "34864eba667d8758258728731d3e3ba972fbada34ff55aa6716d086a24d52a18", rows: 200,
    source: "mlx-optiq's BFCL v3 simple draw, gorilla-llm/Berkeley-Function-Calling-Leaderboard" },
  humaneval_optiq_frozen: { sha256: "b015e913708f70b4a100b126d5345d2b29effc3ed6e348be45a82a26cb6b89f1", rows: 164,
    source: "mlx-optiq's HumanEval set, openai/openai_humaneval (test)" },
  hashhop_optiq_frozen: { sha256: "56f895fd1ca9235e8184170ba3419202951b5977dd5d3a0bfe01064dd0c7329a", rows: 100,
    source: "mlx-optiq's MultiHopEval problems (seed 42, 25 per hop count 1-4, ~12k characters)" },
};

export interface DatasetRecord { name: string; file: string; bytes: number; sha256: string; rows: number }
export interface EvalModel extends ModelSpec {
  /** Main's ChatTemplate.load found a template: chat requests, else raw completions. */
  chatTemplate: boolean;
  /** Hugging Face repository and snapshot revision, when the path is a hub snapshot. */
  repo: string | null;
  revision: string | null;
  diskGb: number;
}
export interface EvalPlan {
  schema: 1;
  kind: "capability-eval";
  tasks: TaskId[];
  /** Main's MLX_BUN_EVAL_THINK: the chat template's enable_thinking (BFCL stays off, as in main). */
  enableThinking: boolean;
  model: EvalModel;
  data: { dir: string; files: DatasetRecord[] };
  /** The MLX library every evaluated server loads (MLX_BUN_LIBMLXC); files[0] is the exact file. */
  native: { library: string; files: FileRecord[] };
  /** Digest-pinned image for the Docker verifier; null uses the verifier's own default. */
  pythonImage: string | null;
}

/** Main's ChatTemplate.load: tokenizer_config.json's chat_template, else
 * chat_template.jinja, else GLM-5.2's built-in renderer. Any failure (no
 * readable tokenizer_config.json) meant no template in main's task runner. */
export function hasChatTemplate(dir: string): boolean {
  try {
    const config = JSON.parse(readFileSync(join(dir, "tokenizer_config.json"), "utf8")) as { chat_template?: unknown };
    if (config.chat_template) return true;
    if (existsSync(join(dir, "chat_template.jinja")) && readFileSync(join(dir, "chat_template.jinja"), "utf8")) return true;
    const model = existsSync(join(dir, "config.json")) ? JSON.parse(readFileSync(join(dir, "config.json"), "utf8")) as { model_type?: unknown } : null;
    return model?.model_type === "glm_moe_dsa";
  } catch { return false; }
}

export function describeEvalModel(path: string): EvalModel {
  const spec = describeModel("model", path);
  const hub = spec.path.match(/\/models--([^/]+?)--([^/]+)\/snapshots\/([0-9a-f]{40})$/);
  return { ...spec, chatTemplate: hasChatTemplate(spec.path), repo: hub ? `${hub[1]}/${hub[2]}` : null,
    revision: hub ? hub[3]! : null, diskGb: diskGb(spec.files) };
}

/** Main's loadJsonl: one JSON value per non-empty trimmed line. */
export function parseJsonl(text: string): unknown[] {
  const out: unknown[] = [];
  for (const line of text.split("\n")) {
    const t = line.trim();
    if (t) out.push(JSON.parse(t));
  }
  return out;
}

/** Read one dataset file once: the rows parsed are the bytes hashed. */
export function readDataset(dir: string, name: string): { record: DatasetRecord; rows: unknown[] } {
  const file = join(dir, `${name}.jsonl`);
  if (!existsSync(file)) throw new Error(`dataset ${name} is missing: ${file}`);
  const bytes = readFileSync(file);
  const rows = parseJsonl(bytes.toString("utf8"));
  return { record: { name, file, bytes: bytes.length, sha256: sha256(bytes), rows: rows.length }, rows };
}

export const datasetsFor = (tasks: readonly TaskId[]) => [...new Set(tasks.flatMap(task => TASKS[task].datasets))];

/** Each dataset of the plan must be main's pinned revision. */
export function datasetPinProblems(plan: EvalPlan, pins: Readonly<Record<string, DatasetPin>> = DATASETS): string[] {
  return plan.data.files.flatMap(file => {
    const pin = pins[file.name];
    if (!pin) return [`dataset ${file.name} has no pinned revision`];
    if (file.sha256 !== pin.sha256 || file.rows !== pin.rows)
      return [`dataset ${file.name} (sha256 ${file.sha256.slice(0, 12)}, ${file.rows} rows) is not the pinned revision (${pin.sha256.slice(0, 12)}, ${pin.rows} rows)`];
    return [];
  });
}

const PINNED_IMAGE = /^[a-z0-9][\w.\-/:]*@sha256:[0-9a-f]{64}$/;
export interface PlanOptions { model: string; data: string; native: string; tasks?: string; enableThinking?: boolean; pythonImage?: string }
export function makePlan(options: PlanOptions, pins: Readonly<Record<string, DatasetPin>> = DATASETS): EvalPlan {
  for (const [flag, value] of [["--model", options.model], ["--data", options.data], ["--native", options.native]] as const)
    if (!value || !isAbsolute(value) || !existsSync(value)) throw new Error(`${flag} must be an existing absolute path`);
  if (options.pythonImage && !PINNED_IMAGE.test(options.pythonImage)) throw new Error("--python-image must be pinned by digest (repo@sha256:<64 hex>)");
  const tasks = parseTasks(options.tasks ?? "all");
  const dir = resolve(options.data);
  const files = datasetsFor(tasks).map(name => readDataset(dir, name).record);
  const plan: EvalPlan = { schema: 1, kind: "capability-eval", tasks, enableThinking: options.enableThinking ?? false,
    model: describeEvalModel(options.model), data: { dir, files },
    native: { library: resolve(options.native), files: nativeFiles(options.native) }, pythonImage: options.pythonImage ?? null };
  const problems = datasetPinProblems(plan, pins);
  if (problems.length) throw new Error(`datasets are not main's pinned revisions:\n  ${problems.join("\n  ")}`);
  return plan;
}

export function validatePlan(value: unknown): EvalPlan {
  const plan = value as EvalPlan;
  const fail = (message: string): never => { throw new Error(`invalid plan: ${message}`); };
  if (!plan || plan.schema !== 1 || plan.kind !== "capability-eval") fail("not a schema 1 capability-eval plan");
  if (!Array.isArray(plan.tasks) || !plan.tasks.length || plan.tasks.some(task => !(task in TASKS)))
    fail("tasks must be known task ids");
  if (JSON.stringify(parseTasks(plan.tasks.join(","))) !== JSON.stringify(plan.tasks)) fail("tasks must be unique and in main's order");
  if (typeof plan.enableThinking !== "boolean") fail("enableThinking must be a boolean");
  if (!plan.model || !isAbsolute(plan.model.path) || !Array.isArray(plan.model.files) || !plan.model.files.length) fail("model is not pinned");
  if (!plan.data || !isAbsolute(plan.data.dir) || !Array.isArray(plan.data.files)) fail("data is not pinned");
  const names = plan.data.files.map(file => file.name);
  if (JSON.stringify(names) !== JSON.stringify(datasetsFor(plan.tasks))) fail("datasets do not match the tasks");
  if (!plan.native?.library || !isAbsolute(plan.native.library) || !plan.native.files?.length) fail("native library is not pinned");
  if (plan.pythonImage !== null && !PINNED_IMAGE.test(plan.pythonImage)) fail("pythonImage must be pinned by digest");
  return plan;
}

/** Re-read every pinned input: model files, datasets (returned parsed) and the MLX library. */
export function checkPins(plan: EvalPlan): { problems: string[]; rows: Record<string, unknown[]> } {
  const problems: string[] = [], rows: Record<string, unknown[]> = {};
  try {
    if (JSON.stringify(artifactFiles(plan.model.path)) !== JSON.stringify(plan.model.files)) problems.push(`model files changed in ${plan.model.path}`);
  } catch (error) { problems.push(`model unreadable: ${String(error)}`); }
  for (const pinned of plan.data.files) {
    try {
      const { record, rows: parsed } = readDataset(plan.data.dir, pinned.name);
      if (record.sha256 !== pinned.sha256 || record.rows !== pinned.rows) problems.push(`dataset ${pinned.name} changed (${basename(record.file)})`);
      else rows[pinned.name] = parsed;
    } catch (error) { problems.push(String(error instanceof Error ? error.message : error)); }
  }
  try {
    if (JSON.stringify(nativeFiles(plan.native.library)) !== JSON.stringify(plan.native.files)) problems.push("native library files changed");
  } catch (error) { problems.push(`native library unreadable: ${String(error)}`); }
  return { problems, rows };
}

export interface TaskListing {
  id: TaskId;
  /** Main's capability component; the smoketest subset has none. */
  component: string | null;
  /** The task sets that contain it (`--tasks capability|smoketest|all`). */
  sets: string[];
  /** Executes generated code, so it needs the Docker verifier. */
  needsVerifier: boolean;
  /** Each dataset file the task reads, with its pin and, when a data directory is named, whether the file is there. */
  datasets: Array<{ name: string; rows: number; sha256: string; source: string; present?: boolean }>;
}

/** The tasks a plan can name, in main's order. `data` adds each dataset's presence (never its content: `plan` verifies the pins). */
export function listTasks(data?: string, pins: Readonly<Record<string, DatasetPin>> = DATASETS): TaskListing[] {
  return parseTasks("all").map(id => ({ id, component: TASKS[id].component,
    sets: [...(CAPABILITY.includes(id) ? ["capability"] : []), ...(SMOKETEST.includes(id) ? ["smoketest"] : []), "all"],
    needsVerifier: TASKS[id].needsVerifier === true,
    datasets: TASKS[id].datasets.map(name => ({ name, rows: pins[name]!.rows, sha256: pins[name]!.sha256, source: pins[name]!.source,
      ...(data ? { present: existsSync(join(data, `${name}.jsonl`)) } : {}) })) }));
}
