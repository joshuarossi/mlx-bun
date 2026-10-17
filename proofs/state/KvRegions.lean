import state.KvAllocation
import contracts.mlx.ArrayFrame

namespace Inference.State.KvRegions
open Contracts.Mlx
set_option maxRecDepth 10000

def bytes (n : Nat) : Nat := 2*(4*KvAllocation.capacity n*256)

structure Layout (n : Nat) where
  keyBase : Nat
  valueBase : Nat
  keyAligned : keyBase%2=0
  valueAligned : valueBase%2=0
  keyBound : keyBase+bytes n ≤ 2^64
  valueBound : valueBase+bytes n ≤ 2^64
  separate : MemoryRegions.Disjoint keyBase (bytes n) valueBase (bytes n)

structure Storage (cache : Kv.Cache Kv.BF n) where
  layout : Layout n
  memory : ByteMemory.Bytes
  keys : ∀ head time i, HalfMemory.load memory
    (layout.keyBase+2*Kv.address (KvAllocation.capacity n) head time.val i)=KvBytes.bits (cache.keys head time i)
  values : ∀ head time i, HalfMemory.load memory
    (layout.valueBase+2*Kv.address (KvAllocation.capacity n) head time.val i)=KvBytes.bits (cache.values head time i)

variable {n : Nat} {cache : Kv.Cache Kv.BF n}

-- Existing KV traces use addresses relative to each allocation. The local
-- views below are projections of one shared memory at the actual bases.
def Storage.local (storage : Storage cache) : KvAllocation.Storage cache where
  keys := MemoryRegions.view storage.memory storage.layout.keyBase
  values := MemoryRegions.view storage.memory storage.layout.valueBase
  keysAttached := by
    intro head time i
    rw [MemoryRegions.load16_view]
    exact storage.keys head time i
  valuesAttached := by
    intro head time i
    rw [MemoryRegions.load16_view]
    exact storage.values head time i

theorem active_bounds (head : Fin 4) (time : Fin n) (i : Fin 256) :
    2*Kv.address (KvAllocation.capacity n) head time.val i+2 ≤ bytes n := by
  have bound := Kv.address_bounds (KvAllocation.capacity n) head time.val i (time.isLt.trans_le (KvAllocation.capacity_bounds n).1)
  unfold bytes
  omega

theorem Storage.key_load (storage : Storage cache) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load storage.local.keys (2*Kv.address (KvAllocation.capacity n) head time.val i)=
      HalfMemory.load storage.memory (storage.layout.keyBase+2*Kv.address (KvAllocation.capacity n) head time.val i) :=
  MemoryRegions.load16_view _ _ _

theorem Storage.value_load (storage : Storage cache) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load storage.local.values (2*Kv.address (KvAllocation.capacity n) head time.val i)=
      HalfMemory.load storage.memory (storage.layout.valueBase+2*Kv.address (KvAllocation.capacity n) head time.val i) :=
  MemoryRegions.load16_view _ _ _

def Storage.reframe (storage : Storage cache) (after : ByteMemory.Bytes)
    (keys : ∀ offset < bytes n, after (storage.layout.keyBase+offset)=storage.memory (storage.layout.keyBase+offset))
    (values : ∀ offset < bytes n, after (storage.layout.valueBase+offset)=storage.memory (storage.layout.valueBase+offset)) :
    Storage cache where
  layout := storage.layout
  memory := after
  keys := by
    intro head time i
    rw [ArrayFrame.half_congr storage.memory after storage.layout.keyBase (bytes n) _ keys (active_bounds head time i)]
    exact storage.keys head time i
  values := by
    intro head time i
    rw [ArrayFrame.half_congr storage.memory after storage.layout.valueBase (bytes n) _ values (active_bounds head time i)]
    exact storage.values head time i

def Storage.after32 (storage : Storage cache) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (keysSeparate : MemoryRegions.Disjoint base size storage.layout.keyBase (bytes n))
    (valuesSeparate : MemoryRegions.Disjoint base size storage.layout.valueBase (bytes n)) : Storage cache :=
  storage.reframe (ByteMemory.execute stores storage.memory)
    (MemoryRegions.execute32_other _ _ inside keysSeparate)
    (MemoryRegions.execute32_other _ _ inside valuesSeparate)

def Storage.after16 (storage : Storage cache) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores)
    (keysSeparate : MemoryRegions.Disjoint base size storage.layout.keyBase (bytes n))
    (valuesSeparate : MemoryRegions.Disjoint base size storage.layout.valueBase (bytes n)) : Storage cache :=
  storage.reframe (HalfMemory.execute stores storage.memory)
    (MemoryRegions.execute16_other _ _ inside keysSeparate)
    (MemoryRegions.execute16_other _ _ inside valuesSeparate)

theorem Storage.after32_memory (storage : Storage cache) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (keysSeparate : MemoryRegions.Disjoint base size storage.layout.keyBase (bytes n))
    (valuesSeparate : MemoryRegions.Disjoint base size storage.layout.valueBase (bytes n)) :
    (storage.after32 stores inside keysSeparate valuesSeparate).memory=ByteMemory.execute stores storage.memory := rfl

theorem Storage.key_addressable (storage : Storage cache) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    (storage.layout.keyBase+2*Kv.address (KvAllocation.capacity n) head time.val i)%2=0 ∧
      storage.layout.keyBase+2*Kv.address (KvAllocation.capacity n) head time.val i+2 ≤ 2^64 := by
  have := storage.layout.keyAligned
  have := storage.layout.keyBound
  have := active_bounds head time i
  omega

end Inference.State.KvRegions
