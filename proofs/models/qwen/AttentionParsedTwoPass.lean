import models.qwen.AttentionTailMemory
import kernels.attention.MlxSdpaTwoPassOutputSource
import kernels.attention.MlxSdpaTwoPassMergeFrame
import kernels.attention.MlxSdpaTwoPassQueryGeometry

namespace Inference.Models.Qwen.AttentionParsedTwoPass
open Contracts.Mlx Kernels.Attention State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
  (attention : SdpaTwoPassDonation.Execution first contracted)
  {gatePlatform : OutputGate.Platform} {projection : Layers.AffineVerifyLinear.Projection 12 5120}
  (tail : AttentionTailMemory.Execution (SdpaShared.Execution.twoPass first attention) gate gatePlatform projection)

-- At long cache all suffixes select this route, without identifying the device.
theorem long_selection (length : 4096≤steps) : SdpaDispatched.twoPass arch steps :=
  SdpaDispatch.qwen_long steps length arch

-- Both dispatch phases complete before the gate sees their final heap.
-- Architecture suffix, environment override, and native descriptor attachment
-- remain explicit in the selected executions and contiguous query premise.
theorem source_to_gate
    (finite : ∀ head, SdpaTwoPassVector.Finite p contracted (SdpaDispatched.blockCount arch steps)
      (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ programs, MlxSdpaTwoPassOutputSource.sourcePrograms first
        (SdpaDispatchedDevice.complete_blocks arch steps) contracted attention.stores.base=some programs ∧
      ThreadgroupWrites.Executes programs attention.stores.schedule attention.stores.remaining ∧
      ThreadgroupWrites.AtBarrier attention.stores.remaining ∧
      HalfMemory.execute attention.stores.schedule first.first.memory=
        (AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
          tail.gates tail.gatesShared tail.gatesSafe).memory :=
  MlxSdpaTwoPassOutputSource.checked attention finite

theorem gate_heap :
    (AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
      tail.gates tail.gatesShared tail.gatesSafe).memory=
      HalfMemory.execute attention.stores.schedule
        (MemoryProjection.execute SdpaTwoPassMemory.write first.first.trace.schedule input.cache.memory) :=
  attention.memory

theorem native_query_capture (base : Nat)
    (contiguous : ∀ head, (input.query head).base=base+2*(head.val*256))
    (head : Fin 24) (block : Fin (SdpaDispatched.blockCount arch steps)) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaTwoPassQueryGeometry.registers input.cache.memory base _ head block lane item=
      ArrayStorage.bits (query head (SdpaScore.index lane item)) :=
  MlxSdpaTwoPassQueryGeometry.captured input base _ contiguous head block lane item

theorem temporary_reads (head : Fin 24) (block : Fin (SdpaDispatched.blockCount arch steps)) (i : Fin 256) :
    MlxSdpaTwoPassMergeFrame.readState
      (AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
        tail.gates tail.gatesShared tail.gatesSafe).memory
      first.first.trace.sumBase first.first.trace.maxBase first.first.trace.outputBase
      (SdpaDispatched.blockCount arch steps) head block i=first.first.readState head block i :=
  MlxSdpaTwoPassMergeFrame.completed_state attention head block i

theorem first_read_provenance (head : Fin 24) (block : Fin (SdpaDispatched.blockCount arch steps))
    (lane : Fin 32) (item : Fin 8) :
    ∃ finish, MlxSdpaTwoPassFirstSource.Executes p first.inputAfter head block lane item
      (List.finRange (SdpaTwoPassLayout.count steps (SdpaDispatched.blockCount arch steps) block))
      (MlxSdpaTwoPassStores.initial .zero) finish ∧
      (first.first.readState head block (SdpaScore.index lane item)).shift=finish.shift ∧
      (first.first.readState head block (SdpaScore.index lane item)).denominator=finish.denominator ∧
      (first.first.readState head block (SdpaScore.index lane item)).numerator=
        BFloat16.widen (BFloat16.narrow finish.numerator) :=
  MlxSdpaTwoPassStores.read_provenance first head block lane item

theorem gate_reads (head : Fin 24) (coordinate : Fin 256) :
    ((AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate=
      SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) coordinate := by
  rw [ArrayStorage.BFBuffer.read_correct]
  exact attention.output_eq head coordinate

theorem gate_read_error (head : Fin 24) (coordinate : Fin 256)
    (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (inputBound : SdpaVector.InputError (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (finite : SdpaDispatched.Finite p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (positive : 0<steps) :
    |Model.toReal (((AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate)-
      SdpaVector.target targetQuery targetKeys targetValues coordinate|≤
      SdpaDispatched.budget p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate := by
  rw [gate_reads first attention tail head coordinate]
  exact SdpaDispatched.forward_error p contracted arch _ _ _ targetQuery errorQuery targetKeys targetValues
    errorKeys errorValues inputBound finite positive coordinate

end Inference.Models.Qwen.AttentionParsedTwoPass
