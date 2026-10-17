import kernels.quantization.AffineDot3SourceMagnitude
import kernels.quantization.AffineTileMagnitude

namespace Inference.Kernels.Quantization.AffineTile3Magnitude
open Contracts.Mlx Contracts.Mlx.Numerics AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

theorem value_bound (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (hs : |Model.toReal scale| ≤ 1/16) (hb : |Model.toReal bias| ≤ 1/2)
    (hf : Finite3 p x w scale bias) :
    |real (value3 p x w scale bias)| ≤ 4*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-40 : Int) := by
  apply AffineTileMagnitude.tail_bound p.tailContracted scale bias (dot3 p x w)
    (AffineInput.summed x AffineInput.groups3) (∑ i, |Model.toReal (x i)|)
    (Finset.sum_nonneg (fun _ _ => abs_nonneg _))
  · have h := Finset.sum_le_sum (s := Finset.univ) (fun i _ => (hx i).2)
    norm_num at h
    exact h
  · exact ⟨hf.scaleFinite, hs⟩
  · exact ⟨hf.biasFinite, hb⟩
  · exact AffineDot3SourceMagnitude.tile_dot p division x w hx hf.dot
  · exact AffineSumMagnitude.sum3 x hf.groups hf.sum
  · exact hf.tail

end Inference.Kernels.Quantization.AffineTile3Magnitude
