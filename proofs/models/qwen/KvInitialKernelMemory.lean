import models.qwen.KvInitialDispatchMemory
import models.qwen.AttentionInitialKvMemory
import kernels.copy.KvRowGeneralCopyBinding
import kernels.copy.GeneralCopy2DSourceRefinement

namespace Inference.Models.Qwen.KvInitialKernelMemory
open Contracts.Mlx State Kernels.Copy
open KvSlicePreparationMemory KvInitialPairMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {cache : Kv.Cache Kv.BF 0} {key value : KvBytes.Row} (execution : Execution cache key value)

private theorem slice_bound {old : KvBytes.History 0} {next : KvBytes.Row} {before : ByteMemory.Bytes} {slab : Nat}
    (slice : Slice old next before slab) : slice.appended.base+2*(4*slice.appended.capacity*256)≤2^64 := by
  rw [slice.appended_base,slice.appended_capacity]
  exact slice.choice.bounded

private theorem slice_supported {old : KvBytes.History 0} {next : KvBytes.Row} {before : ByteMemory.Bytes} {slab : Nat}
    (slice : Slice old next before slab) : slice.appended.capacity≤262144 := by
  rw [slice.appended_capacity]
  decide

def keyAppend := (KvInitialDispatchMemory.keySlice execution).appended

def valueAppend := (KvInitialDispatchMemory.valueSlice execution).appended

theorem key_small (small : 3*execution.keySource.rowStride+255*execution.keySource.columnStride<2^31) :
    3*(keyAppend execution).source.rowStride+255*(keyAppend execution).source.columnStride<2^31 := small

theorem value_small (small : 3*execution.valueSource.rowStride+255*execution.valueSource.columnStride<2^31) :
    3*(valueAppend execution).source.rowStride+255*(valueAppend execution).source.columnStride<2^31 := small

theorem key_source_bound : (keyAppend execution).source.base+KvAppendMemory.sourceBytes (keyAppend execution).source≤2^64 :=
  execution.allocation.keySourceBound

theorem value_source_bound : (valueAppend execution).source.base+KvAppendMemory.sourceBytes (valueAppend execution).source≤2^64 :=
  execution.allocation.valueSourceBound

theorem key_destination_bound : (keyAppend execution).base+2*(4*(keyAppend execution).capacity*256)≤2^64 :=
  slice_bound (KvInitialDispatchMemory.keySlice execution)

theorem value_destination_bound : (valueAppend execution).base+2*(4*(valueAppend execution).capacity*256)≤2^64 :=
  slice_bound (KvInitialDispatchMemory.valueSlice execution)

theorem keyBounds (small : 3*execution.keySource.rowStride+255*execution.keySource.columnStride<2^31) : GeneralCopy2DSemantics.Bounds (KvCopy.layout (keyAppend execution).source (keyAppend execution).base (keyAppend execution).capacity 0) :=
  KvRowGeneralCopyBinding.append_bounds_of_span (keyAppend execution) (key_small execution small)
    (key_source_bound execution) (slice_supported (KvInitialDispatchMemory.keySlice execution)) (key_destination_bound execution)

theorem valueBounds (small : 3*execution.valueSource.rowStride+255*execution.valueSource.columnStride<2^31) : GeneralCopy2DSemantics.Bounds (KvCopy.layout (valueAppend execution).source (valueAppend execution).base (valueAppend execution).capacity 0) :=
  KvRowGeneralCopyBinding.append_bounds_of_span (valueAppend execution) (value_small execution small)
    (value_source_bound execution) (slice_supported (KvInitialDispatchMemory.valueSlice execution)) (value_destination_bound execution)

def keyChecked (small : 3*execution.keySource.rowStride+255*execution.keySource.columnStride<2^31) :=
  GeneralCopy2DSourceRefinement.canonical (keyBounds execution small) (keyAppend execution).copy.before

def valueChecked (small : 3*execution.valueSource.rowStride+255*execution.valueSource.columnStride<2^31) :=
  GeneralCopy2DSourceRefinement.canonical (valueBounds execution small) (valueAppend execution).copy.before

theorem key_heaps (small : 3*execution.keySource.rowStride+255*execution.keySource.columnStride<2^31) :
    (keyChecked execution small).bodyAfter=(KvInitialDispatchMemory.keySlice execution).memory ∧
    (keyChecked execution small).eventAfter.memory=(KvInitialDispatchMemory.keySlice execution).memory :=
  GeneralCopy2DSourceRefinement.checked_eq (keyBounds execution small)
    (KvRowGeneralCopyBinding.append_separate (keyAppend execution)) (keyAppend execution).copy (keyChecked execution small)

theorem value_heaps (small : 3*execution.valueSource.rowStride+255*execution.valueSource.columnStride<2^31) :
    (valueChecked execution small).bodyAfter=execution.after.memory ∧
    (valueChecked execution small).eventAfter.memory=execution.after.memory :=
  GeneralCopy2DSourceRefinement.checked_eq (valueBounds execution small)
    (KvRowGeneralCopyBinding.append_separate (valueAppend execution)) (valueAppend execution).copy (valueChecked execution small)

theorem key_starts (small : 3*execution.keySource.rowStride+255*execution.keySource.columnStride<2^31) :
    GeneralCopy2DInterleaving.Executes
      (KvCopy.layout (keyAppend execution).source (keyAppend execution).base (keyAppend execution).capacity 0)
      (GeneralCopy2DInterleaving.initial (KvInitialDispatchMemory.keySlice execution).preservation.memory)
      (keyChecked execution small).events (keyChecked execution small).eventAfter := by
  rw [← KvInitialDispatchMemory.key_row_starts execution]
  exact (keyChecked execution small).eventExecution

theorem value_starts (small : 3*execution.valueSource.rowStride+255*execution.valueSource.columnStride<2^31) :
    GeneralCopy2DInterleaving.Executes
      (KvCopy.layout (valueAppend execution).source (valueAppend execution).base (valueAppend execution).capacity 0)
      (GeneralCopy2DInterleaving.initial (KvInitialDispatchMemory.valueSlice execution).preservation.memory)
      (valueChecked execution small).events (valueChecked execution small).eventAfter := by
  rw [← KvInitialDispatchMemory.value_row_starts execution]
  exact (valueChecked execution small).eventExecution

section Attention
variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : Kernels.Attention.RopeAngles.Inputs}
    {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache)

theorem prefix_key_small : 3*read.kv.keySource.rowStride+255*read.kv.keySource.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

theorem prefix_value_small : 3*read.kv.valueSource.rowStride+255*read.kv.valueSource.columnStride<2^31 := by
  change 3*256+255*1<2^31
  decide

def prefixKeyChecked := keyChecked read.kv (prefix_key_small read)

def prefixValueChecked := valueChecked read.kv (prefix_value_small read)

theorem prefix_key_heap : (prefixKeyChecked read).eventAfter.memory=(KvInitialDispatchMemory.keySlice read.kv).memory :=
  (key_heaps read.kv (prefix_key_small read)).2

theorem prefix_value_heap : (prefixValueChecked read).eventAfter.memory=read.input.cache.memory :=
  (value_heaps read.kv (prefix_value_small read)).2

end Attention
end Inference.Models.Qwen.KvInitialKernelMemory
