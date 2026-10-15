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

/** Per-row summed response log likelihood, extracted unchanged from DPO.
 * logits [B,L-1,V] predict ids[:,1:]; mask is indexed in the original [B,L]
 * token coordinates. Prompt and padding masks are zero, answer masks one.
 * Borrows every input and returns an owned differentiable f32 tensor [B].
 * Subtraction precedes the f32 cast, retaining the existing DPO operation order.
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
  const logits2d = ops.reshape(logits, [N, V]);
  const targets = MlxArray.fromInt32(targetsHost, [N, 1]);
  const m = MlxArray.fromFloat32(maskHost, [N]);

  const lse = ops.logsumexpAxis(logits2d, -1, false); // [N]
  const gathered = ops.takeAlongAxis(logits2d, targets, -1); // [N,1]
  const picked = ops.reshape(gathered, [N]); // [N]
  const logp = ops.sub(picked, lse); // log_softmax at the label
  const logpF = logp.dtype === Dtype.float32 ? logp : logp.astype(Dtype.float32);
  const masked = ops.mul(logpF, m); // [N]
  const masked2d = ops.reshape(masked, [B, T]); // [B, T]
  const perRow = ops.sumAxis(masked2d, 1, false); // [B]

  for (const a of [logits2d, targets, m, lse, gathered, picked, logp, masked, masked2d]) a.dispose();
  if (logpF !== logp) logpF.dispose();
  return perRow;
}
