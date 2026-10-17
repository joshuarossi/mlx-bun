import contracts.mlx.SquaredSum
import Mathlib.Data.List.Nodup

namespace Inference.Contracts.Mlx.NormalizationSchedule

-- MLX's looped RMS kernel visits four adjacent elements per thread, then
-- advances by four times the threadgroup size. Keep the pipeline-selected
-- thread count symbolic: maxTotalThreadsPerThreadgroup is not assumed 1024.
structure Visit (threads : Nat) where
  iteration : Nat
  thread : Fin threads
  element : Fin 4
  deriving DecidableEq

def address (v : Visit threads) : Nat :=
  v.iteration * (threads * 4) + v.thread.val * 4 + v.element.val

def owner (threads : Nat) (ht : 0 < threads) (column : Nat) : Visit threads where
  iteration := column / (threads * 4)
  thread := ⟨column % (threads * 4) / 4, by
    have := Nat.mod_lt column (show 0 < threads * 4 by omega)
    omega⟩
  element := ⟨column % 4, by omega⟩

theorem address_owner (threads : Nat) (ht : 0 < threads) (column : Nat) :
    address (owner threads ht column) = column := by
  have h₁ := Nat.mod_add_div column (threads * 4)
  have h₂ := Nat.mod_add_div (column % (threads * 4)) 4
  have h₃ : (column % (threads * 4)) % 4 = column % 4 :=
    Nat.mod_mod_of_dvd column (by omega)
  simp only [address, owner]
  rw [Nat.mul_comm (column / (threads * 4))]
  omega

theorem owner_address (threads : Nat) (ht : 0 < threads) (v : Visit threads) :
    owner threads ht (address v) = v := by
  rcases v with ⟨iteration, thread, element⟩
  have hlocal : thread.val * 4 + element.val < threads * 4 := by
    have := thread.isLt
    have := element.isLt
    omega
  have hi : (iteration * (threads * 4) + thread.val * 4 + element.val) / (threads * 4) = iteration := by
    rw [Nat.add_assoc, Nat.add_comm (iteration * (threads * 4)),
      Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hlocal]
    omega
  have hr : (iteration * (threads * 4) + thread.val * 4 + element.val) % (threads * 4) =
      thread.val * 4 + element.val := by
    rw [Nat.add_assoc, Nat.mul_add_mod_self_right, Nat.mod_eq_of_lt hlocal]
  have hs : (iteration * (threads * 4) + thread.val * 4 + element.val) % 4 = element.val := by
    have he := element.isLt
    rw [← Nat.mod_mod_of_dvd _ (show 4 ∣ threads * 4 by omega), hr]
    omega
  simp only [owner, address, hi, hr, hs]
  congr 1
  · apply Fin.ext
    dsimp only
    have := element.isLt
    omega

theorem address_injective (ht : 0 < threads) : Function.Injective (@address threads) := by
  intro a b h
  rw [← owner_address threads ht a, ← owner_address threads ht b, h]

-- A valid visit is exactly an element read by either the full four-element
-- branch or the individually guarded tail branch. This also characterizes
-- writes in the second pass of the looped kernel.
abbrev ValidVisit (threads width : Nat) := {v : Visit threads // address v < width}

def columnEquiv (threads width : Nat) (ht : 0 < threads) : ValidVisit threads width ≃ Fin width where
  toFun v := ⟨address v.val, v.property⟩
  invFun column := ⟨owner threads ht column.val, by rw [address_owner]; exact column.isLt⟩
  left_inv v := by apply Subtype.ext; exact owner_address threads ht v.val
  right_inv column := by apply Fin.ext; exact address_owner threads ht column.val

theorem loop_guard (v : Visit threads) (hv : address v < width) :
    v.iteration * (threads * 4) < width := by
  unfold address at hv
  omega

theorem full_block_safe (v : Visit threads)
    (hfull : v.iteration * (threads * 4) + v.thread.val * 4 + 4 ≤ width) :
    address v < width := by
  have := v.element.isLt
  unfold address
  omega

-- Exactly one thread/iteration/element owns every in-bounds column. Bounds
-- on the selected thread count and SIMD scratch reduction remain separate.
theorem unique_owner (threads width : Nat) (ht : 0 < threads) (column : Fin width) :
    ∃! v : ValidVisit threads width, address v.val = column.val := by
  refine ⟨(columnEquiv threads width ht).symm column, ?_, ?_⟩
  · exact address_owner threads ht column.val
  · intro v hv
    apply (columnEquiv threads width ht).injective
    apply Fin.ext
    simpa only [columnEquiv, Equiv.coe_fn_mk, Equiv.apply_symm_apply] using hv

def boundedVisit (p : Fin threads × Fin width × Fin 4) : Visit threads :=
  ⟨p.2.1.val, p.1, p.2.2⟩

theorem boundedVisit_injective : Function.Injective (@boundedVisit threads width) := by
  intro a b h
  have hi := congrArg Visit.iteration h
  have ht := congrArg Visit.thread h
  have he := congrArg Visit.element h
  exact Prod.ext ht (Prod.ext (Fin.ext hi) he)

-- Iterations after the source's loop guard fails contribute no elements.
-- Bounding the enumerator by width is sufficient for every positive stride;
-- it does not assume that width is divisible by the threadgroup stride.
def visits (threads width : Nat) : List (Visit threads) :=
  ((List.finRange threads).product ((List.finRange width).product (List.finRange 4))).map boundedVisit

def columnIndex (width : Nat) (v : Visit threads) : Option (Fin width) :=
  if h : address v < width then some ⟨address v, h⟩ else none

def columns (threads width : Nat) : List (Fin width) :=
  (visits threads width).filterMap (columnIndex width)

theorem index_some_iff (v : Visit threads) (column : Fin width) :
    columnIndex width v = some column ↔ address v = column.val := by
  unfold columnIndex
  split
  · simp only [Option.some.injEq, Fin.ext_iff]
  · rename_i h
    constructor
    · intro he; cases he
    · intro he
      exact False.elim (h (by rw [he]; exact column.isLt))

theorem mem_visits_of_valid (ht : 0 < threads) (v : Visit threads) (hv : address v < width) :
    v ∈ visits threads width := by
  have hi : v.iteration < width := by
    have hmul := Nat.le_mul_of_pos_right v.iteration (show 0 < threads * 4 by omega)
    have := loop_guard v hv
    omega
  change v ∈ ((List.finRange threads).product ((List.finRange width).product (List.finRange 4))).map boundedVisit
  apply List.mem_map.mpr
  refine ⟨(v.thread, ⟨v.iteration, hi⟩, v.element), ?_, ?_⟩
  · exact List.mem_product.mpr ⟨List.mem_finRange _, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩⟩
  · cases v; rfl

theorem columns_nodup (threads width : Nat) (ht : 0 < threads) :
    (columns threads width).Nodup := by
  apply List.Nodup.filterMap
  · intro a b column ha hb
    apply address_injective ht
    exact ((index_some_iff a column).mp ha).trans ((index_some_iff b column).mp hb).symm
  · exact ((List.nodup_finRange threads).product
      ((List.nodup_finRange width).product (List.nodup_finRange 4))).map boundedVisit_injective

theorem columns_complete (threads width : Nat) (ht : 0 < threads) :
    (columns threads width).Perm (List.finRange width) := by
  apply (List.perm_ext_iff_of_nodup (columns_nodup threads width ht) (List.nodup_finRange width)).mpr
  intro column
  constructor
  · intro _; exact List.mem_finRange column
  · intro _
    apply List.mem_filterMap.mpr
    refine ⟨owner threads ht column.val, ?_, ?_⟩
    · exact mem_visits_of_valid ht _ (by rw [address_owner]; exact column.isLt)
    · exact (index_some_iff _ column).mpr (address_owner threads ht column.val)

def threadColumns (width : Nat) (thread : Fin threads) : List (Fin width) :=
  (((List.finRange width).product (List.finRange 4)).map
    (fun p => Visit.mk p.1.val thread p.2)).filterMap (columnIndex width)

theorem columns_by_thread (threads width : Nat) :
    columns threads width = (List.finRange threads).flatMap (threadColumns width) := by
  unfold columns visits threadColumns
  simp [boundedVisit, List.product, List.map_flatMap,
    List.filterMap_flatMap, List.map_map, Function.comp_def]

def threadExpr (contracted : Bool) (width : Nat) (thread : Fin threads) : SquaredSum.Expr width :=
  SquaredSum.accumulate contracted (threadColumns width thread) .zero

def expression (contracted : Bool) (width : Nat) (tree : Reduction.Tree threads) : SquaredSum.Expr width :=
  SquaredSum.reduceTree (threadExpr contracted width) tree

-- The arithmetic expression now inherits once-only input coverage from the
-- source's strided loop. A reduction tree's primitive lane coverage remains
-- explicit; no floating-point reassociation is used in this argument.
theorem expression_coverage (contracted : Bool) (threads width : Nat) (ht : 0 < threads)
    (tree : Reduction.Tree threads) (hc : (Reduction.leaves tree).Perm (List.finRange threads)) :
    (SquaredSum.indices (expression contracted width tree)).Perm (List.finRange width) := by
  unfold expression
  rw [SquaredSum.reduceTree_indices]
  have h := hc.flatMap (fun i _ => SquaredSum.accumulate_indices contracted (threadColumns width i) .zero)
  simp only [SquaredSum.indices, List.nil_append] at h
  exact h.trans ((columns_by_thread threads width).symm ▸ columns_complete threads width ht)

end Inference.Contracts.Mlx.NormalizationSchedule
