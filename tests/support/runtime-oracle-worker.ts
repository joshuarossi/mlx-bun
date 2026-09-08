// Subprocess worker for runtime-oracle.test.ts. Keep the parent CPU-only so
// the Bun and Python models never occupy the GPU together.
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import type { MlxArray } from "../../src/mlx/array";
import type { Cache } from "../../src/model/gemma4-base";

if (process.env.MLX_BUN_TEST_RUNTIME_ORACLE !== "1")
  throw new Error("Runtime oracle worker requires MLX_BUN_TEST_RUNTIME_ORACLE=1");

const [planPath, reportPath] = process.argv.slice(2);
assert(planPath && reportPath);
const plan = await Bun.file(planPath).json() as {
  model: string; runtime: string; contexts: number[]; lengths: number[]; prefixChunk: number;
};
const [{ Weights }, { loadModelConfig }, { createModel }, { gpuStream }, ffi, ops] = await Promise.all([
  import("../../src/weights"), import("../../src/config"), import("../../src/model/factory"),
  import("../../src/mlx/array"), import("../../src/mlx/ffi"), import("../../src/mlx/ops"),
]);
const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
function array(value: MlxArray) {
  const contiguous = ops.contiguous(value);
  try {
    return { shape: contiguous.shape, dtype: ffi.DTYPE_NAMES[contiguous.dtype], sha256: sha(contiguous.rawBytesView()) };
  } finally { contiguous.dispose(); }
}
function state(caches: Cache[], count: number) {
  return caches.map(cache => {
    assert.equal(cache.offset, count);
    return {
      recurrent: cache.signature() === "ssm", offset: cache.offset,
      arrays: cache.state().map(value => {
        const shape = value.shape;
        const view = cache.signature() !== "ssm" && shape.length === 4 && shape[2]! > cache.offset
          ? value.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
        try { return array(view ?? value); } finally { view?.dispose(); }
      }),
    };
  });
}
assert.equal(ffi.MLX_VERSION, plan.runtime);
const configSha256 = sha(await Bun.file(`${plan.model}/config.json`).bytes());
const weights = await Weights.open(plan.model);
const model = createModel(weights, await loadModelConfig(plan.model));
function forward(ids: number[], caches: Cache[]) {
  const input = ops.fromInt32(ids, [1, ids.length]);
  try { return model.forwardHidden(input, caches); } finally { input.dispose(); }
}
const rows = [];
try {
  for (const context of plan.contexts) for (const m of plan.lengths) {
    const caches = model.makeCache();
    try {
      for (let pos = 0; pos < context; pos += plan.prefixChunk) {
        const count = Math.min(plan.prefixChunk, context - pos);
        const hidden = forward(Array.from({ length: count }, (_, i) => 100 + (pos + i) * 7 % 1000), caches);
        try { ops.evalAll([hidden, ...caches.flatMap(cache => cache.state())]); }
        finally { hidden.dispose(); ffi.clearCache(); }
      }
      const prefix = state(caches, context);
      const hidden = forward(Array.from({ length: m }, (_, i) => 600 + i * 3), caches);
      let logits: MlxArray;
      try { logits = model.logitsFromHidden(hidden); } finally { hidden.dispose(); }
      let current;
      try { current = { logits: array(logits), state: state(caches, context + m) }; }
      finally { logits.dispose(); }
      const next = model.forward([911], caches);
      try {
        rows.push({ context, m, prefix, ...current, continuation: array(next), continuationState: state(caches, context + m + 1) });
      } finally { next.dispose(); }
    } finally {
      for (const cache of caches) cache.dispose();
      ffi.synchronize(gpuStream); ffi.clearCache();
    }
  }
} finally {
  weights.dispose(); ffi.synchronize(gpuStream); ffi.clearCache();
}
await Bun.write(reportPath, JSON.stringify({ runtime: ffi.MLX_VERSION, library: ffi.LIBMLXC_PATH, configSha256, rows, activeAfter: ffi.activeMemory() }));
