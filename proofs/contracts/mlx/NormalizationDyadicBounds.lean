import contracts.mlx.NormalizationBounds
import contracts.mlx.SquaredSumDyadicBounds

namespace Inference.Contracts.Mlx.NormalizationDyadicBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics
open NormalizationExecution

structure Profile where
  inputExponent : Int
  inputLower : -74 ≤ inputExponent
  inputUpper : inputExponent+inputExponent ≤ 112
  eps : Float32
  epsFinite : eps.isFinite = true
  epsNormal : FlushToZero.threshold < real eps
  epsBound : |real eps| ≤ 1
  inverseCap : Float32
  productCap : Float32
  normalizedCap : BFloat16Arithmetic.Value
  weightCap : BFloat16Arithmetic.Value
  outputCap : BFloat16Arithmetic.Value
  inverseFinite : inverseCap.isFinite = true
  productFinite : productCap.isFinite = true
  normalizedFinite : Model.isFinite normalizedCap = true
  outputFinite : Model.isFinite outputCap = true
  productCapacity : (2 : ℝ)^inputExponent * real inverseCap ≤ real productCap
  normalizedCapacity : real productCap ≤ Model.toReal normalizedCap
  outputCapacity : Model.toReal weightCap * Model.toReal normalizedCap ≤ Model.toReal outputCap

theorem Profile.reductionExpr (p : Profile) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionBounds.Contract divide)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (positive : 0 < n) (size : n+1 ≤ 16384) :
    ReductionFinite divide input expr (Float32.ofInt n) p.eps ∧
      real p.eps ≤ real (denominator divide input expr (Float32.ofInt n) p.eps) := by
  have hlo : -149 ≤ p.inputExponent+p.inputExponent := by have := p.inputLower; omega
  have hs := SquaredSumDyadicBounds.covered_range_wide input p.inputExponent hlo p.inputUpper hx expr
    coverage (by omega)
  have hw := IntegerBounds.natural n (by omega)
  have cs := DyadicBounds.ceiling_range_wide n (p.inputExponent+p.inputExponent) (by omega) hlo p.inputUpper
  let denominatorExponent := max 0 (p.inputExponent+p.inputExponent)
  have edLo : -149 ≤ denominatorExponent := by dsimp [denominatorExponent]; omega
  have edHi : denominatorExponent ≤ 112 := by dsimp [denominatorExponent]; have := p.inputUpper; omega
  have cd := DyadicBounds.ceiling_range_wide (n+1) denominatorExponent size edLo edHi
  have hd : Division.DivisorDomain (Float32.ofInt n) := by
    rw [Division.DivisorDomain, hw.2]
    constructor
    · exact_mod_cast positive
    · have hn : (n : ℝ) ≤ 16777216 := by exact_mod_cast (show n ≤ 16777216 by omega)
      exact hn.trans (by norm_num)
  have hsf := SquaredSum.finite_evaluate input expr hs.1
  have hmf := division.finite _ _ hsf hw.1 hd
  have hmb := division.bounded _ _ (DyadicBounds.ceiling n (p.inputExponent+p.inputExponent))
    hsf hw.1 hd cs.1 (by rw [cs.2, abs_of_nonneg hs.2.1]; exact hs.2.2)
  have hmn := accuracy.nonnegative _ _ hsf hw.1 hs.2.1 hd hmf
  have ep : (2 : ℝ)^(p.inputExponent+p.inputExponent) ≤ (2 : ℝ)^denominatorExponent :=
    zpow_le_zpow_right₀ (by norm_num) (le_max_right _ _)
  have he : |real p.eps| ≤ (2 : ℝ)^denominatorExponent :=
    p.epsBound.trans (one_le_zpow₀ (by norm_num) (le_max_left _ _))
  have ha := Float32Bounds.add_range (mean divide input expr (Float32.ofInt n)) p.eps
    (DyadicBounds.ceiling (n+1) denominatorExponent) hmf p.epsFinite cd.1
    (by rw [cd.2]; have hm := hmb; rw [cs.2] at hm; calc
        _ ≤ (n : ℝ) * (2 : ℝ)^denominatorExponent + (2 : ℝ)^denominatorExponent :=
          add_le_add (hm.trans (mul_le_mul_of_nonneg_left ep (Nat.cast_nonneg _))) he
        _ = _ := by push_cast; ring)
  exact ⟨⟨hs.1, hw.1, hw.2, positive, hd.2, hmf, p.epsFinite, ha.1, p.epsNormal⟩,
    FlushToZero.add_ge_normal_right _ _ hmf p.epsFinite hmn p.epsNormal ha.1⟩

theorem Profile.finishExpr (p : Profile) (divide : Float32 → Float32 → Float32)
    (rsqrt : Float32 → Float32) (expr : SquaredSum.Expr n)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (reduction : ReductionFinite divide input expr (Float32.ofInt n) p.eps)
    (inverse : (normalizer divide input expr (Float32.ofInt n) p.eps rsqrt).isFinite = true ∧
      |real (normalizer divide input expr (Float32.ofInt n) p.eps rsqrt)| ≤ real p.inverseCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)| ≤
        Model.toReal p.outputCap := by
  have hm (i : Fin n) := NativeMultiplication.range (input i)
    (normalizer divide input expr (Float32.ofInt n) p.eps rsqrt) p.productCap
    (hx i).1 inverse.1 p.productFinite
    ((mul_le_mul (hx i).2 inverse.2 (abs_nonneg _) (zpow_nonneg (by norm_num) _)).trans p.productCapacity)
  have hb (i : Fin n) := BFloat16ConversionBounds.narrow_range
    (normalized divide input expr (Float32.ofInt n) p.eps rsqrt i) p.normalizedCap
    (FlushToZero.finite_flushExact _ _ (hm i).1) p.normalizedFinite ((hm i).2.trans p.normalizedCapacity)
  have ho (i : Fin n) := BFloat16Bounds.mul_range (weight i)
    (BFloat16.narrow (normalized divide input expr (Float32.ofInt n) p.eps rsqrt i)) p.outputCap
    (hw i).1 (hb i).1 p.outputFinite
    ((mul_le_mul (hw i).2 (hb i).2 (abs_nonneg _) ((abs_nonneg _).trans (hw i).2)).trans p.outputCapacity)
  refine ⟨{ toReductionFinite := reduction
            hNormalizer := inverse.1
            hNormalized := fun i => (hm i).1
            hNarrow := fun i => (hb i).1
            hWeight := fun i => (hw i).1
            hOutput := fun i => (ho i).1 }, ?_⟩
  intro i
  unfold output
  have hf : Model.isFinite (BFloat16Arithmetic.mul (weight i)
      (BFloat16.narrow (normalized divide input expr (Float32.ofInt n) p.eps rsqrt i))) = true :=
    BFloat16Arithmetic.mul_finite _ _ (ho i).1
  rw [BFloat16.widen_real _ hf]
  exact (ho i).2

theorem Profile.rangesExpr (p : Profile) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionBounds.Contract divide) (rsqrt : Float32 → Float32)
    (root : NormalizationBounds.RsqrtRange rsqrt p.eps p.inverseCap)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (positive : 0 < n) (size : n+1 ≤ 16384) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)| ≤
        Model.toReal p.outputCap := by
  have hr := p.reductionExpr divide divError accuracy division expr coverage input hx positive size
  have hd := denominator_finite divide input expr (Float32.ofInt n) p.eps hr.1
  exact p.finishExpr divide rsqrt expr input weight hx hw hr.1 (root.range _ hd hr.2)

-- Preserve the looped RMS entry points while sharing the arithmetic proof
-- with kernels whose lane layout has a different square-sum expression.
theorem Profile.reduction (p : Profile) (platform : RmsNorm.Platform)
    (division : DivisionBounds.Contract platform.divide)
    (input : Fin n → Float32)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (positive : 0 < n) (size : n+1 ≤ 16384) :
    ReductionFinite platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps ∧
      real p.eps ≤ real (denominator platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps) :=
  p.reductionExpr platform.divide platform.divError platform.division division
    (RmsNorm.expression platform n) (RmsNorm.coverage platform n) input hx positive size

theorem Profile.finish (p : Profile) (platform : RmsNorm.Platform)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (reduction : ReductionFinite platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps)
    (inverse : (normalizer platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt).isFinite = true ∧
      |real (normalizer platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt)| ≤ real p.inverseCap) :
    Finite platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt ∧
      ∀ i, |real (output platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt i)| ≤
        Model.toReal p.outputCap :=
  p.finishExpr platform.divide platform.rsqrt (RmsNorm.expression platform n) input weight hx hw reduction inverse

theorem Profile.ranges (p : Profile) (platform : RmsNorm.Platform)
    (division : DivisionBounds.Contract platform.divide)
    (root : NormalizationBounds.RsqrtRange platform.rsqrt p.eps p.inverseCap)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (positive : 0 < n) (size : n+1 ≤ 16384) :
    Finite platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt ∧
      ∀ i, |real (output platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt i)| ≤
        Model.toReal p.outputCap :=
  p.rangesExpr platform.divide platform.divError platform.division division platform.rsqrt root
    (RmsNorm.expression platform n) (RmsNorm.coverage platform n) input weight hx hw positive size

end Inference.Contracts.Mlx.NormalizationDyadicBounds
