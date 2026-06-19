// Fused GeGLU Metal kernel (optimization_plan Phase E, opportunity B/C):
// gelu_approx(a)·b in ONE pass, replacing the ~9 element-wise kernels the
// spelled-out path emits (power, ×3, +, ×, tanh, +, ×, × + a final mul).
// Both GeGLU sites are this shape — MLP (gelu(gate)·up) and the e4b
// per-layer gate (gelu(gate)·pli).
//
// MATCH-COMPAT precision: bf16 in/out, each intermediate rounded to bf16
// op-for-op with the spelled-out path (the mlx-lm parity constraint). A
// first full-f32 version drifted 0.22 KL on e4b (small per-element error
// compounding over 42 MLPs) — match-compat keeps the distribution on the
// trained path; the only residual is the pow/tanh math-lib difference, which
// the KL gate quantifies. Still a perf kernel (not bit-exact) and never
// inside a compiled-decode trace: CustomKernel has no output_shapes (same
// rule as fusedDecodeSdpa) — the caller guards on !isCompiledTrace().

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import { CustomVjp } from "../mlx/custom-vjp";
import * as ops from "../mlx/ops";

/** ON by default: the match-compat kernel is BIT-EXACT with the spelled-out
 *  path (kl --decode = 0 on e4b), so per the bit-parity-floor principle it
 *  ships on — every optimization we can keep while staying bit-exact.
 *  MLX_BUN_FUSED_GELU=0 opts out (e.g. the compile arm of the A/B). */
export function fusedGeluEnabled(): boolean {
  return process.env.MLX_BUN_FUSED_GELU !== "0";
}

/** Dispatch counter (a gate test asserts the kernel actually ran). */
export let fusedGeluCalls = 0;

// Training-mode flag: when set, model GeGLU sites use the DIFFERENTIABLE wrapper
// (Metal-kernel forward + hand-derived vjp) instead of the plain `fusedGeglu`
// (a bare CustomKernel with no vjp — feeding it to autograd throws
// "[Primitive::vjp] Not implemented for CustomKernel"). The differentiable
// wrapper also recomputes the gelu in the backward from the primal `a` instead
// of retaining the ~9 forward intermediates, so it lowers the MLP activation
// memory the backward holds — the dominant resident at long context under
// ops.sdpa (which never materializes the O(T²) scores). Set by the trainer
// around the train loop; cleared in its finally. Off → inference behaviour
// (plain `fusedGeglu`) is byte-for-byte unchanged.
let _trainingGeglu = false;
export function setFusedGeluTraining(on: boolean): void {
  _trainingGeglu = on;
}
export function fusedGeluTraining(): boolean {
  return _trainingGeglu;
}

// Pointwise: one thread per element. gelu_approx =
//   0.5 x (1 + tanh(√(2/π)·(x + 0.044715 x³)))  — composed in f32.
const SOURCE = String.raw`
  const uint i = thread_position_in_grid.x;
  if (i >= SIZE) return;
  // Match-compat: round each intermediate (and the weak scalars) to T, op
  // for op with the spelled-out bf16 path, so the fused distribution tracks
  // the TRAINED path rather than drifting to "more accurate but different".
  // x^3 via pow (the reference uses mx.power, NOT x*x*x — they round
  // differently in bf16). The single remaining residual vs compat is the
  // pow/tanh math-lib difference, which the KL gate quantifies.
  const float C_CUBE = float(T(0.044715f));
  const float C_SQRT = float(T(0.7978845608028654f)); // √(2/π)
  const float C_HALF = float(T(0.5f));
  const float x   = float(a[i]);
  const float x3  = float(T(metal::pow(x, 3.0f)));
  const float cx3 = float(T(x3 * C_CUBE));
  const float inn = float(T(x + cx3));
  const float scl = float(T(inn * C_SQRT));
  const float tnh = float(T(metal::precise::tanh(scl)));
  const float t1  = float(T(1.0f + tnh));
  const float hx  = float(T(x * C_HALF));
  const float g   = float(T(hx * t1));
  out[i] = T(g * float(b[i]));
`;

let kernel: MetalKernel | null = null;
function getKernel(): MetalKernel {
  if (!kernel)
    kernel = new MetalKernel({
      name: "mlx_bun_fused_geglu",
      inputNames: ["a", "b"],
      outputNames: ["out"],
      source: SOURCE,
      ensureRowContiguous: true,
    });
  return kernel;
}

/** bf16/f16 only (the activation dtype the kernel reads/writes). */
export function fusedGeluSupported(a: MlxArray): boolean {
  return a.dtype === Dtype.bfloat16 || a.dtype === Dtype.float16;
}

/** gelu_approx(a) · b, fused. a and b must share shape/dtype; out is a.dtype. */
export function fusedGeglu(a: MlxArray, b: MlxArray): MlxArray {
  fusedGeluCalls++;
  const size = a.shape.reduce((x, y) => x * y, 1);
  const [out] = getKernel().apply([a, b], {
    outputs: [{ shape: a.shape, dtype: a.dtype }],
    grid: [size, 1, 1],
    threadGroup: [Math.min(size, 256), 1, 1],
    templateInts: { SIZE: size },
    templateDtypes: { T: a.dtype },
  });
  return out!;
}

// ---------------------------------------------------------------------------
// Differentiable wrapper: Metal kernel forward + pure-MLX backward
// ---------------------------------------------------------------------------

// GELU tanh-approx constants
const SQRT_2_PI = 0.7978845608028654;
const C_CUBE = 0.044715;

/** Compute gelu_approx(a) = 0.5 * a * (1 + tanh(sqrt(2/pi) * (a + 0.044715*a^3)))
 *  and gelu'(a) using the MLX ops layer. All intermediates are disposed
 *  before returning; caller owns the two returned arrays. */
function geluAndGrad(a: MlxArray): { gelu: MlxArray; geluGrad: MlxArray } {
  // a^3 = a * a * a
  const a2 = ops.mul(a, a);
  const a3 = ops.mul(a2, a);
  // inner = a + 0.044715 * a^3
  const cx3 = ops.mulScalar(a3, C_CUBE);
  const inner = ops.add(a, cx3);
  // z = sqrt(2/pi) * inner
  const z = ops.mulScalar(inner, SQRT_2_PI);
  // t = tanh(z)
  const t = ops.tanh(z);
  // gelu = 0.5 * a * (1 + t)
  const one = ops.scalarLike(1, a);
  const t1 = ops.add(one, t);
  const halfA = ops.mulScalar(a, 0.5);
  const gelu = ops.mul(halfA, t1);

  // gelu'(a) = 0.5*(1+t) + 0.5*a*(1-t^2)*dz/da
  // dz/da = sqrt(2/pi) * (1 + 3*0.044715*a^2)
  // 1 - t^2 = sech^2(z)
  const halfT1 = ops.mulScalar(t1, 0.5);            // 0.5*(1+t)
  const t2 = ops.mul(t, t);                         // t^2
  const sech2 = ops.sub(one, t2);                   // 1 - t^2
  const halfASech2 = ops.mul(halfA, sech2);         // 0.5*a*(1-t^2)
  // dz/da
  const a2scaled = ops.mulScalar(a2, 3 * C_CUBE);   // 3*0.044715*a^2
  const dzda = ops.add(one, a2scaled);               // 1 + 3*0.044715*a^2
  const dzdaScaled = ops.mulScalar(dzda, SQRT_2_PI);// sqrt(2/pi)*dz_unnorm
  // chain: 0.5*a*(1-t^2)*dz/da
  const chainTerm = ops.mul(halfASech2, dzdaScaled);
  const geluGrad = ops.add(halfT1, chainTerm);       // 0.5*(1+t) + chain

  // dispose all intermediates
  for (const arr of [a2, a3, cx3, inner, z, t, one, t1, halfA, halfT1, t2, sech2,
                      halfASech2, a2scaled, dzda, dzdaScaled, chainTerm]) {
    arr.dispose();
  }

  return { gelu, geluGrad };
}

let _differentiableKernel: CustomVjp | null = null;

function getDifferentiableKernel(): CustomVjp {
  if (!_differentiableKernel) {
    _differentiableKernel = new CustomVjp(
      // forward: use the Metal kernel
      ([a, b]: MlxArray[]) => [fusedGeglu(a!, b!)],
      // backward
      (primals: MlxArray[], cotangents: MlxArray[], _outputs: MlxArray[]) => {
        const [a, b] = primals as [MlxArray, MlxArray];
        const [dc] = cotangents as [MlxArray];

        const { gelu, geluGrad } = geluAndGrad(a);

        // grad_b = dc * gelu(a)
        const grad_b = ops.mul(dc, gelu);

        // grad_a = dc * b * gelu'(a)
        const dcb = ops.mul(dc, b);
        const grad_a = ops.mul(dcb, geluGrad);

        gelu.dispose();
        geluGrad.dispose();
        dcb.dispose();

        return [grad_a, grad_b];
      },
    );
  }
  return _differentiableKernel;
}

/** gelu_approx(a) · b with a hand-derived vjp. Uses the Metal kernel forward,
 *  MLX-ops backward. For training only (inference uses the non-differentiable
 *  fusedGeglu). */
export function fusedGegluDifferentiable(a: MlxArray, b: MlxArray): MlxArray {
  return getDifferentiableKernel().apply([a, b])[0]!;
}
