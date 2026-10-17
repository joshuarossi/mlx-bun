import models.qwen.AttentionGateCopyFrames
import models.qwen.AttentionParsedGateReshape

namespace Inference.Models.Qwen.AttentionGateCopyKvMemory
open Contracts.Mlx Kernels.Attention Layers
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

-- The selected caller order is Q projection, parsed gate reshape copy, then
-- K and V projections. Every phase carries its own actual current-heap trace.
structure Execution (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF) where
  q : AffineMemory.Execution (groups:=3072) p.q input
  gateCopy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)
  gateCopySource : gateCopy.source=q.forwardBuffer
  k : AffineMemory.Execution (groups:=256) p.k input
  keyInputMemory : k.source.bytes=gateCopy.trace.memory
  keyInputBase : k.source.base=q.source.base
  v : AffineMemory.Execution (groups:=256) p.v input
  valueInput : v.source=AffineMemoryFrames.sourceAfter k
  copyQuery : MemoryRegions.Disjoint gateCopy.base 12288 q.forwardBuffer.base 24576
  keyQuery : MemoryRegions.Disjoint k.base 2048 q.forwardBuffer.base 24576
  valueQuery : MemoryRegions.Disjoint v.base 2048 q.forwardBuffer.base 24576
  valueKey : MemoryRegions.Disjoint v.base 2048 k.forwardBuffer.base 2048
  keyGate : MemoryRegions.Disjoint k.base 2048 gateCopy.base 12288
  valueGate : MemoryRegions.Disjoint v.base 2048 gateCopy.base 12288

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}

def Execution.memory (execution : Execution p input) : ByteMemory.Bytes := execution.v.outputBuffer.bytes

theorem Execution.value_input_memory (execution : Execution p input) :
    execution.v.source.bytes=execution.k.outputBuffer.bytes := congrArg ArrayStorage.BFBuffer.bytes execution.valueInput

-- Preserve the actual interleaved Q tensor through the copy and both later
-- projection writes, instead of assuming the original projection heap stays.
def Execution.queryGateBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.q.forward input) :=
  ArrayFrame.bf execution.q.forwardBuffer execution.memory (by
    intro offset bound
    have copy := MlxAttentionGateCopyMemory.other_region execution.gateCopy execution.copyQuery offset bound
    have shared := congrArg ArrayStorage.BFBuffer.bytes execution.gateCopySource
    rw [shared] at copy
    have key := execution.k.other_region execution.keyQuery offset bound
    rw [execution.keyInputMemory] at key
    have value := execution.v.other_region execution.valueQuery offset bound
    rw [execution.value_input_memory] at value
    exact value.trans (key.trans copy))

def Execution.gateBuffer (execution : Execution p input) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).gate head) :=
  ArrayFrame.bf (AttentionParsedGateReshape.gateBuffer execution.gateCopy head) execution.memory (by
    intro offset bound
    have gateOffset : 2*(head.val*256)+offset<12288 := by have := head.isLt; omega
    have key := execution.k.other_region execution.keyGate (2*(head.val*256)+offset) gateOffset
    rw [execution.keyInputMemory] at key
    have value := execution.v.other_region execution.valueGate (2*(head.val*256)+offset) gateOffset
    rw [execution.value_input_memory] at value
    have combined := value.trans key
    simpa only [Execution.memory,AttentionParsedGateReshape.gateBuffer, Nat.add_assoc] using combined)

theorem Execution.gate_layout (execution : Execution p input) (head : Fin 24) :
    (execution.gateBuffer head).base=2*(execution.gateCopy.base/2+head.val*256) :=
  AttentionParsedGateReshape.gate_layout execution.gateCopy head

def Execution.keyBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.k.forward input) :=
  ArrayFrame.bf execution.k.forwardBuffer execution.memory (by
    intro offset bound
    exact (execution.v.other_region execution.valueKey offset bound).trans (congrFun execution.value_input_memory _))

def Execution.valueBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.v.forward input) := execution.v.forwardBuffer

theorem Execution.memory_eq (execution : Execution p input) :
    execution.memory=HalfMemory.execute execution.v.stores
      (HalfMemory.execute execution.k.stores
        (CopyExecution.execute execution.gateCopy.trace.schedule execution.q.forwardBuffer.bytes)) := by
  rw [Execution.memory,execution.v.memory,execution.value_input_memory,execution.k.memory,execution.keyInputMemory]
  unfold CopyExecution.Trace.memory
  have shared := congrArg ArrayStorage.BFBuffer.bytes execution.gateCopySource
  rw [execution.gateCopy.initial,shared]

end Inference.Models.Qwen.AttentionGateCopyKvMemory
