import contracts.mlx.NativeDivisionBounds

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

-- A finite flushed quotient has a finite rounded quotient: a flushed exact
-- quotient is far below the overflow threshold.
theorem raw_finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hn : 1 ≤ real y)
    (ho : (FlushToZero.div x y).isFinite = true) : (FlushToZero.flush x / y).isFinite = true := by
  unfold FlushToZero.div FlushToZero.flushExact at ho
  rw [FlushToZero.flush_eq_of_one_le y hn] at ho
  split at ho
  · rename_i s hu
    have hv := FlushToZero.underflow_some (FlushToZero.exact_div _ _) hu
    exact NativeDivisionBounds.finite _ y (FlushToZero.finite_flush x hx) hy (by linarith)
      (hv.trans (by norm_num [FlushToZero.threshold]))
  · exact ho

-- A consistency witness for the already proved flushed IEEE implementation.
theorem flushedRneContract : Contract FlushToZero.div FlushToZero.divBudget := by
  constructor
  · intro x y hx hy hd ho
    exact FlushToZero.div_normal_error x y hy hd.1 (raw_finite x y hx hy hd.1 ho)
  · intro x y hx' hy hx hd ho
    apply FlushToZero.div_nonnegative x y hy hx (by linarith [hd.1])
    rw [FlushToZero.flush_eq_of_one_le y hd.1]
    exact raw_finite x y hx' hy hd.1 ho


end Inference.Contracts.Mlx.Division
