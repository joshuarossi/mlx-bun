import kernels.attention.SdpaTwoPassStorage
import contracts.mlx.MemoryCells
import contracts.mlx.WriteOwnership

namespace Inference.Kernels.Attention.SdpaTwoPassWrites
open Contracts.Mlx SdpaTwoPassLayout

-- Ordinary first-pass launch: six query heads for each KV head, 32 lanes
-- per head, and eight consecutive BF16 coordinates per lane. Only lane 0
-- writes each FP32 summary. The dispatch proof excludes the GQA variant.
abbrev Label (blocks : Nat) := Fin 24 × Fin blocks × Fin 32
def labels (blocks : Nat) : List (Label blocks) :=
  (List.finRange 24).product ((List.finRange blocks).product (List.finRange 32))

theorem labels_unique (blocks : Nat) : (labels blocks).Nodup :=
  (List.nodup_finRange 24).product ((List.nodup_finRange blocks).product (List.nodup_finRange 32))

theorem label_member (label : Label blocks) : label ∈ labels blocks :=
  List.mem_product.mpr ⟨List.mem_finRange _, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩⟩

def summaryEntry (base : Nat) (values : Fin 24 → Fin blocks → α) (label : Label blocks) : MemoryCells.Store α :=
  ⟨base+summaryAddress blocks label.1 label.2.1, values label.1 label.2.1⟩
def summaryThread (base : Nat) (values : Fin 24 → Fin blocks → α) (label : Label blocks) : List (MemoryCells.Store α) :=
  if label.2.2.val=0 then [summaryEntry base values label] else []
def summaryPrograms (base : Nat) (values : Fin 24 → Fin blocks → α) : List (List (MemoryCells.Store α)) :=
  (labels blocks).map (summaryThread base values)

theorem summary_member (base : Nat) (values : Fin 24 → Fin blocks → α) (store : MemoryCells.Store α)
    (inside : store ∈ (summaryPrograms base values).flatten) :
    ∃ label : Label blocks, label.2.2.val=0 ∧ store=summaryEntry base values label := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  unfold summaryThread at hs
  split at hs
  next active => exact ⟨label, active, List.mem_singleton.mp hs⟩
  next inactive => simp at hs

theorem summary_covers (base : Nat) (values : Fin 24 → Fin blocks → α) (head : Fin 24) (block : Fin blocks) :
    summaryEntry base values (head, block, 0) ∈ (summaryPrograms base values).flatten := by
  apply List.mem_flatten.mpr
  refine ⟨summaryThread base values (head, block, 0), List.mem_map.mpr ⟨(head, block, 0), label_member _, rfl⟩, ?_⟩
  simp [summaryThread]

theorem summary_value (base : Nat) (values : Fin 24 → Fin blocks → α) (head : Fin 24) (block : Fin blocks)
    (store : MemoryCells.Store α) (inside : store ∈ (summaryPrograms base values).flatten)
    (same : store.word=base+summaryAddress blocks head block) : store.value=values head block := by
  obtain ⟨label, _, rfl⟩ := summary_member base values store inside
  have address : summaryAddress blocks label.1 label.2.1=summaryAddress blocks head block := by
    simpa only [summaryEntry, Nat.add_left_cancel_iff] using same
  have inv := summary_inverse blocks label.1 label.2.1
  rw [address, (summary_inverse blocks head block).1, (summary_inverse blocks head block).2] at inv
  simp only [summaryEntry, ← Fin.ext inv.1, ← Fin.ext inv.2]

theorem summary_read (base : Nat) (values : Fin 24 → Fin blocks → α) (before : Nat → α)
    (schedule : List (MemoryCells.Store α)) (remaining : List (List (MemoryCells.Store α)))
    (execution : ThreadgroupWrites.Executes (summaryPrograms base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 24) (block : Fin blocks) :
    MemoryCells.execute schedule before (base+summaryAddress blocks head block)=values head block :=
  MemoryCells.completed_value execution completed before _ _
    (fun store inside same => summary_value base values head block store inside same)
    ⟨summaryEntry base values (head, block, 0), summary_covers base values head block, rfl⟩

def partialEntry (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) (label : Label blocks)
    (offset : Fin 8) : MemoryCells.Store α :=
  ⟨base+partialAddress blocks label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset),
    values label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset)⟩
def partialThread (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) (label : Label blocks) :
    List (MemoryCells.Store α) := List.ofFn (partialEntry base values label)
def partialPrograms (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) : List (List (MemoryCells.Store α)) :=
  (labels blocks).map (partialThread base values)

theorem partial_member (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) (store : MemoryCells.Store α)
    (inside : store ∈ (partialPrograms base values).flatten) :
    ∃ label : Label blocks, ∃ offset : Fin 8, store=partialEntry base values label offset := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  obtain ⟨offset, equal⟩ := List.mem_ofFn.mp hs
  exact ⟨label, offset, equal.symm⟩

theorem coordinate_inverse (i : Fin 256) :
    SdpaLayout.coordinate ⟨i.val/8, by omega⟩ ⟨i.val%8, by omega⟩=i := by
  apply Fin.ext
  simp only [SdpaLayout.coordinate]
  omega

theorem partial_covers (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    ∃ store ∈ (partialPrograms base values).flatten, store.word=base+partialAddress blocks head block i := by
  let label : Label blocks := (head, block, ⟨i.val/8, by omega⟩)
  let offset : Fin 8 := ⟨i.val%8, by omega⟩
  refine ⟨partialEntry base values label offset, List.mem_flatten.mpr
    ⟨partialThread base values label, List.mem_map.mpr ⟨label, label_member _, rfl⟩, List.mem_ofFn.mpr ⟨offset, rfl⟩⟩, ?_⟩
  simp only [partialEntry, label, offset, coordinate_inverse]

theorem partial_value (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) (store : MemoryCells.Store α)
    (inside : store ∈ (partialPrograms base values).flatten)
    (same : store.word=base+partialAddress blocks head block i) : store.value=values head block i := by
  obtain ⟨label, offset, rfl⟩ := partial_member base values store inside
  have address : partialAddress blocks label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset)=
      partialAddress blocks head block i := by simpa only [partialEntry, Nat.add_left_cancel_iff] using same
  obtain ⟨headEq, blockEq, indexEq⟩ := partial_unique blocks _ _ _ _ _ _ address
  simp only [partialEntry, headEq, blockEq, indexEq]

theorem partial_read (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) (before : Nat → α)
    (schedule : List (MemoryCells.Store α)) (remaining : List (List (MemoryCells.Store α)))
    (execution : ThreadgroupWrites.Executes (partialPrograms base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    MemoryCells.execute schedule before (base+partialAddress blocks head block i)=values head block i :=
  MemoryCells.completed_value execution completed before _ _
    (fun store inside same => partial_value base values head block i store inside same)
    (partial_covers base values head block i)

private def summaryOwner (positive : 0<blocks) (base word : Nat) : Label blocks :=
  (⟨((word-base)/blocks)%24, by omega⟩, ⟨(word-base)%blocks, Nat.mod_lt _ positive⟩, 0)

theorem summary_separated (positive : 0<blocks) (base : Nat) (values : Fin 24 → Fin blocks → α) :
    WriteOwnership.Separated MemoryCells.Store.word (summaryPrograms base values) := by
  apply WriteOwnership.owned (labels blocks) (labels_unique blocks) _ _ (summaryOwner positive base)
  intro label _ store inside
  unfold summaryThread at inside
  split at inside
  next active =>
    have equal := List.mem_singleton.mp inside
    subst store
    simp only [summaryOwner, summaryEntry, Nat.add_sub_cancel_left,
      (summary_inverse blocks label.1 label.2.1).1, (summary_inverse blocks label.1 label.2.1).2,
      Nat.mod_eq_of_lt label.1.isLt]
    apply Prod.ext
    · rfl
    · apply Prod.ext
      · rfl
      · apply Fin.ext
        exact active.symm
  next inactive => simp at inside

private def partialOwner (positive : 0<blocks) (base word : Nat) : Label blocks :=
  (⟨((word-base)/256/blocks)%24, by omega⟩,
    ⟨(word-base)/256%blocks, Nat.mod_lt _ positive⟩, ⟨(word-base)%256/8, by omega⟩)

theorem partial_separated (positive : 0<blocks) (base : Nat) (values : Fin 24 → Fin blocks → Fin 256 → α) :
    WriteOwnership.Separated MemoryCells.Store.word (partialPrograms base values) := by
  apply WriteOwnership.owned (labels blocks) (labels_unique blocks) _ _ (partialOwner positive base)
  intro label _ store inside
  obtain ⟨offset, rfl⟩ := List.mem_ofFn.mp inside
  have coordinate : (SdpaLayout.coordinate label.2.2 offset).val/8=label.2.2.val := by
    simp only [SdpaLayout.coordinate]
    omega
  simp only [partialOwner, partialEntry, Nat.add_sub_cancel_left,
    (SdpaTwoPassStorage.partial_inverse blocks label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset)).1,
    (SdpaTwoPassStorage.partial_inverse blocks label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset)).2,
    (summary_inverse blocks label.1 label.2.1).1, (summary_inverse blocks label.1 label.2.1).2,
    Nat.mod_eq_of_lt label.1.isLt, coordinate]

end Inference.Kernels.Attention.SdpaTwoPassWrites
