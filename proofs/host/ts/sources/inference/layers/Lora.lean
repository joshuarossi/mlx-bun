import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.Lora
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/lora.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Per-adapter LoRA weights for one linear (mlx-lm LoRALinear shapes:
 *  a [in_features, rank], b [rank, out_features], typically f32). */
export interface LoraWeights {
  a: MlxArray;
  b: MlxArray;
  scale: number;
  rank: number;
}

/** Active-adapter state, shared by every mounted linear of one model.
 *  A plain field, NOT a ContextVar port: under continuous batching requests
 *  interleave, so the field is only valid for the forward being built. Each
 *  execution group binds its rows' adapter list (`bindAdapterContext`) and
 *  sets/restores it around every forward; `adapterScoped` does the same for a
 *  single generation. */
export class LoraState {
  #active: string[] = [];
  readonly #bindings = new Set<(active: readonly string[]) => void>();
  get active(): string[] { return this.#active; }
  set active(ids: string[]) {
    const neutral = this.#active.length === 0 && ids.length === 0;
    this.#active = ids;
    if (!neutral) this.refreshBindings();
  }
  /** Bind request-scoped compound operations before a forward is built. */
  bindOperation(binding: (active: readonly string[]) => void): () => void {
    this.#bindings.add(binding);
    binding(this.#active);
    return () => { this.#bindings.delete(binding); };
  }
  refreshBindings(): void { for (const bind of this.#bindings) bind(this.#active); }
  /** Training-only LoRA-input dropout. `rate` is the drop probability; `seed` is
   *  set per micro-step by the trainer and is CONSTANT across that step's forward
   *  and any recompute (segmented / gradient-checkpoint), so each layer's mask —
   *  keyed by (seed, the linear's dropoutId) — is reproduced exactly in the
   *  backward. `seed === null` (the default, and for inference) disables it. */
  dropoutRate = 0;
  dropoutSeed: number | null = null;
}

/** Inverted LoRA-input dropout, keyed by (seed, id) so it is deterministic —
 *  the same (seed, id, shape) reproduces the mask, which is what makes the
 *  segmented / gradient-checkpoint recompute correct. kept ⇒ x/(1-p),
 *  dropped ⇒ 0 (preserves the expectation). Caller owns the result. */
export function loraInputDropout(x: MlxArray, p: number, seed: number, id: number): MlxArray {
  const key = ops.randomKey(BigInt(seed) * 100003n + BigInt(id));
  const u = ops.randomUniform(x.shape, Dtype.float32, 0, 1, key); // [shape] in [0,1)
  key.dispose();
  const pArr = ops.scalarLike(p, u);
  const keep = ops.less(pArr, u); // u > p ⇒ keep (bool [shape])
  const scaleX = ops.scalarLike(1 / (1 - p), x);
  const zeroX = ops.scalarLike(0, x);
  const mask = ops.where(keep, scaleX, zeroX); // x.dtype
  const xd = ops.mul(x, mask);
  for (const a of [u, pArr, keep, scaleX, zeroX, mask]) a.dispose();
  return xd;
}

/** Adapter delta after any projection. Borrows x and consumes the projection
 * output, returning its owned replacement (or the same handle with no delta).
 * Request routing sets the shared active state before the operation runs. */
export class LoraDelta {
  constructor(readonly inFeatures = 0, readonly outFeatures = 0) {}
  adapters: Map<string, LoraWeights> | null = null;
  #state: LoraState | null = null;
  readonly #stateBindings = new Set<() => void>();
  get loraState(): LoraState | null { return this.#state; }
  set loraState(value: LoraState | null) {
    this.#state = value;
    for (const bind of this.#stateBindings) bind();
  }
  observeState(binding: () => void): () => void {
    this.#stateBindings.add(binding); binding();
    return () => { this.#stateBindings.delete(binding); };
  }
  dropoutId = 0;

  forward(x: MlxArray, out: MlxArray): MlxArray {
    // LoRA residual — composition is mlx-lm LoRALinear / optiq apply.py:
    //   y + (scale · ((x @ A) @ B)).astype(x.dtype)
    // (optiq mount.py omits the astype, leaking the f32 residual into the
    // bf16 stream; the
    // cast form is what the adapters were trained behind.)
    const st = this.loraState;
    if (st && st.active.length > 0 && this.adapters && this.adapters.size > 0) {
      // Training-only LoRA-input dropout (PEFT applies dropout to x before A;
      // the base quantized path is untouched). Keyed by (seed, dropoutId) so the
      // backward recompute reproduces the exact mask.
      let xLora = x;
      let xDrop: MlxArray | null = null;
      if (st.dropoutSeed !== null && st.dropoutRate > 0) {
        xDrop = loraInputDropout(x, st.dropoutRate, st.dropoutSeed, this.dropoutId);
        xLora = xDrop;
      }
      for (const id of st.active) {
        const lw = this.adapters.get(id);
        if (!lw) continue;
        const xa = ops.matmul(xLora, lw.a);
        const z = ops.matmul(xa, lw.b);
        xa.dispose();
        const zs = ops.mulScalar(z, lw.scale);
        z.dispose();
        const zc = zs.astype(x.dtype);
        zs.dispose();
        const previous = out; out = ops.add(out, zc); previous.dispose();
        zc.dispose();
      }
      xDrop?.dispose();
    }
    return out;
  }
}


/** A compound kernel's adapter operation, bound by the request context before
 * forward. Fused no-adapter arithmetic is retained; the adapted operation
 * exposes projections so their deltas precede activation. */
export class LoraOperation {
  #forward: (x: MlxArray) => MlxArray;
  readonly #unbind: (() => void)[] = [];
  readonly #states = new Map<LoraState, () => void>();
  constructor(plain: (x: MlxArray) => MlxArray, adapted: (x: MlxArray) => MlxArray,
    state: LoraState | undefined, targets: readonly LoraDelta[]) {
    this.#forward = plain;
    const refresh = () => {
      this.#forward = targets.some(target => (state?.active ?? target.loraState?.active ?? [])
        .some(id => target.adapters?.has(id))) ? adapted : plain;
    };
    const bind = () => {
      const states = new Set(state ? [state] : targets.flatMap(target => target.loraState ? [target.loraState] : []));
      for (const [previous, unbind] of this.#states) if (!states.has(previous)) { unbind(); this.#states.delete(previous); }
      for (const current of states) if (!this.#states.has(current)) this.#states.set(current, current.bindOperation(refresh));
      refresh();
    };
    if (state) bind();
    else for (const target of targets) this.#unbind.push(target.observeState(bind));
  }
  forward(x: MlxArray): MlxArray { return this.#forward(x); }
  dispose(): void {
    for (const unbind of this.#unbind) unbind();
    for (const unbind of this.#states.values()) unbind();
    this.#states.clear();
  }


}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.Lora
