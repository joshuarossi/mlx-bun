import contracts.mlx.BFloat16Fma
import contracts.mlx.BFloat16
import kernels.quantization.AffineLift

namespace Inference.Kernels.Quantization.AffineDequantize
open Contracts.Mlx Contracts.Mlx.Numerics BFloat16Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := Value

-- Native uint8 -> bfloat conversion is exact for a four-bit field. The
-- integer cast and bfloat narrowing are checked in Lean over all 16 values.
def field (q : Fin 16) : BF := BFloat16.narrow (Float32.ofInt q.val)
set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem field_checked : ∀ q : Fin 16, Model.isFinite (field q) = true ∧
    BFloat16.widen (field q) = AffineLift.value (q.val*2^0) := by decide +kernel

theorem field_real (q : Fin 16) : Model.toReal (field q) = q.val := by
  have h := congrArg Numerics.real (field_checked q).2
  rw [BFloat16.widen_real _ (field_checked q).1] at h
  have hr := AffineLift.field_exact q (0 : Fin 13)
  simpa using h.trans hr

def code (w : BitVec 8) (i : Fin 2) : Fin 16 :=
  ⟨w.toNat / 2^(4*i.val) % 16, Nat.mod_lt _ (by decide)⟩
def extracted (w : BitVec 8) (i : Fin 2) : Nat :=
  (((w.setWidth 32) >>> (4*i.val)) &&& (15 : BitVec 32)).toNat

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem extracted_correct : ∀ w : BitVec 8, ∀ i : Fin 2, extracted w i = (code w i).val := by decide +kernel

-- affine_dequantize<bf16,64,4>: each byte emits two BF16 values. The
-- compiler profile selects separate operations or a fused BF16 multiply-add.
def value (contracted : Bool) (scale bias : BF) (q : Fin 16) : BF :=
  if contracted then BFloat16Fma.value scale (field q) bias else add (mul scale (field q)) bias
noncomputable def target (scale bias : BF) (q : Fin 16) : ℝ := Model.toReal scale*q.val+Model.toReal bias
noncomputable def budget (contracted : Bool) (scale bias : BF) (q : Fin 16) : ℝ :=
  if contracted then BFloat16Fma.budget scale (field q) bias
  else addBudget (mul scale (field q)) bias + mulBudget scale (field q)

structure Finite (contracted : Bool) (scale bias : BF) (q : Fin 16) : Prop where
  scaleFinite : Model.isFinite scale = true
  biasFinite : Model.isFinite bias = true
  arithmetic : if contracted then Model.isFinite (Model.fma (flush scale) (flush (field q)) (flush bias)) = true
    else Model.isFinite (Model.mul (flush scale) (flush (field q))) = true ∧
      Model.isFinite (Model.add (flush (mul scale (field q))) (flush bias)) = true

theorem value_finite (contracted : Bool) (scale bias : BF) (q : Fin 16) (hf : Finite contracted scale bias q) :
    Model.isFinite (value contracted scale bias q) = true := by
  cases contracted with
  | false => exact finite_flush _ hf.arithmetic.2
  | true => exact BFloat16Fma.finite _ _ _ hf.arithmetic

theorem value_error (contracted : Bool) (scale bias : BF) (q : Fin 16) (hf : Finite contracted scale bias q) :
    |Model.toReal (value contracted scale bias q) - target scale bias q| ≤ budget contracted scale bias q := by
  cases contracted with
  | true =>
    have h := BFloat16Fma.error scale (field q) bias hf.scaleFinite (field_checked q).1 hf.biasFinite hf.arithmetic
    simpa only [value, budget, ite_true, target, field_real] using h
  | false =>
    have hm := mul_error scale (field q) hf.scaleFinite (field_checked q).1 hf.arithmetic.1
    have ha := add_error (mul scale (field q)) bias (finite_flushExact _ _ hf.arithmetic.1) hf.biasFinite hf.arithmetic.2
    rw [field_real] at hm
    simp only [value, budget, Bool.false_eq_true, ite_false, target]
    calc
      _ = |(Model.toReal (add (mul scale (field q)) bias) - (Model.toReal (mul scale (field q))+Model.toReal bias)) +
        (Model.toReal (mul scale (field q))-Model.toReal scale*q.val)| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add ha hm)

-- The kernel computes the group from the first coordinate of its two-value
-- pack. Group size 64 ensures that both coordinates use the same parameters.
def byteIndex (i : Fin 5120) : Fin 2560 := ⟨i.val/2, by have := i.isLt; omega⟩
def byteCoordinate (i : Fin 5120) : Fin 2 := ⟨i.val%2, Nat.mod_lt _ (by decide)⟩
def groupIndex (i : Fin 5120) : Fin 80 := ⟨i.val/64, by have := i.isLt; omega⟩
theorem pack_coordinate (i : Fin 5120) : (byteIndex i).val*2+(byteCoordinate i).val = i.val := by
  dsimp [byteIndex, byteCoordinate]
  omega
theorem pack_group (i : Fin 5120) : ((byteIndex i).val*2)/64 = (groupIndex i).val := by
  dsimp [byteIndex, groupIndex]
  omega

def row (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF) (i : Fin 5120) : BF :=
  value contracted (scales (groupIndex i)) (biases (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))
noncomputable def rowTarget (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF) (i : Fin 5120) : ℝ :=
  target (scales (groupIndex i)) (biases (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))
noncomputable def rowBudget (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF) (i : Fin 5120) : ℝ :=
  budget contracted (scales (groupIndex i)) (biases (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))
def RowFinite (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF) : Prop :=
  ∀ i : Fin 5120, Finite contracted (scales (groupIndex i)) (biases (groupIndex i)) (code (bytes (byteIndex i)) (byteCoordinate i))

theorem row_error (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF)
    (hf : RowFinite contracted bytes scales biases) (i : Fin 5120) :
    |Model.toReal (row contracted bytes scales biases i) - rowTarget bytes scales biases i| ≤ rowBudget contracted bytes scales biases i :=
  value_error contracted _ _ _ (hf i)
theorem row_finite (contracted : Bool) (bytes : Fin 2560 → BitVec 8) (scales biases : Fin 80 → BF)
    (hf : RowFinite contracted bytes scales biases) (i : Fin 5120) : Model.isFinite (row contracted bytes scales biases i) = true :=
  value_finite contracted _ _ _ (hf i)

end Inference.Kernels.Quantization.AffineDequantize
