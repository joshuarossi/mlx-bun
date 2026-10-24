import metal.kernels.ArgmaxPartial
import metal.bridge.General
import kernels.sampling.ArgmaxShuffleSemantics
import kernels.sampling.GreedySampling

namespace Metal.Bridge.Argmax
open Metal Metal.Core
open Inference.Contracts Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open Inference.Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Metal.Bridge.General

/-! # normalized argmax: the partial and finish kernels select the model's token

`Metal.Kernels.ArgmaxPartial.gpu_output` and `ArgmaxFinish.gpu_output` state the two launches' outputs as the
source's lane scans and `simd_shuffle_down` trees over candidates `(score, index)` ordered by the source's
`better` (`Kernels.Argmax.better`); `Sampling.GreedySampling.sample` (what `GlueKernels.normalized_argmax`
concludes) is the index of the model's `NormalizedArgmaxExecution.run`. Both select the unique candidate with the
largest (flushed) score and, among ties, the smallest index: the machine's candidates map to the existing
`ArgmaxPairs` candidates (`-INFINITY` is the sentinel `none`), its `better` is `ArgmaxPairs.better`, its trees are
`ArgmaxShuffleSemantics.rounds`, so the existing dominance theorems apply. -/

abbrev MCand := Kernels.Argmax.Cand

/-- A candidate the kernels can hold: a finite score, or `-INFINITY`. -/
def Valid (c : MCand) : Prop := c.1.isFinite = true ∨ c.1 = Kernels.Argmax.negInf

/-- The model's candidate of a machine candidate: `-INFINITY` as `none`. -/
def toPair (c : MCand) : ArgmaxPairs.Candidate := ⟨if c.1.isFinite then some c.1 else none, c.2⟩

theorem toPair_finite (c : MCand) : ArgmaxPairs.Finite (toPair c) := by
  intro v hv
  unfold toPair at hv
  split at hv
  · cases hv; assumption
  · cases hv

theorem negInf_facts : Kernels.Argmax.negInf.isFinite = false ∧ FlushToZero.flush Kernels.Argmax.negInf = Kernels.Argmax.negInf ∧
    Model.isNaN (model Kernels.Argmax.negInf) = false ∧ Model.isInf (model Kernels.Argmax.negInf) = true ∧
    Model.signBit (model Kernels.Argmax.negInf) = true := by decide

theorem valid_empty : Valid Kernels.Argmax.empty := Or.inr rfl

theorem toPair_empty : toPair Kernels.Argmax.empty = ArgmaxPairs.sentinel := by
  unfold toPair Kernels.Argmax.empty ArgmaxPairs.sentinel
  rw [negInf_facts.1]; rfl

theorem finite_model_facts (a : Float32) (ha : a.isFinite = true) :
    Model.isNaN (model (FlushToZero.flush a)) = false ∧ Model.isInf (model (FlushToZero.flush a)) = false := by
  have hf : Model.isFinite (model (FlushToZero.flush a)) = true := by
    rw [finite_model]; exact FlushToZero.finite_flush a ha
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hf
  exact ⟨Model.isNaN_eq_false_of_isFinite_eq_true _ hf, Model.isInf_eq_false_of_toDyadic?_some hd⟩

theorem compare_negInf (a : Float32) (ha : a.isFinite = true) :
    f32Compare a Kernels.Argmax.negInf = some .gt ∧ f32Compare Kernels.Argmax.negInf a = some .lt := by
  obtain ⟨_, hfl, hn, hi, hs⟩ := negInf_facts
  obtain ⟨han, hai⟩ := finite_model_facts a ha
  unfold f32Compare
  rw [hfl]
  constructor
  · simp [Model.compare, Model.compareNonNaN, han, hai, hn, hi, hs]
  · simp [Model.compare, Model.compareNonNaN, han, hai, hn, hi, hs]

theorem compare_negInf_self : f32Compare Kernels.Argmax.negInf Kernels.Argmax.negInf = some .eq := by decide

/-- The source's `better` is the model's `ArgmaxPairs.better` on valid candidates. -/
theorem better_pair (x y : MCand) (hx : Valid x) (hy : Valid y) :
    Kernels.Argmax.better x.1 x.2 y.1 y.2 = ArgmaxPairs.better (toPair x) (toPair y) := by
  obtain ⟨xs, xi⟩ := x
  obtain ⟨ys, yi⟩ := y
  have hni := negInf_facts.1
  rcases hx with hx | hx <;> rcases hy with hy | hy <;> simp only at hx hy
  · simp only [toPair, hx, hy, ite_true, ArgmaxPairs.better, Kernels.Argmax.better, Kernels.Argmax.gtF,
      Kernels.Argmax.eqF, f32Compare]
    rfl
  · subst hy
    simp only [toPair, hx, hni, ite_true, Bool.false_eq_true, ite_false, ArgmaxPairs.better, Kernels.Argmax.better,
      Kernels.Argmax.gtF, Kernels.Argmax.eqF, (compare_negInf xs hx).1]
    rfl
  · subst hx
    simp only [toPair, hy, hni, ite_true, Bool.false_eq_true, ite_false, ArgmaxPairs.better, Kernels.Argmax.better,
      Kernels.Argmax.gtF, Kernels.Argmax.eqF, (compare_negInf ys hy).2]
    rfl
  · subst hx hy
    simp only [toPair, hni, Bool.false_eq_true, ite_false, ArgmaxPairs.better, Kernels.Argmax.better,
      Kernels.Argmax.gtF, Kernels.Argmax.eqF, compare_negInf_self]
    rfl

theorem choose_pair (v c : MCand) (hv : Valid v) (hc : Valid c) :
    toPair (if Kernels.Argmax.better v.1 v.2 c.1 c.2 = true then v else c) = ArgmaxPairs.choose (toPair v) (toPair c) := by
  unfold ArgmaxPairs.choose
  rw [better_pair v c hv hc]
  split <;> rfl

theorem pick_valid (v c : MCand) (hv : Valid v) (hc : Valid c) : Valid (Kernels.Argmax.pick v c) := by
  unfold Kernels.Argmax.pick; split <;> assumption

/-! ## Lane scans -/

theorem scan_append (l : List ArgmaxPairs.Candidate) (x init : ArgmaxPairs.Candidate) :
    ArgmaxPairs.scan (l ++ [x]) init = ArgmaxPairs.choose x (ArgmaxPairs.scan l init) := by
  unfold ArgmaxPairs.scan; rw [List.foldl_append]; rfl

theorem scan_pair (v : Nat → MCand) (start : Nat) :
    ∀ k, (∀ j < k, Valid (v (start + 128 * j))) →
      Valid (Kernels.Argmax.scan v start k) ∧
        toPair (Kernels.Argmax.scan v start k) =
          ArgmaxPairs.scan ((List.range k).map fun j => toPair (v (start + 128 * j))) ArgmaxPairs.sentinel
  | 0, _ => ⟨valid_empty, toPair_empty⟩
  | k + 1, hv => by
    obtain ⟨hk, ih⟩ := scan_pair v start k (fun j hj => hv j (by omega))
    have hvk := hv k (by omega)
    refine ⟨pick_valid _ _ hvk hk, ?_⟩
    rw [List.range_succ, List.map_append, List.map_singleton, scan_append, ← ih]
    exact choose_pair _ _ hvk hk

/-- A lane's scan is `-INFINITY` or one of the candidates it visits. -/
theorem scan_origin (v : Nat → MCand) (start : Nat) :
    ∀ k, Kernels.Argmax.scan v start k = Kernels.Argmax.empty ∨ ∃ j < k, Kernels.Argmax.scan v start k = v (start + 128 * j)
  | 0 => Or.inl rfl
  | k + 1 => by
    show Kernels.Argmax.pick _ _ = _ ∨ ∃ j < k + 1, Kernels.Argmax.pick _ _ = _
    unfold Kernels.Argmax.pick
    split
    · exact Or.inr ⟨k, by omega, rfl⟩
    · rcases scan_origin v start k with h | ⟨j, hj, h⟩
      · exact Or.inl h
      · exact Or.inr ⟨j, by omega, h⟩

/-- A lane's scan dominates every candidate it visits. -/
theorem scan_dominates (v : Nat → MCand) (start k : Nat) (hv : ∀ j < k, Valid (v (start + 128 * j))) (j : Nat) (hj : j < k) :
    Mlx.Argmax.Dominates (ArgmaxPairs.semantic (toPair (Kernels.Argmax.scan v start k)))
      (ArgmaxPairs.semantic (toPair (v (start + 128 * j)))) := by
  rw [(scan_pair v start k hv).2]
  exact ArgmaxPairs.scan_dominates _ _ ArgmaxPairs.sentinel_finite
    (fun x hx => by obtain ⟨i, -, rfl⟩ := List.mem_map.mp hx; exact toPair_finite _) _
    (List.mem_map.mpr ⟨j, List.mem_range.mpr hj, rfl⟩)

/-! ## Shuffle trees -/

open ArgmaxShuffleSemantics in
theorem level_pair (c : Fin 32 → MCand) (hc : ∀ j, Valid (c j)) (d : Nat) :
    (∀ i, Valid (Kernels.Argmax.level 32 d c i)) ∧
      (fun i => toPair (Kernels.Argmax.level 32 d c i)) = ArgmaxShuffleSemantics.round ArgmaxShuffleSyntax.betterExpr d (fun j => toPair (c j)) := by
  refine ⟨fun i => ?_, funext fun i => ?_⟩
  · unfold Kernels.Argmax.level Kernels.Argmax.levelStep Metal.shuffle
    split <;> (try split) <;> exact hc _
  · unfold Kernels.Argmax.level Kernels.Argmax.levelStep ArgmaxShuffleSemantics.round
    by_cases h : i.val + d < 32
    · rw [dite_eq_left h, selected_eq, Metal.shuffle_of_lt c d i h]
      have := choose_pair (c ⟨i.val + d, h⟩) (c i) (hc _) (hc _)
      rw [← this]
      congr 1
      by_cases hb : Kernels.Argmax.better (c ⟨i.val + d, h⟩).1 (c ⟨i.val + d, h⟩).2 (c i).1 (c i).2 = true
      · rw [ite_eq_left ⟨h, hb⟩, ite_eq_left hb]
      · rw [ite_eq_right (fun h' => hb h'.2), ite_eq_right hb]
    · rw [dite_eq_right h, ite_eq_right (fun h' => h h'.1)]

open ArgmaxShuffleSemantics in
theorem tree32_pair : ∀ (ds : List Nat) (c : Fin 32 → MCand), (∀ j, Valid (c j)) →
    (∀ i, Valid (Kernels.Argmax.tree 32 ds c i)) ∧
      (fun i => toPair (Kernels.Argmax.tree 32 ds c i)) = rounds ArgmaxShuffleSyntax.betterExpr ds (fun j => toPair (c j))
  | [], c, hc => ⟨hc, rfl⟩
  | d :: ds, c, hc => by
    obtain ⟨hv, he⟩ := level_pair c hc d
    obtain ⟨hv', he'⟩ := tree32_pair ds _ hv
    refine ⟨hv', ?_⟩
    show (fun i => toPair (Kernels.Argmax.tree 32 ds (Kernels.Argmax.level 32 d c) i)) = _
    rw [he', he]
    rfl

/-- The SIMD tree at distances 16, 8, 4, 2, 1 leaves on lane 0 a valid candidate dominating every lane's. -/
theorem simd_tree (c : Fin 32 → MCand) (hc : ∀ j, Valid (c j)) :
    Valid (Kernels.Argmax.tree 32 [16, 8, 4, 2, 1] c 0) ∧ ∀ j, Mlx.Argmax.Dominates
      (ArgmaxPairs.semantic (toPair (Kernels.Argmax.tree 32 [16, 8, 4, 2, 1] c 0))) (ArgmaxPairs.semantic (toPair (c j))) := by
  obtain ⟨hv, he⟩ := tree32_pair [16, 8, 4, 2, 1] c hc
  refine ⟨hv 0, fun j => ?_⟩
  have hd := ArgmaxShuffleSemantics.simd_dominates (fun j => toPair (c j)) (fun j => toPair_finite _) j
  unfold ArgmaxShuffleSemantics.runLoop at hd
  rw [ArgmaxShuffleSemantics.simd_distances] at hd
  rw [show toPair (Kernels.Argmax.tree 32 [16, 8, 4, 2, 1] c 0) =
    ArgmaxShuffleSemantics.rounds ArgmaxShuffleSyntax.betterExpr [16, 8, 4, 2, 1] (fun j => toPair (c j)) 0 from
    congrFun he 0]
  exact hd

theorem level_origin (w d : Nat) (c : Fin 32 → MCand) (P : MCand → Prop) (hc : ∀ j, P (c j)) (i : Fin 32) :
    P (Kernels.Argmax.level w d c i) := by
  unfold Kernels.Argmax.level Kernels.Argmax.levelStep Metal.shuffle
  split <;> (try split) <;> exact hc _

theorem tree_origin (w : Nat) (P : MCand → Prop) : ∀ (ds : List Nat) (c : Fin 32 → MCand), (∀ j, P (c j)) →
    ∀ i, P (Kernels.Argmax.tree w ds c i)
  | [], _, hc, i => hc i
  | d :: ds, c, hc, i => tree_origin w P ds _ (level_origin w d c P hc) i

/-- The four-lane tree of the merge, on lanes 0–3. -/
def restrict (c : Fin 32 → MCand) (j : Fin 4) : MCand := c ⟨j.val, by omega⟩

open ArgmaxShuffleSemantics in
theorem level4_pair (c : Fin 32 → MCand) (hc : ∀ j : Fin 4, Valid (restrict c j)) (d : Nat) :
    (∀ j : Fin 4, Valid (restrict (Kernels.Argmax.level 4 d c) j)) ∧
      (fun j => toPair (restrict (Kernels.Argmax.level 4 d c) j)) =
        ArgmaxShuffleSemantics.round ArgmaxShuffleSyntax.betterExpr d (fun j => toPair (restrict c j)) := by
  refine ⟨fun j => ?_, funext fun j => ?_⟩
  · unfold restrict Kernels.Argmax.level Kernels.Argmax.levelStep
    by_cases h : j.val + d < 4
    · rw [Metal.shuffle_of_lt c d _ (by simp only; omega)]
      split
      · exact hc ⟨j.val + d, h⟩
      · exact hc j
    · rw [ite_eq_right (fun h' => h h'.1)]; exact hc j
  · unfold restrict Kernels.Argmax.level Kernels.Argmax.levelStep ArgmaxShuffleSemantics.round
    by_cases h : j.val + d < 4
    · rw [dite_eq_left h, selected_eq, Metal.shuffle_of_lt c d _ (by simp only; omega)]
      have := choose_pair (c ⟨j.val + d, by omega⟩) (c ⟨j.val, by omega⟩) (hc ⟨j.val + d, h⟩) (hc j)
      rw [← this]
      congr 1
      by_cases hb : Kernels.Argmax.better (c ⟨j.val + d, by omega⟩).1 (c ⟨j.val + d, by omega⟩).2 (c ⟨j.val, by omega⟩).1
          (c ⟨j.val, by omega⟩).2 = true
      · rw [ite_eq_left ⟨h, hb⟩, ite_eq_left hb]
      · rw [ite_eq_right (fun h' => hb h'.2), ite_eq_right hb]
    · rw [dite_eq_right h, ite_eq_right (fun h' => h h'.1)]

open ArgmaxShuffleSemantics in
theorem tree4_pair : ∀ (ds : List Nat) (c : Fin 32 → MCand), (∀ j : Fin 4, Valid (restrict c j)) →
    (∀ j : Fin 4, Valid (restrict (Kernels.Argmax.tree 4 ds c) j)) ∧
      (fun j => toPair (restrict (Kernels.Argmax.tree 4 ds c) j)) =
        rounds ArgmaxShuffleSyntax.betterExpr ds (fun j => toPair (restrict c j))
  | [], c, hc => ⟨hc, rfl⟩
  | d :: ds, c, hc => by
    obtain ⟨hv, he⟩ := level4_pair c hc d
    obtain ⟨hv', he'⟩ := tree4_pair ds _ hv
    refine ⟨hv', ?_⟩
    show (fun j => toPair (restrict (Kernels.Argmax.tree 4 ds (Kernels.Argmax.level 4 d c)) j)) = _
    rw [he', he]
    rfl

/-- The merge tree at distances 2, 1 leaves on lane 0 a valid candidate dominating lanes 0–3. -/
theorem merge_tree (c : Fin 32 → MCand) (hc : ∀ j : Fin 4, Valid (restrict c j)) :
    Valid (Kernels.Argmax.tree 4 [2, 1] c 0) ∧ ∀ j : Fin 4, Mlx.Argmax.Dominates
      (ArgmaxPairs.semantic (toPair (Kernels.Argmax.tree 4 [2, 1] c 0))) (ArgmaxPairs.semantic (toPair (restrict c j))) := by
  obtain ⟨hv, he⟩ := tree4_pair [2, 1] c hc
  refine ⟨hv 0, fun j => ?_⟩
  have hd := ArgmaxShuffleSemantics.merge_dominates (fun j => toPair (restrict c j)) (fun j => toPair_finite _) j
  unfold ArgmaxShuffleSemantics.runLoop at hd
  rw [ArgmaxShuffleSemantics.merge_distances] at hd
  rw [show toPair (Kernels.Argmax.tree 4 [2, 1] c 0) =
    ArgmaxShuffleSemantics.rounds ArgmaxShuffleSyntax.betterExpr [2, 1] (fun j => toPair (restrict c j)) 0 from
    congrFun he 0]
  exact hd

/-! ## The partial kernel: each tile's candidate -/

section Partial
open Metal.Kernels.ArgmaxPartial
variable (C : M1Max.Contract) (Lg S : ByteMemory.Bytes)

/-- Every candidate the partial kernel can hold is `-INFINITY` or a logit's candidate. -/
def Origin (c : MCand) : Prop := c = Kernels.Argmax.empty ∨ ∃ i < 248320, c = cand C Lg S i

def Dom (x y : MCand) : Prop := Mlx.Argmax.Dominates (ArgmaxPairs.semantic (toPair x)) (ArgmaxPairs.semantic (toPair y))

variable (hv : ∀ i < 248320, (score C Lg S i).isFinite = true)
include hv

theorem cand_valid (i : Nat) (hi : i < 248320) : Valid (cand C Lg S i) := Or.inl (hv i hi)

theorem lane_partial (t tid : Nat) (ht : t < 243) :
    Valid (laneBest C Lg S t tid) ∧ Origin C Lg S (laneBest C Lg S t tid) ∧
      ∀ i < 248320, i / 1024 = t → i % 128 = tid → Dom (laneBest C Lg S t tid) (cand C Lg S i) := by
  have hvis : ∀ j < Kernels.Argmax.count (t * 1024 + tid) (bound t), Valid (cand C Lg S (t * 1024 + tid + 128 * j)) := by
    intro j hj
    apply cand_valid C Lg S hv
    unfold Kernels.Argmax.count bound at hj; omega
  refine ⟨(scan_pair _ _ _ hvis).1, ?_, ?_⟩
  · rcases scan_origin (cand C Lg S) (t * 1024 + tid) (Kernels.Argmax.count (t * 1024 + tid) (bound t)) with h | ⟨j, hj, h⟩
    · exact Or.inl h
    · exact Or.inr ⟨_, by unfold Kernels.Argmax.count bound at hj; omega, h⟩
  · intro i hi hit hil
    have hj : i % 1024 / 128 < Kernels.Argmax.count (t * 1024 + tid) (bound t) := by unfold Kernels.Argmax.count bound; omega
    have := scan_dominates (cand C Lg S) (t * 1024 + tid) _ hvis _ hj
    rwa [show t * 1024 + tid + 128 * (i % 1024 / 128) = i by omega] at this

theorem simd_partial (t s : Nat) (ht : t < 243) :
    Valid (simdBest C Lg S t s) ∧ Origin C Lg S (simdBest C Lg S t s) ∧
      ∀ i < 248320, i / 1024 = t → i % 128 / 32 = s → Dom (simdBest C Lg S t s) (cand C Lg S i) := by
  have hl := fun j : Fin 32 => lane_partial C Lg S hv t (32 * s + j.val) ht
  obtain ⟨hvt, hdt⟩ := simd_tree _ (fun j => (hl j).1)
  refine ⟨hvt, tree_origin 32 (Origin C Lg S) _ _ (fun j => (hl j).2.1) 0, fun i hi hit his => ?_⟩
  have hd := hdt ⟨i % 32, by omega⟩
  exact Mlx.Argmax.dominates_trans hd ((hl ⟨i % 32, by omega⟩).2.2 i hi hit (by simp only; omega))

theorem tile_partial (t : Nat) (ht : t < 243) :
    Valid (tileBest C Lg S t) ∧ Origin C Lg S (tileBest C Lg S t) ∧
      ∀ i < 248320, i / 1024 = t → Dom (tileBest C Lg S t) (cand C Lg S i) := by
  have hs := fun s : Fin 4 => simd_partial C Lg S hv t s ht
  have hm : ∀ j : Fin 4, restrict (merged C Lg S t) j = simdBest C Lg S t j := by
    intro j; unfold restrict merged; rw [ite_eq_left (by simp only; omega)]
  obtain ⟨hvt, hdt⟩ := merge_tree (merged C Lg S t) (fun j => by rw [hm]; exact (hs j).1)
  refine ⟨hvt, tree_origin 4 (Origin C Lg S) _ _ (fun j => ?_) 0, fun i hi hit => ?_⟩
  · unfold merged
    split
    · exact (simd_partial C Lg S hv t j ht).2.1
    · exact Or.inl rfl
  · have hd := hdt ⟨i % 128 / 32, by omega⟩
    rw [hm] at hd
    exact Mlx.Argmax.dominates_trans hd ((hs ⟨i % 128 / 32, by omega⟩).2.2 i hi hit rfl)

end Partial

/-! ## The finish kernel on the partial kernel's outputs -/

section Finish
open Metal.Kernels.ArgmaxPartial
variable (C : M1Max.Contract) (Lg S : ByteMemory.Bytes)

theorem cells_wordBytes (M : ByteMemory.Bytes) (o w : Nat) (h : ∀ k < 4, M (o + k) = (wordBytes 4 w).getD k 0) :
    Metal.cells M o 4 = wordBytes 4 w := by
  apply List.ext_getElem
  · rw [Metal.cells_length, Metal.wordBytes_length]
  · intro k h1 h2
    rw [Metal.cells_length] at h1
    simp only [Metal.cells, List.getElem_map, List.getElem_range]
    rw [h k h1, List.getD_eq_getElem]

theorem tileBest_bound (t : Nat) : (tileBest C Lg S t).2 < 2 ^ 32 :=
  tree_bound _ _ _ (fun j => merged_bound C Lg S t j) 0

/-- The finish kernel reads back each tile's candidate from the partial kernel's output bytes. -/
theorem cand_finish (t : Nat) (ht : t < 243) :
    Metal.Kernels.ArgmaxFinish.cand (values C Lg S) (indices C Lg S) t = tileBest C Lg S t := by
  have hv : Metal.cells (values C Lg S) (4 * t) 4 = wordBytes 4 (Val.f32Bits (tileBest C Lg S t).1) := by
    apply cells_wordBytes
    intro k hk
    unfold values
    rw [ite_eq_left (by omega), show (4 * t + k) / 4 = t by omega, show (4 * t + k) % 4 = k by omega]
  have hx : Metal.cells (indices C Lg S) (4 * t) 4 = wordBytes 4 (tileBest C Lg S t).2 := by
    apply cells_wordBytes
    intro k hk
    unfold indices
    rw [ite_eq_left (by omega), show (4 * t + k) / 4 = t by omega, show (4 * t + k) % 4 = k by omega]
  unfold Metal.Kernels.ArgmaxFinish.cand Metal.Kernels.ArgmaxFinish.value Metal.Kernels.ArgmaxFinish.index
  rw [hv, hx, Metal.bytesWord_wordBytes, Metal.bytesWord_wordBytes,
    Nat.mod_eq_of_lt (show Val.f32Bits (tileBest C Lg S t).1 < 256 ^ 4 from Metal.f32Bits_lt _),
    Nat.mod_eq_of_lt (show (tileBest C Lg S t).2 < 256 ^ 4 from tileBest_bound C Lg S t), Metal.ofF32Bits_f32Bits]

variable (hv : ∀ i < 248320, (score C Lg S i).isFinite = true)
include hv

theorem lane_finish (tid : Nat) :
    Valid (Metal.Kernels.ArgmaxFinish.laneBest (values C Lg S) (indices C Lg S) tid) ∧
      Origin C Lg S (Metal.Kernels.ArgmaxFinish.laneBest (values C Lg S) (indices C Lg S) tid) ∧
      ∀ t < 243, t % 128 = tid →
        Dom (Metal.Kernels.ArgmaxFinish.laneBest (values C Lg S) (indices C Lg S) tid) (tileBest C Lg S t) := by
  have hc : ∀ j < Kernels.Argmax.count tid 243,
      Metal.Kernels.ArgmaxFinish.cand (values C Lg S) (indices C Lg S) (tid + 128 * j) = tileBest C Lg S (tid + 128 * j) :=
    fun j hj => cand_finish C Lg S _ (by unfold Kernels.Argmax.count at hj; omega)
  have hvis : ∀ j < Kernels.Argmax.count tid 243,
      Valid (Metal.Kernels.ArgmaxFinish.cand (values C Lg S) (indices C Lg S) (tid + 128 * j)) := by
    intro j hj
    rw [hc j hj]
    exact (tile_partial C Lg S hv _ (by unfold Kernels.Argmax.count at hj; omega)).1
  refine ⟨(scan_pair _ _ _ hvis).1, ?_, ?_⟩
  · unfold Metal.Kernels.ArgmaxFinish.laneBest
    rcases scan_origin (Metal.Kernels.ArgmaxFinish.cand (values C Lg S) (indices C Lg S)) tid
      (Kernels.Argmax.count tid 243) with h | ⟨j, hj, h⟩
    · exact Or.inl h
    · rw [h, hc j hj]
      exact (tile_partial C Lg S hv _ (by unfold Kernels.Argmax.count at hj; omega)).2.1
  · intro t ht htl
    have hj : t / 128 < Kernels.Argmax.count tid 243 := by unfold Kernels.Argmax.count; omega
    have := scan_dominates _ tid _ hvis _ hj
    rwa [show tid + 128 * (t / 128) = t by omega, cand_finish C Lg S t ht] at this

theorem simd_finish (s : Nat) :
    Valid (Metal.Kernels.ArgmaxFinish.simdBest (values C Lg S) (indices C Lg S) s) ∧
      Origin C Lg S (Metal.Kernels.ArgmaxFinish.simdBest (values C Lg S) (indices C Lg S) s) ∧
      ∀ t < 243, t % 128 / 32 = s →
        Dom (Metal.Kernels.ArgmaxFinish.simdBest (values C Lg S) (indices C Lg S) s) (tileBest C Lg S t) := by
  have hl := fun j : Fin 32 => lane_finish C Lg S hv (32 * s + j.val)
  obtain ⟨hvt, hdt⟩ := simd_tree _ (fun j => (hl j).1)
  refine ⟨hvt, tree_origin 32 (Origin C Lg S) _ _ (fun j => (hl j).2.1) 0, fun t ht hts => ?_⟩
  exact Mlx.Argmax.dominates_trans (hdt ⟨t % 32, by omega⟩)
    ((hl ⟨t % 32, by omega⟩).2.2 t ht (by simp only; omega))

/-- **The finish kernel's candidate is `-INFINITY` or a logit's candidate, and dominates every logit's candidate.** -/
theorem group_finish :
    Origin C Lg S (Metal.Kernels.ArgmaxFinish.groupBest (values C Lg S) (indices C Lg S)) ∧
      ∀ i < 248320, Dom (Metal.Kernels.ArgmaxFinish.groupBest (values C Lg S) (indices C Lg S)) (cand C Lg S i) := by
  have hs := fun s : Fin 4 => simd_finish C Lg S hv s
  have hm : ∀ j : Fin 4, restrict (Metal.Kernels.ArgmaxFinish.merged (values C Lg S) (indices C Lg S)) j =
      Metal.Kernels.ArgmaxFinish.simdBest (values C Lg S) (indices C Lg S) j := by
    intro j; unfold restrict Metal.Kernels.ArgmaxFinish.merged; rw [ite_eq_left (by simp only; omega)]
  obtain ⟨-, hdt⟩ := merge_tree _ (fun j => by rw [hm]; exact (hs j).1)
  refine ⟨tree_origin 4 (Origin C Lg S) _ _ (fun j => ?_) 0, fun i hi => ?_⟩
  · unfold Metal.Kernels.ArgmaxFinish.merged
    split
    · exact (simd_finish C Lg S hv j).2.1
    · exact Or.inl rfl
  · have ht : i / 1024 < 243 := by omega
    have hd := hdt ⟨i / 1024 % 128 / 32, by omega⟩
    rw [hm] at hd
    exact Mlx.Argmax.dominates_trans (Mlx.Argmax.dominates_trans hd
      ((hs ⟨i / 1024 % 128 / 32, by omega⟩).2.2 _ ht rfl)) ((tile_partial C Lg S hv _ ht).2.2 i hi rfl)

end Finish

/-! ## The selected index is the model's sample -/

section Sample
open Metal.Kernels.ArgmaxPartial
variable (C : M1Max.Contract) (Lg S : ByteMemory.Bytes)

/-- Each machine score is the model's normalized score when the buffers decode to the logits and their logsumexp
(the logits finite and bounded as `GlueKernels.normalized_argmax` requires). -/
theorem score_eq (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF)
    (bound : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ) ^ (23 : Nat))
    (hn : Model.isFinite (LogSumExpRanges.value p logits) = true ∧
      |Model.toReal (LogSumExpRanges.value p logits)| ≤ (2 : ℝ) ^ (24 : Nat))
    (hfin : ∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value p logits)).isFinite = true)
    (hLg : ∀ i : Fin 248320, logit Lg i.val = logits i) (hS : lseOf S = LogSumExpRanges.value p logits)
    (i : Fin 248320) : score C Lg S i.val = NormalizedScores.value (logits i) (LogSumExpRanges.value p logits) := by
  have hs : Model.isFinite (NormalizedScores.stored (logits i) (LogSumExpRanges.value p logits)) = true :=
    BFloat16Arithmetic.finite_flush _ (NormalizedScores.raw_finite _ _ (bound i) hn)
  unfold score
  rw [hLg, hS, C.bfsub_model _ _ (bound i).1 hn.1]
  rw [show BFloat16Arithmetic.sub (logits i) (LogSumExpRanges.value p logits) =
    NormalizedScores.stored (logits i) (LogSumExpRanges.value p logits) from rfl, C.widen_model _ hs]
  unfold nanToNegInf
  have hnan : Model.isNaN (model (BFloat16.widen (NormalizedScores.stored (logits i) (LogSumExpRanges.value p logits)))) =
      false :=
    Model.isNaN_eq_false_of_isFinite_eq_true _ (by rw [finite_model]; exact hfin i)
  rw [ite_eq_right (by rw [hnan]; decide)]
  rfl

/-- **The composed kernels select the model's token**: the finish kernel's index on the partial kernel's outputs is
`GreedySampling.sample p logits`. -/
theorem index_eq (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p) (logits : Fin 248320 → BF)
    (bound : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ) ^ (23 : Nat))
    (hLg : ∀ i : Fin 248320, logit Lg i.val = logits i) (hS : lseOf S = LogSumExpRanges.value p logits) :
    (Metal.Kernels.ArgmaxFinish.groupBest (values C Lg S) (indices C Lg S)).2 = GreedySampling.sample p logits := by
  have hn := (LogSumExpRanges.bf16_ranges p primitive logits bound).2
  obtain ⟨-, hfin, sel, hsel, hmax, htie⟩ := GreedySampling.correct p primitive logits bound
  have hscore := score_eq C Lg S p logits bound hn hfin hLg hS
  have hv : ∀ i < 248320, (score C Lg S i).isFinite = true := fun i hi => by rw [hscore ⟨i, hi⟩]; exact hfin _
  have hflush : ∀ i : Fin 248320, FlushToZero.flush (score C Lg S i.val) = score C Lg S i.val := fun i => by
    rw [hscore]; exact NormalizedScores.value_flush _ _ (bound i) hn
  have hsem : ∀ i : Fin 248320, ArgmaxPairs.semantic (toPair (cand C Lg S i.val)) =
      ⟨(GreedySampling.score p logits i : WithBot ℝ), i.val⟩ := by
    intro i
    unfold toPair cand ArgmaxPairs.semantic
    simp only [hscore i, hfin i, ite_true, NormalizedScores.value_flush _ _ (bound i) hn, GreedySampling.score]
  obtain ⟨hO, hD⟩ := group_finish C Lg S hv
  rcases hO with hE | ⟨j, hj, hF⟩
  · exfalso
    have h0 := hD 0 (by decide)
    unfold Dom at h0
    replace h0 := h0.1
    rw [hE, toPair_empty, hsem ⟨0, by decide⟩] at h0
    exact WithBot.not_coe_le_bot _ h0
  · rw [hF, hsel]
    have hd := hD sel.val sel.isLt
    unfold Dom at hd
    rw [hF, hsem ⟨j, hj⟩, hsem sel] at hd
    obtain ⟨hle, htie'⟩ := hd
    have hge := hmax ⟨j, hj⟩
    have heq : GreedySampling.score p logits sel = GreedySampling.score p logits ⟨j, hj⟩ :=
      le_antisymm (WithBot.coe_le_coe.mp hle) hge
    have h1 := htie' (congrArg WithBot.some heq.symm)
    have h2 := htie ⟨j, hj⟩ heq
    show j = sel.val
    simp only at h1 h2
    omega

/-- The output bytes of a token. -/
def tokenBytes (n : Nat) (b : Nat) : BitVec 8 := if b < 4 then (wordBytes 4 n).getD b 0 else 0

/-- **Under the GPU assumption the partial launch followed by the finish launch on its outputs returns the bytes of the
model's sample** `GreedySampling.sample p logits`, when `logits` and `lse` decode to the logits and their
logsumexp (`Primitives p` and the logit bound as in `GlueKernels.normalized_argmax`). -/
theorem gpu_model (G : Gpu C) (hmaxP : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxPartialText)
    (hmaxF : 128 ≤ G.maxThreads Metal.Elab.Tests.argmaxFinishText) (a0 a1 b0 b1 : Nat) (ha0 : 2 ∣ a0) (ha1 : 2 ∣ a1)
    (hb0 : 4 ∣ b0) (hb1 : 4 ∣ b1) (p : LogSumExpRanges.Platform) (primitive : LogSumExpRanges.Primitives p)
    (logits : Fin 248320 → BF)
    (bound : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ) ^ (23 : Nat))
    (hLg : ∀ i : Fin 248320, logit Lg i.val = logits i) (hS : lseOf S = LogSumExpRanges.value p logits) :
    (G.execute Metal.Elab.Tests.argmaxPartialText (31104, 1, 1) (128, 1, 1)
        [⟨.device, 496640, a0, Lg⟩, ⟨.constant, 2, a1, S⟩] [972, 972]).bind (fun outs =>
      match outs with
      | [V, X] => G.execute Metal.Elab.Tests.argmaxFinishText (128, 1, 1) (128, 1, 1)
          [⟨.device, 972, b0, V⟩, ⟨.device, 972, b1, X⟩] [4]
      | _ => none) =
      some [tokenBytes (GreedySampling.sample p logits)] := by
  rw [Metal.Kernels.ArgmaxPartial.gpu_output C G hmaxP Lg S a0 a1 ha0 ha1]
  simp only [Option.bind_some]
  rw [Metal.Kernels.ArgmaxFinish.gpu_output C G hmaxF _ _ b0 b1 hb0 hb1]
  congr 2
  funext b
  unfold Metal.Kernels.ArgmaxFinish.expected tokenBytes
  rw [index_eq C Lg S p primitive logits bound hLg hS]

end Sample

/-! ## Values: the route's `Flat` inputs and readback -/

section Values
open Host.Mlx Metal.Kernels.ArgmaxPartial

/-- Buffers holding the row-major bytes of values that `GlueKernels.normalized_argmax`'s hypotheses (and
`GlueKernels.logsumexp_value`'s conclusion) describe decode to the logits and their logsumexp. -/
theorem decodes_of_values (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (l s : Value)
    (hl : Flat l [1, 248320] logits) (hs : Flat s [1, 1] (fun _ : Fin 1 => LogSumExpRanges.value p logits)) :
    (∀ i : Fin 248320, logit l.storageByte i.val = logits i) ∧ lseOf s.storageByte = LogSumExpRanges.value p logits := by
  constructor
  · intro i
    unfold logit Metal.cells
    rw [storage2 l hl.1, ofBf16Bits_mod]
    exact hl.2.2 i
  · unfold lseOf Metal.cells
    have := storage2 s hs.1 0
    rw [Nat.mul_zero] at this
    rw [this, ofBf16Bits_mod]
    exact hs.2.2 0

/-- The token bytes read back as the route reads them are `GlueKernels.normalized_argmax`'s conclusion. -/
theorem readback (n : Nat) (hn : n < 2 ^ 32) : (wordArray .uint32 (tokenBytes n) 0 [1]).elems 0 = n := by
  change (ByteMemory.load32 (tokenBytes n) (4 * 0)).toNat = n
  rw [load32_wordBytes _ 0 n (fun k hk => by unfold tokenBytes; rw [ite_eq_left (by omega), Nat.mul_zero, Nat.zero_add]),
    BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn]

end Values

end Metal.Bridge.Argmax
