import models.qwen.AttentionTailMemory
import kernels.attention.MlxOutputGateScheduled

namespace Inference.Models.Qwen.AttentionParsedScheduledGate
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)

-- The native descriptor must attach a contiguous 6144-cell BF16 gate vector,
-- select unary v and binary vv, and bind the admitted scheduling contracts.
-- Attention output contiguity itself is derived from the completed SDPA stores.
theorem source_to_projection (gateBase : Nat)
    (gateLayout : ∀ head, (tail.gates head).base=2*(gateBase+head.val*256)) :
    ∃ intermediate gatedHeap,
      MlxOutputGateScheduled.unaryRun gatePlatform gateBase tail.gating.activation.base
        tail.gating.activation.trace.schedule attention.memory=some intermediate ∧
      MlxOutputGateScheduled.binaryRun (attention.base/2) tail.gating.activation.base tail.gating.base
        tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  have layout : ∀ head,
      ((AttentionTailMemory.gateInput attention tail.gates tail.gatesShared tail.gatesSafe).storage.source head).base=
        2*(attention.base/2+head.val*256) := AttentionTailMemory.gateInput_layout attention tail.gates tail.gatesShared tail.gatesSafe
  have gates : ∀ head,
      ((AttentionTailMemory.gateInput attention tail.gates tail.gatesShared tail.gatesSafe).storage.gate head).base=
        2*(gateBase+head.val*256) := gateLayout
  obtain ⟨middle,unary,binary⟩ := MlxOutputGateScheduled.checked tail.gating gateBase (attention.base/2) gates layout
  exact ⟨middle,tail.gating.buffer.bytes,unary,binary,tail.projected.memory⟩

end Inference.Models.Qwen.AttentionParsedScheduledGate
