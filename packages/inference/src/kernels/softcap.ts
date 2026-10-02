// Compiled (fused) Gemma logit softcap, matching mlx-lm's gemma4_text.py
// `@partial(mx.compile) logit_softcap`. The unfused composition lives in
// logits.ts; the two are separate on purpose (see compiledLogitSoftcap).

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { CompiledFunction } from "@mlx-bun/mlx/compile";

/** gemma4_text.py `@partial(mx.compile) def logit_softcap(softcap, x):
 *    return mx.tanh(x / softcap) * softcap`
 *  The oracle fuses divide+tanh+multiply into ONE kernel; our default
 *  `logitSoftcap` (logits.ts) runs them UNFUSED (standalone div + tanh + mul →
 *  a separate `vn_Tanh` + `vsn_Divide`). Keyed by cap so the softcap is baked
 *  as a graph constant (matching the oracle's weak-scalar → the
 *  `…Divide…Tanh…Multiply…_VC_` kernel). The two implementations are
 *  intentionally separate: this one reproduces the oracle's compiled kernel
 *  (Gemma4's final softcap, outside a compiled trace); `logitSoftcap` is the
 *  plain composition used elsewhere (Universal attention/final softcap, and
 *  inside a compiled trace). Neither may replace the other. */
const _softcapClosures = new Map<number, CompiledFunction>();
export function compiledLogitSoftcap(x: MlxArray, cap: number): MlxArray {
  let fn = _softcapClosures.get(cap);
  if (!fn) {
    fn = new CompiledFunction((inputs) => {
      const xx = inputs[0]!;                    // tanh(x / softcap) * softcap
      const capArr = ops.scalarLike(cap, xx);
      const scaled = ops.div(xx, capArr);
      const t = ops.tanh(scaled); scaled.dispose();
      const out = ops.mul(t, capArr); t.dispose(); capArr.dispose();
      return [out];
    });
    _softcapClosures.set(cap, fn);
  }
  return fn.apply([x])[0]!;
}
