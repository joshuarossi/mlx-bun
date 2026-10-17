import kernels.quantization.AffinePacking
import kernels.trellis.CodebookAccuracy
import contracts.mlx.FlushToZero

namespace Inference.Kernels.Quantization.AffineLift
open Contracts.Mlx Contracts.Mlx.Numerics

-- MLXQ_F from affine-row.ts. The source only passes masked 1..4-bit
-- fields, shifted at most 12 places; this finite domain contains every case.
def value (q : Nat) : Float32 :=
  Float32.ofBits (UInt32.ofNat q ||| 0x4b000000) - 8388608

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem fields_checked : ∀ field : Fin 16, ∀ shift : Fin 13,
    Trellis.Codebook.FloatingPoint.representable (value (field.val * 2^shift.val)) = true ∧
    Trellis.Codebook.FloatingPoint.scaled (value (field.val * 2^shift.val)) =
      (field.val * 2^shift.val : ℤ) * 2^32 ∧
    (value (field.val * 2^shift.val)).isFinite = true ∧
    FlushToZero.flush (value (field.val * 2^shift.val)) = value (field.val * 2^shift.val) := by decide +kernel

theorem field_exact (field : Fin 16) (shift : Fin 13) :
    real (value (field.val * 2^shift.val)) = (field.val * 2^shift.val : ℝ) := by
  have h := fields_checked field shift
  rw [Trellis.CodebookAccuracy.scaled_real _ h.1, h.2.1]
  push_cast
  ring

theorem field_finite (field : Fin 16) (shift : Fin 13) :
    (value (field.val * 2^shift.val)).isFinite = true := (fields_checked field shift).2.2.1

theorem field_flush (field : Fin 16) (shift : Fin 13) :
    FlushToZero.flush (value (field.val * 2^shift.val)) = value (field.val * 2^shift.val) :=
  (fields_checked field shift).2.2.2

theorem mask_exact (n width shift : Nat) (hw : width ≤ 4) (hs : shift < 13) :
    real (value (n &&& ((2^width-1)*2^shift))) = (n &&& ((2^width-1)*2^shift) : Nat) := by
  rw [AffinePacking.shifted_mask]
  have hf : n / 2^shift % 2^width < 16 :=
    (Nat.mod_lt _ (by positivity)).trans_le (Nat.pow_le_pow_right (by decide) hw)
  simpa only [Nat.cast_mul, Nat.cast_pow, Nat.cast_ofNat] using
    field_exact ⟨n / 2^shift % 2^width, hf⟩ ⟨shift, hs⟩

theorem mask_finite (n width shift : Nat) (hw : width ≤ 4) (hs : shift < 13) :
    (value (n &&& ((2^width-1)*2^shift))).isFinite = true := by
  rw [AffinePacking.shifted_mask]
  have hf : n / 2^shift % 2^width < 16 :=
    (Nat.mod_lt _ (by positivity)).trans_le (Nat.pow_le_pow_right (by decide) hw)
  exact field_finite ⟨n / 2^shift % 2^width, hf⟩ ⟨shift, hs⟩

end Inference.Kernels.Quantization.AffineLift
