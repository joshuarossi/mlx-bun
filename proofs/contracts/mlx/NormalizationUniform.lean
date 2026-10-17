import contracts.mlx.NormalizationFloorBounds
import contracts.mlx.DyadicCover
import contracts.mlx.RsqrtBounds
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Contracts.Mlx.NormalizationUniform
open Numerics NormalizationExecution
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

private theorem float_cap (e : Int) (lo : -149 ≤ e) (hi : e ≤ 112) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range_wide 1 e (by decide) lo hi
private theorem bf_cap (e : Int) (lo : -133 ≤ e) (hi : e ≤ 119) :
    Model.isFinite (BFloat16DyadicBounds.ceiling 1 e) = true ∧ Model.toReal (BFloat16DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using BFloat16DyadicBounds.ceiling_range 1 e (by decide) lo hi

-- The uniform bound depends on head width and weights, not on input scale.
-- The range [-10,56] below is a proof partition, not runtime dispatch.
structure Profile (n : Nat) where
  positive : 0 < n
  widthLog : Nat
  widthLogBound : widthLog ≤ 13
  widthBound : n ≤ 2^widthLog
  normalizedExponent : Nat
  normalizedPositive : 1 ≤ normalizedExponent
  normalizedBound : normalizedExponent ≤ 30
  rootCapacity : widthLog+4 ≤ 2*normalizedExponent
  eps : Float32
  epsFinite : eps.isFinite = true
  epsNormal : FlushToZero.threshold < real eps
  epsBound : |real eps| ≤ 1
  smallCapacity : 4 ≤ real eps * (2 : ℝ)^(22 : Nat)
  weightCap : BF
  outputCap : BF
  outputFinite : Model.isFinite outputCap = true
  outputCapacity : Model.toReal weightCap * (2 : ℝ)^normalizedExponent ≤ Model.toReal outputCap

private def Profile.dyadic (p : Profile n) (exponent inverse : Int)
    (lo : -10 ≤ exponent) (hi : exponent ≤ 56)
    (ilo : -149 ≤ inverse) (ihi : inverse ≤ 112)
    (capacity : exponent+inverse ≤ (p.normalizedExponent : Int)) : NormalizationDyadicBounds.Profile where
  inputExponent := exponent
  inputLower := by omega
  inputUpper := by omega
  eps := p.eps
  epsFinite := p.epsFinite
  epsNormal := p.epsNormal
  epsBound := p.epsBound
  inverseCap := DyadicBounds.ceiling 1 inverse
  productCap := DyadicBounds.ceiling 1 p.normalizedExponent
  normalizedCap := BFloat16DyadicBounds.ceiling 1 p.normalizedExponent
  weightCap := p.weightCap
  outputCap := p.outputCap
  inverseFinite := (float_cap inverse ilo ihi).1
  productFinite := (float_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).1
  normalizedFinite := (bf_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).1
  outputFinite := p.outputFinite
  productCapacity := by
    rw [(float_cap inverse ilo ihi).2,
      (float_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).2,
      ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    exact zpow_le_zpow_right₀ (by norm_num) capacity
  normalizedCapacity := by
    rw [(float_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).2,
      (bf_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).2]
  outputCapacity := by
    rw [(bf_cap p.normalizedExponent (by omega) (by have := p.normalizedBound; omega)).2, zpow_natCast]
    exact p.outputCapacity

private theorem Profile.size (p : Profile n) : n+1 ≤ 16384 := by
  have h := p.widthBound.trans (Nat.pow_le_pow_right (by decide : 0 < 2) p.widthLogBound)
  norm_num at h
  omega

theorem small_range (p : Profile n) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionBounds.Contract divide) (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BF)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(-10 : Int))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)| ≤ Model.toReal p.outputCap := by
  let profile := p.dyadic (-10) 11 (by decide) (by decide) (by decide) (by decide)
    (by have := p.normalizedPositive; omega)
  have hr := RsqrtBounds.range rsqrt root p.eps (DyadicBounds.ceiling 1 11)
    (FlushToZero.threshold_pos.trans p.epsNormal)
    (by rw [(float_cap 11 (by decide) (by decide)).2]; positivity)
    (by simpa only [(float_cap 11 (by decide) (by decide)).2, zpow_ofNat, ← pow_mul] using p.smallCapacity)
  exact profile.rangesExpr divide divError accuracy division rsqrt hr expr coverage input weight hx hw p.positive p.size

theorem bin_range (p : Profile n) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionDirectedBounds.Contract divide) (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BF)
    (e : Int) (lo : -10 < e) (hi : e ≤ 56)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^e)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap)
    (i : Fin n) (lower : (2 : ℝ)^(e-1) < |real (input i)|) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ j, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt j)| ≤ Model.toReal p.outputCap := by
  let inverse : Int := (p.normalizedExponent : Int)-e
  have il : -149 ≤ inverse := by dsimp [inverse]; omega
  have iu : inverse ≤ 112 := by dsimp [inverse]; have := p.normalizedBound; omega
  let profile := p.dyadic e inverse (by omega) hi il iu (by dsimp [inverse]; omega)
  let squareFloor := DyadicBounds.ceiling 1 (2*e-2)
  let meanFloor := DyadicBounds.ceiling 1 (2*e-2-(p.widthLog : Int))
  have hs := float_cap (2*e-2) (by omega) (by omega)
  have hm := float_cap (2*e-2-(p.widthLog : Int)) (by have := p.widthLogBound; omega) (by omega)
  have hc := float_cap inverse il iu
  have sn : FlushToZero.threshold < real squareFloor := by
    rw [hs.2]
    exact (by norm_num [FlushToZero.threshold] : FlushToZero.threshold < (2 : ℝ)^(-20 : Int)).trans_le
      (zpow_le_zpow_right₀ (by norm_num) (by omega))
  have mn : FlushToZero.threshold < real meanFloor := by
    rw [hm.2]
    exact (by norm_num [FlushToZero.threshold] : FlushToZero.threshold < (2 : ℝ)^(-40 : Int)).trans_le
      (zpow_le_zpow_right₀ (by norm_num) (by have := p.widthLogBound; omega))
  have inputNormal : FlushToZero.threshold < |real (input i)| :=
    ((by norm_num [FlushToZero.threshold] : FlushToZero.threshold < (2 : ℝ)^(-10 : Int)).trans_le
      (zpow_le_zpow_right₀ (by norm_num) (by omega))).trans lower
  have square : real squareFloor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i)) := by
    rw [FlushToZero.flush_eq_of_threshold_lt _ inputNormal, hs.2]
    have hsq := (sq_le_sq₀ (by positivity : 0 ≤ (2 : ℝ)^(e-1)) (abs_nonneg _)).mpr lower.le
    calc
      (2 : ℝ)^(2*e-2) = ((2 : ℝ)^(e-1))^2 := by rw [pow_two, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]; congr 1; ring
      _ ≤ |real (input i)|^2 := hsq
      _ = _ := by rw [sq_abs, pow_two]
  have capacity : real meanFloor ≤ real squareFloor / (n : ℝ) := by
    rw [hm.2, hs.2]
    apply (le_div_iff₀ (by exact_mod_cast p.positive : (0 : ℝ) < n)).mpr
    have hn : (n : ℝ) ≤ (2 : ℝ)^(p.widthLog : Int) := by
      rw [zpow_natCast]; exact_mod_cast p.widthBound
    calc
      _ ≤ (2 : ℝ)^(2*e-2-(p.widthLog : Int)) * (2 : ℝ)^(p.widthLog : Int) := mul_le_mul_of_nonneg_left hn (by positivity)
      _ = _ := by rw [← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]; congr 1; ring
  have hr := RsqrtBounds.range rsqrt root meanFloor (DyadicBounds.ceiling 1 inverse)
    (FlushToZero.threshold_pos.trans mn) (by rw [hc.2]; positivity) (by
      rw [hm.2, hc.2, pow_two, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0),
        ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      calc
        (4 : ℝ) = (2 : ℝ)^(2 : Int) := by norm_num
        _ ≤ _ := zpow_le_zpow_right₀ (by norm_num) (by dsimp [inverse]; have := p.rootCapacity; omega))
  exact NormalizationFloorBounds.ranges_expr profile divide divError accuracy expr coverage division input weight hx hw
    p.positive p.size i squareFloor meanFloor hs.1 sn hm.1 mn square capacity rsqrt hr

theorem ranges_wide (p : Profile n) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionDirectedBounds.Contract divide) (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BF)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(56 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)| ≤ Model.toReal p.outputCap := by
  rcases DyadicCover.interval (fun i => real (input i)) (-10) 66
      (fun i => by simpa only [show (-10 : Int)+(66 : Nat) = 56 from by decide, zpow_ofNat] using (hx i).2) with
    small | ⟨e, lo, hi, upper, i, lower⟩
  · exact small_range p divide divError accuracy division.toContract rsqrt root expr coverage input weight
      (fun i => ⟨(hx i).1, small i⟩) hw
  · exact bin_range p divide divError accuracy division rsqrt root expr coverage input weight e lo (by norm_num at hi; exact hi)
      (fun i => ⟨(hx i).1, upper i⟩) hw i lower

theorem ranges (p : Profile n) (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (division : DivisionDirectedBounds.Contract divide) (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt)
    (expr : SquaredSum.Expr n) (coverage : (SquaredSum.indices expr).Perm (List.finRange n))
    (input : Fin n → Float32) (weight : Fin n → BF)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal p.weightCap) :
    Finite divide input weight expr (Float32.ofInt n) p.eps rsqrt ∧
      ∀ i, |real (output divide input weight expr (Float32.ofInt n) p.eps rsqrt i)| ≤ Model.toReal p.outputCap :=
  ranges_wide p divide divError accuracy division rsqrt root expr coverage input weight
    (fun i => ⟨(hx i).1, (hx i).2.trans (by norm_num)⟩) hw

end Inference.Contracts.Mlx.NormalizationUniform
