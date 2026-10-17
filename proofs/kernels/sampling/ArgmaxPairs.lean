import contracts.mlx.Argmax
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Proof

namespace Inference.Kernels.Sampling.ArgmaxPairs
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- The shader's -infinity sentinel is represented by none. Some values
-- carry finite binary32 scores, including either sign of zero. NaN cleanup
-- and the normalized-score arithmetic are separate source operations.
structure Candidate where
  score : Option Float32
  index : Nat
def Finite (x : Candidate) : Prop := ∀ value, x.score = some value → value.isFinite = true

def better (x y : Candidate) : Bool :=
  match x.score, y.score with
  | none, none => decide (x.index < y.index)
  | some _, none => true
  | none, some _ => false
  | some a, some b => decide (Model.compare (model a) (model b) = some .gt) ||
      (decide (Model.compare (model a) (model b) = some .eq) && decide (x.index < y.index))
def choose (x y : Candidate) : Candidate := if better x y then x else y

noncomputable def semantic (x : Candidate) : Argmax.Candidate (WithBot ℝ) where
  score := match x.score with | none => ⊥ | some value => (real value : WithBot ℝ)
  index := x.index

theorem better_semantic (x y : Candidate) (hx : Finite x) (hy : Finite y) :
    better x y = Argmax.better (semantic x) (semantic y) := by
  cases ha : x.score with
  | none =>
    cases hb : y.score <;> simp [better, semantic, ha, hb, Argmax.better]
  | some a =>
    cases hb : y.score with
    | none => simp [better, semantic, ha, hb, Argmax.better]
    | some b =>
      have haf : Model.isFinite (model a) = true := by rw [finite_model]; exact hx a ha
      have hbf : Model.isFinite (model b) = true := by rw [finite_model]; exact hy b hb
      have he := Model.compare_eq_some_eq_iff_toReal_eq_of_isFinite (model a) (model b) haf hbf
      have hg := Model.compare_eq_some_gt_iff_toReal_gt_of_isFinite (model a) (model b) haf hbf
      apply Bool.eq_iff_iff.mpr
      simp only [better, ha, hb, Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq,
        Argmax.better, semantic, WithBot.coe_lt_coe, WithBot.coe_eq_coe, he, hg, real]

theorem choose_finite (x y : Candidate) (hx : Finite x) (hy : Finite y) : Finite (choose x y) := by
  unfold choose
  split <;> assumption

theorem choose_preserves (predicate : Candidate → Prop) (x y : Candidate)
    (hx : predicate x) (hy : predicate y) : predicate (choose x y) := by
  unfold choose
  split <;> assumption

theorem choose_semantic (x y : Candidate) (hx : Finite x) (hy : Finite y) :
    semantic (choose x y) = Argmax.choose (semantic x) (semantic y) := by
  unfold choose Argmax.choose
  rw [better_semantic x y hx hy]
  split <;> rfl

def scan (values : List Candidate) (initial : Candidate) : Candidate :=
  values.foldl (fun best value => choose value best) initial

theorem scan_finite (values : List Candidate) (initial : Candidate)
    (hi : Finite initial) (hv : ∀ value ∈ values, Finite value) : Finite (scan values initial) := by
  induction values generalizing initial with
  | nil => exact hi
  | cons value rest ih =>
    exact ih (choose value initial) (choose_finite _ _ (hv value (by simp)) hi)
      (fun v h => hv v (by simp [h]))

theorem scan_semantic (values : List Candidate) (initial : Candidate)
    (hi : Finite initial) (hv : ∀ value ∈ values, Finite value) :
    semantic (scan values initial) = Argmax.scan (values.map semantic) (semantic initial) := by
  induction values generalizing initial with
  | nil => rfl
  | cons value rest ih =>
    change semantic (scan rest (choose value initial)) =
      Argmax.scan (rest.map semantic) (Argmax.choose (semantic value) (semantic initial))
    rw [ih (choose value initial) (choose_finite _ _ (hv value (by simp)) hi)
      (fun v h => hv v (by simp [h])), choose_semantic value initial (hv value (by simp)) hi]

theorem scan_preserves (predicate : Candidate → Prop) (values : List Candidate) (initial : Candidate)
    (hi : predicate initial) (hv : ∀ value ∈ values, predicate value) : predicate (scan values initial) := by
  induction values generalizing initial with
  | nil => exact hi
  | cons value rest ih =>
    exact ih (choose value initial) (choose_preserves _ _ _ (hv value (by simp)) hi)
      (fun v h => hv v (by simp [h]))

theorem scan_dominates (values : List Candidate) (initial : Candidate)
    (hi : Finite initial) (hv : ∀ value ∈ values, Finite value) (value : Candidate) (member : value ∈ values) :
    Argmax.Dominates (semantic (scan values initial)) (semantic value) := by
  rw [scan_semantic values initial hi hv]
  exact (Argmax.scan_spec (values.map semantic) (semantic initial)).2.2 _ (List.mem_map.mpr ⟨value, member, rfl⟩)

def tree (input : Fin n → Candidate) : Reduction.Tree n → Candidate
  | .leaf i => input i
  | .add left right => choose (tree input left) (tree input right)

theorem tree_finite (input : Fin n → Candidate) (t : Reduction.Tree n)
    (hi : ∀ i, Finite (input i)) : Finite (tree input t) := by
  induction t with
  | leaf i => exact hi i
  | add left right il ir => exact choose_finite _ _ il ir

theorem tree_preserves (predicate : Candidate → Prop) (input : Fin n → Candidate) (t : Reduction.Tree n)
    (hi : ∀ i, predicate (input i)) : predicate (tree input t) := by
  induction t with
  | leaf i => exact hi i
  | add left right il ir => exact choose_preserves _ _ _ il ir

theorem tree_semantic (input : Fin n → Candidate) (t : Reduction.Tree n)
    (hi : ∀ i, Finite (input i)) : semantic (tree input t) = Argmax.tree (fun i => semantic (input i)) t := by
  induction t with
  | leaf i => rfl
  | add left right il ir =>
    rw [tree, choose_semantic _ _ (tree_finite input left hi) (tree_finite input right hi), il, ir]
    rfl

theorem tree_correct (input : Fin n → Candidate) (t : Reduction.Tree n)
    (hi : ∀ i, Finite (input i)) (coverage : (Reduction.leaves t).Perm (List.finRange n)) :
    ∀ i, Argmax.Dominates (semantic (tree input t)) (semantic (input i)) := by
  rw [tree_semantic input t hi]
  exact (Argmax.tree_complete _ t coverage).2

def sentinel : Candidate := ⟨none, 0xffffffff⟩
theorem sentinel_finite : Finite sentinel := by intro x h; cases h
theorem sentinel_loses_tie (x : Candidate) (hx : x.score = none) (index : x.index < 0xffffffff) :
    choose x sentinel = x := by simp [choose, better, hx, sentinel, index]

end Inference.Kernels.Sampling.ArgmaxPairs
