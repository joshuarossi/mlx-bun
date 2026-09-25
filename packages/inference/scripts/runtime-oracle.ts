/** Full-grid and live-state parity against an externally generated report.
 * No native imports on the compare/help paths; references never run here. */
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { mkdtemp, rm, readdir } from "node:fs/promises";
import { cpus, hostname, release, totalmem, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { parseArgs } from "node:util";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";

export interface Plan {
  model: string;
  runtime: string;
  contexts: number[];
  lengths: number[];
  prefixChunk: number;
  kv?: "artifact";
  restore?: true;
}
export const sha = (bytes: string | Uint8Array) => createHash("sha256").update(bytes).digest("hex");
const object = (v: unknown): Record<string, unknown> => {
  assert(v !== null && typeof v === "object" && !Array.isArray(v), "expected an object");
  return v as Record<string, unknown>;
};
const integer = (v: unknown, min: number) => {
  assert(typeof v === "number" && Number.isSafeInteger(v) && v >= min, `expected integer >= ${min}`);
  return v;
};
const hash = (v: unknown) => assert(typeof v === "string" && /^[a-f0-9]{64}$/.test(v), "invalid SHA-256");
export function parsePlan(value: unknown): Plan {
  const p = object(value);
  assert(typeof p.model === "string" && p.model.length > 0, "model directory is required");
  assert(typeof p.runtime === "string" && p.runtime.length > 0, "runtime version is required");
  function numbers(v: unknown, min: number): number[] {
    assert(Array.isArray(v) && v.length > 0, "case list must not be empty");
    const result = v.map(n => integer(n, min));
    assert.equal(new Set(result).size, result.length, "duplicate cases");
    return result;
  }
  assert(p.kv === undefined || p.kv === "artifact", 'kv must be "artifact" or omitted (plain)');
  assert(p.restore === undefined || p.restore === true, "restore must be true or omitted");
  return { ...(p.kv ? { kv: p.kv as "artifact" } : {}), ...(p.restore ? { restore: true as const } : {}), model: resolve(p.model), runtime: p.runtime, contexts: numbers(p.contexts, 0),
    lengths: numbers(p.lengths, 1), prefixChunk: integer(p.prefixChunk, 1) };
}

function validateArray(value: unknown) {
  const a = object(value);
  assert(Array.isArray(a.shape) && a.shape.length > 0, "missing tensor shape");
  a.shape.forEach(n => integer(n, 0));
  assert(typeof a.dtype === "string" && a.dtype.length > 0, "missing tensor dtype");
  hash(a.sha256);
}
function validateReport(value: unknown, plan: Plan) {
  const report = object(value);
  assert.equal(report.runtime, plan.runtime, "runtime differs from plan");
  hash(report.configSha256);
  assert(Array.isArray(report.rows), "missing rows");
  assert.equal(report.rows.length, plan.contexts.length * plan.lengths.length, "missing or extra cases");
  let index = 0;
  let layers: number | undefined;
  for (const context of plan.contexts) for (const m of plan.lengths) {
    const row = object(report.rows[index++]);
    assert.equal(row.context, context, "unexpected context/order");
    assert.equal(row.m, m, "unexpected append length/order");
    for (const [key, count] of [["prefix", context], ["state", context + m], ["continuationState", context + m + 1]] as const) {
      const state = row[key];
      assert(Array.isArray(state) && state.length > 0, `missing ${key} planes`);
      layers ??= state.length;
      assert.equal(state.length, layers, "inconsistent layer count");
      for (const item of state) {
        const cache = object(item);
        assert.equal(cache.offset, count, `${key}: invalid offset`);
        assert.equal(typeof cache.recurrent, "boolean", "missing cache kind");
        assert(Array.isArray(cache.arrays), "missing state arrays");
        if (count > 0) assert(cache.arrays.some(a => a !== null), "empty populated state");
        cache.arrays.forEach(a => { if (a !== null) validateArray(a); });
      }
    }
    validateArray(row.logits);
    validateArray(row.continuation);
    const logits = object(row.logits).shape as number[];
    const next = object(row.continuation).shape as number[];
    assert.deepEqual(logits.slice(0, 2), [1, m], "expected full logits grid");
    assert.equal(logits.length, 3);
    assert(logits[2]! > 0);
    assert.deepEqual(next, [1, 1, logits[2]!], "expected one-token continuation grid");
  }
  return report;
}
function firstDifference(a: unknown, b: unknown, path: string): string | null {
  if (Object.is(a, b)) return null;
  if (a && b && typeof a === "object" && typeof b === "object") {
    const left = a as Record<string, unknown>, right = b as Record<string, unknown>;
    for (const key of new Set([...Object.keys(left), ...Object.keys(right)])) {
      const difference = firstDifference(left[key], right[key], `${path}.${key}`);
      if (difference) return difference;
    }
    return null;
  }
  return `${path}: actual=${JSON.stringify(a)} reference=${JSON.stringify(b)}`;
}
/** Both reports must contain the complete plan, even when they agree on an omission.
 * Legacy references have no configuration provenance; accepting those is explicit. */
export function compareReports(actual: unknown, reference: unknown, plan: Plan, allowUnrecordedConfig = false): void {
  const a = validateReport(actual, plan), b = validateReport(reference, plan);
  if (plan.restore) assert.equal(a.restorationVerified, true, "actual report did not verify restored continuation");
  const environment = (r: Record<string, unknown>) => r.provenance ? object(r.provenance).runtimeEnvironment : undefined;
  const ae = environment(a), be = environment(b);
  if (ae === undefined || be === undefined) {
    assert(allowUnrecordedConfig, "configuration provenance missing; use --allow-unrecorded-config only with externally verified settings");
  } else {
    const mismatch = firstDifference(ae, be, "runtimeEnvironment");
    assert(!mismatch, mismatch ?? "");
  }
  for (const r of [a, b]) {
    if (r.provenance && object(r.provenance).plan)
      assert.deepEqual(parsePlan(object(r.provenance).plan), plan, "recorded plan differs from requested plan");
  }
  const artifact = (r: Record<string, unknown>) => r.provenance ? object(r.provenance).artifact : undefined;
  const aa = artifact(a), ba = artifact(b);
  if (aa && ba && object(aa).weightHashes && object(ba).weightHashes)
    assert.deepEqual(object(aa).weightHashes, object(ba).weightHashes, "different weight hashes");
  assert.equal(a.configSha256, b.configSha256, "different model configuration");
  const mismatch = firstDifference(a.rows, b.rows, "rows");
  assert(!mismatch, mismatch ?? "");
}

async function fileHash(path: string) {
  const digest = createHash("sha256");
  for await (const chunk of createReadStream(path)) digest.update(chunk);
  return digest.digest("hex");
}
function command(cmd: string[], cwd?: string): string {
  const result = Bun.spawnSync(cmd, { cwd, stdout: "pipe", stderr: "pipe" });
  assert.equal(result.exitCode, 0, `${cmd[0]} failed: ${result.stderr.toString()}`);
  return result.stdout.toString().trim();
}
export async function provenance(planBytes: Uint8Array, model: string, library: string, hashWeights: boolean) {
  const root = resolve(import.meta.dir, "../../..");
  const status = command(["git", "status", "--porcelain"], root);
  const native: Record<string, string> = {};
  for (const name of ["libmlxc.dylib", "libmlx.dylib", "libjaccl.dylib", "mlx.metallib"])
    native[name] = await fileHash(name === "libmlxc.dylib" ? library : join(dirname(library), name));
  const weights: Record<string, string> = {};
  if (hashWeights) for (const name of (await readdir(model)).filter(n => n.endsWith(".safetensors")).sort())
    weights[name] = await fileHash(join(model, name));
  const index = Bun.file(join(model, "model.safetensors.index.json"));
  return {
    createdAt: new Date().toISOString(), sourceCommit: command(["git", "rev-parse", "HEAD"], root),
    dirty: status.length > 0, trackedDiffSha256: sha(command(["git", "diff", "HEAD", "--binary"], root)),
    harnessSha256: await fileHash(import.meta.filename), planSha256: sha(planBytes), plan: parsePlan(JSON.parse(new TextDecoder().decode(planBytes))), native,
    machine: { host: hostname(), chip: cpus()[0]?.model, ramBytes: totalmem(), os: release(),
      macOS: process.platform === "darwin" ? command(["sw_vers", "-productVersion"]) : null,
      build: process.platform === "darwin" ? command(["sw_vers", "-buildVersion"]) : null, bun: Bun.version },
    runtimeEnvironment: Object.fromEntries(Object.entries(process.env).filter(([k]) => /^(MLX_BUN_|MLX_RD_|MLX_MAX_|MLX_BFS_|MLX_METAL_)/.test(k)).sort()),
    artifact: { directory: model, indexSha256: await index.exists() ? sha(await index.bytes()) : null,
      weightHashes: hashWeights ? weights : null },
  };
}

export async function emit(plan: Plan, planBytes: Uint8Array, hashWeights: boolean) {
  const [{ Weights, loadModelConfig, createModel }, { gpuStream }, ffi, ops] = await Promise.all([
    import("@mlx-bun/inference"), import("@mlx-bun/mlx/array"), import("@mlx-bun/mlx/ffi"), import("@mlx-bun/mlx/ops"),
  ]);
  assert.equal(ffi.MLX_VERSION, plan.runtime);
  const record = await provenance(planBytes, plan.model, ffi.LIBMLXC_PATH, hashWeights);
  const configSha256 = sha(await Bun.file(join(plan.model, "config.json")).bytes());
  const stateApi = plan.kv || plan.restore ? await import("@mlx-bun/inference/state") : null;
  function array(value: MlxArray) {
    const contiguous = ops.contiguous(value);
    try { return { shape: contiguous.shape, dtype: ffi.DTYPE_NAMES[contiguous.dtype], sha256: sha(contiguous.rawBytesView()) }; }
    finally { contiguous.dispose(); }
  }
  function withPlanes<T>(cache: Cache, run: (planes: MlxArray[]) => T): T {
    const planes = cache.state();
    try { return run(planes); }
    finally { if (cache.stateNeedsDispose) for (const plane of planes) plane.dispose(); }
  }
  function state(caches: Cache[], count: number) {
    return caches.map(cache => {
      assert.equal(cache.offset, count);
      return { recurrent: cache.signature() === "ssm", offset: cache.offset,
        arrays: withPlanes(cache, planes => planes.map(value => {
          const shape = value.shape;
          const view = cache.signature() !== "ssm" && shape.length === 4 && shape[2]! > cache.offset
            ? value.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
          try { return array(view ?? value); } finally { view?.dispose(); }
        })) };
    });
  }
  const weights = await Weights.open(plan.model);
  const rows = [];
  try {
    const config = await loadModelConfig(plan.model);
    const model = createModel(weights, config);
    if (plan.kv) assert(config.kvQuant?.length, "artifact has no mixed-KV configuration");
    const maintain = plan.kv ? stateApi!.createKvMaintenance({ kvConfig: config.kvQuant!, quantizedKvStart: 0 }) : (_: Cache[]) => {};
    if (plan.kv) Object.assign(record.artifact, { kvConfigSha256: sha(await Bun.file(join(plan.model, "kv_config.json")).bytes()), kvConfig: config.kvQuant });
    function forward(ids: number[], caches: Cache[]) {
      const input = ops.fromInt32(ids, [1, ids.length]);
      try { return model.forwardHidden(input, caches); } finally { input.dispose(); }
    }
    for (const context of plan.contexts) for (const m of plan.lengths) {
      const caches = model.makeCache();
      try {
        for (let pos = 0; pos < context; pos += plan.prefixChunk) {
          const count = Math.min(plan.prefixChunk, context - pos);
          const hidden = forward(Array.from({ length: count }, (_, i) => 100 + (pos + i) * 7 % 1000), caches);
          const groups: { cache: Cache; planes: MlxArray[] }[] = [];
          try {
            for (const cache of caches) groups.push({ cache, planes: cache.state() });
            ops.evalAll([hidden, ...groups.flatMap(group => group.planes)]);
            maintain(caches);
          } finally {
            for (const { cache, planes } of groups) if (cache.stateNeedsDispose)
              for (const plane of planes) plane.dispose();
            hidden.dispose(); ffi.clearCache();
          }
        }
        const prefix = state(caches, context);
        const hidden = forward(Array.from({ length: m }, (_, i) => 600 + i * 3), caches);
        let logits: MlxArray;
        try { logits = model.logitsFromHidden(hidden); } finally { hidden.dispose(); }
        let current;
        try { ops.evalAll([logits]); maintain(caches); current = { logits: array(logits), state: state(caches, context + m) }; }
        finally { logits.dispose(); }
        const directory = plan.restore ? await mkdtemp(join(tmpdir(), "mlx-parity-state-")) : null;
        let restored: ReturnType<NonNullable<typeof stateApi>["loadKvCache"]> | undefined;
        try {
          if (directory) {
            const tokens = [...Array.from({ length: context }, (_, i) => 100 + i * 7 % 1000),
              ...Array.from({ length: m }, (_, i) => 600 + i * 3)];
            const path = join(directory, "state.kv");
            const meta = { modelId: configSha256, configFingerprint: sha(JSON.stringify({ configSha256, kv: plan.kv, spec: config.kvQuant })) };
            stateApi!.saveKvCache(path, tokens, caches, meta);
            restored = stateApi!.loadKvCache(path, model, { ...meta, verify: true });
            assert.deepEqual(restored.tokens, tokens, "restored token prefix");
            assert.deepEqual(state(restored.caches, context + m), current.state, "restored live state");
          }
          const next = model.forward([911], caches);
          let row;
          try {
            ops.evalAll([next]); maintain(caches);
            row = { context, m, prefix, ...current, continuation: array(next), continuationState: state(caches, context + m + 1) };
          } finally { next.dispose(); }
          if (restored) {
            const resumed = model.forward([911], restored.caches);
            try {
              ops.evalAll([resumed]); maintain(restored.caches);
              assert.deepEqual(array(resumed), row.continuation, "restored continuation logits");
              assert.deepEqual(state(restored.caches, context + m + 1), row.continuationState, "restored continuation state");
            } finally { resumed.dispose(); }
          }
          rows.push(row);
        } finally {
          if (restored) {
            for (const cache of restored.caches) cache.dispose();
            stateApi!.disposeAttachments(restored.attachments);
          }
          if (directory) await rm(directory, { recursive: true, force: true });
        }
      } finally {
        for (const cache of caches) cache.dispose();
        ffi.synchronize(gpuStream); ffi.clearCache();
      }
    }
  } finally { weights.dispose(); ffi.synchronize(gpuStream); ffi.clearCache(); }
  return { runtime: ffi.MLX_VERSION, library: ffi.LIBMLXC_PATH, configSha256, rows,
    activeAfter: ffi.activeMemory(), provenance: record, ...(plan.restore ? { restorationVerified: true } : {}) };
}

const help = `Full logits and live-state parity (local weights, no downloads).
  bun packages/inference/scripts/runtime-oracle.ts emit --plan plan.json --report actual.json [--hash-weights]
  bun packages/inference/scripts/runtime-oracle.ts compare --plan plan.json --actual actual.json --reference reference.json [--allow-unrecorded-config]
Plan: {model: absolute directory, runtime: MLX version, contexts: nonnegative integers,
       lengths: positive integers, prefixChunk: positive integer}.
Use bun --no-env-file on both trees to avoid project-local dotenv overrides.
Use a context larger than prefixChunk to exercise chunked prefill. Input IDs follow
main's runtime-oracle worker: prefix 100+(position*7)%1000, append 600+position*3,
continuation 911. The vocabulary must contain these IDs. Every grid and live cache
plane is hashed without dtype conversion. No tolerance, generation or compiled decode is exercised.
Optional plan kv:"artifact" applies the checkpoint's kv_config.json after each
forward (never quantizing empty caches). Optional restore:true verifies persisted
state and continuation against the live path for every case, with tensor hashes
checked on load. Temporary checkpoints are removed after each case. Runtime overrides are recorded, not
reset. Compare requires matching recorded settings unless explicitly accepting a
legacy reference whose environment you have verified externally. A matching config
hash alone does not establish identical weights: use --hash-weights for evidence.
Match the reference dispatch as well as KV bits: this library uses stock quantized
attention for one query and the OptiQ tiled path for supported multi-query input.
Reports/plan files belong outside Git. Run external references separately; check
that training is inactive first. No built-in timeout or Python invocation.\n`;
if (import.meta.main) {
  try {
    const { values, positionals } = parseArgs({ args: process.argv.slice(2), allowPositionals: true, strict: true,
      options: { help: { type: "boolean" }, plan: { type: "string" }, report: { type: "string" }, actual: { type: "string" },
        reference: { type: "string" }, "hash-weights": { type: "boolean" }, "allow-unrecorded-config": { type: "boolean" } } });
    if (values.help) console.log(help);
    else {
      assert.equal(positionals.length, 1, help);
      assert(values.plan, "--plan is required");
      const bytes = await Bun.file(values.plan).bytes();
      const plan = parsePlan(JSON.parse(new TextDecoder().decode(bytes)));
      if (positionals[0] === "emit") {
        assert(values.report, "--report is required");
        await Bun.write(values.report, JSON.stringify(await emit(plan, bytes, !!values["hash-weights"]), null, 2) + "\n");
        console.log(`Wrote ${values.report}`);
      } else if (positionals[0] === "compare") {
        assert(values.actual && values.reference, "--actual and --reference are required");
        compareReports(await Bun.file(values.actual).json(), await Bun.file(values.reference).json(), plan, !!values["allow-unrecorded-config"]);
        console.log(`PASS: ${plan.contexts.length * plan.lengths.length} complete logit/state cases${values["allow-unrecorded-config"] ? " (legacy configuration accepted explicitly)" : ""}`);
      } else throw new Error(`Unknown command: ${positionals[0]}`);
    }
  } catch (error) { console.error(error instanceof Error ? error.message : error); process.exitCode = 1; }
}
