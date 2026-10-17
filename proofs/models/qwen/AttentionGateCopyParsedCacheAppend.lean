import models.qwen.AttentionGateCopyReadConstruction
import kernels.copy.KvRowGeneralCopyBinding
import kernels.copy.GeneralCopy2DSourceRefinement

namespace Inference.Models.Qwen.AttentionGateCopyParsedCacheAppend
open Contracts.Mlx Kernels.Attention Kernels.Copy State
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory List.finRange

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  (read : AttentionGateCopyReadConstruction.ReadPlan s)

def cacheExecution := read.allocation.append.updated

def keys := (cacheExecution read).keys

def vals := (cacheExecution read).values

-- Pointer spans and native capacity attachment stay explicit; source strides
-- are derived from the completed RoPE/value buffers in the same staged front.
structure Bounds (_read : AttentionGateCopyReadConstruction.ReadPlan s) : Prop where
  capacity : KvAllocation.capacity (n+1)≤262144
  keySource : s.front.rope.key.destination+2048≤2^64
  valueSource : s.front.valueBuffer.base+2048≤2^64

theorem key_bounds (bounds : Bounds read) :
    GeneralCopy2DSemantics.Bounds (KvCopy.layout (keys read).source (keys read).base (keys read).capacity n) := by
  apply KvRowGeneralCopyBinding.append_bounds_of_span
  · change 3*256+255*1<2^31
    decide
  · exact bounds.keySource
  · change (cacheExecution read).keys.capacity≤262144
    rw [(cacheExecution read).keyCapacity]
    exact bounds.capacity
  · change (cacheExecution read).keys.base+2*(4*(cacheExecution read).keys.capacity*256)≤2^64
    rw [(cacheExecution read).keyCapacity]
    exact (cacheExecution read).keyBound

theorem value_bounds (bounds : Bounds read) :
    GeneralCopy2DSemantics.Bounds (KvCopy.layout (vals read).source (vals read).base (vals read).capacity n) := by
  apply KvRowGeneralCopyBinding.append_bounds_of_span
  · change 3*256+255*1<2^31
    decide
  · exact bounds.valueSource
  · change (cacheExecution read).values.capacity≤262144
    rw [(cacheExecution read).valueCapacity]
    exact bounds.capacity
  · change (cacheExecution read).values.base+2*(4*(cacheExecution read).values.capacity*256)≤2^64
    rw [(cacheExecution read).valueCapacity]
    exact (cacheExecution read).valueBound

def keyDescriptor (bounds : Bounds read) : KvRowDispatchGeometry.SourceDescriptor (keys read).source where
  dataSize := 1024
  span := by change 3*256+255*1<1024; decide
  small := by decide
  bounded := bounds.keySource

def valueDescriptor (bounds : Bounds read) : KvRowDispatchGeometry.SourceDescriptor (vals read).source where
  dataSize := 1024
  span := by change 3*256+255*1<1024; decide
  small := by decide
  bounded := bounds.valueSource

private theorem capacity_minimum : 2≤KvAllocation.capacity (n+1) := by
  have := (KvAllocation.capacity_bounds (n+1)).1
  have := KvAllocation.capacity_multiple (n+1)
  omega

-- The singleton-axis strides stay symbolic because row attachment does not
-- determine their native descriptor values. This reviewed host model selects
-- GG2/grid256×4 for every representable such pair. Native descriptor extraction
-- still binds the modeled 1024-element source span and original strides.
theorem key_selected (bounds : Bounds read) (batch time : Nat)
    (batchBound : batch<2^63) (timeBound : time<2^63) :
    KvRowDispatchGeometry.Selection (keys read).source (keyDescriptor read bounds)
      batch time (keys read).capacity n := by
  apply KvRowDispatchGeometry.selected _ _ batch time _ _ batchBound timeBound
  · change 2≤(cacheExecution read).keys.capacity
    rw [(cacheExecution read).keyCapacity]
    exact capacity_minimum
  · change (cacheExecution read).keys.capacity≤262144
    rw [(cacheExecution read).keyCapacity]
    exact bounds.capacity
  · exact (keys read).room

theorem value_selected (bounds : Bounds read) (batch time : Nat)
    (batchBound : batch<2^63) (timeBound : time<2^63) :
    KvRowDispatchGeometry.Selection (vals read).source (valueDescriptor read bounds)
      batch time (vals read).capacity n := by
  apply KvRowDispatchGeometry.selected _ _ batch time _ _ batchBound timeBound
  · change 2≤(cacheExecution read).values.capacity
    rw [(cacheExecution read).valueCapacity]
    exact capacity_minimum
  · change (cacheExecution read).values.capacity≤262144
    rw [(cacheExecution read).valueCapacity]
    exact bounds.capacity
  · exact (vals read).room

def keyChecked (bounds : Bounds read) :=
  GeneralCopy2DSourceRefinement.canonical (key_bounds read bounds) (keys read).copy.before

def valueChecked (bounds : Bounds read) :=
  GeneralCopy2DSourceRefinement.canonical (value_bounds read bounds) (vals read).copy.before

theorem key_heap (bounds : Bounds read) :
    (keyChecked read bounds).bodyAfter=(keys read).copy.memory ∧
    (keyChecked read bounds).eventAfter.memory=(keys read).copy.memory :=
  GeneralCopy2DSourceRefinement.checked_eq (key_bounds read bounds)
    (KvRowGeneralCopyBinding.append_separate (keys read)) (keys read).copy (keyChecked read bounds)

theorem value_heap (bounds : Bounds read) :
    (valueChecked read bounds).bodyAfter=read.input.cache.memory ∧
    (valueChecked read bounds).eventAfter.memory=read.input.cache.memory :=
  GeneralCopy2DSourceRefinement.checked_eq (value_bounds read bounds)
    (KvRowGeneralCopyBinding.append_separate (vals read)) (vals read).copy (valueChecked read bounds)

theorem key_starts (bounds : Bounds read) :
    GeneralCopy2DInterleaving.Executes
      (KvCopy.layout (keys read).source (keys read).base (keys read).capacity n)
      (GeneralCopy2DInterleaving.initial read.allocation.preparation.storage.memory)
      (keyChecked read bounds).events (keyChecked read bounds).eventAfter :=
  (keyChecked read bounds).eventExecution

theorem value_starts (bounds : Bounds read) :
    GeneralCopy2DInterleaving.Executes
      (KvCopy.layout (vals read).source (vals read).base (vals read).capacity n)
      (GeneralCopy2DInterleaving.initial (keyChecked read bounds).eventAfter.memory)
      (valueChecked read bounds).events (valueChecked read bounds).eventAfter := by
  rw [(key_heap read bounds).2]
  change GeneralCopy2DInterleaving.Executes _
    (GeneralCopy2DInterleaving.initial (cacheExecution read).keys.copy.memory) _ _
  rw [← (cacheExecution read).linked]
  exact (valueChecked read bounds).eventExecution

end Inference.Models.Qwen.AttentionGateCopyParsedCacheAppend
