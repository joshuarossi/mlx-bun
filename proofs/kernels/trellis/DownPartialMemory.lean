import contracts.mlx.FloatMemory
import contracts.mlx.WriteOwnership
import kernels.trellis.DownCodebook

namespace Inference.Kernels.Trellis.DownPartialMemory
open Contracts.Mlx Contracts.Mlx.M1Max

def entry (base : Nat) (partials : Nat → Nat → Float32) (group thread iteration : Nat) : Memory.Store :=
  let column := thread+256*iteration
  ⟨base/4+group%32*5120+DownCodebook.column group column, partials group column⟩

def programs (base : Nat) (partials : Nat → Nat → Float32) : List (List Memory.Store) :=
  ((List.range 160).product (List.range 256)).map fun pair =>
    (List.range 4).map (entry base partials pair.1 pair.2)

theorem member (base : Nat) (partials : Nat → Nat → Float32) (store : Memory.Store)
    (inside : store ∈ (programs base partials).flatten) :
    ∃ group thread iteration, group<160 ∧ thread<256 ∧ iteration<4 ∧ store=entry base partials group thread iteration := by
  obtain ⟨threadStores, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨pair, hp, rfl⟩ := List.mem_map.mp ht
  obtain ⟨hg, hthread⟩ := List.mem_product.mp hp
  obtain ⟨iteration, hi, equal⟩ := List.mem_map.mp hs
  exact ⟨pair.1, pair.2, iteration, List.mem_range.mp hg, List.mem_range.mp hthread, List.mem_range.mp hi, equal.symm⟩

theorem entry_member (base : Nat) (partials : Nat → Nat → Float32) (group thread iteration : Nat)
    (hg : group<160) (ht : thread<256) (hi : iteration<4) :
    entry base partials group thread iteration ∈ (programs base partials).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨_, List.mem_map.mpr ⟨(group, thread), List.mem_product.mpr ⟨List.mem_range.mpr hg, List.mem_range.mpr ht⟩, rfl⟩, ?_⟩
  exact List.mem_map.mpr ⟨iteration, List.mem_range.mpr hi, rfl⟩

theorem bounds (base : Nat) (partials : Nat → Nat → Float32) (group thread iteration : Nat)
    (hg : group<160) (ht : thread<256) (hi : iteration<4) :
    base/4 ≤ (entry base partials group thread iteration).word ∧
      (entry base partials group thread iteration).word<base/4+32*5120 := by
  have bound := DownCodebook.partial_bounds group (thread+256*iteration) hg (by omega)
  simp only [entry]
  omega

theorem address_decode (base : Nat) (partials : Nat → Nat → Float32) (group thread iteration y column : Nat)
    (hg : group<160) (ht : thread<256) (hi : iteration<4) (_hy : y<32) (hc : column<5120)
    (equal : (entry base partials group thread iteration).word=base/4+y*5120+column) :
    group=32*(column/1024)+y ∧ thread+256*iteration=column%1024 := by
  have bound := DownCodebook.partial_bounds group (thread+256*iteration) hg (by omega)
  have inverse := DownCodebook.partial_inverse group (thread+256*iteration) hg (by omega)
  simp only [entry] at equal
  have sameColumn : DownCodebook.column group (thread+256*iteration)=column := by omega
  have sameY : group%32=y := by omega
  rw [sameColumn, sameY] at inverse
  exact ⟨inverse.1.symm, inverse.2.symm⟩

theorem covers (base : Nat) (partials : Nat → Nat → Float32) (y column : Nat) (hy : y<32) (hc : column<5120) :
    ∃ store ∈ (programs base partials).flatten, store.word=base/4+y*5120+column := by
  obtain ⟨groupBound, localBound, sameY, sameColumn⟩ := DownCodebook.partial_coverage y column hy hc
  refine ⟨entry base partials (32*(column/1024)+y) (column%1024%256) (column%1024/256),
    entry_member base partials _ _ _ groupBound (by omega) (by omega), ?_⟩
  simp only [entry, show column%1024%256+256*(column%1024/256)=column%1024 by omega, sameY, sameColumn]

theorem correct_value (base : Nat) (partials : Nat → Nat → Float32) (y column : Nat) (hy : y<32) (hc : column<5120)
    (store : Memory.Store) (inside : store ∈ (programs base partials).flatten)
    (equal : store.word=base/4+y*5120+column) : store.value=partials (32*(column/1024)+y) (column%1024) := by
  obtain ⟨group, thread, iteration, hg, ht, hi, rfl⟩ := member base partials store inside
  obtain ⟨sameGroup, sameColumn⟩ := address_decode base partials group thread iteration y column hg ht hi hy hc equal
  simp only [entry, sameGroup, sameColumn]

-- Completion here is the device-dispatch dependency before the fold launch,
-- not a hardware threadgroup barrier spanning distinct threadgroups.
theorem stored (before : WordMemory) (base : Nat) (partials : Nat → Nat → Float32)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base partials) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (y column : Nat) (hy : y<32) (hc : column<5120) :
    Memory.execute schedule before (base/4+y*5120+column)=partials (32*(column/1024)+y) (column%1024) :=
  ThreadgroupWrites.completed_value execution completed before _ _
    (fun store inside equal => correct_value base partials y column hy hc store inside equal) (covers base partials y column hy hc)

theorem stored_bytes (before : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (partials : Nat → Nat → Float32)
    (schedule : List Memory.Store) (remaining : List (List Memory.Store))
    (execution : ThreadgroupWrites.Executes (programs base partials) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (y column : Nat) (hy : y<32) (hc : column<5120) :
    FloatMemory.load (FloatMemory.execute schedule before) (base+4*(y*5120+column))=
      partials (32*(column/1024)+y) (column%1024) := by
  rw [FloatMemory.execute_load _ _ _ (by omega), show (base+4*(y*5120+column))/4=base/4+y*5120+column by omega]
  exact stored (FloatMemory.view before) base partials schedule remaining execution completed y column hy hc

private def owner (base word : Nat) : Nat × Nat :=
  let j := word-base/4
  (32*((j%5120)/1024)+j/5120, (j%5120%1024)%256)

theorem separated (base : Nat) (partials : Nat → Nat → Float32) :
    Contracts.Mlx.WriteOwnership.Separated Memory.Store.word (programs base partials) := by
  unfold programs
  apply Contracts.Mlx.WriteOwnership.owned _
    ((show (List.range 160).Nodup from List.nodup_range).product (show (List.range 256).Nodup from List.nodup_range)) _ _ (owner base)
  intro pair hp store hs
  obtain ⟨group, thread⟩ := pair
  obtain ⟨hg, ht⟩ := List.mem_product.mp hp
  obtain ⟨iteration, hi, rfl⟩ := List.mem_map.mp hs
  have groupBound := List.mem_range.mp hg
  have threadBound := List.mem_range.mp ht
  have iterationBound := List.mem_range.mp hi
  have bound := DownCodebook.partial_bounds group (thread+256*iteration) groupBound (by omega)
  have inverse := DownCodebook.partial_inverse group (thread+256*iteration) groupBound (by omega)
  simp only [owner, entry]
  have difference : base/4+group%32*5120+DownCodebook.column group (thread+256*iteration)-base/4=
      group%32*5120+DownCodebook.column group (thread+256*iteration) := by omega
  rw [difference, show (group%32*5120+DownCodebook.column group (thread+256*iteration))%5120=
    DownCodebook.column group (thread+256*iteration) by omega,
    show (group%32*5120+DownCodebook.column group (thread+256*iteration))/5120=group%32 by omega,
    inverse.1, inverse.2, show (thread+256*iteration)%256=thread by omega]

end Inference.Kernels.Trellis.DownPartialMemory
