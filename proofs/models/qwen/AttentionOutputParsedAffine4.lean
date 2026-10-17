import models.qwen.AttentionOutputMemory
import layers.AffineParsedSource4

namespace Inference.Models.Qwen.AttentionOutputParsedAffine4
open Contracts.Mlx Kernels.Attention Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate}
  {p : OutputGate.Platform} {gating : OutputGateMemory.Execution input p}
  {projection : AffineVerifyLinear.Projection4 12 5120}
  (execution : AttentionOutputMemory.Execution gating (.bits4 projection))

-- The 6144→5120 projection consumes the actual completed parsed gate heap.
-- Its carried parameter attachment and finite domain discharge the selected
-- parsed 4-bit matvec's tile obligations; no decoded-weight oracle is added.
theorem source (before : Nat → Float32)
    (finite : projection.Finite (OutputGateMemory.values p x gate)) :
    AffineParsedSource4.Certificate (steps:=12) (blocks:=80) execution.affine before :=
  AffineParsedSource4.checked (steps:=12) (blocks:=80) execution.affine before (by decide) (by decide) finite

theorem current_input : execution.affine.source=gating.buffer := execution.linked

theorem current_input_heap : execution.affine.source.bytes=gating.trace.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.linked

theorem readback (finite : projection.Finite (OutputGateMemory.values p x gate)) (row : Fin 5120) :
    AffineParsedSource4.value (steps:=12) (blocks:=80) execution.affine row=
      projection.forward (OutputGateMemory.values p x gate) row :=
  (source execution (fun _ => 0) finite).readback row

theorem readback_error (before : Nat → Float32)
    (finite : projection.Finite (OutputGateMemory.values p x gate))
    (target error : Fin 6144 → ℝ)
    (inputBound : ∀ i, |Model.toReal (OutputGateMemory.values p x gate i)-target i|≤error i)
    (row : Fin 5120) :
    |Model.toReal (AffineParsedSource4.value (steps:=12) (blocks:=80) execution.affine row)-
      projection.target target row|≤projection.budget (OutputGateMemory.values p x gate) target error row :=
  AffineParsedSource4.readback_error (steps:=12) (blocks:=80) execution.affine before
    (source execution before finite) target error inputBound finite row

end Inference.Models.Qwen.AttentionOutputParsedAffine4
