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

/** ON by default: the match-compat kernel is BIT-EXACT with the spelled-out
 *  path (kl --decode = 0 on e4b), so per the bit-parity-floor principle it
 *  ships on — every optimization we can keep while staying bit-exact.
 *  MLX_BUN_FUSED_GELU=0 opts out (e.g. the compile arm of the A/B). */
export function fusedGeluEnabled(): boolean {
  return process.env.MLX_BUN_FUSED_GELU !== "0";
}

/** Dispatch counter (a gate test asserts the kernel actually ran). */
export let fusedGeluCalls = 0;

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
