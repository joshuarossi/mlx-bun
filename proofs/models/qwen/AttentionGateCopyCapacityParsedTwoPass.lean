import models.qwen.AttentionGateCopyFreshGeometry
import models.qwen.AttentionParsedTwoPass
import models.qwen.AttentionParsedScheduledGate

namespace Inference.Models.Qwen.AttentionGateCopyCapacityParsedTwoPass
open Contracts.Mlx Kernels.Attention State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {preparation : AttentionGateCopyFreshRead.Prepared s}
  (read : AttentionGateCopyFreshRead.Read preparation)
  (first : SdpaTwoPassShared.Execution read.input layer.attention (SdpaDispatched.blockCount layer.architectureSuffix (n+1)))
  (attention : SdpaTwoPassDonation.Execution first layer.mergeContracted)
  (tail : AttentionTailMemory.Execution (SdpaShared.Execution.twoPass first attention)
    (layer.heads values angle).gate layer.gate layer.output)

-- This native query read is from the protected CURRENT first-dispatch heap,
-- with geometry derived from actual Q/normalization/RoPE/cache operations.
theorem current_query (head : Fin 24)
    (block : Fin (SdpaDispatched.blockCount layer.architectureSuffix (n+1))) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaTwoPassQueryGeometry.registers first.inputAfter.cache.memory s.front.rope.query.destination _ head block lane item=
      ArrayStorage.bits ((layer.heads values angle).query head (SdpaScore.index lane item)) :=
  read.two_pass_current_capture first head block lane item

-- Architecture suffix and default block-override attachment stay explicit in
-- the selected two-pass execution. There is no expected score, partial, SDPA
-- output, sigmoid output, gated vector, or projection output premise.
theorem source_to_projection
    (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaTwoPassVector.Finite layer.attention layer.mergeContracted
      (SdpaDispatched.blockCount layer.architectureSuffix (n+1))
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    ∃ sdpaPrograms intermediate gatedHeap,
      MlxSdpaTwoPassOutputSource.sourcePrograms first
        (SdpaDispatchedDevice.complete_blocks layer.architectureSuffix (n+1)) layer.mergeContracted attention.stores.base=some sdpaPrograms ∧
      ThreadgroupWrites.Executes sdpaPrograms attention.stores.schedule attention.stores.remaining ∧
      ThreadgroupWrites.AtBarrier attention.stores.remaining ∧
      MlxOutputGateScheduled.unaryRun layer.gate (s.front.phase.gateCopy.base/2) tail.gating.activation.base
        tail.gating.activation.trace.schedule
        (HalfMemory.execute attention.stores.schedule first.first.memory)=some intermediate ∧
      MlxOutputGateScheduled.binaryRun ((SdpaShared.Execution.twoPass first attention).base/2)
        tail.gating.activation.base tail.gating.base tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  have gateLayout : ∀ head, (tail.gates head).base=2*(s.front.phase.gateCopy.base/2+head.val*256) := by
    intro head
    rw [gateLink]
    exact read.gate_layout head
  obtain ⟨programs,parsed,scheduled,completed,heap⟩ := AttentionParsedTwoPass.source_to_gate first attention tail finite
  obtain ⟨middle,gatedHeap,unary,binary,projected⟩ :=
    AttentionParsedScheduledGate.source_to_projection tail (s.front.phase.gateCopy.base/2) gateLayout
  refine ⟨programs,middle,gatedHeap,parsed,scheduled,completed,?_,binary,projected⟩
  rw [heap]
  exact unary

-- The same current bytes arriving at the gate retain the established real
-- softmax error bound, through the source-derived final memory writes.
theorem gate_reads (head : Fin 24) (coordinate : Fin 256) :
    ((AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate=
      SdpaDispatched.forward layer.attention layer.mergeContracted layer.architectureSuffix
        ((layer.heads values angle).query head)
        ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
        ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head)) coordinate :=
  AttentionParsedTwoPass.gate_reads first attention tail head coordinate

theorem gate_read_error (head : Fin 24) (coordinate : Fin 256)
    (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin (n+1) → Fin 256 → ℝ)
    (inputBound : SdpaVector.InputError ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (finite : SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    |Model.toReal (((AttentionTailMemory.gateInput (SdpaShared.Execution.twoPass first attention)
      tail.gates tail.gatesShared tail.gatesSafe).storage.source head).read coordinate)-
      SdpaVector.target targetQuery targetKeys targetValues coordinate|≤
      SdpaDispatched.budget layer.attention layer.mergeContracted layer.architectureSuffix
        ((layer.heads values angle).query head)
        ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
        ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate :=
  AttentionParsedTwoPass.gate_read_error first attention tail head coordinate targetQuery errorQuery
    targetKeys targetValues errorKeys errorValues inputBound finite (by omega)

end Inference.Models.Qwen.AttentionGateCopyCapacityParsedTwoPass
