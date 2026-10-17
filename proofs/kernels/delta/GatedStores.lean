import kernels.delta.Layout
import contracts.mlx.MemoryCells
import contracts.mlx.WriteOwnership
import Mathlib.Data.List.ProdSigma

namespace Inference.Kernels.Delta.GatedStores
open Contracts.Mlx

-- B=T=1, grid=(32,128,48), threadgroup=(32,4,1). Each SIMD row has
-- 32 lanes; all lanes store four FP32 state cells and lane zero stores y.
abbrev Label := Fin 48 × Fin 128 × Fin 32
def labels : List Label := (List.finRange 48).product ((List.finRange 128).product (List.finRange 32))
def stateIndex (head : Fin 48) (row key : Fin 128) : Nat := (head.val*128+row.val)*128+key.val
def outputIndex (head : Fin 48) (row : Fin 128) : Nat := head.val*128+row.val

theorem state_unique (a b : Fin 48) (u v i j : Fin 128) (same : stateIndex a u i=stateIndex b v j) :
    a=b ∧ u=v ∧ i=j := by
  have := u.isLt; have := v.isLt; have := i.isLt; have := j.isLt
  unfold stateIndex at same
  exact ⟨Fin.ext (by omega), Fin.ext (by omega), Fin.ext (by omega)⟩

theorem output_unique (a b : Fin 48) (u v : Fin 128) (same : outputIndex a u=outputIndex b v) : a=b ∧ u=v := by
  have := u.isLt; have := v.isLt
  unfold outputIndex at same
  exact ⟨Fin.ext (by omega), Fin.ext (by omega)⟩

theorem state_bounds (head : Fin 48) (row key : Fin 128) : stateIndex head row key<786432 := by
  have := head.isLt; have := row.isLt; have := key.isLt
  unfold stateIndex
  omega

theorem output_bounds (head : Fin 48) (row : Fin 128) : outputIndex head row<6144 := by
  have := head.isLt; have := row.isLt
  unfold outputIndex
  omega

theorem state_layout (head : Fin 48) (row key : Fin 128) :
    stateIndex head row key=Layout.stateIndex (batchSize := 1) ⟨⟨0, by decide⟩, head, row⟩ key := by
  simp only [stateIndex, Layout.stateIndex, Layout.rowIndex, Nat.zero_mul, Nat.zero_add]

theorem simd_geometry (row : Fin 128) (lane : Fin 32) :
    (row.val/4)*4+row.val%4=row.val ∧ row.val/4<32 ∧
      ((row.val%4)*32+lane.val)%32=lane.val ∧ ((row.val%4)*32+lane.val)/32=row.val%4 := by
  have := row.isLt; have := lane.isLt
  omega

def stateEntry (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) (label : Label) (offset : Fin 4) : MemoryCells.Store α :=
  ⟨base+stateIndex label.1 label.2.1 (Gated.laneIndex label.2.2 offset), values label.1 label.2.1 (Gated.laneIndex label.2.2 offset)⟩
def stateThread (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) (label : Label) : List (MemoryCells.Store α) :=
  (List.finRange 4).map (stateEntry base values label)
def statePrograms (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) : List (List (MemoryCells.Store α)) :=
  labels.map (stateThread base values)

def outputEntry (base : Nat) (values : Fin 48 → Fin 128 → α) (label : Label) : MemoryCells.Store α :=
  ⟨base+outputIndex label.1 label.2.1, values label.1 label.2.1⟩
def outputThread (base : Nat) (values : Fin 48 → Fin 128 → α) (label : Label) : List (MemoryCells.Store α) :=
  if label.2.2.val=0 then [outputEntry base values label] else []
def outputPrograms (base : Nat) (values : Fin 48 → Fin 128 → α) : List (List (MemoryCells.Store α)) :=
  labels.map (outputThread base values)

theorem label_member (label : Label) : label ∈ labels :=
  List.mem_product.mpr ⟨List.mem_finRange _, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩⟩

theorem state_member (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) (store : MemoryCells.Store α)
    (inside : store ∈ (statePrograms base values).flatten) : ∃ label offset, store=stateEntry base values label offset := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp hs
  exact ⟨label, offset, rfl⟩

theorem output_member (base : Nat) (values : Fin 48 → Fin 128 → α) (store : MemoryCells.Store α)
    (inside : store ∈ (outputPrograms base values).flatten) : ∃ label, store=outputEntry base values label ∧ label.2.2.val=0 := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  unfold outputThread at hs
  split at hs
  · exact ⟨label, List.mem_singleton.mp hs, by assumption⟩
  · simp at hs

theorem state_covers (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) (head : Fin 48) (row key : Fin 128) :
    ∃ store ∈ (statePrograms base values).flatten, store.word=base+stateIndex head row key := by
  let lane : Fin 32 := ⟨key.val/4, by have := key.isLt; omega⟩
  let offset : Fin 4 := ⟨key.val%4, by omega⟩
  let label : Label := (head, row, lane)
  refine ⟨stateEntry base values label offset, ?_, ?_⟩
  · exact List.mem_flatten.mpr ⟨stateThread base values label, List.mem_map.mpr ⟨label, label_member label, rfl⟩,
      List.mem_map.mpr ⟨offset, List.mem_finRange _, rfl⟩⟩
  · have inverse : Gated.laneIndex lane offset=key := by apply Fin.ext; dsimp [Gated.laneIndex, lane, offset]; omega
    simp only [stateEntry, label, inverse]

theorem output_covers (base : Nat) (values : Fin 48 → Fin 128 → α) (head : Fin 48) (row : Fin 128) :
    ∃ store ∈ (outputPrograms base values).flatten, store.word=base+outputIndex head row := by
  let label : Label := (head, row, ⟨0, by decide⟩)
  refine ⟨outputEntry base values label, ?_, rfl⟩
  exact List.mem_flatten.mpr ⟨outputThread base values label, List.mem_map.mpr ⟨label, label_member label, rfl⟩,
    by simp [outputThread, label]⟩

theorem state_stored (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) (before : Nat → α)
    (schedule : List (MemoryCells.Store α)) (remaining : List (List (MemoryCells.Store α)))
    (execution : ThreadgroupWrites.Executes (statePrograms base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 48) (row key : Fin 128) :
    MemoryCells.execute schedule before (base+stateIndex head row key)=values head row key := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨label, offset, rfl⟩ := state_member base values store inside
    obtain ⟨a, b, c⟩ := state_unique label.1 head label.2.1 row (Gated.laneIndex label.2.2 offset) key (Nat.add_left_cancel same)
    simp only [stateEntry, a, b, c]
  · exact state_covers base values head row key

theorem output_stored (base : Nat) (values : Fin 48 → Fin 128 → α) (before : Nat → α)
    (schedule : List (MemoryCells.Store α)) (remaining : List (List (MemoryCells.Store α)))
    (execution : ThreadgroupWrites.Executes (outputPrograms base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 48) (row : Fin 128) :
    MemoryCells.execute schedule before (base+outputIndex head row)=values head row := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨label, rfl, _⟩ := output_member base values store inside
    obtain ⟨a, b⟩ := output_unique label.1 head label.2.1 row (Nat.add_left_cancel same)
    simp only [outputEntry, a, b]
  · exact output_covers base values head row

private def stateOwner (base word : Nat) : Label :=
  (⟨(word-base)/16384%48, by omega⟩, ⟨(word-base)/128%128, by omega⟩, ⟨(word-base)%128/4, by omega⟩)

private def outputOwner (base word : Nat) : Label :=
  (⟨(word-base)/128%48, by omega⟩, ⟨(word-base)%128, by omega⟩, ⟨0, by decide⟩)

theorem state_separated (base : Nat) (values : Fin 48 → Fin 128 → Fin 128 → α) :
    WriteOwnership.Separated MemoryCells.Store.word (statePrograms base values) := by
  apply WriteOwnership.owned labels ((List.nodup_finRange 48).product ((List.nodup_finRange 128).product (List.nodup_finRange 32))) _ _ (stateOwner base)
  intro label _ store inside
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp inside
  have := label.1.isLt; have := label.2.1.isLt; have := label.2.2.isLt; have := offset.isLt
  apply Prod.ext
  · apply Fin.ext; dsimp [stateOwner, stateEntry, stateIndex, Gated.laneIndex]; omega
  · apply Prod.ext <;> apply Fin.ext <;> dsimp [stateOwner, stateEntry, stateIndex, Gated.laneIndex] <;> omega

theorem output_separated (base : Nat) (values : Fin 48 → Fin 128 → α) :
    WriteOwnership.Separated MemoryCells.Store.word (outputPrograms base values) := by
  apply WriteOwnership.owned labels ((List.nodup_finRange 48).product ((List.nodup_finRange 128).product (List.nodup_finRange 32))) _ _ (outputOwner base)
  intro label _ store inside
  unfold outputThread at inside
  split at inside
  · have same := List.mem_singleton.mp inside
    subst store
    have := label.1.isLt; have := label.2.1.isLt
    apply Prod.ext
    · apply Fin.ext; dsimp [outputOwner, outputEntry, outputIndex]; omega
    · apply Prod.ext <;> apply Fin.ext <;> dsimp [outputOwner, outputEntry, outputIndex] <;> omega
  · simp at inside

end Inference.Kernels.Delta.GatedStores
