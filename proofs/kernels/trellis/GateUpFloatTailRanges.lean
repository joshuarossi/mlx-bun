import kernels.trellis.GateUpTailFlushToZero
import kernels.trellis.GateUpSplitTailRanges
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.Float32UnitInterval
import contracts.mlx.Float32OverflowMargin
import contracts.mlx.NativeMultiplication

namespace Inference.Kernels.Trellis.GateUpFloatTailRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx Contracts.Mlx.Numerics GateUpTailFlushToZero
open GateUpSplitTailRanges (Profile)

-- The only range fact about precise::exp(-x): a finite result is
-- nonnegative, otherwise it overflowed to +infinity. No ceiling is needed:
-- 1+e cannot overflow under nearest-even rounding.
structure ExponentialRange (expNeg : Float32 → Float32) : Prop where
  result : ∀ x, x.isFinite=true →
    ((expNeg x).isFinite=true ∧ 0 ≤ real (expNeg x)) ∨ expNeg x=Float32.inf

-- A flushed product rounded to bfloat16 stays below a bfloat16 ceiling.
theorem rounded_product (x y : Float32) (cap : BFloat16Arithmetic.Value)
    (hx : x.isFinite=true) (hy : y.isFinite=true) (hc : Model.isFinite cap=true)
    (bound : |real x| * |real y| ≤ Model.toReal cap) :
    (FlushToZero.flush x*FlushToZero.flush y).isFinite=true ∧
      Model.isFinite (BFloat16.narrow (FlushToZero.mul x y))=true ∧
      (roundedMul x y).isFinite=true ∧ |real (roundedMul x y)| ≤ Model.toReal cap := by
  have hm := NativeMultiplication.range x y (BFloat16.widen cap) hx hy (BFloat16.widen_finite cap hc)
    (by rw [BFloat16.widen_real cap hc]; exact bound)
  rw [BFloat16.widen_real cap hc] at hm
  have hn := BFloat16ConversionBounds.narrow_range (FlushToZero.mul x y) cap (FlushToZero.finite_flush _ hm.1) hc hm.2
  refine ⟨hm.1, hn.1, BFloat16.widen_finite _ hn.1, ?_⟩
  change |real (BFloat16.widen (BFloat16.narrow (FlushToZero.mul x y)))| ≤ _
  rw [BFloat16.widen_real _ hn.1]
  exact hn.2

theorem products (p : Profile) (expNeg : Float32 → Float32) (gate up : Float32)
    (hg : gate.isFinite=true ∧ |real gate| ≤ Model.toReal p.gateCap)
    (hu : up.isFinite=true ∧ |real up| ≤ Model.toReal p.upCap)
    (hs : (roundedSigmoid expNeg gate).isFinite=true ∧ |real (roundedSigmoid expNeg gate)| ≤ 1) :
    ProductsFinite expNeg gate up ∧ (tail expNeg gate up).isFinite=true ∧
      |real (tail expNeg gate up)| ≤ Model.toReal p.outputCap := by
  have hm := rounded_product gate (roundedSigmoid expNeg gate) p.gateCap hg.1 hs.1 p.gateFinite
    ((mul_le_of_le_one_right (abs_nonneg _) hs.2).trans hg.2)
  have ho := rounded_product (roundedMul gate (roundedSigmoid expNeg gate)) up p.outputCap hm.2.2.1 hu.1
    p.outputFinite ((mul_le_mul hm.2.2.2 hu.2 (abs_nonneg _) ((abs_nonneg _).trans hg.2)).trans p.capacity)
  exact ⟨⟨hm.1, hm.2.1, ho.1, ho.2.1⟩, ho.2.2⟩

theorem ranges (p : Profile) (expNeg : Float32 → Float32) (range : ExponentialRange expNeg)
    (gate up : Float32)
    (hg : gate.isFinite=true ∧ |real gate| ≤ Model.toReal p.gateCap)
    (hu : up.isFinite=true ∧ |real up| ≤ Model.toReal p.upCap) :
    Valid expNeg gate up ∧ (tail expNeg gate up).isFinite=true ∧
      |real (tail expNeg gate up)| ≤ Model.toReal p.outputCap := by
  rcases range.result gate hg.1 with ⟨he, hn⟩ | he
  · have hf := FlushToZero.finite_flush _ he
    have hd : ((1 : Float32)+FlushToZero.flush (expNeg gate)).isFinite=true := by
      rw [← finite_model, Float32Bounds.add_model _ _ (by decide) hf]
      apply Float32OverflowMargin.add_finite _ _ (by rw [finite_model]; decide) (by rw [finite_model]; exact hf)
      change |real (1 : Float32)+real (FlushToZero.flush (expNeg gate))| ≤ _
      have hm := Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model (FlushToZero.flush (expNeg gate)))
        (by decide) (by rw [finite_model]; exact hf)
      change |real (FlushToZero.flush (expNeg gate))| ≤ Float32OverflowMargin.maximum at hm
      have hz := FlushToZero.flush_nonnegative _ hn
      rw [real_one, abs_of_nonneg (by linarith)]
      rw [abs_of_nonneg hz] at hm
      have ht : (1 : ℝ) ≤ (2 : ℝ)^(100 : Int) := one_le_zpow₀ (by norm_num) (by norm_num)
      linarith
    have lower := FlushToZero.add_one_ge_one _ he hn hd
    have hq := Float32UnitInterval.reciprocal (denominator expNeg gate) (denominator_finite expNeg gate hd) lower
    have hb := BFloat16ConversionBounds.narrow_range (quotient expNeg gate) BFloat16Arithmetic.one hq.2.1
      BFloat16Arithmetic.finite_one (by change |real (FlushToZero.div 1 (denominator expNeg gate))| ≤ _; rw [BFloat16Arithmetic.real_one, abs_of_nonneg hq.2.2.1]; exact hq.2.2.2)
    have hs : (roundedSigmoid expNeg gate).isFinite=true ∧ |real (roundedSigmoid expNeg gate)| ≤ 1 := by
      refine ⟨BFloat16.widen_finite _ hb.1, ?_⟩
      change |real (BFloat16.widen (BFloat16.narrow (quotient expNeg gate)))| ≤ 1
      rw [BFloat16.widen_real _ hb.1, ← BFloat16Arithmetic.real_one]
      exact hb.2
    have ht := products p expNeg gate up hg hu hs
    exact ⟨Or.inl ⟨hg.1, he, hd, hq.1, hb.1, ht.1.hSilu, ht.1.hSiluBfloat, ht.1.hOutput, ht.1.hOutputBfloat⟩, ht.2⟩
  · have hz := sigmoid_of_exp_inf expNeg gate he
    have hr : real (0 : Float32)=0 := by
      rw [real_unpack]
      exact Model.unpackedToReal_zero .positive
    have ht := products p expNeg gate up hg hu ⟨by rw [hz]; decide, by rw [hz, hr]; norm_num⟩
    exact ⟨Or.inr ⟨he, ht.1⟩, ht.2⟩

-- Includes the +infinity exponential branch through validBudget.
theorem error (p : Profile) (expNeg : Float32 → Float32) (expError : Float32 → ℝ)
    (exponential : GateUpTail.ExpNegContract expNeg expError) (range : ExponentialRange expNeg)
    (gate up : Float32)
    (hg : gate.isFinite=true ∧ |real gate| ≤ Model.toReal p.gateCap)
    (hu : up.isFinite=true ∧ |real up| ≤ Model.toReal p.upCap) :
    |real (tail expNeg gate up) - GateUpTail.swiglu (real gate) (real up)| ≤
      validBudget expNeg expError gate up :=
  valid_error expNeg expError exponential gate up (ranges p expNeg range gate up hg hu).1

end Inference.Kernels.Trellis.GateUpFloatTailRanges
