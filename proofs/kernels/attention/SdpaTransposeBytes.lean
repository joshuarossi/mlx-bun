import contracts.mlx.FloatMemory
import contracts.mlx.WriteOwnership
import contracts.mlx.ReadOnlyThreads

namespace Inference.Kernels.Attention.SdpaTransposeBytes
open Contracts.Mlx

abbrev Lanes := Fin 32 → Fin 32 → Float32
abbrev Label := Fin 32 × Fin 32
def labels : List Label := (List.finRange 32).product (List.finRange 32)

-- Writer (group,lane) stores at lane*32+group. The transposed reader
-- (group,lane) loads group*32+lane. Both coordinates are actual lane IDs.
def entry (base : Nat) (values : Lanes) (label : Label) : Memory.Store :=
  ⟨base/4+label.2.val*32+label.1.val, values label.1 label.2⟩
def programs (base : Nat) (values : Lanes) : List (List Memory.Store) :=
  labels.map (fun label => [entry base values label])

theorem member (base : Nat) (values : Lanes) (store : Memory.Store) (inside : store ∈ (programs base values).flatten) :
    ∃ label, store=entry base values label := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  exact ⟨label, List.mem_singleton.mp hs⟩

theorem covers (base : Nat) (values : Lanes) (group lane : Fin 32) :
    entry base values (lane, group) ∈ (programs base values).flatten := by
  apply List.mem_flatten.mpr
  exact ⟨[entry base values (lane, group)], List.mem_map.mpr
    ⟨(lane, group), List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, by simp⟩

theorem stored (base : Nat) (values : Lanes) (before : M1Max.WordMemory)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (group lane : Fin 32) :
    Memory.execute schedule before (base/4+group.val*32+lane.val)=values lane group := by
  apply ThreadgroupWrites.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨label, rfl⟩ := member base values store inside
    have first : label.1=lane := by
      apply Fin.ext
      simp only [entry] at same
      have := label.1.isLt
      have := label.2.isLt
      have := group.isLt
      have := lane.isLt
      omega
    have second : label.2=group := by
      apply Fin.ext
      simp only [entry] at same
      have := label.1.isLt
      have := label.2.isLt
      have := group.isLt
      have := lane.isLt
      omega
    simp only [entry, first, second]
  · exact ⟨entry base values (lane, group), covers base values group lane, rfl⟩

private def owner (base word : Nat) : Label :=
  (⟨(word-base/4)%32, by omega⟩, ⟨(word-base/4)/32%32, by omega⟩)

theorem separated (base : Nat) (values : Lanes) : WriteOwnership.Separated Memory.Store.word (programs base values) := by
  apply WriteOwnership.owned labels ((List.nodup_finRange 32).product (List.nodup_finRange 32)) _ _ (owner base)
  intro label _ store inside
  have equal := List.mem_singleton.mp inside
  subst store
  apply Prod.ext
  · apply Fin.ext
    simp only [owner, entry]
    have := label.1.isLt
    omega
  · apply Fin.ext
    simp only [owner, entry]
    have := label.1.isLt
    have := label.2.isLt
    omega

def loads (memory : ByteMemory.Bytes) (base thread : Nat) : Float32 :=
  FloatMemory.load memory (base+4*thread)

-- A completed write barrier exposes the transposed values. A second,
-- read-only phase must complete before the next iteration can overwrite
-- scratch. Register values are saved in readAfter at that second barrier.
structure Trace (values : Lanes) where
  before : ByteMemory.Bytes
  base : Nat
  aligned : base%4=0
  bounded : base+4096 ≤ 2^64
  schedule : List Memory.Store
  remaining : List (List Memory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  writeBarrier : ThreadgroupWrites.AtBarrier remaining
  readSchedule : List Nat
  readAfter : ReadOnlyThreads.State Float32
  reads : ReadOnlyThreads.Executes 1024 (loads (FloatMemory.execute schedule before) base)
    ReadOnlyThreads.initial readSchedule readAfter
  readBarrier : ReadOnlyThreads.AtBarrier 1024 readAfter

def Trace.canonical (values : Lanes) (before : ByteMemory.Bytes) (base : Nat)
    (aligned : base%4=0) (bounded : base+4096 ≤ 2^64) : Trace values :=
  let stores := programs base values
  let read := loads (FloatMemory.execute stores.flatten before) base
  ⟨before, base, aligned, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores,
    List.range 1024, ReadOnlyThreads.run read (List.range 1024) ReadOnlyThreads.initial,
    ReadOnlyThreads.canonical 1024 read, ReadOnlyThreads.canonical_barrier 1024 read⟩

def Trace.memory (trace : Trace values) : ByteMemory.Bytes := FloatMemory.execute trace.schedule trace.before
def Trace.register (trace : Trace values) (group lane : Fin 32) : Float32 :=
  (trace.readAfter (group.val*32+lane.val)).getD 0

theorem Trace.register_correct (trace : Trace values) (group lane : Fin 32) : trace.register group lane=values lane group := by
  unfold Trace.register
  rw [ReadOnlyThreads.completed trace.reads trace.readBarrier (group.val*32+lane.val) (by have := group.isLt; have := lane.isLt; omega)]
  simp only [Option.getD_some, loads]
  rw [FloatMemory.execute_load _ _ _ (by have := trace.aligned; omega),
    show (trace.base+4*(group.val*32+lane.val))/4=trace.base/4+group.val*32+lane.val by omega]
  exact stored trace.base values _ trace.schedule trace.remaining trace.execution trace.writeBarrier group lane

theorem Trace.read_bounds (trace : Trace values) (group lane : Fin 32) :
    let address := trace.base+4*(group.val*32+lane.val)
    address%4=0 ∧ trace.base ≤ address ∧ address+4 ≤ trace.base+4096 ∧ address+4 ≤ 2^64 := by
  have := trace.aligned
  have := trace.bounded
  have := group.isLt
  have := lane.isLt
  dsimp only
  omega

def Trace.reduce (trace : Trace values) (reduce : (Fin 32 → Float32) → Float32) (group : Fin 32) : Float32 :=
  reduce (trace.register group)

theorem Trace.reduce_correct (trace : Trace values) (reduce : (Fin 32 → Float32) → Float32) (group : Fin 32) :
    trace.reduce reduce group=reduce (fun lane => values lane group) := by
  unfold Trace.reduce
  apply congrArg reduce
  funext lane
  exact trace.register_correct group lane

end Inference.Kernels.Attention.SdpaTransposeBytes
