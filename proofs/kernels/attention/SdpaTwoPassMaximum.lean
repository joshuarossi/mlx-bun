import kernels.attention.SdpaTwoPassFirstPass

namespace Inference.Kernels.Attention.SdpaTwoPassMaximum
open Contracts.Mlx Contracts.Mlx.Numerics

-- Second-pass maximum: each lane reduces its strided block maxima, then
-- simd_max reduces the 32 lane results. All first-pass blocks are active
-- on the default Qwen two-pass route (blocks <= active keys).
def foldMaximum (p : SdpaVector.Platform) (values : α → Float32) (indices : List α) (initial : Float32) : Float32 :=
  indices.foldl (fun acc i => p.maximum acc (values i)) initial

theorem fold_contract (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (values : α → Float32) (finite : ∀ i, (values i).isFinite = true)
    (indices : List α) (initial : Float32) (hi : initial.isFinite = true) :
    (foldMaximum p values indices initial).isFinite = true ∧
      real (FlushToZero.flush initial) ≤ real (FlushToZero.flush (foldMaximum p values indices initial)) ∧
      (∀ i ∈ indices, real (FlushToZero.flush (values i)) ≤
        real (FlushToZero.flush (foldMaximum p values indices initial))) ∧
      (foldMaximum p values indices initial = initial ∨
        ∃ i ∈ indices, foldMaximum p values indices initial = values i) := by
  induction indices generalizing initial with
  | nil => exact ⟨hi, le_refl _, by simp, Or.inl rfl⟩
  | cons i rest ih =>
    have pair := maximum.pair initial (values i) hi (finite i)
    have nextFinite : (p.maximum initial (values i)).isFinite = true := by
      rcases pair.1 with h | h <;> rw [h]
      · exact hi
      · exact finite i
    have tail := ih _ nextFinite
    have initialNext : real (FlushToZero.flush initial) ≤ real (FlushToZero.flush (p.maximum initial (values i))) := by
      rw [pair.2]; exact le_max_left _ _
    have valueNext : real (FlushToZero.flush (values i)) ≤ real (FlushToZero.flush (p.maximum initial (values i))) := by
      rw [pair.2]; exact le_max_right _ _
    refine ⟨tail.1, initialNext.trans tail.2.1, ?_, ?_⟩
    · intro j member
      rcases List.mem_cons.mp member with rfl | hj
      · exact valueNext.trans tail.2.1
      · exact tail.2.2.1 j hj
    · rcases tail.2.2.2 with same | ⟨j, hj, same⟩
      · rcases pair.1 with left | right
        · exact Or.inl (same.trans left)
        · exact Or.inr ⟨i, by simp, same.trans right⟩
      · exact Or.inr ⟨j, List.mem_cons_of_mem _ hj, same⟩

theorem initialized (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (values : α → Float32) (finite : ∀ i, (values i).isFinite = true)
    (bound : ∀ i, |real (values i)| ≤ (2 : ℝ)^(24 : Nat)) (indices : List α) (nonempty : indices ≠ []) :
    ∃ i ∈ indices, foldMaximum p values indices SdpaVector.initialShift = values i ∧
      ∀ j ∈ indices, real (FlushToZero.flush (values j)) ≤ real (FlushToZero.flush (values i)) := by
  have h := fold_contract p maximum values finite indices SdpaVector.initialShift SdpaVector.initial_finite
  rcases h.2.2.2 with same | ⟨i, hi, same⟩
  · cases indices with
    | nil => exact False.elim (nonempty rfl)
    | cons i rest =>
      have bad := h.2.2.1 i (by simp)
      rw [same] at bad
      exact False.elim ((not_le_of_gt (SdpaInitialLoopRanges.initial_lt _ (bound i))) bad)
  · exact ⟨i, hi, same, by intro j hj; simpa only [same] using h.2.2.1 j hj⟩

def lane (p : SdpaVector.Platform) (maxima : Fin blocks → Float32) (thread : Fin 32) : Float32 :=
  foldMaximum p maxima (SdpaLayout.keys blocks thread) SdpaVector.initialShift
def common (p : SdpaVector.Platform) (maxima : Fin blocks → Float32) : Float32 := p.simdMaximum (lane p maxima)

theorem lane_nonempty (minimum : 32 ≤ blocks) (thread : Fin 32) : SdpaLayout.keys blocks thread ≠ [] := by
  have small : thread.val < blocks := thread.isLt.trans_le minimum
  have member := (SdpaLayout.keys_mem blocks thread ⟨thread.val, small⟩).mpr (Nat.mod_eq_of_lt thread.isLt)
  intro empty
  rw [empty] at member
  exact List.not_mem_nil member

theorem lane_count (blocks : Nat) (complete : blocks%32 = 0) (thread : Fin 32) :
    SdpaLayout.count blocks thread = blocks/32 := by
  have := thread.isLt
  unfold SdpaLayout.count
  omega

theorem selected (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (minimum : 32 ≤ blocks) (maxima : Fin blocks → Float32)
    (finite : ∀ i, (maxima i).isFinite = true)
    (bound : ∀ i, |real (maxima i)| ≤ (2 : ℝ)^(24 : Nat)) :
    ∃ winner : Fin blocks, common p maxima = maxima winner ∧
      ∀ i, real (FlushToZero.flush (maxima i)) ≤ real (FlushToZero.flush (maxima winner)) := by
  have lanes thread := initialized p maximum maxima finite bound (SdpaLayout.keys blocks thread) (lane_nonempty minimum thread)
  have laneFinite thread : (lane p maxima thread).isFinite = true := by
    obtain ⟨i, _, same, _⟩ := lanes thread
    change (foldMaximum p maxima _ _).isFinite = true
    rw [same]
    exact finite i
  obtain ⟨winningLane, chosen, largest⟩ := maximum.simd (lane p maxima) laneFinite
  obtain ⟨winner, _, same, _⟩ := lanes winningLane
  have result : common p maxima = maxima winner := chosen.trans same
  refine ⟨winner, result, ?_⟩
  intro i
  let owner : Fin 32 := ⟨i.val%32, by omega⟩
  obtain ⟨j, _, laneSame, laneLargest⟩ := lanes owner
  have inside := (SdpaLayout.keys_mem blocks owner i).mpr rfl
  have localBound := laneLargest i inside
  have globalBound := largest owner
  change real (FlushToZero.flush (foldMaximum p maxima _ _)) ≤ real (FlushToZero.flush (foldMaximum p maxima _ _)) at globalBound

  rw [same, laneSame] at globalBound
  exact localBound.trans globalBound

theorem ranges (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (minimum : 32 ≤ blocks) (maxima : Fin blocks → Float32)
    (finite : ∀ i, (maxima i).isFinite = true)
    (bound : ∀ i, |real (maxima i)| ≤ (2 : ℝ)^(24 : Nat)) :
    (common p maxima).isFinite = true ∧ |real (common p maxima)| ≤ (2 : ℝ)^(24 : Nat) := by
  obtain ⟨winner, same, _⟩ := selected p maximum minimum maxima finite bound
  rw [same]
  exact ⟨finite winner, bound winner⟩

end Inference.Kernels.Attention.SdpaTwoPassMaximum
