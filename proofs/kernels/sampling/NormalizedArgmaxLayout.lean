import contracts.mlx.Reduction

namespace Inference.Kernels.Sampling.NormalizedArgmaxLayout
open Contracts.Mlx

-- Written normalized_argmax geometry for V=248320: 243 tiles, 128 threads,
-- 8 visits per thread before tail filtering. The finish pass visits at most
-- two partials per thread. Every token and partial has a unique owner.
def partialOffset (tile : Fin 243) (thread : Fin 128) (visit : Fin 8) : Nat :=
  tile.val*1024 + thread.val + visit.val*128
def tileOf (i : Fin 248320) : Fin 243 := ⟨i.val/1024, by omega⟩
def threadOf (i : Fin 248320) : Fin 128 := ⟨i.val%128, Nat.mod_lt _ (by decide)⟩
def visitOf (i : Fin 248320) : Fin 8 := ⟨(i.val%1024)/128, by omega⟩

theorem reconstruct (i : Fin 248320) : partialOffset (tileOf i) (threadOf i) (visitOf i) = i.val := by
  simp only [partialOffset, tileOf, threadOf, visitOf]
  omega

theorem inside_tile (tile : Fin 243) (thread : Fin 128) (visit : Fin 8) :
    partialOffset tile thread visit < (tile.val+1)*1024 := by
  simp only [partialOffset]
  omega

theorem loop_condition (tile : Fin 243) (thread : Fin 128) (visit : Fin 8) :
    partialOffset tile thread visit < min 248320 ((tile.val+1)*1024) ↔ partialOffset tile thread visit < 248320 := by
  exact ⟨fun h => h.trans_le (min_le_left _ _), fun h => lt_min h (inside_tile tile thread visit)⟩

theorem owner_unique (i : Fin 248320) (tile : Fin 243) (thread : Fin 128) (visit : Fin 8)
    (address : partialOffset tile thread visit = i.val) :
    tileOf i = tile ∧ threadOf i = thread ∧ visitOf i = visit := by
  simp only [partialOffset] at address
  refine ⟨Fin.ext ?_, Fin.ext ?_, Fin.ext ?_⟩ <;>
    simp only [tileOf, threadOf, visitOf] <;> omega

def partialOffsets (tile : Fin 243) (thread : Fin 128) : List Nat :=
  ((List.finRange 8).map (partialOffset tile thread)).filter (fun i => i < 248320)

theorem token_visited (i : Fin 248320) : i.val ∈ partialOffsets (tileOf i) (threadOf i) := by
  apply List.mem_filter.mpr
  refine ⟨List.mem_map.mpr ⟨visitOf i, by simp, reconstruct i⟩, by simp⟩

theorem visited_in_bounds (tile : Fin 243) (thread : Fin 128) (i : Nat)
    (hi : i ∈ partialOffsets tile thread) : i < 248320 := by
  exact of_decide_eq_true (List.mem_filter.mp hi).2

theorem tile_has_first_visit (tile : Fin 243) (thread : Fin 128) : partialOffset tile thread ⟨0, by decide⟩ < 248320 := by
  simp only [partialOffset]
  omega

theorem uint32_addresses (tile : Fin 243) (thread : Fin 128) (visit : Fin 8) :
    partialOffset tile thread visit + 128 < 2^32 ∧ (tile.val+1)*1024 < 2^32 := by
  simp only [partialOffset]
  norm_num
  omega

def finishOffset (thread : Fin 128) (visit : Fin 2) : Nat := thread.val + visit.val*128
def finishThread (tile : Fin 243) : Fin 128 := ⟨tile.val%128, Nat.mod_lt _ (by decide)⟩
def finishVisit (tile : Fin 243) : Fin 2 := ⟨tile.val/128, by omega⟩
def finishOffsets (thread : Fin 128) : List Nat :=
  ((List.finRange 2).map (finishOffset thread)).filter (fun i => i < 243)

theorem finish_reconstruct (tile : Fin 243) : finishOffset (finishThread tile) (finishVisit tile) = tile.val := by
  simp only [finishOffset, finishThread, finishVisit]
  omega

theorem partial_visited (tile : Fin 243) : tile.val ∈ finishOffsets (finishThread tile) := by
  apply List.mem_filter.mpr
  exact ⟨List.mem_map.mpr ⟨finishVisit tile, by simp, finish_reconstruct tile⟩, by simp⟩

theorem finish_in_bounds (thread : Fin 128) (i : Nat) (hi : i ∈ finishOffsets thread) : i < 243 :=
  of_decide_eq_true (List.mem_filter.mp hi).2

theorem finish_owner_unique (tile : Fin 243) (thread : Fin 128) (visit : Fin 2)
    (address : finishOffset thread visit = tile.val) : finishThread tile = thread ∧ finishVisit tile = visit := by
  simp only [finishOffset] at address
  constructor <;> apply Fin.ext <;> simp only [finishThread, finishVisit] <;> omega

-- Exact shuffle-down trees of the two reductions in the source. Only
-- lane zero stores the result; barrier and scratch execution remain native
-- memory obligations. Coverage is proved for the actual written distances.
def shuffle (distance : Nat) (lanes : Fin n → Reduction.Tree n) : Fin n → Reduction.Tree n := fun lane =>
  if h : lane.val + distance < n then .add (lanes lane) (lanes ⟨lane.val+distance, h⟩) else lanes lane
def simdTree : Reduction.Tree 32 :=
  (([16,8,4,2,1] : List Nat).foldl (fun lanes distance => shuffle distance lanes) Reduction.Tree.leaf) ⟨0, by decide⟩
def mergeTree : Reduction.Tree 4 :=
  (([2,1] : List Nat).foldl (fun lanes distance => shuffle distance lanes) Reduction.Tree.leaf) ⟨0, by decide⟩

def rename (f : Fin n → Fin m) : Reduction.Tree n → Reduction.Tree m
  | .leaf i => .leaf (f i)
  | .add left right => .add (rename f left) (rename f right)
def substitute (input : Fin n → Reduction.Tree m) : Reduction.Tree n → Reduction.Tree m
  | .leaf i => input i
  | .add left right => .add (substitute input left) (substitute input right)
def groupTree (group : Fin 4) : Reduction.Tree 128 :=
  rename (fun lane => ⟨group.val*32+lane.val, by omega⟩) simdTree
def threadgroupTree : Reduction.Tree 128 := substitute groupTree mergeTree

theorem simd_coverage : (Reduction.leaves simdTree).Perm (List.finRange 32) := by decide +kernel
theorem merge_coverage : (Reduction.leaves mergeTree).Perm (List.finRange 4) := by decide +kernel
set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem threadgroup_coverage : (Reduction.leaves threadgroupTree).Perm (List.finRange 128) := by decide +kernel

end Inference.Kernels.Sampling.NormalizedArgmaxLayout
