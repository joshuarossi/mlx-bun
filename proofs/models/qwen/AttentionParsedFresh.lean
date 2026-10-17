import models.qwen.AttentionTailMemory
import kernels.attention.MlxSdpaFreshOutputSource

namespace Inference.Models.Qwen.AttentionParsedFresh
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (attention : SdpaOutputMemory.Execution input p contracted arch)
  (selected : ¬SdpaDispatched.twoPass arch steps)
  {gatePlatform : OutputGate.Platform} {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  (tail : AttentionTailMemory.Execution (SdpaShared.Execution.onePassFresh attention selected) gate gatePlatform projection)

-- The fresh-output constructor's actual parsed stores supply the same heap
-- from which the layer gate subsequently reads.
theorem source_to_gate
    (finite : ∀ head, SdpaVector.Finite p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ programs, MlxSdpaFreshOutputSource.source attention selected=some programs ∧
      ThreadgroupWrites.Executes programs attention.kernel.output.schedule attention.kernel.output.remaining ∧
      ThreadgroupWrites.AtBarrier attention.kernel.output.remaining ∧
      HalfMemory.execute attention.kernel.output.schedule input.cache.memory=
        (AttentionTailMemory.gateInput (SdpaShared.Execution.onePassFresh attention selected)
          tail.gates tail.gatesShared tail.gatesSafe).memory :=
  MlxSdpaFreshOutputSource.checked attention selected finite

theorem gate_reads (head : Fin 24) (coordinate : Fin 256) :
    ((AttentionTailMemory.gateInput (SdpaShared.Execution.onePassFresh attention selected)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate=
      SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) coordinate := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact attention.output_eq head coordinate

end Inference.Models.Qwen.AttentionParsedFresh
