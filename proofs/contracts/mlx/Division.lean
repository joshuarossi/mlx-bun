import contracts.mlx.FlushToZero

namespace Inference.Contracts.Mlx.Division
open Numerics

-- Keep the scalar division implementation and accuracy separate from RMS
-- scheduling. MLX v0.32.2 builds rms_norm.metal with -fno-fast-math; selecting
-- this reference's nearest-even behavior remains a compiler/platform premise.
-- The domain includes the statically known normalization widths.
def DivisorDomain (y : Float32) : Prop := 1 ≤ real y ∧ real y ≤ (2 : ℝ) ^ (126 : Nat)

structure Contract (divide : Float32 → Float32 → Float32) (error : Float32 → Float32 → ℝ) : Prop where
  accuracy : ∀ x y, x.isFinite = true → y.isFinite = true → DivisorDomain y → (divide x y).isFinite = true →
    |real (divide x y) - real x / real y| ≤ error x y
  nonnegative : ∀ x y, x.isFinite = true → y.isFinite = true → 0 ≤ real x → DivisorDomain y →
    (divide x y).isFinite = true → 0 ≤ real (divide x y)

-- A consistency witness for the already proved flushed IEEE implementation.
theorem flushedRneContract : Contract FlushToZero.div FlushToZero.divBudget := by
  constructor
  · intro x y _ hy hd ho
    have hraw : (FlushToZero.flush x / y).isFinite = true := by
      simpa only [FlushToZero.div, FlushToZero.flush_eq_of_one_le y hd.1, FlushToZero.finite_flush_iff] using ho
    exact FlushToZero.div_normal_error x y hy hd.1 hraw
  · intro x y _ hy hx hd ho
    apply FlushToZero.div_nonnegative x y hy hx (by linarith [hd.1])
    simpa only [FlushToZero.div, FlushToZero.finite_flush_iff] using ho

end Inference.Contracts.Mlx.Division
