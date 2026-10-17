import models.qwen.AttentionGateCopyPreservation
import state.KvSources

namespace Inference.Models.Qwen.AttentionGateCopyFront
open Contracts.Mlx Kernels Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

structure Execution (layer : Attention.Layer) (input : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  phase : AttentionGateCopyKvMemory.Execution layer.projections input
  queryCopy : AttentionGateCopyQueryMemory.Execution phase
  parameters : AttentionParameterMemory.Storage layer queryCopy.copy.memory
  normal : AttentionGateCopyNormalizationMemory.Execution queryCopy parameters
  rope : AttentionGateCopyRopeMemory.Execution normal angle
  normalGateSafe : ∀ head, AttentionGateCopyNormalizationMemory.Safe normal (queryCopy.gate head).base 512
  gateSafe : ∀ head, AttentionGateCopyRopeMemory.Safe rope (normal.gate head (normalGateSafe head)).base 512
  copyValueSafe : MemoryRegions.Disjoint (2*queryCopy.destination) 12288 phase.valueBuffer.base 2048
  normalValueSafe : AttentionGateCopyNormalizationMemory.Safe normal phase.valueBuffer.base 2048
  valueSafe : AttentionGateCopyRopeMemory.Safe rope (normal.valueBuffer copyValueSafe normalValueSafe).base 2048

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}

def Execution.memory (execution : Execution layer input angle) : ByteMemory.Bytes := execution.rope.memory

def Execution.query (execution : Execution layer input angle) (head : Fin 24) : ArrayStorage.BFBuffer ((layer.heads input angle).query head) :=
  execution.rope.queryBuffer head

def Execution.gate (execution : Execution layer input angle) (head : Fin 24) : ArrayStorage.BFBuffer ((layer.heads input angle).gate head) :=
  execution.rope.gate head (execution.normalGateSafe head) (execution.gateSafe head)

def Execution.valueBuffer (execution : Execution layer input angle) : ArrayStorage.BFBuffer (layer.projections.v.forward input) :=
  execution.rope.valueBuffer execution.copyValueSafe execution.normalValueSafe execution.valueSafe

def Execution.keySource (execution : Execution layer input angle) : KvCopy.Source (layer.heads input angle).key where
  bytes := execution.memory
  base := execution.rope.key.destination
  rowStride := 256
  columnStride := 1
  aligned := execution.rope.key.output.aligned
  attached := by
    intro head i
    have read := execution.rope.key.output.attached head i
    change HalfMemory.load execution.memory (execution.rope.key.destination+512*head.val+2*i.val)=
      KvBytes.bits ((layer.heads input angle).key head i) at read
    rw [show execution.rope.key.destination+2*(i.val*1+head.val*256)=
      execution.rope.key.destination+512*head.val+2*i.val by omega]
    exact read

def Execution.valueSource (execution : Execution layer input angle) : KvCopy.Source (layer.heads input angle).value where
  bytes := execution.memory
  base := execution.valueBuffer.base
  rowStride := 256
  columnStride := 1
  aligned := execution.valueBuffer.aligned
  attached := by
    intro head i
    have read := execution.valueBuffer.attached (AttentionHeads.kvIndex head i)
    change HalfMemory.load execution.memory (execution.valueBuffer.base+2*(AttentionHeads.kvIndex head i).val)=
      ArrayStorage.bits (layer.projections.v.forward input (AttentionHeads.kvIndex head i)) at read
    simpa only [Attention.Layer.heads,AttentionHeads.Preparation.forward,AttentionHeads.Preparation.normalized,
      AttentionHeads.Projections.forward,AttentionHeads.kvIndex,ArrayStorage.bits,KvBytes.bits,Nat.mul_one,Nat.add_comm] using read

-- The copied gate and native RoPE outputs retain concrete contiguous head
-- geometry through all frames. Native descriptor extraction can bind to these
-- proved addresses instead of assuming head layouts independently.
theorem Execution.query_base (execution : Execution layer input angle) (head : Fin 24) :
    (execution.query head).base=execution.rope.query.destination+2*(head.val*256) := by
  change execution.rope.query.destination+512*head.val=_
  omega

theorem Execution.gate_base (execution : Execution layer input angle) (head : Fin 24) :
    (execution.gate head).base=execution.phase.gateCopy.base+2*(head.val*256) := rfl

theorem Execution.shared (execution : Execution layer input angle) :
    (∀ head, (execution.query head).bytes=execution.memory) ∧
      (∀ head, (execution.gate head).bytes=execution.memory) ∧
      execution.keySource.bytes=execution.memory ∧ execution.valueSource.bytes=execution.memory :=
  ⟨fun _ => rfl,fun _ => rfl,rfl,rfl⟩

abbrev Safe (execution : Execution layer input angle) (base size : Nat) :=
  AttentionGateCopyPreservation.Safe execution.rope base size

def Execution.cacheAfter {n : Nat} {cache : Kv.Cache Kv.BF n} (execution : Execution layer input angle)
    (storage : KvRegions.Storage cache) (shared : storage.memory=execution.phase.q.source.bytes)
    (keysSafe : Safe execution storage.layout.keyBase (KvRegions.bytes n))
    (valuesSafe : Safe execution storage.layout.valueBase (KvRegions.bytes n)) : KvRegions.Storage cache :=
  AttentionGateCopyPreservation.cacheAfter execution.rope storage shared keysSafe valuesSafe

end Inference.Models.Qwen.AttentionGateCopyFront
