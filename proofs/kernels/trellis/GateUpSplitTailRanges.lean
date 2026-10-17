import kernels.trellis.SigmoidRanges

namespace Inference.Kernels.Trellis.GateUpSplitTailRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx Contracts.Mlx.BFloat16Arithmetic GateUpSplitTail

structure Profile where
  gateCap : Value
  upCap : Value
  outputCap : Value
  gateFinite : Model.isFinite gateCap = true
  outputFinite : Model.isFinite outputCap = true
  capacity : Model.toReal gateCap * Model.toReal upCap ≤ Model.toReal outputCap

theorem ranges (p : Profile) (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : ExpAbsContract expAbs error) (expRange : SigmoidRanges.ExponentialRange expAbs)
    (gate up : Value)
    (hg : Model.isFinite gate = true ∧ |Model.toReal gate| ≤ Model.toReal p.gateCap)
    (hu : Model.isFinite up = true ∧ |Model.toReal up| ≤ Model.toReal p.upCap) :
    Delta.Gates.BetaValid expAbs gate ∧ ProductsFinite expAbs gate up ∧
      Model.isFinite (tail expAbs gate up) = true ∧
      |Model.toReal (tail expAbs gate up)| ≤ Model.toReal p.outputCap := by
  have hs := SigmoidRanges.product expAbs error exponential expRange gate p.gateCap hg.1 p.gateFinite hg.2
  have ho := BFloat16Bounds.mul_range (mul gate (sigmoidValue expAbs gate)) up p.outputCap
    (finite_flush _ hs.2.1) hu.1 p.outputFinite (by
      exact (mul_le_mul hs.2.2 hu.2 (abs_nonneg _) ((abs_nonneg _).trans hg.2)).trans p.capacity)
  exact ⟨hs.1, ⟨hg.1, hu.1, hs.2.1, ho.1⟩, finite_flush _ ho.1, ho.2⟩

-- Includes the actual +infinity exponential branch. The finite error and
-- overflow error both come from the scalar arithmetic proofs.
theorem error (p : Profile) (expAbs : Value → Value) (expError : Value → ℝ)
    (exponential : ExpAbsContract expAbs expError) (expRange : SigmoidRanges.ExponentialRange expAbs)
    (gate up : Value)
    (hg : Model.isFinite gate = true ∧ |Model.toReal gate| ≤ Model.toReal p.gateCap)
    (hu : Model.isFinite up = true ∧ |Model.toReal up| ≤ Model.toReal p.upCap) :
    |Model.toReal (tail expAbs gate up) - GateUpTail.swiglu (Model.toReal gate) (Model.toReal up)| ≤
      tailBudget expAbs gate up (Delta.Gates.betaBudget expAbs expError gate) := by
  have h := ranges p expAbs expError exponential expRange gate up hg hu
  have hs := Delta.Gates.beta_total_error expAbs expError exponential gate hg.1 h.1 (Model.toReal gate) 0 (by simp)
  simp only [zero_div, add_zero] at hs
  exact tail_error_of_sigmoid_error expAbs gate up _ hg.1 hu.1
    (Delta.Gates.beta_finite expAbs expError exponential gate h.1) h.2.1.hSilu h.2.1.hOutput hs

end Inference.Kernels.Trellis.GateUpSplitTailRanges
