import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.Geglu
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/geglu.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// GeGLU activation and feed-forward shared by the Gemma family: the compiled
// geglu closure (mlx-lm's @mx.compile geglu), the spelled-out composition, and
// the dense quantized MLP built on them. Which one a layer runs is its owner's
// construction-time choice (`compiled`), never read here.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

import { CompiledFunction } from "@mlx-bun/mlx/compile";
import type { ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import { isCompiledTrace } from "../runtime/compiled-trace";
import { QuantizedLinear, QuantizedLinearPlain } from "./quantized-linear";

/** Verbatim port of mlx_lm/models/gemma4_text.py:
 *    `@partial(mx.compile, shapeless=True) def geglu(gate, x): return nn.gelu_approx(gate) * x`
 *  The oracle @mx.compile's this and uses it for EVERY MLP shape (dense MLP
 *  __call__ line 114, and the SwitchGLU GeGLU activation line 149-150). The
 *  spelled-out composition runs the SAME math UNFUSED (standalone
 *  ops.geluApprox + ops.mul), a different dispatched kernel set + the per-op
 *  host tax the MiniCPM5 swiglu fix measured at ~5%. This closure fuses
 *  geluApprox's ~9 element-wise ops + the final mul into one traced-once/replayed
 *  graph, matching the oracle's kernel set. `geluApprox` is composed op-for-op
 *  from the same primitives as the oracle's nn.gelu_approx
 *  (0.5·x·(1+tanh(√(2/π)(x+0.044715·x³)))), so the compiled graph is the
 *  oracle's geglu graph. Autograd-safe (verified: the vjp through this closure is
 *  bit-identical to the plain composition). */
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

/** gelu_approx(gate) * up, consuming both inputs. `compiled` is the owner's
 *  construction-time choice: the compiled closure (the oracle's @mx.compile'd
 *  geglu, one kernel set; the default the Gemma graphs compose), or the
 *  spelled-out operation (same L1
 *  parity, slower). Inside a compiled-decode trace the closure records the
 *  spelled-out ops. */
export function geglu(gate: MlxArray, up: MlxArray, compiled: boolean): MlxArray {
  let out: MlxArray;
  if (compiled && !isCompiledTrace()) {
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

/** Dense GeGLU feed-forward: down(geglu(gate(x), up(x))) over quantized linears,
 *  with the activation form its owner chose at construction (`compiled`). */
export class GegluMLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string, readonly compiled: boolean) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray): MlxArray {
    const m = geglu(this.gate.forward(x), this.up.forward(x), this.compiled);
    const out = this.down.forward(m);
    m.dispose();
    return out;
  }
}

/** Plain GeGLU consumes both activation inputs. */
export class PlainGeglu {
  forward(gate: MlxArray, up: MlxArray): MlxArray {
    using act = ops.geluApprox(gate);
    const out = ops.mul(act, up);
    gate.dispose(); up.dispose();
    return out;
  }
}

/** Compiled GeGLU consumes both activation inputs. */
export class CompiledGeglu {
  forward(gate: MlxArray, up: MlxArray): MlxArray {
    const out = compiledGeglu(gate, up);
    gate.dispose(); up.dispose();
    return out;
  }
}

export class PlainGegluMLP {
  readonly #activation = new PlainGeglu();
  readonly #gate: QuantizedLinearPlain;
  readonly #up: QuantizedLinearPlain;
  readonly #down: QuantizedLinearPlain;
  constructor(readonly base: GegluMLP) {
    this.#gate = new QuantizedLinearPlain(base.gate);
    this.#up = new QuantizedLinearPlain(base.up);
    this.#down = new QuantizedLinearPlain(base.down);
  }
  forward(x: MlxArray): MlxArray {
    using hidden = this.#activation.forward(this.#gate.forward(x), this.#up.forward(x));
    return this.#down.forward(hidden);
  }
}
export class CompiledGegluMLP {
  readonly #activation = new CompiledGeglu();
  readonly #gate: QuantizedLinearPlain;
  readonly #up: QuantizedLinearPlain;
  readonly #down: QuantizedLinearPlain;
  constructor(readonly base: GegluMLP) {
    this.#gate = new QuantizedLinearPlain(base.gate);
    this.#up = new QuantizedLinearPlain(base.up);
    this.#down = new QuantizedLinearPlain(base.down);
  }
  forward(x: MlxArray): MlxArray {
    using hidden = this.#activation.forward(this.#gate.forward(x), this.#up.forward(x));
    return this.#down.forward(hidden);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.Geglu
