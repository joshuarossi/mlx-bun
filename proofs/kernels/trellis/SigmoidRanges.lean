import contracts.mlx.BFloat16UnitInterval
import contracts.mlx.BFloat16OverflowMargin
import kernels.delta.Gates

namespace Inference.Kernels.Trellis.SigmoidRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx Contracts.Mlx.BFloat16Arithmetic
open GateUpSplitTail

-- A scalar exponential obligation, separate from its approximation error:
-- a finite result, or overflow to +inf. No ceiling is needed: 1+e cannot
-- overflow under nearest-even rounding (BFloat16OverflowMargin).
structure ExponentialRange (expAbs : Value → Value) : Prop where
  result : ∀ x, Model.isFinite x = true →
    Model.isFinite (expAbs x) = true ∨ expAbs x = Model.posInf FloatFormat.bfloat16

theorem finite_branch (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (x : Value) (hx : Model.isFinite x = true) (he : Model.isFinite (expAbs x) = true) :
    SigmoidFinite expAbs x ∧
    (0 ≤ Model.toReal (sigmoidValue expAbs x) ∧ Model.toReal (sigmoidValue expAbs x) ≤ 1) := by
  have hn := exponential.nonnegative x hx he
  have hd' : Model.isFinite (Model.add one (flush (expAbs x))) = true :=
    BFloat16OverflowMargin.one_add_finite _ he hn
  have hden : Model.isFinite (denominator expAbs x) = true := by
    unfold denominator add; rw [flush_one]; exact finite_flush _ hd'
  have lower : 1 ≤ Model.toReal (denominator expAbs x) :=
    add_one_ge_one _ he hn hd'
  have hq := BFloat16UnitInterval.reciprocal (denominator expAbs x) hden lower
  have hs := BFloat16UnitInterval.complement (sigY expAbs x) hq.2.1 hq.2.2
  refine ⟨⟨hx, he, hd', hq.1, fun _ => hs.1⟩, ?_⟩
  unfold sigmoidValue
  split
  · exact hq.2.2
  · exact hs.2.2

theorem ranges (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (range : ExponentialRange expAbs)
    (x : Value) (hx : Model.isFinite x = true) :
    Delta.Gates.BetaValid expAbs x ∧ Model.isFinite (sigmoidValue expAbs x) = true ∧
    (0 ≤ Model.toReal (sigmoidValue expAbs x) ∧ Model.toReal (sigmoidValue expAbs x) ≤ 1) := by
  rcases range.result x hx with he | he
  · have h := finite_branch expAbs error exponential x hx he
    exact ⟨Or.inl h.1, sigmoid_finite expAbs error exponential x h.1, h.2⟩
  · refine ⟨Or.inr he, ?_, ?_⟩
    · rw [sigmoid_of_exp_inf expAbs x he]
      split
      · rfl
      · exact finite_one
    · rw [sigmoid_of_exp_inf expAbs x he]
      split
      · simp only [zero, Model.toReal_zero]; norm_num
      · rw [real_one]; norm_num

theorem product (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (range : ExponentialRange expAbs)
    (x cap : Value) (hx : Model.isFinite x = true) (hc : Model.isFinite cap = true)
    (bound : |Model.toReal x| ≤ Model.toReal cap) :
    Delta.Gates.BetaValid expAbs x ∧
    Model.isFinite (Model.mul (flush x) (flush (sigmoidValue expAbs x))) = true ∧
    |Model.toReal (mul x (sigmoidValue expAbs x))| ≤ Model.toReal cap := by
  have h := ranges expAbs error exponential range x hx
  have hp := BFloat16Bounds.mul_range x (sigmoidValue expAbs x) cap hx h.2.1 hc (by
    rw [abs_of_nonneg h.2.2.1]
    exact (mul_le_of_le_one_right (abs_nonneg _) h.2.2.2).trans bound)
  exact ⟨h.1, hp⟩

end Inference.Kernels.Trellis.SigmoidRanges
