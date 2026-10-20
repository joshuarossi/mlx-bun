import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { sequenceLogitsOperation } from "./full-sequence";

/** The existing DPO/ORPO head geometry, shared with inference. Two- and
 * three-row response spans pad to four before the head and slice back. Borrows
 * hidden and model, returns caller-owned logits; preserves training numerics. */
export function logitsFromHiddenPadM(
  model: object,
  hSpan: MlxArray, // [1, M, hidden]
): MlxArray {
  const M = hSpan.shape[1]!;
  if (M !== 2 && M !== 3) return sequenceLogitsOperation(model, hSpan);
  const [B, , H] = hSpan.shape as [number, number, number];
  const pad = ops.zeros([B, 4 - M, H], hSpan.dtype);
  const hPad = ops.concatAxis([hSpan, pad], 1);
  pad.dispose();
  const lgPad = sequenceLogitsOperation(model, hPad); // [1, 4, V]
  hPad.dispose();
  const start = MlxArray.fromInt32(new Int32Array([0]), [1]);
  const lg = ops.sliceDynamic(lgPad, start, [1], [B, M, lgPad.shape[2]!]);
  start.dispose();
  lgPad.dispose();
  return lg;
}

/** Per-row summed response log likelihood for DPO and decision scoring.
 * logits [B,L-1,V] predict ids[:,1:]; mask is indexed in the original [B,L]
 * token coordinates. Prompt and padding masks are zero, answer masks one.
 * Borrows every input and returns an owned differentiable f32 tensor [B].
 * Normalize in f32: casting after logsumexp/subtraction cannot recover precision
 * lost when logits are bf16 or f16.
 */
export function sequenceLogProbabilities(logits: MlxArray, ids: number[][], mask: number[][]): MlxArray {
  const B = ids.length;
  const L = ids[0]!.length;
  const T = L - 1;
  const V = logits.shape[2]!;
  const N = B * T;

  const targetsHost = new Int32Array(N);
  const maskHost = new Float32Array(N);
  for (let b = 0; b < B; b++)
    for (let t = 0; t < T; t++) {
      const flat = b * T + t;
      targetsHost[flat] = ids[b]![t + 1]!;
      maskHost[flat] = mask[b]![t + 1]!; // resp_mask[:, 1:]
    }
  const logitsF = logits.dtype === Dtype.float32 ? logits : logits.astype(Dtype.float32);
  const logits2d = ops.reshape(logitsF, [N, V]);
  const targets = MlxArray.fromInt32(targetsHost, [N, 1]);
  const m = MlxArray.fromFloat32(maskHost, [N]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [N]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [N,1]
  const picked = ops.reshape(gathered, [N]); // [N]
  const logp = ops.sub(picked, lse); // log_softmax at the label
  const masked = ops.mul(logp, m); // [N]
  const masked2d = ops.reshape(masked, [B, T]); // [B, T]
  const perRow = ops.sumAxis(masked2d, 1, false); // [B]

  for (const a of [logits2d, targets, m, lse, gathered, picked, logp, masked, masked2d]) a.dispose();
  if (logitsF !== logits) logitsF.dispose();
  return perRow;
}

/** Same summed response score, applying the head only where mask[:,1:] is
 * nonzero. Hidden states still come from the complete causal forward: gathering
 * here preserves gradients through the prompt. Rows are padded to the longest
 * response in the batch, not to the prompt length. Borrows hidden and model. */
export function sequenceLogProbabilitiesFromHidden(
  model: object,
  hidden: MlxArray, // [B, L-1, hidden]
  ids: number[][],
  mask: number[][],
): MlxArray {
  const [B, T, H] = hidden.shape as [number, number, number];
  const positions = mask.map(row => row.slice(1).flatMap((weight, t) => weight !== 0 ? [t] : []));
  const M = Math.max(...positions.map(row => row.length));
  if (M === 0) return ops.zeros([B], Dtype.float32);
  const indices = new Int32Array(B * M);
  const compactIds: number[][] = [], compactMask: number[][] = [];
  for (let b = 0; b < B; b++) {
    const tokens = [0], weights = [0];
    for (let m = 0; m < M; m++) {
      const t = positions[b]![m];
      indices[b * M + m] = b * T + (t ?? 0);
      tokens.push(t === undefined ? 0 : ids[b]![t + 1]!);
      weights.push(t === undefined ? 0 : mask[b]![t + 1]!);
    }
    compactIds.push(tokens);
    compactMask.push(weights);
  }
  using flat = ops.reshape(hidden, [B * T, H]);
  using index = MlxArray.fromInt32(indices, [B * M]);
  using selected = ops.takeAxis(flat, index, 0);
  using span = ops.reshape(selected, [B, M, H]);
  using logits = logitsFromHiddenPadM(model, span);
  return sequenceLogProbabilities(logits, compactIds, compactMask);
}
