import state.KvCacheMemory

namespace Inference.State.KvPreparedMemory
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory

-- Old entries already occupy the capacity required for the next append.
-- The extra capacity may come from growth or from the current allocation.
structure Storage (cache : Kv.Cache BF n) where
  layout : KvRegions.Layout (n+1)
  memory : ByteMemory.Bytes
  keys : ∀ head time i, HalfMemory.load memory
    (layout.keyBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=bits (cache.keys head time i)
  values : ∀ head time i, HalfMemory.load memory
    (layout.valueBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=bits (cache.values head time i)

variable {n : Nat} {cache : Kv.Cache BF n} {key value : Row}

def Storage.fromExisting (storage : KvRegions.Storage cache)
    (same : KvAllocation.capacity n=KvAllocation.capacity (n+1)) : Storage cache where
  layout := {
    keyBase := storage.layout.keyBase
    valueBase := storage.layout.valueBase
    keyAligned := storage.layout.keyAligned
    valueAligned := storage.layout.valueAligned
    keyBound := by unfold KvRegions.bytes; rw [← same]; exact storage.layout.keyBound
    valueBound := by unfold KvRegions.bytes; rw [← same]; exact storage.layout.valueBound
    separate := by unfold KvRegions.bytes; rw [← same]; exact storage.layout.separate }
  memory := storage.memory
  keys := by
    intro head time i
    change HalfMemory.load storage.memory (storage.layout.keyBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [← same]
    exact storage.keys head time i
  values := by
    intro head time i
    change HalfMemory.load storage.memory (storage.layout.valueBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [← same]
    exact storage.values head time i

theorem old_bounds (head : Fin 4) (time : Fin n) (i : Fin 256) :
    2*Kv.address (KvAllocation.capacity (n+1)) head time.val i+2 ≤ KvRegions.bytes (n+1) :=
  KvRegions.active_bounds head ⟨time.val, Nat.lt_trans time.isLt (Nat.lt_succ_self n)⟩ i

def fromKeys (storage : Storage cache) (keys : KvAppendMemory.Execution cache.keys key)
    (keyBase : keys.base=storage.layout.keyBase) (keyCapacity : keys.capacity=KvAllocation.capacity (n+1))
    (keyShared : keys.copy.before=storage.memory) (valueSource : KvCopy.Source value)
    (valueShared : valueSource.bytes=storage.memory)
    (valueInputSeparate : MemoryRegions.Disjoint storage.layout.valueBase (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource))
    (valueSourceSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)) :
    KvCacheMemory.Execution cache key value := by
  have room : n<KvAllocation.capacity (n+1) := Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1
  have cacheSeparate : MemoryRegions.Disjoint keys.base (2*(4*keys.capacity*256)) storage.layout.valueBase (KvRegions.bytes (n+1)) := by
    rw [keyBase, keyCapacity]
    exact storage.layout.separate
  have sourceSeparate : MemoryRegions.Disjoint keys.base (2*(4*keys.capacity*256)) valueSource.base (KvAppendMemory.sourceBytes valueSource) := by
    rw [keyBase, keyCapacity]
    exact valueSourceSeparate
  have valuePreserved : ∀ offset < KvRegions.bytes (n+1),
      keys.copy.memory (storage.layout.valueBase+offset)=storage.memory (storage.layout.valueBase+offset) := by
    intro offset bound
    have same := keys.other_region cacheSeparate offset bound
    exact same.trans (congrFun keyShared (storage.layout.valueBase+offset))
  let source := KvAppendMemory.reframe valueSource keys.copy.memory (by
    intro offset bound
    have same := keys.other_region sourceSeparate offset bound
    exact same.trans ((congrFun keyShared (valueSource.base+offset)).trans (congrFun valueShared (valueSource.base+offset)).symm))
  let values := KvAppendMemory.Execution.canonical cache.values value source storage.layout.valueBase (KvAllocation.capacity (n+1))
    storage.layout.valueAligned room valueInputSeparate (by
      intro head time i
      change HalfMemory.load keys.copy.memory (storage.layout.valueBase+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
      rw [ArrayFrame.half_congr storage.memory keys.copy.memory storage.layout.valueBase (KvRegions.bytes (n+1))
        (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i) valuePreserved (old_bounds head time i)]
      exact storage.values head time i)
  exact {
    keys := keys
    values := values
    keyCapacity := keyCapacity
    valueCapacity := rfl
    linked := rfl
    separate := by rw [keyBase]; exact storage.layout.separate
    keyBound := by rw [keyBase]; exact storage.layout.keyBound
    valueBound := storage.layout.valueBound }

def append (storage : Storage cache) (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value)
    (keyShared : keySource.bytes=storage.memory) (valueShared : valueSource.bytes=storage.memory)
    (keyInputSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes (n+1)) keySource.base (KvAppendMemory.sourceBytes keySource))
    (valueInputSeparate : MemoryRegions.Disjoint storage.layout.valueBase (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource))
    (valueSourceSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)) :
    KvCacheMemory.Execution cache key value :=
  let room : n<KvAllocation.capacity (n+1) := Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1
  let keys := KvAppendMemory.Execution.canonical cache.keys key keySource storage.layout.keyBase (KvAllocation.capacity (n+1))
    storage.layout.keyAligned room keyInputSeparate (by intro head time i; rw [keyShared]; exact storage.keys head time i)
  fromKeys storage keys rfl rfl keyShared valueSource valueShared valueInputSeparate valueSourceSeparate

end Inference.State.KvPreparedMemory
