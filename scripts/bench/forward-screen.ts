// Short, teacher-forced forward screening. No servers, sampling, or drafter.
// Every timing completes the logits AND cache work; hashing is outside it.
import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, realpathSync, statSync, writeFileSync } from "node:fs";
import { hostname } from "node:os";
import { dirname, isAbsolute, join, relative, resolve } from "node:path";
import { parseArgs } from "node:util";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import { fileSha, sourceSnapshot } from "./plan";
import { checkMachine, pairedDelta } from "./perf-check";

const ROOT = resolve(import.meta.dir, "../..");
const sha = (bytes: Uint8Array | string) => createHash("sha256").update(bytes).digest("hex");
export const median = (values: number[]): number => {
  if (!values.length || values.some(n => !Number.isFinite(n) || n <= 0)) throw new Error("expected positive timing samples");
  const sorted = [...values].sort((a, b) => a - b), middle = sorted.length >> 1;
  return sorted.length % 2 ? sorted[middle]! : (sorted[middle - 1]! + sorted[middle]!) / 2;
};
interface Sample { buildMs: number; completedMs: number; logits: string }
export interface ScreenReport {
  schema: 1;
  pid: number;
  graph: string;
  source: ReturnType<typeof sourceSnapshot>;
  match: {
    tool: string;
    model: string; config: string; metadata: Record<string, string>; weights: Array<{ name: string; bytes: number; modifiedMs: number }>;
    native: Record<string, string>; architecture: string; host: string; bun: string; mlx: string;
    environment: Record<string, string | undefined>; gpuWiredLimitMB: number;
    context: number; warmup: number; steps: number; rows: number[]; kv: string;
  };
  preflight: ReturnType<typeof checkMachine>;
  cells: Array<{ rows: number; prefillMs: number; warmup: Sample[]; samples: Sample[]; state: string;
    memory: { activeBytes: number; cacheBytes: number; peakBytes: number } }>;
}

/** Compare session medians, so consecutive tokens are not treated as independent sessions. */
export function compareScreens(baselines: ScreenReport[], candidates: ScreenReport[]) {
  if (!baselines.length || baselines.length !== candidates.length) throw new Error("supply equal nonempty baseline/candidate lists");
  const match = JSON.stringify(baselines[0]!.match);
  for (const report of [...baselines, ...candidates]) {
    if (report.schema !== 1 || JSON.stringify(report.match) !== match) throw new Error("screen workloads, artifacts, machine, or native runtime differ");
    if (JSON.stringify(report.cells.map(c => c.rows)) !== JSON.stringify(report.match.rows)) throw new Error("screen has missing or reordered cells");
    if (report.cells.some(c => c.samples.length !== report.match.steps)) throw new Error("screen has missing samples");
  }
  return baselines[0]!.match.rows.map((rows, index) => {
    const pairs = baselines.map((base, session) => {
      const a = base.cells[index]!, b = candidates[session]!.cells[index]!;
      if (a.state !== b.state || a.samples.some((s, i) => s.logits !== b.samples[i]!.logits))
        throw new Error(`rows ${rows}, session ${session + 1}: logits or live state differ`);
      return { id: String(session + 1), baseline: median(a.samples.map(s => s.completedMs)),
        candidate: median(b.samples.map(s => s.completedMs)) };
    });
    return { rows, identity: "exact logits and final live state", qualification: "screen only",
      preflightClear: [...baselines, ...candidates].every(r => r.preflight.ok),
      preflightProblems: [...new Set([...baselines, ...candidates].flatMap(r => r.preflight.problems))], ...pairedDelta({
      metric: "completed forward + head + cache", unit: "ms", direction: "lower-is-better", pairs,
      baselineMedian: median(pairs.map(p => p.baseline)), candidateMedian: median(pairs.map(p => p.candidate)),
      ratio: null, observation: "unpaired", unpaired: { baseline: [], candidate: [] }, excluded: [],
    }, false) };
  });
}

function outputPath(path: string, roots: string[]): string {
  if (!isAbsolute(path)) throw new Error("output paths must be absolute and outside the source trees");
  const out = join(realpathSync(dirname(path)), path.slice(path.lastIndexOf("/") + 1));
  for (const root of roots) {
    const rel = relative(realpathSync(root), out);
    if (!rel || (!rel.startsWith("../") && !isAbsolute(rel))) throw new Error("outputs must stay outside source trees");
  }
  if (existsSync(out)) throw new Error(`output already exists: ${out}`);
  return out;
}
const integer = (raw: string, min = 1): number => {
  const n = Number(raw);
  if (!/^\d+$/.test(raw) || !Number.isSafeInteger(n) || n < min) throw new Error(`invalid integer: ${raw}`);
  return n;
};

export async function runScreen(argv: string[]): Promise<ScreenReport> {
  const { values } = parseArgs({ args: argv, options: {
    root: { type: "string", default: ROOT }, model: { type: "string" }, out: { type: "string" },
    rows: { type: "string", default: "1" }, context: { type: "string", default: "64" }, steps: { type: "string", default: "16" },
    warmup: { type: "string", default: "3" }, kv: { type: "string", default: "bf16" },
    "profile-gap-ms": { type: "string", default: "0" },
  } });
  if (!values.model || !values.out) throw new Error("run requires --model and --out");
  const root = realpathSync(values.root!), modelPath = realpathSync(values.model), inf = `${root}/packages/inference/src`;
  const out = outputPath(values.out, [ROOT, root]);
  const rows = values.rows!.split(",").map(s => integer(s)), context = integer(values.context!, 0);
  const steps = integer(values.steps!), warmup = integer(values.warmup!, 0), gap = integer(values["profile-gap-ms"]!, 0);
  if (new Set(rows).size !== rows.length) throw new Error("duplicate row counts");
  if (!["bf16", "4"].includes(values.kv!)) throw new Error("--kv is bf16 or 4");
  const preflight = checkMachine(), source = sourceSnapshot(root);
  const [factory, artifacts, compositionApi, phases, rowApi, ops, ffi] = await Promise.all([
    import(`${inf}/models/factory.ts`) as Promise<typeof import("../../packages/inference/src/models/factory")>,
    import(`${inf}/artifacts/config.ts`) as Promise<typeof import("../../packages/inference/src/artifacts/config")>,
    import(`${inf}/models/composition.ts`) as Promise<typeof import("../../packages/inference/src/models/composition")>,
    import(`${inf}/generation/phase-dispatch.ts`) as Promise<typeof import("../../packages/inference/src/generation/phase-dispatch")>,
    import(`${inf}/runtime/row-operations.ts`) as Promise<typeof import("../../packages/inference/src/runtime/row-operations")>,
    import(`${root}/packages/mlx/src/ops.ts`) as Promise<typeof import("@mlx-bun/mlx/ops")>,
    import(`${root}/packages/mlx/src/ffi.ts`) as Promise<typeof import("@mlx-bun/mlx/ffi")>,
  ]);
  const config = await artifacts.loadModelConfig(modelPath);
  const composition = compositionApi.resolveComposition(config, values.kv === "4" ? { kv: { override: 4 } } : {});
  const report: ScreenReport = { schema: 1, pid: process.pid, graph: "", source, preflight, match: {
    tool: fileSha(import.meta.filename),
    model: modelPath, config: fileSha(join(modelPath, "config.json")),
    metadata: Object.fromEntries(readdirSync(modelPath).filter(n => n.endsWith(".json")).sort()
      .map(name => [name, fileSha(join(modelPath, name))])),
    // Cheap artifact identity for screening; the full suite hashes weight contents.
    weights: readdirSync(modelPath).filter(n => n.endsWith(".safetensors")).sort().map(name => {
      const s = statSync(join(modelPath, name)); return { name, bytes: s.size, modifiedMs: s.mtimeMs };
    }),
    native: Object.fromEntries(["libmlxc.dylib", "libmlx.dylib", "mlx.metallib"].map(name =>
      [name, fileSha(join(dirname(ffi.LIBMLXC_PATH), name))])),
    architecture: ffi.deviceArchitecture(), host: hostname(), bun: Bun.version, mlx: ffi.MLX_VERSION,
    environment: Object.fromEntries(Object.entries(process.env).filter(([key]) => /^(MLX_|MLX_BUN_|MTL_|DYLD_)/.test(key)).sort()),
    gpuWiredLimitMB: preflight.gpuWiredLimitMB, context, warmup, steps, rows, kv: values.kv!,
  }, cells: [] };
  function planes(caches: Cache[]) { return caches.map(cache => ({ cache, values: cache.state() })); }
  function release(groups: ReturnType<typeof planes>) {
    for (const { cache, values } of groups) if (cache.stateNeedsDispose) for (const value of values) value.dispose();
  }
  function digest(array: MlxArray) {
    using contiguous = ops.contiguous(array);
    return sha(contiguous.rawBytesView());
  }
  function state(caches: Cache[]) {
    const groups = planes(caches);
    try { return sha(JSON.stringify(groups.map(({ cache, values }) => ({ offset: cache.offset, kind: cache.signature(),
      arrays: values.map(value => {
        const shape = value.shape;
        const view = cache.signature() !== "ssm" && shape.length === 4 && shape[2]! > cache.offset
          ? value.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        try { const a = view ?? value; return { shape: a.shape, dtype: a.dtype, hash: digest(a) }; }
        finally { view?.dispose(); }
      }) })))); } finally { release(groups); }
  }
  const ids = (count: number, seed: number) => ops.fromInt32(Array.from({ length: count },
    (_, i) => (seed * 7919 + i * 104729) % config.text.vocabSize), [1, count]);
  const model = await factory.openModel(modelPath, { composition });
  try {
    report.graph = "graph" in model && typeof model.graph === "string" ? model.graph : model.constructor.name;
    if (!("decode" in model) || !("verify" in model) || !("logits" in model)) throw new Error("model has no token phase tables");
    for (const count of rows) {
      const caches = model.makeCache();
      try {
        const start = performance.now();
        for (let pos = 0; pos < context; pos += 256) {
          const n = Math.min(256, context - pos);
          using input = ids(n, pos + 1);
          using hidden = await new phases.MlxPhaseDispatch(model).prompt("tail", 1, n)(input, caches, null);
          const groups = planes(caches);
          try { ops.evalAll([hidden, ...groups.flatMap(g => g.values)]); } finally { release(groups); }
        }
        const cell: ScreenReport["cells"][number] = { rows: count, prefillMs: performance.now() - start,
          warmup: [], samples: [], state: "", memory: { activeBytes: 0, cacheBytes: 0, peakBytes: 0 } };
        const forward = rowApi.rowOperationFor(count === 1 ? model.decode : model.verify, count);
        const head = rowApi.rowOperationFor(model.logits, count);
        ffi.resetPeakMemory();
        for (let step = 0; step < warmup + steps; step++) {
          if (step === warmup && gap) { console.error("profile gap: timed forwards follow"); await Bun.sleep(gap); }
          using input = ids(count, 5000 + step);
          const began = performance.now();
          using hidden = await forward(input, caches, null);
          using logits = head(hidden);
          const groups = planes(caches), built = performance.now();
          try { ops.evalAll([logits, ...groups.flatMap(g => g.values)]); } finally { release(groups); }
          const completed = performance.now();
          (step < warmup ? cell.warmup : cell.samples).push({ buildMs: built - began,
            completedMs: completed - began, logits: digest(logits) });
        }
        cell.state = state(caches);
        cell.memory = { activeBytes: ffi.activeMemory(), cacheBytes: ffi.cacheMemory(), peakBytes: ffi.peakMemory() };
        report.cells.push(cell);
        console.error(`rows ${count}: completed ${median(cell.samples.map(s => s.completedMs)).toFixed(3)} ms, ` +
          `build ${median(cell.samples.map(s => s.buildMs)).toFixed(3)} ms (overlaps submitted GPU work)`);
      } finally { for (const cache of caches) cache.dispose(); }
    }
    if (sourceSnapshot(root).sha256 !== source.sha256 || fileSha(import.meta.filename) !== report.match.tool)
      throw new Error("source or screening tool changed during screening");
    writeFileSync(out, JSON.stringify(report, null, 1) + "\n");
    return report;
  } finally { model.dispose(); }
}

const HELP = `Fast hypothesis screening, not performance qualification. Run GPU work under the shared machine lock.
  bun scripts/bench/forward-screen.ts run --root TREE --model /abs/snapshot --out /abs/new.json
      [--rows 1,4,8] [--context 64] [--steps 16] [--warmup 3] [--kv bf16|4] [--profile-gap-ms 1500]
  bun scripts/bench/forward-screen.ts compare --baseline /abs/a1.json --candidate /abs/b1.json
      [--baseline /abs/a2.json --candidate /abs/b2.json ...]
One sequence, teacher-forced tokens: rows=1 is plain decode; larger rows are verification windows.
No drafter or server is started. Timings finish logits and cache work; hashes are outside the timer.
Use fresh processes in alternating A B B A order. Compare uses session medians and requires exact
logits and final cache state. Artifact paths/sizes/mtimes are checked cheaply; weights are not content-hashed.
Preflight conditions are recorded. Promote repeatable wins to bench-serve and the full applicable numerical checks.
For GPU attribution, launch run under xctrace (Metal System Trace or a shader-profiler template) with
one --rows value and --profile-gap-ms 1500. The report records its PID. profile-screen.ts summarizes
exported shader/GPU intervals for that PID and reports overlapping processes. Profiling distorts timings.`;

if (import.meta.main) {
  const [command, ...argv] = process.argv.slice(2);
  if (!command || command === "--help") console.log(HELP);
  else if (command === "run") await runScreen(argv);
  else if (command === "compare") {
    const { values } = parseArgs({ args: argv, options: { baseline: { type: "string", multiple: true }, candidate: { type: "string", multiple: true } } });
    console.log(JSON.stringify(compareScreens((values.baseline ?? []).map(p => JSON.parse(readFileSync(p, "utf8"))),
      (values.candidate ?? []).map(p => JSON.parse(readFileSync(p, "utf8")))), null, 2));
  } else throw new Error(HELP);
}
