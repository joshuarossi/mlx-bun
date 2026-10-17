import contracts.mlx.NormalizationSchedule
import contracts.mlx.Memory
import contracts.mlx.FlushedReduction
import Mathlib.Data.List.Basic

namespace Inference.Contracts.Mlx.NormalizationReduction
open Numerics

abbrev SimdContract := FlushedReduction.SimdContract

theorem evaluate_reduceTree (input : Fin n → Float32) (expr : Fin m → SquaredSum.Expr n)
    (tree : Reduction.Tree m) :
    SquaredSum.evaluate input (SquaredSum.reduceTree expr tree) =
      FlushedReduction.evaluate (fun i => SquaredSum.evaluate input (expr i)) tree := by
  induction tree with
  | leaf i => rfl
  | add a b ia ib => simp only [SquaredSum.reduceTree, SquaredSum.evaluate, FlushedReduction.evaluate, ia, ib]

def truncateIndex (size : Nat) (i : Fin capacity) : Option (Fin size) :=
  if h : i.val < size then some ⟨i.val, h⟩ else none

theorem truncate_some_iff (i : Fin capacity) (j : Fin size) :
    truncateIndex size i = some j ↔ i.val = j.val := by
  unfold truncateIndex
  split
  · simp only [Option.some.injEq, Fin.ext_iff]
  · rename_i h
    constructor
    · intro he; cases he
    · intro he; exact False.elim (h (by rw [he]; exact j.isLt))

theorem truncated_coverage (size capacity : Nat) (hc : size ≤ capacity) :
    ((List.finRange capacity).filterMap (truncateIndex size)).Perm (List.finRange size) := by
  have hn : ((List.finRange capacity).filterMap (truncateIndex size)).Nodup := by
    apply List.Nodup.filterMap
    · intro a b j ha hb
      apply Fin.ext
      exact ((truncate_some_iff a j).mp ha).trans ((truncate_some_iff b j).mp hb).symm
    · exact List.nodup_finRange capacity
  apply (List.perm_ext_iff_of_nodup hn (List.nodup_finRange size)).mpr
  intro j
  constructor
  · intro _; exact List.mem_finRange j
  · intro _
    exact List.mem_filterMap.mpr ⟨⟨j.val, lt_of_lt_of_le j.isLt hc⟩, List.mem_finRange _,
      (truncate_some_iff _ j).mpr rfl⟩

theorem padded_flatMap (size capacity : Nat) (hc : size ≤ capacity) (f : Fin size → List α) :
    ((List.finRange capacity).flatMap (fun i => if h : i.val < size then f ⟨i.val, h⟩ else [])).Perm
      ((List.finRange size).flatMap f) := by
  have h := (truncated_coverage size capacity hc).flatMap_right f
  rw [List.filterMap_eq_flatMap_toList, List.flatMap_assoc] at h
  simpa only [truncateIndex, apply_dite Option.toList, Option.toList_some, Option.toList_none,
    apply_dite (fun l => List.flatMap f l), List.flatMap_singleton, List.flatMap_nil] using h

def laneIndex (group : Fin groups) (lane : Fin 32) : Fin (groups * 32) :=
  ⟨group.val * 32 + lane.val, by have := group.isLt; have := lane.isLt; omega⟩

def laneEquiv (groups : Nat) : (Fin groups × Fin 32) ≃ Fin (groups * 32) where
  toFun p := laneIndex p.1 p.2
  invFun i := (⟨i.val / 32, by have := i.isLt; omega⟩, ⟨i.val % 32, by omega⟩)
  left_inv p := by
    apply Prod.ext <;> apply Fin.ext <;> dsimp only [laneIndex]
    all_goals have := p.2.isLt; omega
  right_inv i := by apply Fin.ext; dsimp only [laneIndex]; omega

theorem lanes_complete (groups : Nat) :
    ((List.finRange groups).flatMap (fun group => (List.finRange 32).map (laneIndex group))).Perm
      (List.finRange (groups * 32)) := by
  have h : (((List.finRange groups).product (List.finRange 32)).map (laneEquiv groups)).Perm
      (List.finRange (groups * 32)) := by
    apply (List.perm_ext_iff_of_nodup
      (((List.nodup_finRange groups).product (List.nodup_finRange 32)).map (laneEquiv groups).injective)
      (List.nodup_finRange (groups * 32))).mpr
    intro i
    constructor
    · intro _; exact List.mem_finRange i
    · intro _
      exact List.mem_map.mpr ⟨(laneEquiv groups).symm i,
        List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, (laneEquiv groups).apply_symm_apply i⟩
  simpa only [List.product, List.map_flatMap, List.map_map, Function.comp_def,
    laneEquiv, Equiv.coe_fn_mk] using h

def groupExpr (contracted : Bool) (width : Nat) (tree : Reduction.Tree 32)
    (group : Fin groups) : SquaredSum.Expr width :=
  SquaredSum.reduceTree (fun lane => NormalizationSchedule.threadExpr contracted width (laneIndex group lane)) tree

def scratchExpr (contracted : Bool) (groups width : Nat) (tree : Reduction.Tree 32)
    (lane : Fin 32) : SquaredSum.Expr width :=
  if h : lane.val < groups then groupExpr contracted width tree ⟨lane.val, h⟩ else .zero

-- Each active SIMD group writes one partial sum. The second reduction reads
-- all 32 scratch slots; slots for inactive groups retain initialized zero.
def expression (contracted : Bool) (groups width : Nat) (first second : Reduction.Tree 32) : SquaredSum.Expr width :=
  SquaredSum.reduceTree (scratchExpr contracted groups width first) second

theorem expression_coverage (contracted : Bool) (groups width : Nat) (hg : 0 < groups) (hc : groups ≤ 32)
    (first second : Reduction.Tree 32)
    (hf : (Reduction.leaves first).Perm (List.finRange 32))
    (hs : (Reduction.leaves second).Perm (List.finRange 32)) :
    (SquaredSum.indices (expression contracted groups width first second)).Perm (List.finRange width) := by
  unfold expression
  rw [SquaredSum.reduceTree_indices]
  have hsecond := hs.flatMap_right (fun i => SquaredSum.indices (scratchExpr contracted groups width first i))
  have hpadded := padded_flatMap groups 32 hc (fun group => SquaredSum.indices (groupExpr contracted width first group))
  have hgroups : ((List.finRange groups).flatMap (fun group => SquaredSum.indices (groupExpr contracted width first group))).Perm
      ((List.finRange groups).flatMap (fun group => (List.finRange 32).flatMap
        (fun lane => SquaredSum.indices (NormalizationSchedule.threadExpr contracted width (laneIndex group lane))))) := by
    apply List.Perm.flatMap_left
    intro group _
    unfold groupExpr
    rw [SquaredSum.reduceTree_indices]
    exact hf.flatMap_right _
  have hlanes := (lanes_complete groups).flatMap_right
    (fun thread => SquaredSum.indices (NormalizationSchedule.threadExpr contracted width thread))
  simp only [List.flatMap_assoc, List.flatMap_map] at hlanes
  have hthreads := (List.Perm.refl (List.finRange (groups * 32))).flatMap
    (fun thread _ => SquaredSum.accumulate_indices contracted (NormalizationSchedule.threadColumns width thread) .zero)
  simp only [SquaredSum.indices, List.nil_append] at hthreads
  have hcolumns := NormalizationSchedule.columns_complete (groups * 32) width (by omega)
  rw [NormalizationSchedule.columns_by_thread] at hcolumns
  apply hsecond.trans
  have hp : ((List.finRange 32).flatMap (fun i => SquaredSum.indices (scratchExpr contracted groups width first i))).Perm
      ((List.finRange groups).flatMap (fun group => SquaredSum.indices (groupExpr contracted width first group))) := by
    simpa only [scratchExpr, apply_dite SquaredSum.indices, SquaredSum.indices] using hpadded
  exact hp.trans (hgroups.trans (hlanes.trans (hthreads.trans hcolumns)))

-- Addresses here are float words, as in the native typed local_sums array.
def initialStores (base : Nat) : List Memory.Store :=
  (List.finRange 32).map (fun lane => ⟨base + lane.val, 0⟩)

def partialStores (base : Nat) (values : Fin groups → Float32) : List Memory.Store :=
  (List.finRange groups).map (fun group => ⟨base + group.val, values group⟩)

theorem initialized (before : M1Max.WordMemory) (base : Nat)
    (schedule : List Memory.Store) (order : schedule.Perm (initialStores base)) (lane : Fin 32) :
    Memory.execute schedule before (base + lane.val) = 0 := by
  apply Memory.written_value_permuted (initialStores base) schedule order
  · intro s hs _
    obtain ⟨j, _, rfl⟩ := List.mem_map.mp hs
    rfl
  · exact ⟨⟨base + lane.val, 0⟩, List.mem_map.mpr ⟨lane, List.mem_finRange _, rfl⟩, rfl⟩

theorem partial_written (before : M1Max.WordMemory) (base : Nat) (values : Fin groups → Float32)
    (schedule : List Memory.Store) (order : schedule.Perm (partialStores base values)) (group : Fin groups) :
    Memory.execute schedule before (base + group.val) = values group := by
  apply Memory.written_value_permuted (partialStores base values) schedule order
  · intro s hs he
    obtain ⟨j, _, rfl⟩ := List.mem_map.mp hs
    have hj : j = group := by apply Fin.ext; simp only at he; omega
    subst j
    rfl
  · exact ⟨⟨base + group.val, values group⟩, List.mem_map.mpr ⟨group, List.mem_finRange _, rfl⟩, rfl⟩

theorem padding_preserved (before : M1Max.WordMemory) (base : Nat) (values : Fin groups → Float32)
    (schedule : List Memory.Store) (order : schedule.Perm (partialStores base values))
    (lane : Fin 32) (hl : groups ≤ lane.val) :
    Memory.execute schedule before (base + lane.val) = before (base + lane.val) := by
  apply Memory.frame
  intro s hs he
  obtain ⟨j, _, rfl⟩ := List.mem_map.mp (order.mem_iff.mp hs)
  have := j.isLt
  simp only at he
  omega

def shared (before : M1Max.WordMemory) (initial partials : List Memory.Store) : M1Max.WordMemory :=
  Memory.execute partials (Memory.execute initial before)

-- The two source barriers separate initialization from partial writes, and
-- partial writes from reads. Stores may be arbitrarily reordered within
-- either phase. This theorem does not assume scratch memory was initially 0.
theorem shared_read (before : M1Max.WordMemory) (base : Nat) (values : Fin groups → Float32)
    (initial partials : List Memory.Store)
    (hi : initial.Perm (initialStores base)) (hp : partials.Perm (partialStores base values)) (lane : Fin 32) :
    shared before initial partials (base + lane.val) =
      if h : lane.val < groups then values ⟨lane.val, h⟩ else 0 := by
  unfold shared
  split
  · rename_i h
    exact partial_written (Memory.execute initial before) base values partials hp ⟨lane.val, h⟩
  · rename_i h
    rw [padding_preserved _ base values partials hp lane (by omega)]
    exact initialized before base initial hi lane

theorem partial_address_bound (base : Nat) (values : Fin groups → Float32) (hc : groups ≤ 32)
    (s : Memory.Store) (hs : s ∈ partialStores base values) : base ≤ s.word ∧ s.word < base + 32 := by
  obtain ⟨group, _, rfl⟩ := List.mem_map.mp hs
  have := group.isLt
  simp only
  omega

def threadSum (contracted : Bool) (input : Fin width → Float32) (thread : Fin threads) : Float32 :=
  (NormalizationSchedule.threadColumns width thread).foldl (SquaredSum.arithmeticStep contracted input) 0

theorem threadSum_correct (contracted : Bool) (input : Fin width → Float32) (thread : Fin threads) :
    threadSum contracted input thread =
      SquaredSum.evaluate input (NormalizationSchedule.threadExpr contracted width thread) := by
  exact (SquaredSum.evaluate_accumulate contracted input (NormalizationSchedule.threadColumns width thread) .zero).symm

def groupSum (reduce : (Fin 32 → Float32) → Float32) (contracted : Bool)
    (input : Fin width → Float32) (group : Fin groups) : Float32 :=
  reduce (fun lane => threadSum contracted input (laneIndex group lane))

theorem groupSum_correct (reduce : (Fin 32 → Float32) → Float32) (hardware : SimdContract reduce)
    (contracted : Bool) (input : Fin width → Float32) (group : Fin groups) :
    groupSum reduce contracted input group = SquaredSum.evaluate input (groupExpr contracted width hardware.tree group) := by
  unfold groupSum groupExpr
  rw [hardware.execution, evaluate_reduceTree]
  congr 1
  funext lane
  exact threadSum_correct contracted input _

def sourceSum (reduce : (Fin 32 → Float32) → Float32) (contracted : Bool)
    (input : Fin width → Float32) (before : M1Max.WordMemory) (base groups : Nat) : Float32 :=
  let scratch := shared before (initialStores base) (partialStores base (groupSum reduce contracted input (groups := groups)))
  reduce (fun lane => scratch (base + lane.val))

theorem sourceSum_correct (reduce : (Fin 32 → Float32) → Float32) (hardware : SimdContract reduce)
    (contracted : Bool) (input : Fin width → Float32) (before : M1Max.WordMemory) (base groups : Nat) :
    sourceSum reduce contracted input before base groups =
      SquaredSum.evaluate input (expression contracted groups width hardware.tree hardware.tree) := by
  unfold sourceSum expression
  rw [hardware.execution, evaluate_reduceTree]
  congr 1
  funext lane
  rw [shared_read before base _ _ _ (List.Perm.refl _) (List.Perm.refl _)]
  unfold scratchExpr
  split
  · exact groupSum_correct reduce hardware contracted input _
  · rfl

theorem sourceSum_error (reduce : (Fin 32 → Float32) → Float32) (hardware : SimdContract reduce)
    (contracted : Bool) (input : Fin width → Float32) (before : M1Max.WordMemory) (base groups : Nat)
    (hg : 0 < groups) (hc : groups ≤ 32)
    (hf : SquaredSum.Finite input (expression contracted groups width hardware.tree hardware.tree)) :
    |real (sourceSum reduce contracted input before base groups) -
      ((List.finRange width).map (fun i => real (input i)^2)).sum| ≤
      SquaredSum.budget input (expression contracted groups width hardware.tree hardware.tree) := by
  rw [sourceSum_correct reduce hardware]
  exact SquaredSum.sum_error input _
    (expression_coverage contracted groups width hg hc _ _ hardware.coverage hardware.coverage) hf

end Inference.Contracts.Mlx.NormalizationReduction
