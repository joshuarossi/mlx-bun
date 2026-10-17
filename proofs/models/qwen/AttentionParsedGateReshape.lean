import models.qwen.AttentionAffineMemory
import kernels.attention.MlxAttentionGateReshapeHost

namespace Inference.Models.Qwen.AttentionParsedGateReshape
open Contracts.Mlx Kernels.Attention
set_option maxRecDepth 10000
variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}

-- This dispatch can be instantiated at any current heap carrying the actual
-- Q projection. Its position among the K/V writes is a caller scheduling join.
theorem gate_value (_copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input))
    (head : Fin 24) (i : Fin 256) :
    MlxAttentionGateCopyMemory.values (p.q.forward input)
      ⟨head.val*256+i.val,by have := head.isLt; have := i.isLt; omega⟩=(p.forward input).gate head i := by
  change p.q.forward input (MlxAttentionGateCopyMemory.index _) = p.q.forward input (AttentionHeads.gateIndex head i)
  apply congrArg (p.q.forward input)
  apply Fin.ext
  dsimp [MlxAttentionGateCopyMemory.index,AttentionHeads.gateIndex]
  have := head.isLt
  have := i.isLt
  omega

def gateBuffer (copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).gate head) where
  bytes := copy.trace.memory
  base := copy.base+2*(head.val*256)
  aligned := by have := copy.aligned; omega
  bounded := by have := copy.bounded; have := head.isLt; omega
  attached := by
    intro i
    have read := (MlxAttentionGateCopyMemory.headBuffer copy head).attached i
    rw [gate_value copy head i] at read
    exact read

theorem gate_layout (copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)) (head : Fin 24) :
    (gateBuffer copy head).base=2*(copy.base/2+head.val*256) := by
  have := copy.aligned
  dsimp [gateBuffer]
  omega

theorem gate_current (copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)) (head : Fin 24) (i : Fin 256) :
    HalfMemory.load copy.trace.memory ((gateBuffer copy head).base+2*i.val)=ArrayStorage.bits ((p.forward input).gate head i) :=
  (gateBuffer copy head).attached i

theorem source_to_contiguous (copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)) :
    ∃ programs, MlxAttentionGateCopyMemory.sourcePrograms (copy.source.base+512) copy.base=some programs ∧
      ThreadgroupWrites.Executes programs copy.trace.schedule copy.trace.remaining ∧
      ThreadgroupWrites.AtBarrier copy.trace.remaining ∧
      CopyExecution.execute copy.trace.schedule copy.source.bytes=copy.trace.memory :=
  MlxAttentionGateCopyMemory.checked copy

end Inference.Models.Qwen.AttentionParsedGateReshape
