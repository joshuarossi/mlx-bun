// Per-layer quantization sensitivity analysis (native TS port of
// optiq/core/sensitivity.py `analyze_sensitivity_exact`, uniform-baseline path).
//
// For each quantizable Linear in a loaded (already-quantized) model:
//   1. dequantize its packed weight back to bf16 — this is the bf16 "source"
//      the OptIQ uniform_4bit path streams off disk; here it's self-contained
//      because the running model already carries quantized weights.
//   2. for each candidate bit-width, re-quantize that bf16 source at the new
//      bits and SWAP it into the running QuantizedLinear (mutate w/scales/biases
//      + the QuantSpec bits/groupSize).
//   3. run a no-KV full-sequence forward on each calibration sample, compute
//      KL(reference || current) (port of `_kl_from_ref`), average over samples.
//   4. restore the layer's original quantized weight.
//
// Reference logits = the UNMODIFIED running model (taken once up front). When a
// candidate bit equals the layer's baseline bit-width, re-quantizing reproduces
// exactly what the layer already is, so KL is 0 by construction — we record 0.0
// and skip the forward passes (port of the OptIQ baseline-bit short-circuit).
//
// Faithful to: `_simulate_quantize` (quantize→dequantize via MlxArray ops),
// `_mutate_quantized_layer_to_bits`, `_kl_from_ref`, the uniform-4bit-baseline
// path, and the bits==baseline ⇒ 0 short-circuit.

import { Dtype } from "../mlx/ffi";
import { cpuStream, MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { trainForward } from "../train/forward";
import type { RuntimeModel } from "../model/factory";
import type { QuantizedLinear } from "../model/gemma4-base";

/** Per-layer KL sensitivity at each candidate bit-width (port of
 *  optiq SensitivityResult). */
export interface SensitivityResult {
  layerName: string;
  /** bit-width → mean KL(reference || that-bit) over calibration samples. */
  sensitivities: Record<number, number>;
  paramCount: number;
}

export interface AnalyzeSensitivityOptions {
  candidateBits?: number[];
  groupSize?: number;
}

// --------------------------------------------------------------------------
// Minimal in-place mutation of a QuantizedLinear.
//
// gemma4-base.ts declares QuantizedLinear's w/scales/biases/spec as `readonly`
// (they never change at inference time). The sensitivity sweep needs to swap a
// layer's quantized weight transiently. Rather than edit the model file, we
// poke the public fields here via a typed cast — a quantize-only mutation
// helper. The fields are public, so this is a write to public state, not a
// reach into private internals. Flagged in the port report.
// --------------------------------------------------------------------------

/** Mutable view of the public QuantizedLinear fields we swap. */
type MutableQuantizedLinear = {
  w: MlxArray;
  scales: MlxArray;
  biases: MlxArray | null;
  spec: ops.QuantSpec;
};

/** Snapshot of a QuantizedLinear's quantized state (for restore). */
interface LayerState {
  w: MlxArray;
  scales: MlxArray;
  biases: MlxArray | null;
  spec: ops.QuantSpec;
}

function captureState(layer: QuantizedLinear): LayerState {
  return { w: layer.w, scales: layer.scales, biases: layer.biases, spec: layer.spec };
}

function restoreState(layer: QuantizedLinear, state: LayerState): void {
  const m = layer as unknown as MutableQuantizedLinear;
  // Dispose the transient swapped-in tensors before restoring the originals.
  if (m.w !== state.w) m.w.dispose();
  if (m.scales !== state.scales) m.scales.dispose();
  if (m.biases && m.biases !== state.biases) m.biases.dispose();
  m.w = state.w;
  m.scales = state.scales;
  m.biases = state.biases;
  m.spec = state.spec;
}

/** Quantize `bf16Weight` at `newBits`/`groupSize` and swap it into `layer`
 *  in place (port of `_mutate_quantized_layer_to_bits`). The previously
 *  swapped-in tensors (if any beyond the captured original) are released by
 *  the caller via restoreState; this only installs the new ones. */
function mutateLayerToBits(
  layer: QuantizedLinear,
  bf16Weight: MlxArray,
  newBits: number,
  groupSize: number,
  original: LayerState,
): void {
  const q = ops.quantize(bf16Weight, groupSize, newBits, "affine", cpuStream);
  const m = layer as unknown as MutableQuantizedLinear;
  // Free any previously swapped-in transient tensors (not the original).
  if (m.w !== original.w) m.w.dispose();
  if (m.scales !== original.scales) m.scales.dispose();
  if (m.biases && m.biases !== original.biases) m.biases.dispose();
  m.w = q.packed;
  m.scales = q.scales;
  m.biases = q.biases;
  m.spec = { bits: newBits, groupSize, mode: "affine" };
  ops.evalAll([q.packed, q.scales, q.biases]);
}

// --------------------------------------------------------------------------
// KL primitive (port of _kl_from_ref)
// --------------------------------------------------------------------------

/** KL(reference || current) averaged across batch/seq (port of `_kl_from_ref`):
 *    log_cur = cur - logsumexp(cur); log_ref = ref - logsumexp(ref)
 *    ref_probs = softmax(ref)
 *    mean( sum( ref_probs * (log_ref - log_cur), axis=-1 ) )
 *  Returns the scalar KL as a JS number. Casts to f32 for stability. */
export function klFromRef(curLogits: MlxArray, refLogits: MlxArray): number {
  const cur = curLogits.dtype === Dtype.float32 ? curLogits : curLogits.astype(Dtype.float32);
  const ref = refLogits.dtype === Dtype.float32 ? refLogits : refLogits.astype(Dtype.float32);

  const lseCur = ops.logsumexpAxis(cur, -1, true);
  const lseRef = ops.logsumexpAxis(ref, -1, true);
  const logCur = ops.sub(cur, lseCur);
  const logRef = ops.sub(ref, lseRef);
  const refProbs = ops.softmaxAxis(ref, -1, true);

  const diff = ops.sub(logRef, logCur);
  const weighted = ops.mul(refProbs, diff);
  const summed = ops.sumAxis(weighted, -1, false);
  const meaned = ops.meanAll(summed, false);

  const val = meaned.toFloat32()[0]!;

  for (const a of [lseCur, lseRef, logCur, logRef, refProbs, diff, weighted, summed, meaned]) {
    a.dispose();
  }
  if (cur !== curLogits) cur.dispose();
  if (ref !== refLogits) ref.dispose();
  return val;
}

// --------------------------------------------------------------------------
// Public entry: analyzeSensitivityExact
// --------------------------------------------------------------------------

/** Per-layer KL sensitivity of an already-quantized MLX model.
 *
 *  @param model        loaded RuntimeModel (its QuantizedLinears are the
 *                      uniform baseline; their dequantized weights are the
 *                      self-contained bf16 source).
 *  @param layers       the quantizable linears to probe, keyed by module path
 *                      (typically `model.loraTargets()`).
 *  @param calIds       calibration samples — each a row of int32 token ids.
 *  @param options      candidateBits (default [4,8]) and groupSize (default 64).
 */
export function analyzeSensitivityExact(
  model: RuntimeModel,
  layers: Map<string, QuantizedLinear>,
  calIds: number[][],
  options: AnalyzeSensitivityOptions = {},
  onProgress?: (done: number, total: number, layerName: string) => void,
): SensitivityResult[] {
  const candidateBits = [...(options.candidateBits ?? [4, 8])];
  const groupSize = options.groupSize ?? 64;

  // Calibration sample arrays (int32 [1, L]).
  const calArrays = calIds.map((ids) =>
    MlxArray.fromInt32(new Int32Array(ids), [1, ids.length]),
  );

  try {
    // Reference logits from the unmodified running model (taken once).
    const refLogits: MlxArray[] = calArrays.map((ids) => trainForward(model, ids));
    ops.evalAll(refLogits);

    const entries = [...layers.entries()];
    const results: SensitivityResult[] = [];

    try {
      for (let li = 0; li < entries.length; li++) {
        const [layerName, layer] = entries[li]!;
        const original = captureState(layer);
        const baselineBits = layer.spec.bits;

        // Self-contained bf16 source: dequantize the layer's own packed weight.
        const bf16Source = ops.dequantize(
          original.w, original.scales, original.biases, original.spec, cpuStream,
        ).astype(Dtype.bfloat16, cpuStream);
        ops.evalAll([bf16Source]);

        const sensitivities: Record<number, number> = {};

        for (const bits of candidateBits) {
          if (bits === baselineBits) {
            // KL is 0 by construction (re-quantizing to the baseline bit-width
            // reproduces the running model). Skip the forwards.
            sensitivities[bits] = 0.0;
            continue;
          }
          mutateLayerToBits(layer, bf16Source, bits, groupSize, original);

          let klSum = 0;
          for (let i = 0; i < calArrays.length; i++) {
            const cur = trainForward(model, calArrays[i]!);
            klSum += klFromRef(cur, refLogits[i]!);
            cur.dispose();
          }
          sensitivities[bits] = klSum / Math.max(calArrays.length, 1);
        }

        // Restore the original quantized weight; release the bf16 source.
        restoreState(layer, original);
        bf16Source.dispose();

        // param count = product of the dequantized (full) weight shape.
        const fullShape = [layer.outFeatures, layer.inFeatures];
        const paramCount = fullShape.reduce((a, b) => a * b, 1);

        results.push({ layerName, sensitivities, paramCount });
        onProgress?.(li + 1, entries.length, layerName);
      }
    } finally {
      for (const r of refLogits) r.dispose();
    }

    return results;
  } finally {
    for (const a of calArrays) a.dispose();
  }
}
