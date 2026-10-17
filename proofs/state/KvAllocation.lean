import state.KvBytes

namespace Inference.State.KvAllocation
open Contracts.Mlx
open KvBytes
set_option maxRecDepth 10000

-- KVCache.updateAndFetch with L=1, starting empty and without trimming or
-- restoring an external cache. These are host allocation/slice semantics;
-- native allocation, concat and copy kernels still owe their refinements.
def capacity (n : Nat) : Nat := ((n+255)/256)*256

theorem capacity_bounds (n : Nat) : n ≤ capacity n ∧ capacity n < n+256 := by
  unfold capacity
  omega

theorem capacity_zero : capacity 0=0 := by decide +kernel

theorem capacity_multiple (n : Nat) : capacity n%256=0 := by
  unfold capacity
  omega

theorem growth_iff (n : Nat) : capacity n<n+1 ↔ n%256=0 := by
  unfold capacity
  omega

theorem growth_full (n : Nat) (growth : capacity n<n+1) : capacity n=n := by
  have := capacity_bounds n
  omega

theorem next_capacity (n : Nat) :
    capacity (n+1)=if capacity n<n+1 then capacity n+256 else capacity n := by
  unfold capacity
  split <;> omega

theorem no_trim_on_growth (n : Nat) (growth : capacity n<n+1) : n%256=0 :=
  (growth_iff n).mp growth

theorem supported_capacity (n : Nat) (supported : n ≤ 262144) : capacity n ≤ 262144 := by
  unfold capacity
  omega

-- concatAxis(..., 2) repacks each head at its new stride. Reinterpreting
-- the old flat buffer at the new stride would not preserve the cache.
def concatWords (oldCapacity : Nat) (before : HalfMemory.Words) (word : Nat) : BitVec 16 :=
  let head : Fin 4 := ⟨word/256/(oldCapacity+256)%4, by omega⟩
  let time := word/256%(oldCapacity+256)
  let i : Fin 256 := ⟨word%256, by omega⟩
  if time<oldCapacity then before (Kv.address oldCapacity head time i) else 0

theorem concat_old (oldCapacity : Nat) (before : HalfMemory.Words)
    (head : Fin 4) (time : Nat) (active : time<oldCapacity) (i : Fin 256) :
    concatWords oldCapacity before (Kv.address (oldCapacity+256) head time i)=
      before (Kv.address oldCapacity head time i) := by
  have room : time<oldCapacity+256 := by omega
  simp only [concatWords, Kv.address_head _ _ _ _ room, Kv.address_time _ _ _ _ room,
    Kv.address_coordinate, Nat.mod_eq_of_lt head.isLt, active, ↓reduceIte]

theorem concat_zero (oldCapacity : Nat) (before : HalfMemory.Words)
    (head : Fin 4) (time : Nat) (newRow : oldCapacity ≤ time) (room : time<oldCapacity+256) (i : Fin 256) :
    concatWords oldCapacity before (Kv.address (oldCapacity+256) head time i)=0 := by
  have inactive : ¬ time<oldCapacity := by omega
  simp only [concatWords, Kv.address_time _ _ _ _ room, inactive, ↓reduceIte]

def prepare (n : Nat) (before : HalfMemory.Bytes) : HalfMemory.Bytes :=
  if capacity n<n+1 then HalfMemory.encode (concatWords (capacity n) (HalfMemory.view before)) else before

def Attached (before : HalfMemory.Bytes) (old : History n) : Prop :=
  ∀ head time i, HalfMemory.load before (2*Kv.address (capacity n) head time.val i)=bits (old head time i)

theorem prepare_attached (before : HalfMemory.Bytes) (old : History n) (attached : Attached before old)
    (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load (prepare n before) (2*Kv.address (capacity (n+1)) head time.val i)=bits (old head time i) := by
  unfold prepare
  rw [next_capacity]
  split
  · rw [HalfMemory.load_encode _ _ (by omega),
      show 2*Kv.address (capacity n+256) head time.val i/2=Kv.address (capacity n+256) head time.val i by omega,
      concat_old _ _ _ _ (time.isLt.trans_le (capacity_bounds n).1)]
    exact attached head time i
  · exact attached head time i

def appendTrace (before : HalfMemory.Bytes) (old : History n) (attached : Attached before old) (next : Row) : KvBytes.Trace old next where
  capacity := capacity (n+1)
  room := Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (capacity_bounds (n+1)).1
  before := prepare n before
  base := 0
  aligned := by decide
  attached := by
    intro head time i
    simpa only [Nat.zero_add] using prepare_attached before old attached head time i
  schedule := (programs 0 (capacity (n+1)) n next).flatten
  remaining := List.replicate (programs 0 (capacity (n+1)) n next).length []
  execution := ThreadgroupWrites.canonical _
  completed := ThreadgroupWrites.canonical_barrier _

def canonical (old : History n) (next : Row) : KvBytes.Trace old next :=
  appendTrace (HalfMemory.encode (initialWords (capacity n) old)) old
    (initial_attached (capacity n) (capacity_bounds n).1 old) next

theorem canonical_capacity (old : History n) (next : Row) : (canonical old next).capacity=capacity (n+1) := rfl

theorem canonical_addressable (old : History n) (next : Row) (supported : n+1 ≤ 262144) :
    (canonical old next).base+2*(4*(canonical old next).capacity*256) ≤ 2^64 := by
  change 0+2*(4*capacity (n+1)*256) ≤ 2^64
  have := supported_capacity (n+1) supported
  omega

def execution (old : Kv.Cache BF n) (key value : Row) : KvBytes.Execution old key value :=
  ⟨canonical old.keys key, canonical old.values value⟩

structure Storage (cache : Kv.Cache BF n) where
  keys : HalfMemory.Bytes
  values : HalfMemory.Bytes
  keysAttached : Attached keys cache.keys
  valuesAttached : Attached values cache.values

def Storage.canonical (cache : Kv.Cache BF n) : Storage cache where
  keys := HalfMemory.encode (initialWords (capacity n) cache.keys)
  values := HalfMemory.encode (initialWords (capacity n) cache.values)
  keysAttached := initial_attached (capacity n) (capacity_bounds n).1 cache.keys
  valuesAttached := initial_attached (capacity n) (capacity_bounds n).1 cache.values

variable {n : Nat} {cache : Kv.Cache BF n}

def Storage.trace (storage : Storage cache) (key value : Row) : KvBytes.Execution cache key value :=
  ⟨appendTrace storage.keys cache.keys storage.keysAttached key,
    appendTrace storage.values cache.values storage.valuesAttached value⟩

def Storage.advance (storage : Storage cache) (key value : Row) : Storage (Kv.append cache key value) where
  keys := (storage.trace key value).keys.memory
  values := (storage.trace key value).values.memory
  keysAttached := by
    intro head time i
    simpa only [Storage.trace, appendTrace, Kv.append, Nat.zero_add] using (storage.trace key value).keys.load_correct head time i
  valuesAttached := by
    intro head time i
    simpa only [Storage.trace, appendTrace, Kv.append, Nat.zero_add] using (storage.trace key value).values.load_correct head time i

theorem advance_keys (storage : Storage cache) (key value : Row) :
    (storage.advance key value).keys=(storage.trace key value).keys.memory := rfl

theorem advance_values (storage : Storage cache) (key value : Row) :
    (storage.advance key value).values=(storage.trace key value).values.memory := rfl

theorem advance_read (storage : Storage cache) (key value : Row) :
    KvBytes.cacheAfter (storage.trace key value)=Kv.append cache key value :=
  KvBytes.cacheAfter_eq _

end Inference.State.KvAllocation
