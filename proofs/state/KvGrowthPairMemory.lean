import state.KvPreparedMemory
import state.KvConcatMemory

namespace Inference.State.KvGrowthPairMemory
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000
attribute [local irreducible] KvConcatMemory.programs CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

theorem growth_frame {capacity : Nat} (layout : KvConcatMemory.Layout capacity) (growth : KvConcatMemory.Initialized layout)
    {base size : Nat} (zeroSeparate : MemoryRegions.Disjoint (2*layout.zeroBase) 524288 base size)
    (copySeparate : MemoryRegions.Disjoint (2*layout.destination) (2*(4*(capacity+256)*256)) base size)
    (offset : Nat) (bound : offset<size) :
    growth.concatenation.memory (base+offset)=growth.zeros.before (base+offset) := by
  have copied := KvConcatMemory.other_region layout growth.concatenation copySeparate offset bound
  rw [growth.initial] at copied
  exact copied.trans (MemoryRegions.execute16_other growth.zeros.schedule growth.zeros.before
    (KvConcatMemory.zero_stores_inside _ growth.zeros) zeroSeparate offset bound)

structure Execution (cache : Kv.Cache BF n) where
  growing : KvAllocation.capacity n<n+1
  keyLayout : KvConcatMemory.Layout n
  valueLayout : KvConcatMemory.Layout n
  keys : KvConcatMemory.Initialized keyLayout
  values : KvConcatMemory.Initialized valueLayout
  linked : values.zeros.before=keys.concatenation.memory
  zeroKeepsOldValues : MemoryRegions.Disjoint (2*keyLayout.zeroBase) 524288 (2*valueLayout.oldBase) (2*(4*n*256))
  copyKeepsOldValues : MemoryRegions.Disjoint (2*keyLayout.destination) (2*(4*(n+256)*256)) (2*valueLayout.oldBase) (2*(4*n*256))
  zeroKeepsKeys : MemoryRegions.Disjoint (2*valueLayout.zeroBase) 524288 (2*keyLayout.destination) (2*(4*(n+256)*256))
  separate : MemoryRegions.Disjoint (2*keyLayout.destination) (2*(4*(n+256)*256)) (2*valueLayout.destination) (2*(4*(n+256)*256))
  keyBound : 2*keyLayout.destination+2*(4*(n+256)*256) ≤ 2^64
  valueBound : 2*valueLayout.destination+2*(4*(n+256)*256) ≤ 2^64
  keysAttached : ∀ head time i, HalfMemory.load keys.zeros.before
    (2*(keyLayout.oldBase+Kv.address n head time.val i))=bits (cache.keys head time i)
  valuesAttached : ∀ head time i, HalfMemory.load keys.zeros.before
    (2*(valueLayout.oldBase+Kv.address n head time.val i))=bits (cache.values head time i)

variable {n : Nat} {cache : Kv.Cache BF n}

-- Allocation supplies addresses and separation, not the contents of the
-- grown caches. Those contents are derived from the incoming shared heap.
structure Allocation (storage : KvRegions.Storage cache) where
  growing : KvAllocation.capacity n<n+1
  keyLayout : KvConcatMemory.Layout n
  valueLayout : KvConcatMemory.Layout n
  keyBase : 2*keyLayout.oldBase=storage.layout.keyBase
  valueBase : 2*valueLayout.oldBase=storage.layout.valueBase
  keyZeroSeparate : MemoryRegions.Disjoint (2*keyLayout.zeroBase) 524288 (2*keyLayout.oldBase) (2*(4*n*256))
  valueZeroSeparate : MemoryRegions.Disjoint (2*valueLayout.zeroBase) 524288 (2*valueLayout.oldBase) (2*(4*n*256))
  zeroKeepsOldValues : MemoryRegions.Disjoint (2*keyLayout.zeroBase) 524288 (2*valueLayout.oldBase) (2*(4*n*256))
  copyKeepsOldValues : MemoryRegions.Disjoint (2*keyLayout.destination) (2*(4*(n+256)*256)) (2*valueLayout.oldBase) (2*(4*n*256))
  zeroKeepsKeys : MemoryRegions.Disjoint (2*valueLayout.zeroBase) 524288 (2*keyLayout.destination) (2*(4*(n+256)*256))
  separate : MemoryRegions.Disjoint (2*keyLayout.destination) (2*(4*(n+256)*256)) (2*valueLayout.destination) (2*(4*(n+256)*256))
  keyBound : 2*keyLayout.destination+2*(4*(n+256)*256) ≤ 2^64
  valueBound : 2*valueLayout.destination+2*(4*(n+256)*256) ≤ 2^64

def fromKeys (storage : KvRegions.Storage cache) (allocation : Allocation storage)
    (keys : KvConcatMemory.Initialized allocation.keyLayout) (initial : keys.zeros.before=storage.memory) :
    Execution cache where
  growing := allocation.growing
  keyLayout := allocation.keyLayout
  valueLayout := allocation.valueLayout
  keys := keys
  values := KvConcatMemory.Initialized.canonical allocation.valueLayout keys.concatenation.memory allocation.valueZeroSeparate
  linked := rfl
  zeroKeepsOldValues := allocation.zeroKeepsOldValues
  copyKeepsOldValues := allocation.copyKeepsOldValues
  zeroKeepsKeys := allocation.zeroKeepsKeys
  separate := allocation.separate
  keyBound := allocation.keyBound
  valueBound := allocation.valueBound
  keysAttached := by
    intro head time i
    rw [initial, Nat.mul_add, allocation.keyBase]
    have attached := storage.keys head time i
    rw [KvAllocation.growth_full n allocation.growing] at attached
    exact attached
  valuesAttached := by
    intro head time i
    rw [initial, Nat.mul_add, allocation.valueBase]
    have attached := storage.values head time i
    rw [KvAllocation.growth_full n allocation.growing] at attached
    exact attached

def fromStorage (storage : KvRegions.Storage cache) (allocation : Allocation storage) : Execution cache :=
  fromKeys storage allocation
    (KvConcatMemory.Initialized.canonical allocation.keyLayout storage.memory allocation.keyZeroSeparate) rfl

theorem fromStorage_initial (storage : KvRegions.Storage cache) (allocation : Allocation storage) :
    (fromStorage storage allocation).keys.zeros.before=storage.memory := rfl

theorem Execution.capacity_next (execution : Execution cache) : KvAllocation.capacity (n+1)=n+256 := by
  rw [KvAllocation.next_capacity, ite_eq_left execution.growing, KvAllocation.growth_full n execution.growing]

theorem Execution.keys_preserved (execution : Execution cache) (offset : Nat) (bound : offset<2*(4*(n+256)*256)) :
    execution.values.concatenation.memory (2*execution.keyLayout.destination+offset)=
      execution.keys.concatenation.memory (2*execution.keyLayout.destination+offset) :=
  (growth_frame execution.valueLayout execution.values execution.zeroKeepsKeys
    (MemoryRegions.disjoint_symm execution.separate) offset bound).trans
      (congrFun execution.linked (2*execution.keyLayout.destination+offset))

theorem Execution.key_read (execution : Execution cache) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load execution.values.concatenation.memory
      (2*(execution.keyLayout.destination+Kv.address (n+256) head time.val i))=bits (cache.keys head time i) := by
  have bound := Kv.address_bounds (n+256) head time.val i (by have := time.isLt; omega)
  have same := ArrayFrame.half_congr execution.keys.concatenation.memory execution.values.concatenation.memory
    (2*execution.keyLayout.destination) (2*(4*(n+256)*256)) (2*Kv.address (n+256) head time.val i)
    execution.keys_preserved (by omega)
  have read := (execution.keys.preserves head time i).trans (execution.keysAttached head time i)
  simpa only [Nat.mul_add] using same.trans (by simpa only [Nat.mul_add] using read)

theorem Execution.value_read (execution : Execution cache) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load execution.values.concatenation.memory
      (2*(execution.valueLayout.destination+Kv.address (n+256) head time.val i))=bits (cache.values head time i) := by
  have oldBound := Kv.address_bounds n head time.val i time.isLt
  have same := ArrayFrame.half_congr execution.keys.zeros.before execution.keys.concatenation.memory
    (2*execution.valueLayout.oldBase) (2*(4*n*256)) (2*Kv.address n head time.val i)
    (growth_frame execution.keyLayout execution.keys execution.zeroKeepsOldValues execution.copyKeepsOldValues) (by omega)
  have joined := congrArg (fun memory => HalfMemory.load memory (2*(execution.valueLayout.oldBase+Kv.address n head time.val i))) execution.linked
  have copied := execution.values.preserves head time i
  have frame : HalfMemory.load execution.keys.concatenation.memory (2*(execution.valueLayout.oldBase+Kv.address n head time.val i))=
      HalfMemory.load execution.keys.zeros.before (2*(execution.valueLayout.oldBase+Kv.address n head time.val i)) := by
    simpa only [Nat.mul_add] using same
  exact copied.trans (joined.trans (frame.trans (execution.valuesAttached head time i)))

def Execution.layout (execution : Execution cache) : KvRegions.Layout (n+1) where
  keyBase := 2*execution.keyLayout.destination
  valueBase := 2*execution.valueLayout.destination
  keyAligned := by omega
  valueAligned := by omega
  keyBound := by unfold KvRegions.bytes; rw [execution.capacity_next]; exact execution.keyBound
  valueBound := by unfold KvRegions.bytes; rw [execution.capacity_next]; exact execution.valueBound
  separate := by unfold KvRegions.bytes; rw [execution.capacity_next]; exact execution.separate

def Execution.prepared (execution : Execution cache) : KvPreparedMemory.Storage cache where
  layout := execution.layout
  memory := execution.values.concatenation.memory
  keys := by
    intro head time i
    change HalfMemory.load execution.values.concatenation.memory
      (2*execution.keyLayout.destination+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [execution.capacity_next]
    simpa only [Nat.mul_add] using execution.key_read head time i
  values := by
    intro head time i
    change HalfMemory.load execution.values.concatenation.memory
      (2*execution.valueLayout.destination+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=_
    rw [execution.capacity_next]
    simpa only [Nat.mul_add] using execution.value_read head time i

theorem Execution.other_region (execution : Execution cache) {base size : Nat}
    (keyZero : MemoryRegions.Disjoint (2*execution.keyLayout.zeroBase) 524288 base size)
    (keyDestination : MemoryRegions.Disjoint (2*execution.keyLayout.destination) (2*(4*(n+256)*256)) base size)
    (valueZero : MemoryRegions.Disjoint (2*execution.valueLayout.zeroBase) 524288 base size)
    (valueDestination : MemoryRegions.Disjoint (2*execution.valueLayout.destination) (2*(4*(n+256)*256)) base size)
    (offset : Nat) (bound : offset<size) :
    execution.prepared.memory (base+offset)=execution.keys.zeros.before (base+offset) :=
  (growth_frame execution.valueLayout execution.values valueZero valueDestination offset bound).trans
    ((congrFun execution.linked (base+offset)).trans
      (growth_frame execution.keyLayout execution.keys keyZero keyDestination offset bound))

structure SourceSafe (execution : Execution cache) (source : KvCopy.Source next) : Prop where
  keyZero : MemoryRegions.Disjoint (2*execution.keyLayout.zeroBase) 524288 source.base (KvAppendMemory.sourceBytes source)
  keyDestination : MemoryRegions.Disjoint (2*execution.keyLayout.destination) (2*(4*(n+256)*256)) source.base (KvAppendMemory.sourceBytes source)
  valueZero : MemoryRegions.Disjoint (2*execution.valueLayout.zeroBase) 524288 source.base (KvAppendMemory.sourceBytes source)
  valueDestination : MemoryRegions.Disjoint (2*execution.valueLayout.destination) (2*(4*(n+256)*256)) source.base (KvAppendMemory.sourceBytes source)

theorem Execution.source_preserved (execution : Execution cache) (source : KvCopy.Source next)
    (shared : source.bytes=execution.keys.zeros.before) (safe : SourceSafe execution source)
    (offset : Nat) (bound : offset<KvAppendMemory.sourceBytes source) :
    execution.prepared.memory (source.base+offset)=source.bytes (source.base+offset) := by
  have valuePhase := growth_frame execution.valueLayout execution.values safe.valueZero safe.valueDestination offset bound
  have keyPhase := growth_frame execution.keyLayout execution.keys safe.keyZero safe.keyDestination offset bound
  exact valuePhase.trans ((congrFun execution.linked (source.base+offset)).trans
    (keyPhase.trans (congrFun shared (source.base+offset)).symm))

def Execution.source (execution : Execution cache) (source : KvCopy.Source next)
    (shared : source.bytes=execution.keys.zeros.before) (safe : SourceSafe execution source) : KvCopy.Source next :=
  KvAppendMemory.reframe source execution.prepared.memory (execution.source_preserved source shared safe)

def Execution.append {key value : Row} (execution : Execution cache) (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value)
    (keyShared : keySource.bytes=execution.keys.zeros.before) (valueShared : valueSource.bytes=execution.keys.zeros.before)
    (keySafe : SourceSafe execution keySource) (valueSafe : SourceSafe execution valueSource) :
    KvCacheMemory.Execution cache key value :=
  KvPreparedMemory.append execution.prepared (execution.source keySource keyShared keySafe) (execution.source valueSource valueShared valueSafe)
    rfl rfl
    (by
      change MemoryRegions.Disjoint (2*execution.keyLayout.destination) (KvRegions.bytes (n+1)) keySource.base (KvAppendMemory.sourceBytes keySource)
      unfold KvRegions.bytes
      rw [execution.capacity_next]
      exact keySafe.keyDestination)
    (by
      change MemoryRegions.Disjoint (2*execution.valueLayout.destination) (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)
      unfold KvRegions.bytes
      rw [execution.capacity_next]
      exact valueSafe.valueDestination)
    (by
      change MemoryRegions.Disjoint (2*execution.keyLayout.destination) (KvRegions.bytes (n+1)) valueSource.base (KvAppendMemory.sourceBytes valueSource)
      unfold KvRegions.bytes
      rw [execution.capacity_next]
      exact valueSafe.keyDestination)

end Inference.State.KvGrowthPairMemory
