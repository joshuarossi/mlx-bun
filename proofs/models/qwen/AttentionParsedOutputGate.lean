import models.qwen.AttentionTailMemory
import kernels.attention.MlxOutputGateMemory

namespace Inference.Models.Qwen.AttentionParsedOutputGate
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)

-- Parsed BF16 scalar operations are inserted into the existing current-heap
-- schedules. Native contiguous/strided loop dispatch is a separate obligation.
theorem source_to_projection :
    ∃ unary binary,
      MlxOutputGateMemory.parsedSigmoidKernel
        (AttentionTailMemory.gateInput attention tail.gates tail.gatesShared tail.gatesSafe)
        gatePlatform tail.gating.activation.base=some unary ∧
      MlxOutputGateMemory.parsedMultiplyKernel tail.gating.activation tail.gating.base=some binary ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores
        (ElementwiseMemory.execute binary tail.gating.trace.schedule
          (ElementwiseMemory.execute unary tail.gating.activation.trace.schedule attention.memory)) := by
  obtain ⟨unary,binary,parsedUnary,parsedBinary,heap⟩ := MlxOutputGateMemory.checked tail.gating
  refine ⟨unary,binary,parsedUnary,parsedBinary,?_⟩
  change tail.projected.buffer.bytes=_
  rw [tail.projected.memory]
  change HalfMemory.execute tail.projected.affine.stores tail.gating.buffer.bytes=_
  rw [heap]
  rfl

end Inference.Models.Qwen.AttentionParsedOutputGate
