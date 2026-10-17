import kernels.delta.Softplus
import contracts.mlx.BFloat16Bounds

namespace Inference.Kernels.Delta.SoftplusRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx Contracts.Mlx.BFloat16Arithmetic

-- Only scalar exp/log1p behavior is assumed. The subtraction and addition
-- surrounding them are proved from operand bounds, including flushing.
-- MLX's bf16 log1p divides fast_log(1+x) by (1+x)-1, so on [0,1] only a
-- coarse ceiling of 8 follows from operation-level clauses.
structure PrimitiveRanges (exp log1p : Value → Value) : Prop where
  exponential : ∀ x, Model.isFinite x = true → Model.toReal x ≤ 0 →
    Model.isFinite (exp x) = true ∧ (0 ≤ Model.toReal (exp x) ∧ Model.toReal (exp x) ≤ 1)
  logarithm : ∀ x, Model.isFinite x = true → (0 ≤ Model.toReal x ∧ Model.toReal x ≤ 1) →
    Model.isFinite (log1p x) = true ∧ (0 ≤ Model.toReal (log1p x) ∧ Model.toReal (log1p x) ≤ 8)

theorem difference (policy : Softplus.Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.isFinite (Softplus.difference policy x) = true ∧ Model.toReal (Softplus.difference policy x) ≤ 0 := by
  refine ⟨finite_flush _ (Softplus.raw_difference_finite policy x hx), ?_⟩
  apply sub_nonpositive_flushed _ _ (Softplus.bottom_finite policy x hx) (Softplus.top_finite policy x hx) _ _
    (Softplus.raw_difference_finite policy x hx)
  · rw [Softplus.bottom_real policy x hx]; exact min_le_right _ _
  · rw [Softplus.top_real policy x hx]; exact le_max_right _ _

theorem top_bound (policy : Softplus.Policy) (x : Value) : |Model.toReal (Softplus.top policy x)| ≤ |Model.toReal x| := by
  rcases Softplus.top_mem policy x with e | e <;> rw [e]
  rw [Trellis.GateUpSplitTail.zero, Model.toReal_zero, abs_zero]
  exact abs_nonneg _

theorem ranges (policy : Softplus.Policy) (exp log1p : Value → Value) (primitive : PrimitiveRanges exp log1p)
    (x inputCap outputCap : Value) (hx : Model.isFinite x = true) (ho : Model.isFinite outputCap = true)
    (bound : |Model.toReal x| ≤ Model.toReal inputCap)
    (capacity : Model.toReal inputCap + 8 ≤ Model.toReal outputCap) :
    Softplus.Finite policy exp log1p x ∧ Model.isFinite (Softplus.value policy exp log1p x) = true ∧
      (0 ≤ Model.toReal (Softplus.value policy exp log1p x) ∧
        |Model.toReal (Softplus.value policy exp log1p x)| ≤ Model.toReal outputCap) := by
  have hd := difference policy x hx
  have he := primitive.exponential _ hd.1 hd.2
  have hl := primitive.logarithm _ he.1 he.2
  have hb : |Model.toReal (Softplus.top policy x)| + |Model.toReal (log1p (exp (Softplus.difference policy x)))| ≤ Model.toReal outputCap := by
    rw [abs_of_nonneg hl.2.1]
    exact (add_le_add ((top_bound policy x).trans bound) hl.2.2).trans capacity
  have ha := BFloat16Bounds.add_range (Softplus.top policy x) (log1p (exp (Softplus.difference policy x))) outputCap
    (Softplus.top_finite policy x hx) hl.1 ho hb
  refine ⟨⟨hx, he.1, hl.1, ha.1, hl.2.1⟩, finite_flush _ ha.1, ?_, ha.2⟩
  apply add_nonnegative_flushed _ _ (Softplus.top_finite policy x hx) hl.1 _ (flush_nonnegative _ hl.2.1) ha.1
  rw [Softplus.top_real policy x hx]
  exact le_max_right _ _


end Inference.Kernels.Delta.SoftplusRanges
