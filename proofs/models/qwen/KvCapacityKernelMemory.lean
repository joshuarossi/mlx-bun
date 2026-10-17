import state.KvSliceCapacityMemory
import kernels.copy.KvRowGeneralCopyBinding
import kernels.copy.GeneralCopy2DSourceRefinement
namespace Inference.Models.Qwen.KvCapacityKernelMemory
open Contracts.Mlx State Kernels.Copy KvSliceCapacityMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory
variable {old : KvBytes.History n} {next : KvBytes.Row} {before : ByteMemory.Bytes} {slab : Nat}
  (slice : Slice old next before slab)
  (small : 3*slice.source.rowStride+255*slice.source.columnStride<2^31)
  (sourceBound : slice.source.base+KvAppendMemory.sourceBytes slice.source≤2^64)
  (supported : n+1≤262144)

theorem destination_bound : slice.appended.base+2*(4*slice.appended.capacity*256)≤2^64 := by
  have bound := slice.choice.bounded
  rw [slice.appended_base,slice.appended_capacity]
  simpa only [KvSliceCapacityPreparation.bytes,KvSliceCapacityPreparation.words,Nat.mul_assoc] using bound

theorem capacity_supported (supported : n+1≤262144) : slice.appended.capacity≤262144 := by
  rw [slice.appended_capacity]
  exact KvAllocation.supported_capacity (n+1) supported

theorem source_small (small : 3*slice.source.rowStride+255*slice.source.columnStride<2^31) : 3*slice.appended.source.rowStride+255*slice.appended.source.columnStride<2^31 := small

theorem source_bound (sourceBound : slice.source.base+KvAppendMemory.sourceBytes slice.source≤2^64) : slice.appended.source.base+KvAppendMemory.sourceBytes slice.appended.source≤2^64 := sourceBound

def bounds (small : 3*slice.source.rowStride+255*slice.source.columnStride<2^31)
    (sourceBound : slice.source.base+KvAppendMemory.sourceBytes slice.source≤2^64) (supported : n+1≤262144) : GeneralCopy2DSemantics.Bounds (KvCopy.layout slice.appended.source slice.appended.base slice.appended.capacity n) :=
  KvRowGeneralCopyBinding.append_bounds_of_span slice.appended (source_small slice small) (source_bound slice sourceBound)
    (capacity_supported slice supported) (destination_bound slice)

def checked (small : 3*slice.source.rowStride+255*slice.source.columnStride<2^31)
    (sourceBound : slice.source.base+KvAppendMemory.sourceBytes slice.source≤2^64) (supported : n+1≤262144) := GeneralCopy2DSourceRefinement.canonical (bounds slice small sourceBound supported) slice.appended.copy.before

theorem heaps : (checked slice small sourceBound supported).bodyAfter=slice.memory ∧
    (checked slice small sourceBound supported).eventAfter.memory=slice.memory :=
  GeneralCopy2DSourceRefinement.checked_eq (bounds slice small sourceBound supported)
    (KvRowGeneralCopyBinding.append_separate slice.appended) slice.appended.copy (checked slice small sourceBound supported)

theorem starts : GeneralCopy2DInterleaving.Executes
    (KvCopy.layout slice.appended.source slice.appended.base slice.appended.capacity n)
    (GeneralCopy2DInterleaving.initial slice.preservation.memory)
    (checked slice small sourceBound supported).events (checked slice small sourceBound supported).eventAfter := by
  rw [← slice.appended_before]
  exact (checked slice small sourceBound supported).eventExecution
end Inference.Models.Qwen.KvCapacityKernelMemory
