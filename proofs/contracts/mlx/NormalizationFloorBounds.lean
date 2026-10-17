import contracts.mlx.NormalizationDyadicBounds
import contracts.mlx.DivisionDirectedBounds

namespace Inference.Contracts.Mlx.NormalizationFloorBounds
open Numerics NormalizationExecution
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- A lower bound on a single input square gives a denominator floor. The
-- witness is a mathematical premise on the input vector; it inserts no
-- branching or range checks into the inference implementation.
theorem reduction_lower_expr (p : NormalizationDyadicBounds.Profile) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (division : DivisionDirectedBounds.Contract divide)
    (input : Fin n → Float32)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (positive : 0 < n) (size : n+1 ≤ 16384)
    (i : Fin n) (squareFloor meanFloor : Float32)
    (sf : squareFloor.isFinite = true) (sn : FlushToZero.threshold < real squareFloor)
    (mf : meanFloor.isFinite = true) (mn : FlushToZero.threshold < real meanFloor)
    (square : real squareFloor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i)))
    (capacity : real meanFloor ≤ real squareFloor / (n : ℝ)) :
    ReductionFinite divide input expr (Float32.ofInt n) p.eps ∧
      real meanFloor ≤ real (denominator divide input expr (Float32.ofInt n) p.eps) := by
  have hr := p.reductionExpr divide divError accuracy division.toContract expr coverage input hx positive size
  have hmemb : i ∈ SquaredSum.indices expr := coverage.mem_iff.mpr (List.mem_finRange i)
  have hs := SquaredSumDyadicBounds.lower input (fun j => (hx j).1) expr hr.1.hSum i hmemb squareFloor sf sn square
  have hsf := SquaredSum.finite_evaluate input expr hr.1.hSum
  have hsfloor := SquaredSumDyadicBounds.flush_lower squareFloor (SquaredSum.evaluate input expr) sn hs
  have hd : Division.DivisorDomain (Float32.ofInt n) := by
    constructor
    · rw [hr.1.hWidthValue]; exact_mod_cast positive
    · exact hr.1.hWidthUpper
  have hml := division.lower (sum input expr) (Float32.ofInt n) meanFloor hsf hr.1.hWidth hd mf mn
    (by rw [hr.1.hWidthValue]; exact capacity.trans (div_le_div_of_nonneg_right hsfloor (Nat.cast_nonneg _)))
  have hmfl := SquaredSumDyadicBounds.flush_lower meanFloor (mean divide input expr (Float32.ofInt n)) mn hml
  refine ⟨hr.1, ?_⟩
  apply SquaredSumDyadicBounds.flush_lower meanFloor _ mn
  rw [Numerics.add_real _ _ (FlushToZero.finite_flush _ hr.1.hMean) (FlushToZero.finite_flush _ p.epsFinite) hr.1.hDenominator]
  apply SquaredSumDyadicBounds.round_lower meanFloor mf
  exact hmfl.trans (le_add_of_nonneg_right (FlushToZero.flush_nonnegative p.eps
    (FlushToZero.threshold_pos.trans p.epsNormal).le))

theorem ranges_expr (p : NormalizationDyadicBounds.Profile) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (division : DivisionDirectedBounds.Contract divide)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (positive : 0 < n) (size : n+1 ≤ 16384)
    (i : Fin n) (squareFloor meanFloor : Float32)
    (sf : squareFloor.isFinite = true) (sn : FlushToZero.threshold < real squareFloor)
    (mf : meanFloor.isFinite = true) (mn : FlushToZero.threshold < real meanFloor)
    (square : real squareFloor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i)))
    (capacity : real meanFloor ≤ real squareFloor / (n : ℝ))
    (rsqrt : Float32 → Float32)
    (root : NormalizationBounds.RsqrtRange rsqrt meanFloor p.inverseCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ j, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt j)| ≤
        Model.toReal p.outputCap := by
  have hr := reduction_lower_expr p divide divError accuracy expr coverage division input hx positive size i squareFloor meanFloor sf sn mf mn square capacity
  have hd := denominator_finite divide input expr (Float32.ofInt n) p.eps hr.1
  exact p.finishExpr divide rsqrt expr input weight hx hw hr.1 (root.range _ hd hr.2)

theorem reduction_lower (p : NormalizationDyadicBounds.Profile) (platform : RmsNorm.Platform)
    (division : DivisionDirectedBounds.Contract platform.divide)
    (input : Fin n → Float32)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (positive : 0 < n) (size : n+1 ≤ 16384)
    (i : Fin n) (squareFloor meanFloor : Float32)
    (sf : squareFloor.isFinite = true) (sn : FlushToZero.threshold < real squareFloor)
    (mf : meanFloor.isFinite = true) (mn : FlushToZero.threshold < real meanFloor)
    (square : real squareFloor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i)))
    (capacity : real meanFloor ≤ real squareFloor / (n : ℝ)) :
    ReductionFinite platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps ∧
      real meanFloor ≤ real (denominator platform.divide input (RmsNorm.expression platform n) (Float32.ofInt n) p.eps) :=
  reduction_lower_expr p platform.divide platform.divError platform.division
    (RmsNorm.expression platform n) (RmsNorm.coverage platform n) division input hx positive size
    i squareFloor meanFloor sf sn mf mn square capacity

theorem ranges (p : NormalizationDyadicBounds.Profile) (platform : RmsNorm.Platform)
    (division : DivisionDirectedBounds.Contract platform.divide)
    (input : Fin n → Float32) (weight : Fin n → BFloat16Arithmetic.Value)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^p.inputExponent)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (positive : 0 < n) (size : n+1 ≤ 16384)
    (i : Fin n) (squareFloor meanFloor : Float32)
    (sf : squareFloor.isFinite = true) (sn : FlushToZero.threshold < real squareFloor)
    (mf : meanFloor.isFinite = true) (mn : FlushToZero.threshold < real meanFloor)
    (square : real squareFloor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i)))
    (capacity : real meanFloor ≤ real squareFloor / (n : ℝ))
    (root : NormalizationBounds.RsqrtRange platform.rsqrt meanFloor p.inverseCap) :
    Finite platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt ∧
      ∀ j, |real (output platform.divide input weight (RmsNorm.expression platform n) (Float32.ofInt n) p.eps platform.rsqrt j)| ≤
        Model.toReal p.outputCap :=
  ranges_expr p platform.divide platform.divError platform.division
    (RmsNorm.expression platform n) (RmsNorm.coverage platform n) division input weight hx hw positive size
    i squareFloor meanFloor sf sn mf mn square capacity platform.rsqrt root

end Inference.Contracts.Mlx.NormalizationFloorBounds
