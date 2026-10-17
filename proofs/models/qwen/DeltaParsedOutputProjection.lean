import models.qwen.DeltaParsedGatedNormalization
import layers.AffineParsedSource

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

-- The full-row custom wrapper supports either checkpoint bit width here.
-- Native wrapper installation/descriptor attachment remains explicit.
theorem source (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output)) :
    AffineParsedSource.Certificate (steps := 12) (blocks := 80) tail.affine before :=
  AffineParsedSource.checked (steps := 12) (blocks := 80) (p := projection)
    tail.affine before (by decide) (by decide) finite

theorem current_input : tail.affine.source=tail.normalization.outputBuffer := tail.linked

theorem current_heap : tail.affine.source.bytes=tail.normalization.stores.memory :=
  DeltaParsedGatedNormalization.affine_input_heap tail

theorem readback (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output)) (row : Fin 5120) :
    AffineParsedSource.value (steps := 12) (blocks := 80) tail.affine row=tail.buffer.read row :=
  AffineParsedSource.same_buffer (steps := 12) (blocks := 80) (p := projection)
    tail.affine before (source tail before finite) row

theorem readback_error (before : Nat → Float32)
    (finite : projection.Finite (GatedInputs.flatten tail.normalization.output))
    (target error : Fin 6144 → ℝ)
    (inputBound : ∀ i, |Model.toReal (GatedInputs.flatten tail.normalization.output i)-target i| ≤ error i)
    (row : Fin 5120) :
    |Model.toReal (tail.buffer.read row)-projection.target target row| ≤
      projection.budget (GatedInputs.flatten tail.normalization.output) target error row := by
  rw [←readback tail before finite row]
  exact AffineParsedSource.readback_error (steps := 12) (blocks := 80) (p := projection)
    tail.affine before (source tail before finite) target error inputBound finite row

theorem cache_heap : tail.afterState.bytes=tail.buffer.bytes := tail.state_output_shared

end Inference.Models.Qwen.DeltaParsedOutputProjection
