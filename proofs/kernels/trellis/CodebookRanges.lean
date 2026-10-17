import kernels.trellis.CodebookAccuracy

namespace Inference.Kernels.Trellis.CodebookRanges
open Contracts.Mlx.Numerics FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model.UnpackedFloat

theorem representable_finite (v : Float32)
    (h : Codebook.FloatingPoint.representable v = true) : v.isFinite = true := by
  unfold Codebook.FloatingPoint.representable at h
  change v.toModel.unpack.isFinite = true
  cases hv : v.toModel.unpack <;> simp_all [Float.Model.UnpackedFloat.isFinite]

-- A bound for every packed state, not a sample of checkpoint coefficients.
theorem ranges (s : BitVec 32) :
    (CodebookLoad.mathematicalCode s).isFinite = true ∧
      |real (CodebookLoad.mathematicalCode s)| ≤ 4 := by
  refine ⟨representable_finite _ (CodebookLoad.mathematicalCode_accuracy s).1, ?_⟩
  have hr := Codebook.range s
  rw [Codebook.correct] at hr
  have lo : (-510 : ℝ) ≤ (Codebook.specification s : ℝ) := by exact_mod_cast hr.1
  have hi : (Codebook.specification s : ℝ) ≤ (510 : ℝ) := by exact_mod_cast hr.2
  have ideal : |CodebookAccuracy.ideal s| ≤ (510 : ℝ)*4096/605391 := by
    apply abs_le.mpr
    unfold CodebookAccuracy.ideal
    constructor <;> linarith
  have error := CodebookAccuracy.relative_error s
  have triangle := abs_add_le (real (CodebookLoad.mathematicalCode s)-CodebookAccuracy.ideal s)
    (CodebookAccuracy.ideal s)
  rw [sub_add_cancel] at triangle
  norm_num at ideal error
  linarith

end Inference.Kernels.Trellis.CodebookRanges
