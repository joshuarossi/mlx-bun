// Qwen3.5/3.8 multimodal RoPE (mRoPE) — the language-side position machinery
// for vision requests (PLAN 14v), port of mlx-vlm's qwen3_5 language rope:
// MRoPERotaryEmbedding (style "interleaved", mrope_section [11,11,10]) +
// get_rope_index + the rope_deltas decode continuation.
//
// TEXT-ONLY EQUIVALENCE: with all three position streams equal, interleaved
// selection collapses to plain partial RoPE — which is why the text path's
// ops.rope stays bit-exact untouched. This module only activates for
// requests whose prompt contains vision spans; while active, EVERY
// full-attention rope in the request (prefill AND decode) goes through the
// manual interleaved path, mirroring the reference (which never uses the
// fused fast-rope kernel when position_ids are supplied).
//
// Position semantics (get_rope_index, B=1 serial): text tokens advance all
// three streams together; an image span of grid (t, h/merge, w/merge) gets
// t/h/w grid positions offset by the current base; text after an image
// resumes at max+1. delta = (max position + 1) - sequence length; decode
// positions are offset + delta on all three streams.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { MetalKernel } from "../mlx/metal-kernel";

export interface MropeRequestState {
  /** Full-grid positions for the prompt, one Int32Array per t/h/w stream. */
  positions: [Int32Array, Int32Array, Int32Array];
  /** (max position + 1) - promptLength; decode positions = offset + delta. */
  delta: number;
}

export interface MropeForwardState {
  /** Effective positions [3, 1, L] int32 for the CURRENT forward window. */
  posIds: MlxArray;
  /** Borrowed model-owned f32 inv_freq (mropeInvFreq) — not disposed here. */
  invFreq: MlxArray;
  rotaryDims: number;
}

/** Active per-forward mRoPE cos/sin, read by Qwen3Attention.forward. Null on
 *  the text-only path (serial lane only — vision requests never batch). */
export let activeMrope: MropeForwardState | null = null;
export function setActiveMrope(s: MropeForwardState | null): void {
  activeMrope = s;
}

const MROPE_SECTION = [11, 11, 10] as const;

/** Interleaved frequency→stream selector (rope_utils
 *  _interleaved_position_selector): default t(0); indices 1,4,7,… take
 *  h(1) while < section[1]*3; indices 2,5,8,… take w(2) while < section[2]*3. */
export function interleavedSelector(freqDim: number): Int32Array {
  const sel = new Int32Array(freqDim);
  for (let dim = 1; dim <= 2; dim++) {
    const offset = dim; // h starts at 1, w at 2
    for (let i = offset; i < Math.min(MROPE_SECTION[dim]! * 3, freqDim); i += 3)
      sel[i] = dim;
  }
  return sel;
}

/** inv_freq for the language rope — computed on-device exactly like
 *  compute_inv_freq (Metal powf is not correctly rounded; a JS emulation
 *  drifts by 1 ulp on some entries). Returned as a live f32 device array
 *  (the apply kernel reads it directly). */
export function mropeInvFreq(rotaryDims: number, base: number): MlxArray {
  const ar = ops.arange(0, rotaryDims, 2, Dtype.float32);
  const ex = ops.mulScalar(ar, 1 / rotaryDims);
  ar.dispose();
  const theta = MlxArray.fromFloat32(Float32Array.from([base]), [1]);
  const p = ops.pow(theta, ex);
  theta.dispose();
  ex.dispose();
  const one = MlxArray.fromFloat32(Float32Array.from([1]), [1]);
  const invA = ops.div(one, p);
  one.dispose();
  p.dispose();
  return invA;
}

/** Effective positions [3,1,L] int32 for window [offset, offset+L) —
 *  prompt-grid positions while inside the prompt, offset+delta beyond it
 *  (the reference's rope_deltas continuation). */
export function buildMropePositions(
  state: MropeRequestState, offset: number, L: number,
  invFreq: MlxArray, rotaryDims: number,
): MropeForwardState {
  const P = state.positions;
  const promptLen = P[0].length;
  const joint = new Int32Array(3 * L);
  for (let axis = 0; axis < 3; axis++) {
    for (let l = 0; l < L; l++) {
      const idx = offset + l;
      joint[axis * L + l] = idx < promptLen ? P[axis]![idx]! : idx + state.delta;
    }
  }
  return { posIds: MlxArray.fromInt32(joint, [3, 1, L]), invFreq, rotaryDims };
}

// The reference language-side apply is a CUSTOM METAL KERNEL (rope_utils
// _mrope_apply_kernel, pairing "half_split", position_ndim 3): per rotated
// pair it computes angle = pos * inv_freq in f32, cos/sin in-kernel, and
// writes x*c − x_pair*s / x_pair*c + x*s with ONE rounding to the tensor
// dtype. A bf16 cos/sin manual path is ~0.4% off per rotation and moved
// step-0 logits by ~1.0 — this verbatim port is the oracle's arithmetic.
const kernelCache = new Map<number, MetalKernel>();
function mropeKernel(rotaryDims: number): MetalKernel {
  let k = kernelCache.get(rotaryDims);
  if (k) return k;
  const half = rotaryDims / 2;
  const source = `
        uint elem = thread_position_in_grid.x;

        const int half_dim = ${half};
        const int q_bsz = x_shape[0];
        const int q_heads = x_shape[1];
        const int q_len = x_shape[2];
        const int q_dim = x_shape[3];
        const int slots = half_dim + q_dim - ${rotaryDims};
        const int work_size = q_bsz * q_heads * q_len * slots;

        if (elem >= uint(work_size)) {
            return;
        }

        int local = int(elem);
        int slot = local % slots;
        int tmp = local / slots;
        int t = tmp % q_len;
        tmp = tmp / q_len;
        int h = tmp % q_heads;
        int b = tmp / q_heads;
        int base = ((b * q_heads + h) * q_len + t) * q_dim;

        if (slot >= half_dim) {
            int pass_d = ${rotaryDims} + slot - half_dim;
            int pass_idx = base + pass_d;
            x_out[pass_idx] = x[pass_idx];
            return;
        }

        int freq_idx = slot;
        int d = freq_idx;
        int pair_d = d + half_dim;
        int axis = int(position_selector[freq_idx]);
        float pos = static_cast<float>(position_ids[(axis * q_bsz + b) * q_len + t]);
        float angle = pos * static_cast<float>(inv_freq[freq_idx]);
        float c = metal::cos(angle);
        float s = metal::sin(angle);

        int idx = base + d;
        float xv = static_cast<float>(x[idx]);
        float xp = static_cast<float>(x[base + pair_d]);
        x_out[idx] = static_cast<T>(xv * c - xp * s);
        x_out[base + pair_d] = static_cast<T>(xp * c + xv * s);
`;
  k = new MetalKernel({
    name: `mrope_apply_half_split_${rotaryDims}_3d`,
    inputNames: ["x", "position_ids", "inv_freq", "position_selector"],
    outputNames: ["x_out"],
    source,
    ensureRowContiguous: true,
  });
  kernelCache.set(rotaryDims, k);
  return k;
}

const selectorCache = new Map<number, MlxArray>();
function selectorArr(half: number): MlxArray {
  let s = selectorCache.get(half);
  if (!s) {
    s = MlxArray.fromInt32(interleavedSelector(half), [half]);
    selectorCache.set(half, s);
  }
  return s;
}

/** Apply interleaved mRoPE to one [B, heads, L, headDim] tensor via the
 *  reference's exact Metal kernel. `invFreq` is the f32 device array from
 *  mropeInvFreq. */
export function applyInterleavedRope(
  x: MlxArray, fwd: MropeForwardState,
): MlxArray {
  const rotaryDims = fwd.rotaryDims;
  const [B, H, L, D] = x.shape as [number, number, number, number];
  const half = rotaryDims / 2;
  const slots = half + D - rotaryDims;
  const work = B * H * L * slots;
  const [out] = mropeKernel(rotaryDims).apply(
    [x, fwd.posIds, fwd.invFreq, selectorArr(half)],
    {
      outputs: [{ shape: [B, H, L, D], dtype: x.dtype }],
      grid: [work, 1, 1],
      threadGroup: [256, 1, 1],
      templateDtypes: { T: x.dtype },
    },
  );
  return out!;
}

/** get_rope_index port (B=1, no attention mask): positions per stream + the
 *  decode delta for a prompt with vision spans. `grids` are the per-image
 *  (t, h, w) grids in PATCH units and must appear in prompt order. */
export function qwenRopeIndex(
  ids: readonly number[],
  grids: readonly [number, number, number][],
  mergeSize: number,
  imageTokenId: number,
  videoTokenId: number,
): MropeRequestState {
  const L = ids.length;
  const P: [Int32Array, Int32Array, Int32Array] =
    [new Int32Array(L), new Int32Array(L), new Int32Array(L)];
  let write = 0; // next output index (== st in the reference walk)
  let base = 0; // st_idx: next position after everything placed so far
  let gi = 0;
  let i = 0;
  while (i < L) {
    const tok = ids[i]!;
    if ((tok === imageTokenId || tok === videoTokenId) && gi < grids.length) {
      const [t, h, w] = grids[gi]!;
      gi++;
      const gh = Math.trunc(h / mergeSize);
      const gw = Math.trunc(w / mergeSize);
      const span = t * gh * gw;
      for (let k = 0; k < span; k++) {
        const tt = Math.trunc(k / (gh * gw));
        const rem = k % (gh * gw);
        const hh = Math.trunc(rem / gw);
        const ww = rem % gw;
        P[0][write + k] = base + tt;
        P[1][write + k] = base + hh;
        P[2][write + k] = base + ww;
      }
      // Reference: next base = max position in the span + 1 = base +
      // max(t, gh, gw) … computed as llm_pos_ids.max()+1.
      base = base + Math.max(t, gh, gw);
      write += span;
      i += span;
    } else {
      P[0][write] = base;
      P[1][write] = base;
      P[2][write] = base;
      base++;
      write++;
      i++;
    }
  }
  if (write !== L)
    throw new Error(`qwenRopeIndex covered ${write} of ${L} tokens (grids misaligned?)`);
  return { positions: P, delta: base - L };
}
