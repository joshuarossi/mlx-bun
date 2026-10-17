import models.qwen.CheckpointRanges
import models.qwen.NormalizedAffineProjection
import models.qwen.DeltaOutputRanges

namespace Inference.Models.Qwen.CheckpointAffine
open Contracts.Mlx Kernels.Quantization Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Exact contiguous payloads for group-size-64 affine projections. Packed
-- weights need no numerical range assumption: all 3-/4-bit fields are valid.
-- Source buffer identity, tensor names, and host parsing remain separate.
def weightByte (bits : Nat) (kind : bits = 3 ∨ bits = 4)
    (bytes : Fin (rows*(steps*64*bits)) → BitVec 8) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (offset : Nat) (bound : offset < 2*bits) : BitVec 8 :=
  bytes ⟨AffineLayout.weightOffset bits row.val steps step.val lane.val offset,
    AffineLayout.weight_bound bits kind row step lane offset bound⟩

def projection3 (platform : AffineRow.Platform)
    (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) : Projection3 steps rows where
  platform := platform
  weights row := {
    bytes := fun step lane chunk byte => weightByte 3 (Or.inl rfl) weights row step lane
      (chunk.val*3+byte.val) (AffineLayout.three_bit_byte chunk byte)
    scale := CheckpointRanges.matrix scales row
    bias := CheckpointRanges.matrix biases row }

def projection4 (platform : AffineRow.Platform)
    (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8) : Projection4 steps rows where
  platform := platform
  weights row := {
    words := fun step lane chunk => TensorWords.littleEndian16
      (weightByte 4 (Or.inr rfl) weights row step lane (chunk.val*2) (by have := chunk.isLt; omega))
      (weightByte 4 (Or.inr rfl) weights row step lane (chunk.val*2+1) (by have := chunk.isLt; omega))
    scale := CheckpointRanges.matrix scales row
    bias := CheckpointRanges.matrix biases row }

theorem parameters3 (platform : AffineRow.Platform)
    (weights : Fin (rows*(steps*64*3)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8)
    (profile : Profile steps 36 shift) (scaleCap biasCap : BFloat16Arithmetic.Value)
    (scaleValue : Model.toReal scaleCap = (2 : ℝ)^profile.scaleExponent)
    (biasValue : Model.toReal biasCap = (2 : ℝ)^profile.biasExponent)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    Parameters3 (projection3 platform weights scales biases) profile := by
  constructor
  · intro row group
    simpa only [projection3, scaleValue] using CheckpointRanges.matrix_bound scales scaleCap sc row group
  · intro row group
    simpa only [projection3, biasValue] using CheckpointRanges.matrix_bound biases biasCap bc row group

theorem parameters4 (platform : AffineRow.Platform)
    (weights : Fin (rows*(steps*64*4)) → BitVec 8)
    (scales biases : Fin (2*(rows*(steps*8))) → BitVec 8)
    (profile : Profile steps 32 shift) (scaleCap biasCap : BFloat16Arithmetic.Value)
    (scaleValue : Model.toReal scaleCap = (2 : ℝ)^profile.scaleExponent)
    (biasValue : Model.toReal biasCap = (2 : ℝ)^profile.biasExponent)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    Parameters4 (projection4 platform weights scales biases) profile := by
  constructor
  · intro row group
    simpa only [projection4, scaleValue] using CheckpointRanges.matrix_bound scales scaleCap sc row group
  · intro row group
    simpa only [projection4, biasValue] using CheckpointRanges.matrix_bound biases biasCap bc row group

def scaleCap : BFloat16Arithmetic.Value := BFloat16DyadicBounds.ceiling 1 (-4)
def biasCap : BFloat16Arithmetic.Value := BFloat16DyadicBounds.ceiling 1 (-1)
theorem scaleCap_real : Model.toReal scaleCap = (2 : ℝ)^(-4 : Int) := by
  simpa only [scaleCap, Nat.cast_one, one_mul] using
    (BFloat16DyadicBounds.ceiling_range 1 (-4) (by decide) (by decide) (by decide)).2
theorem biasCap_real : Model.toReal biasCap = (2 : ℝ)^(-1 : Int) := by
  simpa only [biasCap, Nat.cast_one, one_mul] using
    (BFloat16DyadicBounds.ceiling_range 1 (-1) (by decide) (by decide) (by decide)).2

theorem normalized3 (platform : AffineRow.Platform)
    (weights : Fin (rows*(10*64*3)) → BitVec 8) (scales biases : Fin (2*(rows*(10*8))) → BitVec 8)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    NormalizedAffineProjection.Parameters (.bits3 (projection3 platform weights scales biases)) :=
  parameters3 platform weights scales biases NormalizedAffineProjection.profile3 scaleCap biasCap scaleCap_real biasCap_real sc bc

theorem normalized4 (platform : AffineRow.Platform)
    (weights : Fin (rows*(10*64*4)) → BitVec 8) (scales biases : Fin (2*(rows*(10*8))) → BitVec 8)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    NormalizedAffineProjection.Parameters (.bits4 (projection4 platform weights scales biases)) :=
  parameters4 platform weights scales biases NormalizedAffineProjection.profile4 scaleCap biasCap scaleCap_real biasCap_real sc bc

theorem output3 (platform : AffineRow.Platform)
    (weights : Fin (5120*(12*64*3)) → BitVec 8) (scales biases : Fin (2*(5120*(12*8))) → BitVec 8)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    DeltaOutputRanges.Parameters (.bits3 (projection3 platform weights scales biases)) :=
  parameters3 platform weights scales biases DeltaOutputRanges.profile3 scaleCap biasCap scaleCap_real biasCap_real sc bc

theorem output4 (platform : AffineRow.Platform)
    (weights : Fin (5120*(12*64*4)) → BitVec 8) (scales biases : Fin (2*(5120*(12*8))) → BitVec 8)
    (sc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 scales)) scaleCap = true)
    (bc : TensorWords.check (List.ofFn (TensorWords.readBFloat16 biases)) biasCap = true) :
    DeltaOutputRanges.Parameters (.bits4 (projection4 platform weights scales biases)) :=
  parameters4 platform weights scales biases DeltaOutputRanges.profile4 scaleCap biasCap scaleCap_real biasCap_real sc bc

end Inference.Models.Qwen.CheckpointAffine
