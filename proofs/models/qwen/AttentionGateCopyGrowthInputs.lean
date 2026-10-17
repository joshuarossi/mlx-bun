import kernels.copy.MlxKvGrowthPairSource
import models.qwen.AttentionGateCopyReadConstruction

namespace Inference.Models.Qwen.AttentionGateCopyGrowthInputs
open Contracts.Mlx State Kernels.Copy Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels CopyContiguous.programs Copy2DMemory.programs
  CopyExecution.Trace.memory KvConcatMemory.programs ScalarCopyQuadSourceRefinement.zeroTrace

variable {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache)
  (allocation : KvGrowthPairMemory.Allocation storage)

-- Original native constant inputs, freshness and spans. Incoming cache spans
-- are derived below from the ORIGINAL storage descriptor, rather than supplied
-- as post-growth cache attachments.
structure Scalars where
  key : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  value : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  keyShared : key.bytes=storage.memory
  valueShared : value.bytes=storage.memory
  keyAllocation : ScalarCopyQuadSemantics.Allocation key.base (2*allocation.keyLayout.zeroBase)
  keyZeroKeepsValue : MemoryRegions.Disjoint (2*allocation.keyLayout.zeroBase) 524288 value.base 2
  keyCopyKeepsValue : MemoryRegions.Disjoint (2*allocation.keyLayout.destination) (2*(4*(n+256)*256)) value.base 2
  valueFresh : MemoryRegions.Disjoint (2*allocation.valueLayout.zeroBase) 524288 value.base 2
  valueZeroBound : 2*allocation.valueLayout.zeroBase+524288≤2^64

variable (scalars : Scalars storage allocation)

theorem key_original_bound : 2*allocation.keyLayout.oldBase+2*(4*n*256)≤2^64 := by
  have bound := storage.layout.keyBound
  have full := KvAllocation.growth_full n allocation.growing
  rw [←allocation.keyBase] at bound
  simpa only [KvRegions.bytes,full] using bound

theorem value_original_bound : 2*allocation.valueLayout.oldBase+2*(4*n*256)≤2^64 := by
  have bound := storage.layout.valueBound
  have full := KvAllocation.growth_full n allocation.growing
  rw [←allocation.valueBase] at bound
  simpa only [KvRegions.bytes,full] using bound

def sources : MlxKvGrowthPairSource.Sources (KvGrowthPairMemory.fromStorage storage allocation) where
  key := scalars.key
  value := scalars.value
  keyShared := scalars.keyShared
  valueShared := scalars.valueShared
  keyAllocation := scalars.keyAllocation
  keyZeroKeepsValue := scalars.keyZeroKeepsValue
  keyCopyKeepsValue := scalars.keyCopyKeepsValue
  valueFresh := scalars.valueFresh
  valueZeroBound := scalars.valueZeroBound
  keyOldBound := key_original_bound storage allocation
  valueOldBound := value_original_bound storage allocation

theorem checked (supported : n≤262144) :
    MlxKvGrowthPairSource.Certificate (KvGrowthPairMemory.fromStorage storage allocation)
      (sources storage allocation scalars) supported :=
  MlxKvGrowthPairSource.checked _ _ supported

end Inference.Models.Qwen.AttentionGateCopyGrowthInputs
