import contracts.mlx.BFloat16DyadicBounds
import contracts.mlx.ElementwiseAdd

namespace Inference.Models.Qwen.CheckpointTransforms
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open BFloat16Arithmetic

-- Value/layout translation of the selected checkpoint.ts fixups. Tensor
-- discovery, byte decoding, native allocation and dispatch are separate
-- obligations; these theorems do not certify the contents of a checkpoint.
def shiftNorm (stored : Fin n → Value) (i : Fin n) : Value :=
  add (stored i) one

private theorem flush_zero_real (x : Value) (hx : Model.toReal x = 0) :
    Model.toReal (flush x) = 0 := by
  have h := flush_abs_le x
  rw [hx, abs_zero] at h
  exact abs_eq_zero.mp (le_antisymm h (abs_nonneg _))

theorem zero_norm (stored : Fin n → Value)
    (finite : ∀ i, Model.isFinite (stored i) = true)
    (zero : ∀ i, Model.toReal (stored i) = 0) (i : Fin n) :
    Model.isFinite (shiftNorm stored i) = true ∧ Model.toReal (shiftNorm stored i) = 1 := by
  have hb : |Model.toReal (stored i)| + |Model.toReal one| ≤ Model.toReal one := by
    rw [zero i, real_one]
    norm_num
  have hf := BFloat16Bounds.add_range (stored i) one one (finite i) finite_one finite_one hb
  have hr : Model.toReal (Model.add (flush (stored i)) (flush one)) = 1 := by
    rw [Model.toReal_add_eq_roundAt _ _ (by decide) (finite_flush _ (finite i))
      (finite_flush _ finite_one) hf.1, flush_zero_real _ (zero i), flush_one, real_one, zero_add]
    have h := Model.roundAt_toReal_eq one finite_one
    rwa [real_one] at h
  refine ⟨finite_flush _ hf.1, ?_⟩
  unfold shiftNorm add
  rw [flush_eq_of_one_le _ (by rw [hr]), hr]

theorem zero_norm_bound (stored : Fin n → Value)
    (finite : ∀ i, Model.isFinite (stored i) = true)
    (zero : ∀ i, Model.toReal (stored i) = 0) :
    ∀ i, Model.isFinite (shiftNorm stored i) = true ∧ |Model.toReal (shiftNorm stored i)| ≤ 1 := by
  intro i
  have h := zero_norm stored finite zero i
  exact ⟨h.1, by rw [h.2]; norm_num⟩

def headCap : Value := BFloat16DyadicBounds.ceiling 1 2
theorem headCap_finite : Model.isFinite headCap = true :=
  (BFloat16DyadicBounds.ceiling_range 1 2 (by decide) (by decide) (by decide)).1
theorem headCap_real : Model.toReal headCap = 4 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 2 (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

theorem head_norm_bound (stored : Fin n → Value)
    (bound : ∀ i, Model.isFinite (stored i) = true ∧ |Model.toReal (stored i)| ≤ 3) :
    ∀ i, Model.isFinite (shiftNorm stored i) = true ∧ |Model.toReal (shiftNorm stored i)| ≤ 4 := by
  intro i
  have h := BFloat16Bounds.add_range (stored i) one headCap (bound i).1 finite_one headCap_finite
    (by rw [headCap_real, real_one, abs_one]; linarith [(bound i).2])
  exact ⟨finite_flush _ h.1, by simpa only [shiftNorm, headCap_real] using h.2⟩

theorem shift_norm_error (stored : Fin n → Value)
    (bound : ∀ i, Model.isFinite (stored i) = true ∧ |Model.toReal (stored i)| ≤ 3) (i : Fin n) :
    |Model.toReal (shiftNorm stored i) - (Model.toReal (stored i) + 1)| ≤ addBudget (stored i) one := by
  have h := BFloat16Bounds.add_range (stored i) one headCap (bound i).1 finite_one headCap_finite
    (by rw [headCap_real, real_one, abs_one]; linarith [(bound i).2])
  simpa only [shiftNorm, real_one] using add_error (stored i) one (bound i).1 finite_one h.1

-- The selected convolution has shape [C,1,K]. Moving axis 2 to axis 1
-- gives [C,K,1]; singleton axes make the contiguous element order identical.
def sourceOffset (width : Nat) (c : Fin channels) (singleton : Fin 1) (k : Fin width) : Nat :=
  (c.val * 1 + singleton.val) * width + k.val
def destinationOffset (width : Nat) (c : Fin channels) (k : Fin width) (singleton : Fin 1) : Nat :=
  (c.val * width + k.val) * 1 + singleton.val

theorem conv_offsets (c : Fin channels) (k : Fin width) (singleton : Fin 1) :
    destinationOffset width c k singleton = sourceOffset width c singleton k := by
  have hz : singleton.val = 0 := by omega
  simp only [destinationOffset, sourceOffset, hz, mul_one, add_zero]

theorem conv_offset_in_bounds (c : Fin channels) (k : Fin width) (singleton : Fin 1) :
    destinationOffset width c k singleton < channels * width := by
  have hz : singleton.val = 0 := by omega
  simp only [destinationOffset, hz, mul_one, add_zero]
  calc
    c.val * width + k.val < c.val * width + width := Nat.add_lt_add_left k.isLt _
    _ = (c.val + 1) * width := by ring
    _ ≤ channels * width := Nat.mul_le_mul_right _ c.isLt

def convMoveaxis (stored : Fin channels → Fin 1 → Fin width → α) :
    Fin channels → Fin width → Fin 1 → α := fun c k singleton => stored c singleton k

theorem conv_exact (stored : Fin channels → Fin 1 → Fin width → α)
    (c : Fin channels) (k : Fin width) (singleton : Fin 1) :
    convMoveaxis stored c k singleton = stored c singleton k := rfl

theorem conv_materialize_exact (stored : Nat → α)
    (c : Fin channels) (k : Fin width) (singleton : Fin 1) :
    stored (destinationOffset width c k singleton) = stored (sourceOffset width c singleton k) := by
  rw [conv_offsets]

theorem conv_bound (stored : Fin channels → Fin 1 → Fin width → Value) (cap : ℝ)
    (bound : ∀ c singleton k, Model.isFinite (stored c singleton k) = true ∧
      |Model.toReal (stored c singleton k)| ≤ cap) :
    ∀ c k singleton, Model.isFinite (convMoveaxis stored c k singleton) = true ∧
      |Model.toReal (convMoveaxis stored c k singleton)| ≤ cap := by
  intro c k singleton
  exact bound c singleton k

end Inference.Models.Qwen.CheckpointTransforms
