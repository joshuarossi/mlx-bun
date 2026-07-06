// Minimal repro hunt: does the rot-quant TWIN diverge from serial on the
// REAL 12B at B=1 (no padding, no scheduler)? Serial-prefill one cache set,
// convert per kv_config, then EITHER continue serially (reference) or swap
// each rot layer for a BatchedRotatingQuantCache built from its
// temporalView (twin path) — teacher-forced, per-step max|Δlogit|.
//
// MODE=twin (default): rot layers → twins, full layers stay serial-class.
// MODE=serial: control — both sides identical (must print 0s).
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { maybeQuantizeKv } from "../../src/generate";
import { lastPositionLogits, argmaxLastPosition } from "../../src/model/gemma4";
import { RotatingQuantizedKVCache, type Cache } from "../../src/model/gemma4-base";
import { BatchedRotatingQuantCache } from "../../src/model/batched-rotating-quant";
import { SNAPSHOT } from "../../tests/paths";
import { clearCache } from "../../src/mlx/ffi";

const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = createModel(weights, config);
const STEPS = 12;
const MODE = process.env.MODE ?? "twin";
const prompt = [2, 100, 200, 300, 400, 500, 600, 700];
const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };

/** Prefill + convert; returns caches ready for decode step 1. */
const prep = (): { caches: Cache[]; tok0: number } => {
  const caches = model.makeCache();
  const l = model.forward(prompt, caches);
  const tok0 = argmaxLastPosition(l);
  l.dispose();
  maybeQuantizeKv(caches, kvOpts);
  return { caches, tok0 };
};

// Reference: pure serial continuation.
const ref = prep();
const refLogits: Float32Array[] = [];
const refToks: number[] = [ref.tok0];
for (let s = 1; s < STEPS; s++) {
  const l = model.forward([refToks[s - 1]!], ref.caches);
  refLogits.push(lastPositionLogits(l));
  refToks.push(argmaxLastPosition(l));
  l.dispose();
}
for (const c of ref.caches) c.dispose();
clearCache();

// Candidate: same prefill, rot layers swapped for twins (MODE=twin).
const cand = prep();
const only = process.env.TWIN_LAYER !== undefined ? Number(process.env.TWIN_LAYER) : null;
if (MODE === "twin") {
  for (let i = 0; i < cand.caches.length; i++) {
    if (only !== null && i !== only) continue;
    const c = cand.caches[i]!;
    if (c instanceof RotatingQuantizedKVCache) {
      const [k, v] = c.temporalView();
      const twin = BatchedRotatingQuantCache.merge([{ keys: k, values: v }], [c.offset], c.maxSize, c.groupSize, c.bits);
      for (const t of [k, v]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
      c.dispose();
      // Bisect knobs: TWIN_MASK=serial forces the serial no-mask;
      // TWIN_ROPE=scalar hides ropeOffsetArr (model falls back to scalar).
      if (process.env.TWIN_MASK === "serial")
        (twin as { makeMask: unknown }).makeMask = () => ({ mode: "", arr: null });
      if (process.env.TWIN_ROPE === "scalar")
        Object.defineProperty(twin, "ropeOffsetArr", { get: () => undefined, set: () => {} });
      cand.caches[i] = twin;
    }
  }
}
const diffs: number[] = [];
for (let s = 1; s < STEPS; s++) {
  const l = model.forward([refToks[s - 1]!], cand.caches); // teacher-forced
  const got = lastPositionLogits(l);
  l.dispose();
  const refL = refLogits[s - 1]!;
  let d = 0;
  for (let i = 0; i < refL.length; i++) d = Math.max(d, Math.abs(refL[i]! - got[i]!));
  diffs.push(d);
  for (const c of cand.caches) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
}
for (const c of cand.caches) c.dispose();
console.log(`MODE=${MODE} per-step max|Δlogit| vs serial: ${diffs.map((d) => d.toExponential(1)).join(" ")}`);
