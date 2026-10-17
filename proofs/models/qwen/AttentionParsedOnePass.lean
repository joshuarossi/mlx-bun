import models.qwen.AttentionTailMemory
import kernels.attention.MlxSdpaOutputSource

namespace Inference.Models.Qwen.AttentionParsedOnePass
open Contracts.Mlx Kernels.Attention State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (attention : SdpaOnePassDonation.Execution input p arch)
  {gatePlatform : OutputGate.Platform} {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  (tail : AttentionTailMemory.Execution
    (SdpaShared.Execution.onePassDonated (contracted:=contracted) attention) gate gatePlatform projection)

-- This theorem deliberately names the donated one-pass constructor. The
-- fresh-output and two-pass constructors have separate source obligations.
theorem source_to_gate
    (finite : ∀ head, SdpaVector.Finite p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ programs, MlxSdpaOutputSource.source attention.stores.base attention.kernels=some programs ∧
      ThreadgroupWrites.Executes programs attention.stores.schedule attention.stores.remaining ∧
      ThreadgroupWrites.AtBarrier attention.stores.remaining ∧
      HalfMemory.execute attention.stores.schedule input.cache.memory=
        (AttentionTailMemory.gateInput
          (SdpaShared.Execution.onePassDonated (contracted:=contracted) attention)
          tail.gates tail.gatesShared tail.gatesSafe).memory ∧
      attention.queries.after.memory=
        (AttentionTailMemory.gateInput
          (SdpaShared.Execution.onePassDonated (contracted:=contracted) attention)
          tail.gates tail.gatesShared tail.gatesSafe).memory :=
  MlxSdpaOutputSource.checked attention finite

theorem gate_reads (head : Fin 24) (coordinate : Fin 256) :
    ((AttentionTailMemory.gateInput
      (SdpaShared.Execution.onePassDonated (contracted:=contracted) attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate=
      SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) coordinate := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact attention.output_eq contracted head coordinate

-- The same bytes consumed by the gate carry the existing real softmax
-- reference bound. No expected attention tensor is a premise.
theorem gate_read_error (head : Fin 24) (coordinate : Fin 256)
    (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (inputBound : SdpaVector.InputError (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (finite : SdpaDispatched.Finite p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (positive : 0<steps) :
    |Model.toReal (((AttentionTailMemory.gateInput
      (SdpaShared.Execution.onePassDonated (contracted:=contracted) attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate)-
      SdpaVector.target targetQuery targetKeys targetValues coordinate|≤
      SdpaDispatched.budget p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate := by
  rw [gate_reads attention tail head coordinate]
  exact SdpaDispatched.forward_error p contracted arch _ _ _ targetQuery errorQuery targetKeys targetValues
    errorKeys errorValues inputBound finite positive coordinate

end Inference.Models.Qwen.AttentionParsedOnePass
