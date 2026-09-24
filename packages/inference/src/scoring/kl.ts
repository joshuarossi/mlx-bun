import { MlxArray } from '@mlx-bun/mlx/array';
import { Dtype } from '@mlx-bun/mlx/ffi';
import * as ops from '@mlx-bun/mlx/ops';


/** KL(p ‖ q) per token for logits [1, T, V]; returns a length-T array. */
export function klPerToken(pLogits: MlxArray, qLogits: MlxArray): Float32Array {
  const f32 = (a: MlxArray): { arr: MlxArray; owned: boolean } =>
    a.dtype === Dtype.float32 ? { arr: a, owned: false } : { arr: a.astype(Dtype.float32), owned: true };
  const pp = f32(pLogits);
  const qq = f32(qLogits);
  const p = pp.arr;
  const q = qq.arr;

  const lseP = ops.logsumexpAxis(p, -1, true);   // [1,T,1]
  const lseQ = ops.logsumexpAxis(q, -1, true);
  const logP = ops.sub(p, lseP);                  // [1,T,V]
  const logQ = ops.sub(q, lseQ);
  const pProbs = ops.softmaxAxis(p, -1, true);    // precise softmax
  const diff = ops.sub(logP, logQ);
  const prod = ops.mul(pProbs, diff);
  const kl = ops.sumAxis(prod, -1, false);        // [1,T]
  const out = kl.toFloat32();

  for (const a of [lseP, lseQ, logP, logQ, pProbs, diff, prod, kl]) a.dispose();
  if (pp.owned) p.dispose();
  if (qq.owned) q.dispose();
  return out;
}
