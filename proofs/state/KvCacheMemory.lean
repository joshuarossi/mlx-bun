import state.KvAppendMemory
import state.KvRegions

namespace Inference.State.KvCacheMemory
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs
attribute [local irreducible] CopyExecution.Trace.memory

-- Keys are updated first, then values consume that changed heap. The final
-- cache is attached to the heap after both copies, including preservation
-- of the completed key writes through the value-copy dispatch.
structure Execution (cache : Kv.Cache BF n) (key value : Row) where
  keys : KvAppendMemory.Execution cache.keys key
  values : KvAppendMemory.Execution cache.values value
  keyCapacity : keys.capacity=KvAllocation.capacity (n+1)
  valueCapacity : values.capacity=KvAllocation.capacity (n+1)
  linked : values.copy.before=keys.copy.memory
  separate : MemoryRegions.Disjoint keys.base (KvRegions.bytes (n+1)) values.base (KvRegions.bytes (n+1))
  keyBound : keys.base+KvRegions.bytes (n+1) ≤ 2^64
  valueBound : values.base+KvRegions.bytes (n+1) ≤ 2^64

variable {n : Nat} {cache : Kv.Cache BF n} {key value : Row}

-- The in-place branch needs no independent old-value attachment after
-- updating keys: both the saved value cache and the projected value source
-- are preserved by the actual key-copy stores.
def fromKeys (storage : KvRegions.Storage cache) (keys : KvAppendMemory.Execution cache.keys key)
    (keyBase : keys.base=storage.layout.keyBase) (keyCapacity : keys.capacity=KvAllocation.capacity n)
    (keyShared : keys.copy.before=storage.memory) (valueSource : KvCopy.Source value)
    (valueShared : valueSource.bytes=storage.memory)
    (capacitySame : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (valueInputSeparate : MemoryRegions.Disjoint storage.layout.valueBase (KvRegions.bytes n) valueSource.base (KvAppendMemory.sourceBytes valueSource))
    (valueSourceSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes n) valueSource.base (KvAppendMemory.sourceBytes valueSource)) :
    Execution cache key value := by
  have room : n<KvAllocation.capacity n := by
    have bound := (KvAllocation.capacity_bounds (n+1)).1
    rw [← capacitySame] at bound
    omega
  have cacheSeparate : MemoryRegions.Disjoint keys.base (2*(4*keys.capacity*256)) storage.layout.valueBase (KvRegions.bytes n) := by
    rw [keyBase, keyCapacity]
    exact storage.layout.separate
  have sourceSeparate : MemoryRegions.Disjoint keys.base (2*(4*keys.capacity*256)) valueSource.base (KvAppendMemory.sourceBytes valueSource) := by
    rw [keyBase, keyCapacity]
    exact valueSourceSeparate
  have valuePreserved : ∀ offset < KvRegions.bytes n,
      keys.copy.memory (storage.layout.valueBase+offset)=storage.memory (storage.layout.valueBase+offset) := by
    intro offset bound
    have same := keys.other_region cacheSeparate offset bound
    exact same.trans (congrFun keyShared (storage.layout.valueBase+offset))
  let source := KvAppendMemory.reframe valueSource keys.copy.memory (by
    intro offset bound
    have same := keys.other_region sourceSeparate offset bound
    exact same.trans ((congrFun keyShared (valueSource.base+offset)).trans (congrFun valueShared (valueSource.base+offset)).symm))
  let values := KvAppendMemory.Execution.canonical cache.values value source storage.layout.valueBase (KvAllocation.capacity n)
    storage.layout.valueAligned room valueInputSeparate (by
      intro head time i
      change HalfMemory.load keys.copy.memory (storage.layout.valueBase+2*Kv.address (KvAllocation.capacity n) head time.val i)=_
      rw [ArrayFrame.half_congr storage.memory keys.copy.memory storage.layout.valueBase (KvRegions.bytes n)
        (2*Kv.address (KvAllocation.capacity n) head time.val i) valuePreserved (KvRegions.active_bounds head time i)]
      exact storage.values head time i)
  exact {
    keys := keys
    values := values
    keyCapacity := keyCapacity.trans capacitySame
    valueCapacity := capacitySame
    linked := rfl
    separate := by
      change MemoryRegions.Disjoint keys.base (KvRegions.bytes (n+1)) storage.layout.valueBase (KvRegions.bytes (n+1))
      rw [keyBase]
      unfold KvRegions.bytes
      rw [← capacitySame]
      exact storage.layout.separate
    keyBound := by
      rw [keyBase]
      unfold KvRegions.bytes
      rw [← capacitySame]
      exact storage.layout.keyBound
    valueBound := by
      change storage.layout.valueBase+KvRegions.bytes (n+1) ≤ 2^64
      unfold KvRegions.bytes
      rw [← capacitySame]
      exact storage.layout.valueBound }

def fromStorage (storage : KvRegions.Storage cache) (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value)
    (keyShared : keySource.bytes=storage.memory) (valueShared : valueSource.bytes=storage.memory)
    (capacitySame : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (keyInputSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes n) keySource.base (KvAppendMemory.sourceBytes keySource))
    (valueInputSeparate : MemoryRegions.Disjoint storage.layout.valueBase (KvRegions.bytes n) valueSource.base (KvAppendMemory.sourceBytes valueSource))
    (valueSourceSeparate : MemoryRegions.Disjoint storage.layout.keyBase (KvRegions.bytes n) valueSource.base (KvAppendMemory.sourceBytes valueSource)) :
    Execution cache key value :=
  let room : n<KvAllocation.capacity n := by
    have bound := (KvAllocation.capacity_bounds (n+1)).1
    rw [← capacitySame] at bound
    omega
  let keys := KvAppendMemory.Execution.canonical cache.keys key keySource storage.layout.keyBase (KvAllocation.capacity n)
    storage.layout.keyAligned room keyInputSeparate (by intro head time i; rw [keyShared]; exact storage.keys head time i)
  fromKeys storage keys rfl rfl keyShared valueSource valueShared capacitySame valueInputSeparate valueSourceSeparate

def Execution.layout (execution : Execution cache key value) : KvRegions.Layout (n+1) where
  keyBase := execution.keys.base
  valueBase := execution.values.base
  keyAligned := execution.keys.aligned
  valueAligned := execution.values.aligned
  keyBound := execution.keyBound
  valueBound := execution.valueBound
  separate := execution.separate

theorem Execution.keys_preserved (execution : Execution cache key value) (offset : Nat) (bound : offset<KvRegions.bytes (n+1)) :
    execution.values.copy.memory (execution.keys.base+offset)=execution.keys.copy.memory (execution.keys.base+offset) := by
  have separate : MemoryRegions.Disjoint execution.values.base (2*(4*execution.values.capacity*256))
      execution.keys.base (KvRegions.bytes (n+1)) := by
    rw [execution.valueCapacity]
    exact MemoryRegions.disjoint_symm execution.separate
  have same := execution.values.other_region separate offset bound
  exact same.trans (congrFun execution.linked (execution.keys.base+offset))

def Execution.after (execution : Execution cache key value) : KvRegions.Storage (Kv.append cache key value) where
  layout := execution.layout
  memory := execution.values.copy.memory
  keys := by
    intro head time i
    have same := ArrayFrame.half_congr execution.keys.copy.memory execution.values.copy.memory execution.keys.base
      (KvRegions.bytes (n+1)) (2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)
      execution.keys_preserved (KvRegions.active_bounds head time i)
    change HalfMemory.load execution.values.copy.memory
      (execution.keys.base+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [same, ← execution.keyCapacity]
    exact execution.keys.load_correct head time i
  values := by
    intro head time i
    change HalfMemory.load execution.values.copy.memory
      (execution.values.base+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [← execution.valueCapacity]
    exact execution.values.load_correct head time i

def Execution.localStorage (execution : Execution cache key value) : KvAllocation.Storage (Kv.append cache key value) :=
  execution.after.local

theorem Execution.key_read (execution : Execution cache key value) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.keys.base+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits ((Kv.append cache key value).keys head time i) := execution.after.keys head time i

theorem Execution.value_read (execution : Execution cache key value) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load execution.after.memory (execution.values.base+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits ((Kv.append cache key value).values head time i) := execution.after.values head time i

theorem Execution.memory (execution : Execution cache key value) : execution.after.memory=execution.values.copy.memory := rfl

end Inference.State.KvCacheMemory
