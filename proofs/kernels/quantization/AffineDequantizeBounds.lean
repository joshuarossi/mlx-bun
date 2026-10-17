import kernels.quantization.AffineDequantize
import contracts.mlx.BFloat16Bounds

namespace Inference.Kernels.Quantization.AffineDequantizeBounds
open Contracts.Mlx Contracts.Mlx.BFloat16Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineDequantize

-- These bounds are on loaded parameters, independent of the quantized field
-- and of an observed execution. A pair of representable ceilings suffices for
-- both compiler contraction choices and every possible four-bit code.
structure Bounds (scale bias : BF) where
  scaleFinite : Model.isFinite scale = true
  biasFinite : Model.isFinite bias = true
  productCeiling : BF
  outputCeiling : BF
  productCeilingFinite : Model.isFinite productCeiling = true
  outputCeilingFinite : Model.isFinite outputCeiling = true
  scaleBound : 15 * |Model.toReal scale| ≤ Model.toReal productCeiling
  capacity : Model.toReal productCeiling + |Model.toReal bias| ≤ Model.toReal outputCeiling

theorem code_bound (q : Fin 16) : |Model.toReal (field q)| ≤ 15 := by
  rw [field_real, abs_of_nonneg (Nat.cast_nonneg _)]
  exact_mod_cast (show q.val ≤ 15 by have := q.isLt; omega)

theorem product_bound (scale bias : BF) (b : Bounds scale bias) (q : Fin 16) :
    |Model.toReal scale| * |Model.toReal (field q)| ≤ Model.toReal b.productCeiling := by
  have h := mul_le_mul_of_nonneg_left (code_bound q) (abs_nonneg (Model.toReal scale))
  linarith [b.scaleBound]

theorem range (contracted : Bool) (scale bias : BF) (b : Bounds scale bias) (q : Fin 16) :
    Finite contracted scale bias q ∧ |Model.toReal (value contracted scale bias q)| ≤ Model.toReal b.outputCeiling := by
  have hp := product_bound scale bias b q
  cases contracted with
  | false =>
    have hm := BFloat16Bounds.mul_range scale (field q) b.productCeiling b.scaleFinite (field_checked q).1 b.productCeilingFinite hp
    have ha := BFloat16Bounds.add_range (mul scale (field q)) bias b.outputCeiling (finite_flushExact _ _ hm.1) b.biasFinite b.outputCeilingFinite
      ((add_le_add hm.2 (le_refl _)).trans b.capacity)
    exact ⟨⟨b.scaleFinite, b.biasFinite, hm.1, ha.1⟩, ha.2⟩
  | true =>
    have hf := BFloat16Bounds.fma_range scale (field q) bias b.outputCeiling b.scaleFinite (field_checked q).1 b.biasFinite b.outputCeilingFinite
      ((add_le_add hp (le_refl _)).trans b.capacity)
    exact ⟨⟨b.scaleFinite, b.biasFinite, hf.1⟩, hf.2⟩

theorem row_finite (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF)
    (bounds : ∀ g, Bounds (scales g) (biases g)) : RowFinite contracted bytes scales biases :=
  fun i => (range contracted _ _ (bounds (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))).1

theorem row_bounded (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF)
    (bounds : ∀ g, Bounds (scales g) (biases g)) (i : Fin 5120) :
    |Model.toReal (row contracted bytes scales biases i)| ≤ Model.toReal (bounds (groupIndex i)).outputCeiling :=
  (range contracted _ _ (bounds (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))).2

end Inference.Kernels.Quantization.AffineDequantizeBounds
