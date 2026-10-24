import host.mlx.KernelGpu
namespace Host.Mlx.SimGraph.Mach
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Argmax
open FloatLib.Floats.Formats.BinaryInterchange

/-! # The normalized argmax selects a vocabulary index, on any logits

`Metal.Bridge.Argmax` proves the partial and finish kernels select the model's sample when the scores are finite.
On arbitrary logits only this survives: every score is ordered (the partial kernel maps NaN to `-INFINITY`), so a
lane holding any logit's candidate never loses it to the empty candidate `(-INFINITY, 0xffffffff)`, and the
empty candidate never wins against one (`better` breaks the `-INFINITY` tie by the smaller index). Every lane of
both kernels scans at least one candidate, so the finish kernel's index is a logit's: below 248320.

* `VocabCand`; `pick_left`, `pick_right`, `scan_vocab`, `tree_vocab`.
* `tile_vocab`, `group_vocab`: the partial kernel's tiles and the finish kernel's result.
* `token_lt`: the token the route reads back is below 248320. -/

/-- A candidate whose score is ordered (not NaN after the comparison's flush) and whose index is a logit's. -/
def VocabCand (c : Cand) : Prop := Model.isNaN (Numerics.model (FlushToZero.flush c.1)) = false ∧ c.2 < 248320

theorem flush_nan (w : Float32) (h : Model.isNaN (Numerics.model w) = false) :
    Model.isNaN (Numerics.model (FlushToZero.flush w)) = false := by
  unfold FlushToZero.flush
  split
  · split
    · rename_i s _ _ _ _ _
      cases s <;> decide
    · exact h
  · exact h

theorem negInf_nan : Model.isNaN (Numerics.model (FlushToZero.flush negInf)) = false := by decide

theorem score_ordered (C : M1Max.Contract) (Lg S : ByteMemory.Bytes) (i : Nat) :
    Model.isNaN (Numerics.model (FlushToZero.flush (Metal.Kernels.ArgmaxPartial.score C Lg S i))) = false := by
  unfold Metal.Kernels.ArgmaxPartial.score Metal.Kernels.ArgmaxPartial.nanToNegInf
  split
  · exact negInf_nan
  · exact flush_nan _ (Bool.eq_false_iff.mpr ‹_›)

/-- An ordered score is at least `-INFINITY`. -/
theorem compare_negInf_ge (x : Float32) (hx : Model.isNaN (Numerics.model (FlushToZero.flush x)) = false) :
    f32Compare x negInf = some .gt ∨ f32Compare x negInf = some .eq := by
  obtain ⟨_, hfl, hn, hi, hs⟩ := Metal.Bridge.Argmax.negInf_facts
  unfold f32Compare
  rw [hfl]
  by_cases hxi : Model.isInf (Numerics.model (FlushToZero.flush x)) = true
  · by_cases hxs : Model.signBit (Numerics.model (FlushToZero.flush x)) = true
    · right; simp [Model.compare, Model.compareNonNaN, hx, hn, hi, hs, hxi, hxs]
    · left; simp [Model.compare, Model.compareNonNaN, hx, hn, hi, hs, hxi, hxs]
  · left; simp [Model.compare, Model.compareNonNaN, hx, hn, hi, hs, hxi]

/-- Nothing is below `-INFINITY`. -/
theorem compare_negInf_not_gt (x : Float32) : f32Compare negInf x ≠ some .gt := by
  obtain ⟨_, hfl, hn, hi, hs⟩ := Metal.Bridge.Argmax.negInf_facts
  unfold f32Compare
  rw [hfl]
  by_cases hxn : Model.isNaN (Numerics.model (FlushToZero.flush x)) = true
  · simp [Model.compare, hxn]
  · have hxn' : Model.isNaN (Numerics.model (FlushToZero.flush x)) = false := Bool.eq_false_iff.mpr hxn
    by_cases hxi : Model.isInf (Numerics.model (FlushToZero.flush x)) = true
    · by_cases hxs : Model.signBit (Numerics.model (FlushToZero.flush x)) = true
      · simp [Model.compare, Model.compareNonNaN, hxn', hn, hi, hs, hxi, hxs]
      · simp [Model.compare, Model.compareNonNaN, hxn', hn, hi, hs, hxi, hxs]
    · simp [Model.compare, Model.compareNonNaN, hxn', hn, hi, hs, hxi]

theorem better_empty {v : Cand} (hv : VocabCand v) : better v.1 v.2 empty.1 empty.2 = true := by
  have h2 : v.2 < 0xffffffff := by have := hv.2; omega
  rcases compare_negInf_ge v.1 hv.1 with h | h
  · simp [better, gtF, empty, h]
  · simp [better, gtF, eqF, empty, h, h2]

theorem empty_better {c : Cand} (hc : VocabCand c) : better empty.1 empty.2 c.1 c.2 = false := by
  have h1 := compare_negInf_not_gt c.1
  have h2 : ¬ (0xffffffff < c.2) := by have := hc.2; omega
  simp [better, gtF, eqF, empty, h1, h2]

theorem pick_left {v c : Cand} (hv : VocabCand v) (hc : VocabCand c ∨ c = empty) : VocabCand (pick v c) := by
  unfold pick
  split
  · exact hv
  · rcases hc with hc | rfl
    · exact hc
    · rename_i h
      exact absurd (better_empty hv) h

theorem pick_right {v c : Cand} (hv : VocabCand v ∨ v = empty) (hc : VocabCand c) : VocabCand (pick v c) := by
  unfold pick
  split
  · rcases hv with hv | rfl
    · exact hv
    · rename_i h
      rw [empty_better hc] at h
      exact absurd h Bool.false_ne_true
  · exact hc

theorem scan_some (v : Nat → Cand) (start : Nat) :
    ∀ k, (∀ j < k, VocabCand (v (start + 128 * j))) → VocabCand (scan v start k) ∨ scan v start k = empty
  | 0, _ => Or.inr rfl
  | k + 1, h => Or.inl (pick_left (h k (by omega)) (scan_some v start k fun j hj => h j (by omega)))

/-- **A lane that scans a candidate holds a vocabulary candidate.** -/
theorem scan_vocab (v : Nat → Cand) (start k : Nat) (h : ∀ j < k, VocabCand (v (start + 128 * j))) (hk : 0 < k) :
    VocabCand (scan v start k) := by
  obtain ⟨k, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  exact pick_left (h k (by omega)) (scan_some v start k fun j hj => h j (by omega))

theorem level_vocab (w d : Nat) (hw : w ≤ 32) (c : Fin 32 → Cand) (hc : ∀ j : Fin 32, j.val < w → VocabCand (c j))
    (i : Fin 32) (hi : i.val < w) : VocabCand (level w d c i) := by
  unfold level levelStep
  split
  · rename_i h
    rw [shuffle_of_lt c d i (by omega)]
    exact hc _ (by simp only; omega)
  · exact hc i hi

/-- **A tree over vocabulary candidates on its `w` lanes** holds vocabulary candidates there. -/
theorem tree_vocab (w : Nat) (hw : w ≤ 32) : ∀ (ds : List Nat) (c : Fin 32 → Cand),
    (∀ j : Fin 32, j.val < w → VocabCand (c j)) → ∀ i : Fin 32, i.val < w → VocabCand (tree w ds c i)
  | [], _, hc => hc
  | d :: ds, c, hc => tree_vocab w hw ds _ fun j hj => level_vocab w d hw c hc j hj

section
open Metal.Kernels.ArgmaxPartial
variable (C : M1Max.Contract) (Lg S : ByteMemory.Bytes)

theorem lane_vocab (t tid : Nat) (ht : t < 243) (htid : tid < 128) : VocabCand (laneBest C Lg S t tid) := by
  unfold laneBest
  refine scan_vocab _ _ _ (fun j hj => ⟨score_ordered C Lg S _, ?_⟩) ?_
  · show t * 1024 + tid + 128 * j < 248320
    unfold count bound at hj
    omega
  · unfold count bound
    omega

theorem simd_vocab (t s : Nat) (ht : t < 243) (hs : s < 4) : VocabCand (simdBest C Lg S t s) :=
  tree_vocab 32 le_rfl _ _ (fun j _ => lane_vocab C Lg S t _ ht (by omega)) 0 (by decide)

/-- **Every tile's candidate is a vocabulary candidate.** -/
theorem tile_vocab (t : Nat) (ht : t < 243) : VocabCand (tileBest C Lg S t) :=
  tree_vocab 4 (by decide) _ _ (fun j hj => by
    unfold merged
    rw [ite_eq_left hj]
    exact simd_vocab C Lg S t j ht hj) 0 (by decide)

theorem finish_lane_vocab (tid : Nat) (htid : tid < 128) :
    VocabCand (Metal.Kernels.ArgmaxFinish.laneBest (values C Lg S) (indices C Lg S) tid) := by
  unfold Metal.Kernels.ArgmaxFinish.laneBest
  refine scan_vocab _ _ _ (fun j hj => ?_) ?_
  · have ht : tid + 128 * j < 243 := by unfold count at hj; omega
    rw [Metal.Bridge.Argmax.cand_finish C Lg S _ ht]
    exact tile_vocab C Lg S _ ht
  · unfold count
    omega

/-- **The finish kernel's candidate is a vocabulary candidate.** -/
theorem group_vocab : VocabCand (Metal.Kernels.ArgmaxFinish.groupBest (values C Lg S) (indices C Lg S)) :=
  tree_vocab 4 (by decide) _ _ (fun j hj => by
    unfold Metal.Kernels.ArgmaxFinish.merged
    rw [ite_eq_left hj]
    exact tree_vocab 32 le_rfl _ _ (fun i _ => finish_lane_vocab C Lg S _ (by omega)) 0 (by decide)) 0 (by decide)

/-- **The token the route reads back is below 248320**, whatever the logits. -/
theorem token_lt :
    (KernelGpu.readOutput (Metal.Kernels.ArgmaxFinish.expected (values C Lg S) (indices C Lg S)) ([1], .uint32)).elems 0 <
      248320 := by
  rw [KernelGpu.readOutput_word _ _ _ rfl]
  have hg := (group_vocab C Lg S).2
  show (wordArray .uint32 (Metal.Bridge.Argmax.tokenBytes
    (Metal.Kernels.ArgmaxFinish.groupBest (values C Lg S) (indices C Lg S)).2) 0 [1]).elems 0 < 248320
  rw [Metal.Bridge.Argmax.readback _ (by omega)]
  exact hg

end

end Host.Mlx.SimGraph.Mach
