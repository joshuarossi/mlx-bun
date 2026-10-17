import kernels.quantization.AffineDot4Magnitude
import kernels.quantization.AffineSumMagnitude

namespace Inference.Kernels.Quantization.AffineTileMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

theorem tail_bound (contracted : Bool) (scale bias : BF) (dot sum : Float32) (mass : ℝ)
    (mn : 0 ≤ mass) (mb : mass ≤ 8192)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ 1/16)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ 1/2)
    (hd : |real dot| ≤ 36*mass+(2 : ℝ)^(-40 : Int))
    (hu : |real sum| ≤ 2*mass+(2 : ℝ)^(-99 : Int))
    (hf : Arithmetic.Finite (tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)) (tailExpr contracted)) :
    |real (combine contracted scale dot sum bias)| ≤ 4*mass+(2 : ℝ)^(-40 : Int) := by
  let input := tailBind (BFloat16.widen scale) dot sum (BFloat16.widen bias)
  let acc := Expr.mul (.input 2) (.input 3)
  have ha := (ArithmeticDependencies.madd_finite input contracted (.input 0) (.input 1) acc hf).2.2
  have biasReal : |real (BFloat16.widen bias)| ≤ 1/2 := by rw [BFloat16.widen_real _ hb.1]; exact hb.2
  have scaleReal : |real (BFloat16.widen scale)| ≤ 1/16 := by rw [BFloat16.widen_real _ hs.1]; exact hs.2
  have raw : (FlushToZero.flush sum*FlushToZero.flush (BFloat16.widen bias)).isFinite = true := ha.2.2
  have pe := NormalizedCastBounds.absolute_of_error _ _ _ (RelativeRounding.multiplication sum (BFloat16.widen bias) raw)
  rw [abs_mul] at pe
  have product := mul_le_mul hu biasReal (abs_nonneg _) (by positivity : (0 : ℝ) ≤ 2*mass+2^(-99 : Int))
  have small : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real sum|+|real (BFloat16.widen bias)|) ≤
      (2 : ℝ)^(-110 : Int) := by
    norm_num [FlushToZero.threshold] at hu ⊢
    linarith only [hu, biasReal, mb]
  have accBound : |real (evaluate input acc)| ≤ (9/8 : ℝ)*mass+(2 : ℝ)^(-90 : Int) := by
    change |real (FlushToZero.mul sum (BFloat16.widen bias))| ≤ _
    norm_num at pe product small ⊢
    linarith only [pe, product, small, mn]
  have operands : |real (evaluate input (.input 0))|+|real (evaluate input (.input 1))| ≤ (2 : ℝ)^62+2 := by
    change |real (BFloat16.widen scale)|+|real dot| ≤ _
    norm_num at hd ⊢
    linarith only [scaleReal, hd, mb]
  have scaled : |real (evaluate input (.input 0))| * |real (evaluate input (.input 1))| ≤
      (9/4 : ℝ)*mass+(2 : ℝ)^(-44 : Int) := by
    have h := mul_le_mul scaleReal hd (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1/16)
    change |real (BFloat16.widen scale)| * |real dot| ≤ _
    norm_num at h ⊢
    linarith only [h]
  have result := MaddMagnitude.madd_bound input contracted (.input 0) (.input 1) acc hf operands
    ((9/4 : ℝ)*mass+(2 : ℝ)^(-44 : Int)) ((9/8 : ℝ)*mass+(2 : ℝ)^(-90 : Int)) 0
    (by decide) (by positivity) scaled (by simpa using accBound)
  change |real (evaluate input (tailExpr contracted))| ≤ _ at result
  rw [tail_execution] at result
  norm_num at result ⊢
  linarith only [result, mn]

theorem value4_bound (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (hs : |Model.toReal scale| ≤ 1/16) (hb : |Model.toReal bias| ≤ 1/2)
    (hf : Finite4 p x w scale bias) :
    |real (value4 p x w scale bias)| ≤ 4*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-40 : Int) := by
  apply tail_bound p.tailContracted scale bias (dot4 p x w) (AffineInput.summed x AffineInput.groups4)
    (∑ i, |Model.toReal (x i)|)
    (Finset.sum_nonneg (fun _ _ => abs_nonneg _))
  · have h := Finset.sum_le_sum (s := Finset.univ) (fun i _ => (hx i).2)
    norm_num at h
    exact h
  · exact ⟨hf.scaleFinite, hs⟩
  · exact ⟨hf.biasFinite, hb⟩
  · have h := AffineDot4Magnitude.tile_dot p division x w hx hf.dot
    have hn : 0 ≤ ∑ i, |Model.toReal (x i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
    linarith only [h, hn]
  · exact AffineSumMagnitude.sum4 x hf.groups hf.sum
  · exact hf.tail

end Inference.Kernels.Quantization.AffineTileMagnitude
