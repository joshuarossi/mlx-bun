import models.qwen.DeltaParsedGatedNormalization
import layers.AffineRouteParsedSource

namespace Inference.Models.Qwen.DeltaParsedOutputProjection
open Contracts.Mlx Kernels Kernels.Delta Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weight : Fin 128 → ArrayStorage.BF}
  {input : DeltaTailMemory.Input recurrence gate weight}
  {p : GatedRmsNorm.Platform} {width eps : Float32}
  {projection : AffineVerifyLinear.Projection 12 5120}
  (tail : DeltaTailMemory.Execution input p width eps projection)

-- The executed route follows the stored width: three-bit uses the custom
-- complete-row wrapper, four-bit MLX qmv_fast. Descriptor attachment remains
-- explicit.
theorem source (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output)) :
    AffineRouteParsedSource.Certificate 80 640 tail.affine before rfl rfl :=
  AffineRouteParsedSource.checked tail.affine before (by decide) (by decide) (by decide) finite rfl rfl

theorem current_input : tail.affine.source=tail.normalization.outputBuffer := tail.linked

theorem current_heap : tail.affine.source.bytes=tail.normalization.stores.memory :=
  DeltaParsedGatedNormalization.affine_input_heap tail

theorem readback (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output)) (row : Fin 5120) :
    AffineRouteParsedSource.value tail.affine row=tail.buffer.read row :=
  AffineRouteParsedSource.same_buffer tail.affine before (source tail before finite) row

theorem readback_error (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output))
    (target error : Fin 6144 → ℝ)
    (inputBound : ∀ i, |Model.toReal (GatedInputs.flatten tail.normalization.output i)-target i| ≤ error i)
    (row : Fin 5120) :
    |Model.toReal (tail.buffer.read row)-projection.target target row| ≤
      projection.budget (GatedInputs.flatten tail.normalization.output) target error row := by
  rw [←readback tail before finite row]
  exact AffineRouteParsedSource.readback_error tail.affine before (source tail before finite) target error inputBound finite row

theorem cache_heap : tail.afterState.bytes=tail.buffer.bytes := tail.state_output_shared

end Inference.Models.Qwen.DeltaParsedOutputProjection
