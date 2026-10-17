import kernels.attention.SdpaTwoPassRanges
import contracts.mlx.SdpaTwoPassDispatch

namespace Inference.Kernels.Attention.SdpaDispatched
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Reflect the existing native dispatch, with MLX_SDPA_BLOCKS unset/zero.
-- This introduces no runtime validation into the inference implementation.
def twoPass (arch : Char) (steps : Nat) : Prop := SdpaDispatch.route (SdpaDispatch.qwen steps) arch = .twoPass
instance (arch : Char) (steps : Nat) : Decidable (twoPass arch steps) := inferInstanceAs (Decidable (_ = _))
def blockCount (arch : Char) (steps : Nat) : Nat := SdpaTwoPassDispatch.blocks arch (SdpaDispatch.qwen steps) 0

theorem route (arch : Char) (steps : Nat) (positive : 0 < steps) :
    SdpaDispatch.route (SdpaDispatch.qwen steps) arch =
      if twoPass arch steps then .twoPass else .onePass := by
  have valid : SdpaDispatch.route (SdpaDispatch.qwen steps) arch = .onePass ∨
      SdpaDispatch.route (SdpaDispatch.qwen steps) arch = .twoPass := by
    unfold SdpaDispatch.route
    rw [SdpaDispatch.qwen_fused steps positive]
    simp only [SdpaDispatch.qwen, show ¬(1 : Nat) > 8 from by decide, ↓reduceIte]
    by_cases branch : (arch = 'd' ∨ arch = 's') ∧ steps ≥ 1024 ∨ 4 < 24 ∧ steps ≥ 4096
    · simp only [branch, ↓reduceIte, or_true]
    · simp only [branch, ↓reduceIte, true_or]
  by_cases selected : twoPass arch steps
  · rw [ite_eq_left selected]
    exact selected
  · rw [ite_eq_right selected]
    exact valid.resolve_right selected

theorem long (arch : Char) (steps : Nat) (positive : 0 < steps) (selected : twoPass arch steps) : 1024 ≤ steps := by
  by_contra short
  have h := SdpaDispatch.qwen_short steps positive (by omega) arch
  unfold twoPass at selected
  rw [h] at selected
  cases selected

theorem block_contract (arch : Char) (steps : Nat) (positive : 0 < steps) (selected : twoPass arch steps) :
    32 ≤ blockCount arch steps ∧ blockCount arch steps ≤ 1024 ∧
      blockCount arch steps ≤ steps ∧ blockCount arch steps%32 = 0 := by
  have h := SdpaTwoPassDispatch.qwen_bounds arch steps
  have length := long arch steps positive selected
  unfold blockCount
  omega

def forward (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) : Fin 256 → BF :=
  if twoPass arch steps then SdpaTwoPassVector.forward p contracted (blockCount arch steps) query keys values
  else SdpaVector.forward p query keys values
noncomputable def budget (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ) : Fin 256 → ℝ :=
  if twoPass arch steps then SdpaTwoPassVector.budget p contracted (blockCount arch steps) query keys values
    targetQuery errorQuery targetKeys targetValues errorKeys errorValues
  else SdpaVector.budget p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues
def Finite (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) : Prop :=
  if twoPass arch steps then SdpaTwoPassVector.Finite p contracted (blockCount arch steps) query keys values
  else SdpaVector.Finite p query keys values

theorem forward_error (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : Finite p contracted arch query keys values) (positive : 0 < steps) (i : Fin 256) :
    |Model.toReal (forward p contracted arch query keys values i)-SdpaVector.target targetQuery targetKeys targetValues i| ≤
      budget p contracted arch query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues i := by
  unfold forward budget Finite at *
  split at hf
  · rename_i selected
    simp only [selected, ↓reduceIte]
    exact SdpaTwoPassVector.forward_error p contracted _ query keys values targetQuery errorQuery targetKeys targetValues
      errorKeys errorValues he hf positive (by have := block_contract arch steps positive selected; omega) i
  · rename_i selected
    simp only [selected, ↓reduceIte]
    exact SdpaVector.forward_error p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues he hf positive i

theorem forward_finite (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (hf : Finite p contracted arch query keys values) (i : Fin 256) :
    Model.isFinite (forward p contracted arch query keys values i) = true := by
  unfold Finite at hf
  unfold forward
  split at hf
  · rename_i selected
    simp only [selected, ↓reduceIte]
    exact SdpaTwoPassVector.forward_finite p contracted _ query keys values hf i
  · rename_i selected
    simp only [selected, ↓reduceIte]
    exact SdpaVector.forward_finite p query keys values hf i

theorem ranges (p : SdpaVector.Platform) (primitive : SdpaSequenceRanges.Primitives p)
    (contracted : Bool) (arch : Char) (steps : Nat) (positive : 0 < steps) (supported : steps ≤ 262144)
    (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Finite p contracted arch query keys values ∧ ∀ i,
      |Model.toReal (forward p contracted arch query keys values i)| ≤ (2 : ℝ)^(27 : Nat) := by
  unfold Finite forward
  by_cases selected : twoPass arch steps
  · simp only [selected, ↓reduceIte]
    have blocks := block_contract arch steps positive selected
    exact SdpaTwoPassRanges.ranges p primitive contracted (blockCount arch steps) blocks.1 blocks.2.1 blocks.2.2.1
      supported query keys values hq hk hv
  · simp only [selected, ↓reduceIte]
    have h := SdpaSequenceRanges.ranges p primitive steps positive supported query keys values hq hk hv
    exact ⟨h.1, fun i => (h.2 i).trans (by norm_num)⟩

theorem single (arch : Char) : ¬twoPass arch 1 := by
  unfold twoPass
  rw [SdpaDispatch.qwen_short 1 (by decide) (by decide) arch]
  decide

theorem forward_single (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin 1 → Fin 256 → BF) :
    forward p contracted arch query keys values = SdpaVector.forward p query keys values := by
  simp only [forward, single, ↓reduceIte]

theorem finite_single (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 256 → BF)
    (keys values : Fin 1 → Fin 256 → BF) (hf : SdpaVector.Finite p query keys values) :
    Finite p contracted arch query keys values := by
  simpa only [Finite, single, ↓reduceIte] using hf

end Inference.Kernels.Attention.SdpaDispatched
