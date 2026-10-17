import state.KvSliceCapacityMemory
namespace Inference.State.KvCacheFreshMemory
open Contracts.Mlx KvBytes KvSliceCapacityPreparation KvSliceCapacityMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory Slice.appended

structure Allocation {n : Nat} {cache : Kv.Cache BF n} {key value : Row} (storage : KvPreparedMemory.Storage cache) (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) where
  keyChoice : Choice (KvAllocation.capacity (n+1)) storage.layout.keyBase
  valueChoice : Choice (KvAllocation.capacity (n+1)) storage.layout.valueBase
  keySafe : MemoryRegions.Disjoint keyChoice.destination (KvRegions.bytes (n+1)) keySource.base (KvAppendMemory.sourceBytes keySource)
  valueSafe : MemoryRegions.Disjoint valueChoice.destination (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)
  keyKeepsValueSource : MemoryRegions.Disjoint keyChoice.destination (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)
  keyKeepsOldValues : MemoryRegions.Disjoint keyChoice.destination (KvRegions.bytes (n+1)) storage.layout.valueBase (KvRegions.bytes (n+1))
  separate : MemoryRegions.Disjoint keyChoice.destination (KvRegions.bytes (n+1)) valueChoice.destination (KvRegions.bytes (n+1))

variable {cache : Kv.Cache BF n} {key value : Row} {storage : KvPreparedMemory.Storage cache}
  {keySource : KvCopy.Source key} {valueSource : KvCopy.Source value}
  (allocation : Allocation storage keySource valueSource)
  (keyShared : keySource.bytes=storage.memory) (valueShared : valueSource.bytes=storage.memory)

def keys : Slice cache.keys key storage.memory storage.layout.keyBase where
  choice := allocation.keyChoice
  source := keySource
  shared := keyShared
  safe := by rw [region_bytes]; exact allocation.keySafe
  oldValues := storage.keys

def valueInput : KvCopy.Source value :=
  KvAppendMemory.reframe valueSource (keys allocation keyShared).memory (fun offset bound =>
    ((keys allocation keyShared).frame allocation.keyKeepsValueSource offset bound).trans (congrFun valueShared _).symm)

def values : Slice cache.values value (keys allocation keyShared).memory storage.layout.valueBase where
  choice := allocation.valueChoice
  source := valueInput allocation keyShared valueShared
  shared := rfl
  safe := by rw [region_bytes]; exact allocation.valueSafe
  oldValues := by
    intro head time i
    have same := ArrayFrame.half_congr storage.memory (keys allocation keyShared).memory storage.layout.valueBase
      (KvRegions.bytes (n+1)) (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)
      ((keys allocation keyShared).frame allocation.keyKeepsOldValues) (KvPreparedMemory.old_bounds head time i)
    exact same.trans (storage.values head time i)

def memory := (values allocation keyShared valueShared).memory

def layout : KvRegions.Layout (n+1) where
  keyBase := allocation.keyChoice.destination
  valueBase := allocation.valueChoice.destination
  keyAligned := allocation.keyChoice.aligned
  valueAligned := allocation.valueChoice.aligned
  keyBound := by simpa only [region_bytes] using allocation.keyChoice.bounded
  valueBound := by simpa only [region_bytes] using allocation.valueChoice.bounded
  separate := allocation.separate

theorem keys_preserved (offset : Nat) (bound : offset<KvRegions.bytes (n+1)) :
    memory allocation keyShared valueShared (allocation.keyChoice.destination+offset)=
      (keys allocation keyShared).memory (allocation.keyChoice.destination+offset) :=
  (values allocation keyShared valueShared).frame (MemoryRegions.disjoint_symm allocation.separate) offset bound

def after : KvRegions.Storage (Kv.append cache key value) where
  layout := layout allocation
  memory := memory allocation keyShared valueShared
  keys := by
    intro head time i
    have same := ArrayFrame.half_congr (keys allocation keyShared).memory (memory allocation keyShared valueShared)
      allocation.keyChoice.destination (KvRegions.bytes (n+1))
      (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)
      (keys_preserved allocation keyShared valueShared) (KvRegions.active_bounds head time i)
    exact same.trans ((keys allocation keyShared).read head time i)
  values := fun head time i => (values allocation keyShared valueShared).read head time i

structure Safe (allocation : Allocation storage keySource valueSource) (base size : Nat) : Prop where
  keys : MemoryRegions.Disjoint allocation.keyChoice.destination (KvRegions.bytes (n+1)) base size
  values : MemoryRegions.Disjoint allocation.valueChoice.destination (KvRegions.bytes (n+1)) base size

theorem other_region (safe : Safe allocation base size) (offset : Nat) (bound : offset<size) :
    (after allocation keyShared valueShared).memory (base+offset)=storage.memory (base+offset) :=
  ((values allocation keyShared valueShared).frame safe.values offset bound).trans
    ((keys allocation keyShared).frame safe.keys offset bound)

-- This separate execution type retains both preservation launches. It does
-- not pretend the value row starts immediately after the key row: a fresh
-- value slab is copied from that current heap first.
structure Execution (cache : Kv.Cache BF n) (key value : Row) where
  storage : KvPreparedMemory.Storage cache
  keySource : KvCopy.Source key
  valueSource : KvCopy.Source value
  keyShared : keySource.bytes=storage.memory
  valueShared : valueSource.bytes=storage.memory
  allocation : Allocation storage keySource valueSource

def Execution.keys (execution : Execution cache key value) := KvCacheFreshMemory.keys execution.allocation execution.keyShared

def Execution.values (execution : Execution cache key value) := KvCacheFreshMemory.values execution.allocation execution.keyShared execution.valueShared

def Execution.after (execution : Execution cache key value) := KvCacheFreshMemory.after execution.allocation execution.keyShared execution.valueShared

def Execution.Safe (execution : Execution cache key value) := KvCacheFreshMemory.Safe execution.allocation

theorem Execution.other_region (execution : Execution cache key value) (safe : execution.Safe base size)
    (offset : Nat) (bound : offset<size) : execution.after.memory (base+offset)=execution.storage.memory (base+offset) :=
  KvCacheFreshMemory.other_region execution.allocation execution.keyShared execution.valueShared safe offset bound

theorem Execution.key_read (execution : Execution cache key value) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.after.layout.keyBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits ((Kv.append cache key value).keys head time i) := execution.after.keys head time i

theorem Execution.value_read (execution : Execution cache key value) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.after.layout.valueBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits ((Kv.append cache key value).values head time i) := execution.after.values head time i

def Execution.bufferAfter {x : Fin count → ArrayStorage.BF} (execution : Execution cache key value)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=execution.storage.memory)
    (safe : execution.Safe source.base (2*count)) : ArrayStorage.BFBuffer x :=
  ArrayFrame.bf source execution.after.memory (fun offset bound =>
    (execution.other_region safe offset bound).trans (congrFun shared _).symm)
end Inference.State.KvCacheFreshMemory
