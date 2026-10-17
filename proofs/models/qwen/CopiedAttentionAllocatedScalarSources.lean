import models.qwen.CopiedAttentionInitialReadAllocation
import models.qwen.CopiedAttentionGrowthPreparation
import models.qwen.InitialKvSourceMemory
import models.qwen.AttentionGateCopyGrowthInputs

namespace Inference.Models.Qwen.CopiedAttentionAllocatedScalarSources
open Contracts.Mlx Layers State Kernels.Attention Kernels.Copy
set_option maxRecDepth 10000

-- One produced buffer may witness both modeled reads. This establishes no
-- native scalar-object sharing or descriptor identity between separate calls.
private theorem bytes_one : KvRegions.bytes 1=524288 := by
  norm_num [KvRegions.bytes,KvAllocation.capacity]

namespace Initial
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer input angle}
  (request : CopiedAttentionInitialReadAllocation.Request front) (cache : Kv.Cache Kv.BF 0)
  (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=front.memory) (below : zero.base+2≤request.cursor)

def sources : InitialKvSourceMemory.Sources (CopiedAttentionInitialReadAllocation.read request cache).kv.zeros where
  keyScalar := zero
  valueScalar := zero
  keyShared := shared
  valueShared := shared
  keyAllocation := {
    sourceAligned := zero.aligned
    sourceBounded := by simpa using zero.bounded
    destinationAligned := (CopiedAttentionInitialReadAllocation.layout request).keyAligned
    destinationBounded := by
      change request.cursor+524288≤2^64
      have bound := (CopiedAttentionInitialReadAllocation.layout request).keyBound
      change request.cursor+KvRegions.bytes 1≤2^64 at bound
      rw [bytes_one] at bound
      exact bound
    fresh := Or.inr below }
  keyKeepsValue := Or.inr below
  valueFresh := Or.inr (below.trans (Nat.le_add_right _ _))

theorem key_base : (sources request cache zero shared below).keyScalar.base=zero.base := rfl

theorem key_heap : (sources request cache zero shared below).keyScalar.bytes=front.memory := shared
end Initial

namespace Growth
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache input angle}
  (request : CopiedAttentionGrowthPreparation.Request s)
  (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=s.oldAfter.memory) (below : zero.base+2≤request.cursor)

abbrev workspace := CopiedAttentionGrowthPreparation.workspace request

def scalars : AttentionGateCopyGrowthInputs.Scalars s.oldAfter ((workspace request).allocation request.growing) where
  key := zero
  value := zero
  keyShared := shared
  valueShared := shared
  keyAllocation := {
    sourceAligned := zero.aligned
    sourceBounded := by simpa using zero.bounded
    destinationAligned := by change (2*((workspace request).base/2))%2=0; omega
    destinationBounded := by
      change 2*((workspace request).base/2)+2*ScalarCopyQuadSemantics.count≤2^64
      rw [(workspace request).half_bases.1]
      have bound := (workspace request).bounded
      dsimp only [KvGrowthAllocation.bytes,ScalarCopyQuadSemantics.count] at *
      omega
    fresh := by
      change MemoryRegions.Disjoint (2*((workspace request).base/2)) (2*ScalarCopyQuadSemantics.count) zero.base 2
      rw [(workspace request).half_bases.1]
      exact Or.inr below }
  keyZeroKeepsValue := by
    change MemoryRegions.Disjoint (2*((workspace request).base/2)) 524288 zero.base 2
    rw [(workspace request).half_bases.1]
    exact Or.inr below
  keyCopyKeepsValue := by
    change MemoryRegions.Disjoint (2*(((workspace request).base+524288)/2)) _ zero.base 2
    rw [(workspace request).half_bases.2.1]
    exact Or.inr (below.trans (Nat.le_add_right _ _))
  valueFresh := by
    change MemoryRegions.Disjoint (2*(((workspace request).base+524288+KvGrowthAllocation.tensorBytes n)/2)) 524288 zero.base 2
    rw [(workspace request).half_bases.2.2.1]
    exact Or.inr (by change zero.base+2≤request.cursor+524288+KvGrowthAllocation.tensorBytes n; omega)
  valueZeroBound := by
    change 2*(((workspace request).base+524288+KvGrowthAllocation.tensorBytes n)/2)+524288≤2^64
    rw [(workspace request).half_bases.2.2.1]
    have bound := (workspace request).bounded
    dsimp only [KvGrowthAllocation.bytes] at bound
    omega

theorem key_base : (scalars request zero shared below).key.base=zero.base := rfl

theorem key_heap : (scalars request zero shared below).key.bytes=s.oldAfter.memory := shared
end Growth
end Inference.Models.Qwen.CopiedAttentionAllocatedScalarSources
