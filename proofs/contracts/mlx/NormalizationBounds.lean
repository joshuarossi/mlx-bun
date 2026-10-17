import contracts.mlx.RmsNorm
import contracts.mlx.SquaredSumBounds
import contracts.mlx.DivisionBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Contracts.Mlx.NormalizationBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics
open NormalizationExecution
set_option maxHeartbeats 200000

-- This contract covers only the scalar rsqrt instruction. Every surrounding
-- reduction, addition, multiplication and conversion is discharged below.
structure RsqrtRange (rsqrt : Float32 → Float32) (floor cap : Float32) : Prop where
  range : ∀ x, x.isFinite = true → real floor ≤ real x →
    (rsqrt x).isFinite = true ∧ |real (rsqrt x)| ≤ real cap

structure Profile where
  eps : Float32
  inverseCap : Float32
  normalizedCap : BFloat16Arithmetic.Value
  weightCap : BFloat16Arithmetic.Value
  outputCap : BFloat16Arithmetic.Value
  epsFinite : eps.isFinite = true
  epsNormal : FlushToZero.threshold < real eps
  epsBound : |real eps| ≤ 1
  inverseFinite : inverseCap.isFinite = true
  normalizedFinite : Model.isFinite normalizedCap = true
  outputFinite : Model.isFinite outputCap = true
  normalizedCapacity : real inverseCap ≤ Model.toReal normalizedCap
  outputCapacity : Model.toReal weightCap * Model.toReal normalizedCap ≤ Model.toReal outputCap

theorem Profile.reduction (p : Profile) (platform : RmsNorm.Platform)
    (division : DivisionBounds.Contract platform.divide)
    (input : Fin n → Float32) (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ 1)
    (positive : 0 < n) (size : n + 1 < 16777216) :
    ReductionFinite platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps ∧
      real p.eps ≤ real (denominator platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps) := by
  let expr := RmsNorm.expression platform n
  have hs := SquaredSumBounds.covered_range input hi expr (RmsNorm.coverage platform n) (by omega)
  have hw := IntegerBounds.natural n (by omega)
  have hc := IntegerBounds.natural (n + 1) size
  have hd : Division.DivisorDomain (Float32.ofInt n) := by
    rw [Division.DivisorDomain, hw.2]
    constructor
    · exact_mod_cast positive
    · have hn : (n : ℝ) ≤ 16777216 := by exact_mod_cast (show n ≤ 16777216 by omega)
      exact hn.trans (by norm_num)
  have hsf := SquaredSum.finite_evaluate input expr hs.1
  have hmf := division.finite _ _ hsf hw.1 hd
  have hmb := division.bounded _ _ (Float32.ofInt n) hsf hw.1 hd hw.1
    (by rw [hw.2, abs_of_nonneg hs.2.1]; exact hs.2.2)
  have hmn := platform.division.nonnegative _ _ hsf hw.1 hs.2.1 hd hmf
  have ha := Float32Bounds.add_range (mean platform.divide input expr (Float32.ofInt n)) p.eps
    (Float32.ofInt ((n+1 : Nat) : Int)) hmf p.epsFinite hc.1
    (by rw [hc.2]; have hmb' := hmb; rw [hw.2] at hmb'; simpa only [mean, sum, Nat.cast_add, Nat.cast_one] using add_le_add hmb' p.epsBound)
  refine ⟨⟨hs.1, hw.1, hw.2, positive, hd.2, hmf, p.epsFinite, ha.1, p.epsNormal⟩, ?_⟩
  exact FlushToZero.add_ge_normal_right _ _ hmf p.epsFinite hmn p.epsNormal ha.1

theorem Profile.ranges (p : Profile) (platform : RmsNorm.Platform)
    (division : DivisionBounds.Contract platform.divide) (root : RsqrtRange platform.rsqrt p.eps p.inverseCap)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ 1)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (positive : 0 < n) (size : n + 1 < 16777216) :
    Finite platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt ∧
      ∀ i, |real (output platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt i)| ≤
        Model.toReal p.outputCap := by
  let expr := RmsNorm.expression platform n
  have hr := p.reduction platform division input hi positive size
  have hd := denominator_finite platform.divide input expr (Float32.ofInt n) p.eps hr.1
  have hs := root.range _ hd hr.2
  have hm (i : Fin n) := NativeMultiplication.range (input i)
    (normalizer platform.divide input expr (Float32.ofInt n) p.eps platform.rsqrt) p.inverseCap
    (hi i).1 hs.1 p.inverseFinite
    (calc
      _ ≤ 1 * real p.inverseCap := mul_le_mul (hi i).2 hs.2 (abs_nonneg _) (by norm_num)
      _ = _ := one_mul _)
  have hb (i : Fin n) := BFloat16ConversionBounds.narrow_range
    (normalized platform.divide input expr (Float32.ofInt n) p.eps platform.rsqrt i) p.normalizedCap
    (FlushToZero.finite_flush _ (hm i).1) p.normalizedFinite ((hm i).2.trans p.normalizedCapacity)
  have ho (i : Fin n) := BFloat16Bounds.mul_range (weight i)
    (BFloat16.narrow (normalized platform.divide input expr (Float32.ofInt n) p.eps platform.rsqrt i)) p.outputCap
    (hw i).1 (hb i).1 p.outputFinite
    ((mul_le_mul (hw i).2 (hb i).2 (abs_nonneg _) ((abs_nonneg _).trans (hw i).2)).trans p.outputCapacity)
  refine ⟨{ toReductionFinite := hr.1
            hNormalizer := hs.1
            hNormalized := fun i => (hm i).1
            hNarrow := fun i => (hb i).1
            hWeight := fun i => (hw i).1
            hOutput := fun i => (ho i).1 }, ?_⟩
  intro i
  unfold output
  have hf : Model.isFinite (BFloat16Arithmetic.mul (weight i)
      (BFloat16.narrow (normalized platform.divide input expr (Float32.ofInt n) p.eps platform.rsqrt i))) = true :=
    BFloat16Arithmetic.finite_flush _ (ho i).1
  rw [BFloat16.widen_real _ hf]
  exact (ho i).2

end Inference.Contracts.Mlx.NormalizationBounds
