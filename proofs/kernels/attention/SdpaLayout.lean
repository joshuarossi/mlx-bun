import contracts.mlx.Memory
import Mathlib.Data.List.FinRange
import Mathlib.Data.List.Nodup

namespace Inference.Kernels.Attention.SdpaLayout
open Contracts.Mlx

-- One-pass sdpa_vector: group g visits g, g+32, ... while the key is < N.
-- Empty groups remain empty, including when N is smaller than 32.
def count (steps : Nat) (group : Fin 32) : Nat := (steps+31-group.val)/32

def key (steps : Nat) (group : Fin 32) (ordinal : Fin (count steps group)) : Fin steps :=
  ⟨group.val + 32*ordinal.val, by
    have := group.isLt
    have := ordinal.isLt
    unfold count at this
    omega⟩

def keys (steps : Nat) (group : Fin 32) : List (Fin steps) := List.ofFn (key steps group)
def allKeys (steps : Nat) : List (Fin steps) := (List.finRange 32).flatMap (keys steps)

theorem key_stride (steps : Nat) (group : Fin 32) (i : Fin (count steps group)) :
    (key steps group i).val = group.val + 32*i.val := rfl

theorem first_outside (steps : Nat) (group : Fin 32) : steps ≤ group.val + 32*count steps group := by
  have := group.isLt
  unfold count
  omega

theorem key_owner (steps : Nat) (group : Fin 32) (i : Fin (count steps group)) :
    (key steps group i).val % 32 = group.val ∧ (key steps group i).val / 32 = i.val := by
  have := group.isLt
  dsimp [key]
  omega

theorem keys_mem (steps : Nat) (group : Fin 32) (i : Fin steps) : i ∈ keys steps group ↔ i.val % 32 = group.val := by
  unfold keys
  rw [List.mem_ofFn]
  constructor
  · rintro ⟨j, rfl⟩
    exact (key_owner steps group j).1
  · intro hi
    have hg := group.isLt
    have hidx := i.isLt
    have hj : i.val/32 < count steps group := by unfold count; omega
    refine ⟨⟨i.val/32, hj⟩, ?_⟩
    apply Fin.ext
    dsimp [key]
    omega

theorem keys_nodup (steps : Nat) (group : Fin 32) : (keys steps group).Nodup := by
  apply List.nodup_ofFn_ofInjective
  intro i j h
  apply Fin.ext
  have hi := (key_owner steps group i).2
  have hj := (key_owner steps group j).2
  rw [h] at hi
  exact hi.symm.trans hj

theorem keys_disjoint (steps : Nat) (a b : Fin 32) (hne : a ≠ b) : (keys steps a).Disjoint (keys steps b) := by
  apply List.disjoint_left.mpr
  intro i ha hb
  have ha := (keys_mem steps a i).mp ha
  have hb := (keys_mem steps b i).mp hb
  exact hne (Fin.ext (ha.symm.trans hb))

theorem allKeys_nodup (steps : Nat) : (allKeys steps).Nodup := by
  apply List.nodup_flatMap.mpr
  constructor
  · intro group _; exact keys_nodup steps group
  · exact (List.nodup_finRange 32).imp (fun {_ _} h => keys_disjoint steps _ _ h)

theorem allKeys_mem (steps : Nat) (i : Fin steps) : i ∈ allKeys steps := by
  apply List.mem_flatMap.mpr
  refine ⟨⟨i.val%32, by omega⟩, List.mem_finRange _, ?_⟩
  exact (keys_mem steps _ i).mpr rfl

theorem coverage (steps : Nat) : (allKeys steps).Perm (List.finRange steps) := by
  apply (List.perm_ext_iff_of_nodup (allKeys_nodup steps) (List.nodup_finRange steps)).mpr
  intro i
  exact ⟨fun _ => List.mem_finRange i, fun _ => allKeys_mem steps i⟩

theorem nonempty (steps : Nat) (hn : 0 < steps) : allKeys steps ≠ [] := by
  intro he
  have h := allKeys_mem steps ⟨0, hn⟩
  rw [he] at h
  exact List.not_mem_nil h

-- The scratch array transposes (group, lane). On the read side each lane
-- contributes one group's partial for the output coordinate owned by the
-- reader group. All 1024 scratch cells have one writer.
def scratch (group lane : Fin 32) : Nat := lane.val*32+group.val

theorem scratch_bounds (group lane : Fin 32) : scratch group lane < 1024 := by
  have := group.isLt
  have := lane.isLt
  unfold scratch
  omega

theorem scratch_inverse (group lane : Fin 32) : scratch group lane % 32 = group.val ∧ scratch group lane / 32 = lane.val := by
  have := group.isLt
  unfold scratch
  omega

theorem scratch_unique (g1 l1 g2 l2 : Fin 32) (he : scratch g1 l1 = scratch g2 l2) : g1 = g2 ∧ l1 = l2 := by
  have h1 := scratch_inverse g1 l1
  have h2 := scratch_inverse g2 l2
  rw [he] at h1
  exact ⟨Fin.ext (h1.1.symm.trans h2.1), Fin.ext (h1.2.symm.trans h2.2)⟩

def stored (partials : Fin 32 → Fin 32 → α) (before : Nat → α) (schedule : List Nat) : Nat → α :=
  Memory.writeCells (fun j => partials ⟨j%32, by omega⟩ ⟨j/32%32, by omega⟩) schedule before

theorem scratch_read (partials : Fin 32 → Fin 32 → α) (before : Nat → α) (schedule : List Nat)
    (hs : schedule.Perm (List.range 1024)) (group lane : Fin 32) :
    stored partials before schedule (group.val*32+lane.val) = partials lane group := by
  have hg := group.isLt
  have hl := lane.isLt
  have hm : group.val*32+lane.val ∈ schedule := hs.mem_iff.mpr (List.mem_range.mpr (by omega))
  unfold stored
  rw [Memory.writeCells_read, ite_eq_left hm]
  have h1 : (group.val*32+lane.val)%32 = lane.val := by omega
  have h2 : (group.val*32+lane.val)/32%32 = group.val := by omega
  simp only [h1, h2]

theorem scratch_frame (partials : Fin 32 → Fin 32 → α) (before : Nat → α) (schedule : List Nat)
    (hs : schedule.Perm (List.range 1024)) (j : Nat) (hj : 1024 ≤ j) : stored partials before schedule j = before j := by
  unfold stored
  rw [Memory.writeCells_read, ite_eq_right (fun h => by have := List.mem_range.mp (hs.mem_iff.mp h); omega)]

def coordinate (group : Fin 32) (offset : Fin 8) : Fin 256 :=
  ⟨group.val*8+offset.val, by have := group.isLt; have := offset.isLt; omega⟩

theorem output_owner (i : Fin 256) :
    coordinate ⟨i.val/8, by have := i.isLt; omega⟩ ⟨i.val%8, by omega⟩ = i := by
  apply Fin.ext
  dsimp [coordinate]
  omega

end Inference.Kernels.Attention.SdpaLayout
