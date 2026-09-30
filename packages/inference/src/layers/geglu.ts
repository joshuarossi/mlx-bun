// GeGLU activation and feed-forward shared by the Gemma family: the compiled
// geglu closure (mlx-lm's @mx.compile geglu), the flag/trace rule that selects it,
// and the dense quantized MLP built on it.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

import { CompiledFunction } from "@mlx-bun/mlx/compile";
import type { ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import { isCompiledTrace } from "../runtime/compiled-trace";
import { runtimeFlag } from "../runtime/config";
import { QuantizedLinear } from "./quantized-linear";

/** Verbatim port of mlx_lm/models/gemma4_text.py:
 *    `@partial(mx.compile, shapeless=True) def geglu(gate, x): return nn.gelu_approx(gate) * x`
 *  The oracle @mx.compile's this and uses it for EVERY MLP shape (dense MLP
 *  __call__ line 114, and the SwitchGLU GeGLU activation line 149-150). Our
 *  default MLP runs the SAME math UNFUSED (standalone ops.geluApprox + ops.mul),
 *  a different dispatched kernel set + the per-op host tax the MiniCPM5 swiglu
 *  fix measured at ~5%. This closure fuses geluApprox's ~9 element-wise ops + the
 *  final mul into one traced-once/replayed graph, matching the oracle's kernel
 *  set. `geluApprox` is composed op-for-op from the same primitives as the
 *  oracle's nn.gelu_approx (0.5·x·(1+tanh(√(2/π)(x+0.044715·x³)))), so the
 *  compiled graph is the oracle's geglu graph. Autograd-safe (verified: the vjp
 *  through this closure is bit-identical to the plain composition). */
/** True when gemma's geglu activation runs through the compiled closure (matching
 *  the oracle's @mx.compile geglu) instead of the spelled-out ops.geluApprox+ops.mul.
 *  DEFAULT ON: compiled geglu is bit-exact to mlx-lm's @mx.compile geglu (same
 *  libmlx graph → same kernel) AND dispatches one fused kernel set instead of the
 *  ~9-op path. `MLX_BUN_COMPILED_GEGLU=0` (--compiled-activations off) selects the
 *  uncompiled composition — same L1 parity, slower (the A/B opt-out). */
export function compiledGegluActive(): boolean {
  return runtimeFlag("MLX_BUN_COMPILED_GEGLU", true);
}

let _gegluClosure: CompiledFunction | null = null;
export function compiledGeglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_gegluClosure) {
    _gegluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!; // nn.gelu_approx(gate) * x
      const act = ops.geluApprox(g);
      const out = ops.mul(act, u); act.dispose();
      return [out];
    });
  }
  return _gegluClosure.apply([gate, up])[0]!;
}

/** gelu_approx(gate) * up, consuming both inputs. Compiled by default (the
 *  oracle's @mx.compile'd geglu, one kernel set) and spelled out under
 *  MLX_BUN_COMPILED_GEGLU=0 or inside a compiled-decode trace. */
export function geglu(gate: MlxArray, up: MlxArray): MlxArray {
  let out: MlxArray;
  if (compiledGegluActive() && !isCompiledTrace()) {
    out = compiledGeglu(gate, up);
  } else {
    const act = ops.geluApprox(gate);
    out = ops.mul(act, up);
    act.dispose();
  }
  gate.dispose();
  up.dispose();
  return out;
}

/** Dense GeGLU feed-forward: down(geglu(gate(x), up(x))) over quantized linears. */
export class GegluMLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const m = geglu(this.gate.forward(x), this.up.forward(x));
    const out = this.down.forward(m);
    m.dispose();
    return out;
  }
}
