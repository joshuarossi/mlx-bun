// Paired serve benchmark plan: which trees, reference servers and artifacts
// are compared, pinned before any server starts and verified again at the end.
// Metadata only: nothing here loads MLX, models or Python.
import { createHash } from "node:crypto";
import { closeSync, existsSync, openSync, readdirSync, readFileSync, readSync, realpathSync, statSync } from "node:fs";
import { basename, isAbsolute, join, relative, resolve } from "node:path";

export type Tree = "baseline" | "candidate";
export const TREES: readonly Tree[] = ["baseline", "candidate"];

/** Server configurations measured on both trees, as main's matrix measured its own arms. */
export const CONFIGURATIONS = {
  default: { args: [] as string[], note: "real CLI defaults" },
  /** Capacity-1 control: main's `--batch 1` serial path versus the candidate's
   * continuous scheduler at capacity 1. Not a candidate serial lane. */
  serial: { args: ["--batch", "1"], note: "capacity-1 control (baseline serial, candidate continuous at capacity 1)" },
  mixed: { args: ["--kv-quant", "config"], note: "artifact kv_config.json", requiresKvConfig: true },
} as const;
export type Configuration = keyof typeof CONFIGURATIONS;

/** Main's canonical `all` matrix: every model, every configuration, the stock reference. */
export const CANONICAL = {
  models: ["cpm5", "e4b", "12B", "qwen27b"],
  configurations: ["default", "serial", "mixed"] as Configuration[],
  references: ["mlx-lm"],
  withContext: true,
} as const;

/** Main's workload, unchanged: sample counts, lengths and the stability guard. */
export const WORKLOAD = {
  decodeTokens: 192, contextTokens: 16384, decodeRuns: 5, ttftRuns: 3,
  aggregateStreams: 4, aggregateTokens: 128, aggregateContext: 0, aggregateStaggerMs: 0,
  /** Stability guard on one arm's own decode samples, never a comparison tolerance. */
  spreadLimit: 1.15,
} as const;

export const REQUIRED_PHASES = ["warmup", "parity", "decode", "ttft1k", "ctx", "restart", "agg"] as const;
export type Phase = (typeof REQUIRED_PHASES)[number];

export interface FileRecord { name: string; bytes: number; sha256: string; path?: string }
export interface TreeSpec {
  root: string;
  commit: string;
  /** Exact argv prefix that starts this tree's server; serve arguments follow. */
  command: string[];
}
export interface ReferenceSpec {
  /** Labeled external server, e.g. "mlx-lm". Its environment stays outside this repo. */
  label: string;
  command: string[];
  /** Used instead for architectures the stock server cannot load (main: gemma4_unified). */
  registerCommand?: string[];
  version?: string;
  /** Bearer key the reference server requires, if any. */
  apiKey?: string;
}
export interface ModelSpec {
  id: string;
  label: string;
  path: string;
  modelType: string;
  kvConfig: boolean;
  packedTrellis: boolean;
  files: FileRecord[];
}
export interface Plan {
  schema: 1;
  profile: "all" | "scoped";
  seed: string;
  /** Scoped plans may shrink the workload; profile all requires main's exact values. */
  workload: { -readonly [K in keyof typeof WORKLOAD]: number } & { withContext: boolean };
  trees: Record<Tree, TreeSpec>;
  references: ReferenceSpec[];
  configurations: Configuration[];
  models: ModelSpec[];
  /** Intended MLX library for both trees; children must prove they loaded it.
   * files[0] is the exact resolved library, the rest its bundled runtime. */
  native: { library: string; files: FileRecord[] };
  /** Predeclared applicability: every cell, with main's N/A reasons. Recomputed at run time. */
  cells: PlannedCell[];
}

export const sha256 = (bytes: Uint8Array | string) => createHash("sha256").update(bytes).digest("hex");
/** Streamed: weight shards are many gigabytes. */
export function fileSha(path: string): string {
  const hash = createHash("sha256"), fd = openSync(path, "r"), buffer = Buffer.allocUnsafe(8 << 20);
  try {
    for (let read; (read = readSync(fd, buffer, 0, buffer.length, null)) > 0;) hash.update(buffer.subarray(0, read));
  } finally { closeSync(fd); }
  return hash.digest("hex");
}

/** Every regular file of a snapshot, followed through the hub's symlinks. */
export function artifactFiles(dir: string): FileRecord[] {
  return readdirSync(dir).sort().flatMap(name => {
    const path = join(dir, name);
    if (!statSync(path).isFile()) return [];
    return [{ name, bytes: statSync(path).size, sha256: fileSha(path) }];
  });
}

export function describeModel(id: string, path: string, label?: string): ModelSpec {
  const resolved = realpathSync(path);
  const config = JSON.parse(readFileSync(join(resolved, "config.json"), "utf8"));
  const quant = config.quantization ?? config.quantization_config ?? config.text_config?.quantization ?? {};
  const files = artifactFiles(resolved);
  if (!files.some(file => file.name.endsWith(".safetensors") && file.bytes > 0)) throw new Error(`${id}: no weights in ${resolved}`);
  return {
    id, label: label || basename(resolved), path: resolved, modelType: config.model_type,
    kvConfig: existsSync(join(resolved, "kv_config.json")),
    packedTrellis: quant.mode === "trellis" || Object.values(quant).some(v =>
      v !== null && typeof v === "object" && (v as { mode?: string }).mode === "trellis"),
    files,
  };
}

/** The exact library supplied (resolved through symlinks) first, then every
 * runtime file bundled beside it (MLX, JACCL, the metallib, and any others). */
export function nativeFiles(library: string): FileRecord[] {
  const chosen = realpathSync(library), dir = resolve(chosen, "..");
  const record = (path: string): FileRecord => ({ name: basename(path), path, bytes: statSync(path).size, sha256: fileSha(path) });
  const bundled = readdirSync(dir).sort().map(name => join(dir, name))
    .filter(path => path !== chosen && /\.(dylib|metallib)$/.test(path) && statSync(path).isFile());
  return [record(chosen), ...bundled.map(record)];
}

const within = (path: string, root: string) => {
  const rel = relative(realpathSync(root), path);
  return rel === "" || (!rel.startsWith("..") && !isAbsolute(rel));
};
/** Captures stay outside every source tree the run measures (and this tooling's own). */
export function outsideTrees(path: string, roots: string[]): string {
  if (!isAbsolute(path)) throw new Error(`${path} must be an absolute path`);
  let probe = path;
  while (!existsSync(probe)) probe = resolve(probe, "..");
  const real = join(realpathSync(probe), relative(probe, path));
  for (const root of roots) if (within(real, root)) throw new Error(`${path} is inside source tree ${root}`);
  return real;
}
export function checkOutputDirectory(out: string, roots: string[]): string {
  const real = outsideTrees(out, roots);
  if (existsSync(out) && readdirSync(out).length) throw new Error(`--out ${out} must be empty or absent`);
  return real;
}

/** A plan labeled `all` must be main's full matrix; anything narrower is scoped. */
export function profileProblems(plan: Plan): string[] {
  if (plan.profile !== "all") return [];
  const problems: string[] = [];
  const ids = plan.models.map(model => model.id);
  if (JSON.stringify(ids) !== JSON.stringify(CANONICAL.models)) problems.push(`models ${ids} are not ${CANONICAL.models}`);
  if (JSON.stringify(plan.configurations) !== JSON.stringify(CANONICAL.configurations))
    problems.push(`configurations ${plan.configurations} are not ${CANONICAL.configurations}`);
  if (JSON.stringify(plan.references.map(ref => ref.label)) !== JSON.stringify(CANONICAL.references))
    problems.push(`references ${plan.references.map(ref => ref.label)} are not ${CANONICAL.references}`);
  if (!plan.workload.withContext) problems.push("long-context, restart phases are skipped");
  for (const model of plan.models) if (needsRegister(model))
    for (const ref of plan.references) if (!ref.registerCommand) problems.push(`${ref.label} has no register command for ${model.id}`);
  for (const [key, value] of Object.entries(WORKLOAD))
    if ((plan.workload as Record<string, unknown>)[key] !== value) problems.push(`workload ${key} differs from main`);
  return problems;
}

export function validatePlan(value: unknown): Plan {
  const plan = value as Plan;
  const fail = (message: string) => { throw new Error(`invalid plan: ${message}`); };
  if (!plan || plan.schema !== 1) fail("schema must be 1");
  if (plan.profile !== "all" && plan.profile !== "scoped") fail("profile must be all or scoped");
  if (typeof plan.seed !== "string" || !plan.seed) fail("seed is required");
  for (const tree of TREES) {
    const spec = plan.trees?.[tree];
    if (!spec || !isAbsolute(spec.root) || !/^[0-9a-f]{40}$/.test(spec.commit) || !Array.isArray(spec.command) ||
        !spec.command.length || spec.command.some(part => typeof part !== "string" || !part))
      fail(`${tree} needs an absolute root, a full commit and an explicit command`);
  }
  if (plan.trees.baseline.root === plan.trees.candidate.root) fail("baseline and candidate must be different trees");
  if (!Array.isArray(plan.references) || plan.references.some(ref => !ref.label || !Array.isArray(ref.command) || !ref.command.length))
    fail("each reference needs a label and an explicit command");
  if (!Array.isArray(plan.configurations) || !plan.configurations.length ||
      plan.configurations.some(name => !(name in CONFIGURATIONS))) fail("unknown configuration");
  if (!Array.isArray(plan.models) || !plan.models.length) fail("at least one model is required");
  for (const model of plan.models)
    if (!model.id || !isAbsolute(model.path) || !Array.isArray(model.files) || !model.files.length) fail(`model ${model.id} is not pinned`);
  if (!plan.native?.library || !isAbsolute(plan.native.library) || !plan.native.files?.length) fail("native library is not pinned");
  const problems = profileProblems(plan);
  if (problems.length) fail(`profile all is not main's full matrix: ${problems.join("; ")}`);
  if (JSON.stringify(plan.cells) !== JSON.stringify(planCells(plan))) fail("predeclared cells do not match the plan's matrix");
  return plan;
}

/** Tracked and untracked, non-ignored files of a tree: the measured source identity. */
export function sourceSnapshot(root: string): { head: string; clean: boolean; sha256: string; files: number } {
  const git = (...args: string[]) => {
    const result = Bun.spawnSync(["git", "-C", root, ...args]);
    if (result.exitCode !== 0) throw new Error(`git ${args[0]} failed in ${root}`);
    return result.stdout.toString();
  };
  const head = git("rev-parse", "HEAD").trim(), clean = !git("status", "--porcelain").trim();
  const names = git("ls-files", "-z", "--cached", "--others", "--exclude-standard").split("\0").filter(Boolean).sort();
  const files = names.filter(name => existsSync(join(root, name)) && statSync(join(root, name)).isFile())
    .map(name => [name, fileSha(join(root, name))]);
  return { head, clean, sha256: sha256(JSON.stringify(files)), files: files.length };
}

/** Pins that must hold at start and end: trees, artifacts and the intended native library. */
export function pinProblems(plan: Plan): string[] {
  const problems: string[] = [];
  for (const tree of TREES) {
    const snapshot = sourceSnapshot(plan.trees[tree].root);
    if (snapshot.head !== plan.trees[tree].commit) problems.push(`${tree} head ${snapshot.head} is not ${plan.trees[tree].commit}`);
    if (!snapshot.clean) problems.push(`${tree} tree is not clean`);
  }
  for (const model of plan.models) {
    const actual = artifactFiles(model.path);
    if (JSON.stringify(actual) !== JSON.stringify(model.files)) problems.push(`model ${model.id} files changed`);
  }
  if (JSON.stringify(nativeFiles(plan.native.library)) !== JSON.stringify(plan.native.files)) problems.push("native library files changed");
  return problems;
}


/** Main: plain mlx-lm cannot load gemma4_unified; the reference registers it through optiq (bf16 KV). */
export const needsRegister = (model: ModelSpec) => model.modelType === "gemma4_unified";

export interface PlannedCell {
  key: string; model: string; kind: "tree" | "reference"; order: number;
  tree?: Tree; configuration?: Configuration; reference?: string; skipped?: string;
}
/** Every cell of the matrix in run order. Per model, each configuration runs on
 * both trees back to back, alternating which tree goes first; references follow. */
export function planCells(plan: Plan): PlannedCell[] {
  const cells: PlannedCell[] = [];
  plan.models.forEach((model, m) => {
    plan.configurations.forEach((configuration, c) => {
      const trees = (m + c) % 2 ? [...TREES].reverse() : TREES;
      const skipped = "requiresKvConfig" in CONFIGURATIONS[configuration] && !model.kvConfig ? "no kv_config.json in the artifact" : undefined;
      for (const tree of trees) cells.push({ key: `${model.id}/${configuration}/${tree}`, model: model.id, kind: "tree", tree,
        configuration, order: cells.length, ...(skipped ? { skipped } : {}) });
    });
    for (const ref of plan.references) {
      const skipped = model.packedTrellis ? "packed trellis has no stock reference loader; an expanded carrier is a different artifact"
        : needsRegister(model) && !ref.registerCommand ? `${ref.label} cannot load ${model.modelType} without a register command` : undefined;
      cells.push({ key: `${model.id}/${ref.label}`, model: model.id, kind: "reference", reference: ref.label,
        order: cells.length, ...(skipped ? { skipped } : {}) });
    }
  });
  return cells;
}

/** The exact argv for one cell: the explicit command, then serve arguments. */
export function cellArgs(plan: Plan, cell: PlannedCell, port: number, ssdDir: string): string[] {
  const model = plan.models.find(m => m.id === cell.model)!;
  if (cell.kind === "tree")
    return [...plan.trees[cell.tree!].command, "--model", model.path, "--port", String(port), "--no-open",
      "--ssd-cache", ssdDir, ...CONFIGURATIONS[cell.configuration!].args];
  const ref = plan.references.find(r => r.label === cell.reference)!;
  return [...(needsRegister(model) ? ref.registerCommand! : ref.command), "--model", model.path, "--port", String(port)];
}
