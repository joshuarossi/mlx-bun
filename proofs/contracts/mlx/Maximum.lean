import contracts.mlx.Reduction
import contracts.mlx.FlushToZero
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Proof

namespace Inference.Contracts.Mlx.Maximum
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FlushToZero (flush)

-- With denormals disabled, float comparison sees flushed operands.
def less (left right : Float32) : Bool := Model.compare (model (flush left)) (model (flush right)) == some .lt

theorem less_iff (left right : Float32) (hl : left.isFinite = true) (hr : right.isFinite = true) :
    less left right = true ↔ real (flush left) < real (flush right) := by
  have comparison := Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite (model (flush left)) (model (flush right))
    (by rw [finite_model]; exact FlushToZero.finite_flush _ hl) (by rw [finite_model]; exact FlushToZero.finite_flush _ hr)
  simp only [less, beq_iff_eq]
  exact comparison

-- Strict replacement matches `maxval < value ? value : maxval`, retaining
-- the previous unflushed word on a flushed tie (including signed zero and
-- subnormals).
def value (left right : Float32) : Float32 := if less left right then right else left

theorem selected (left right : Float32) : value left right = left ∨ value left right = right := by
  unfold value
  split <;> simp
theorem finite (left right : Float32) (hl : left.isFinite = true) (hr : right.isFinite = true) :
    (value left right).isFinite = true := by
  rcases selected left right with h | h <;> rw [h] <;> assumption

theorem real_value (left right : Float32) (hl : left.isFinite = true) (hr : right.isFinite = true) :
    real (flush (value left right)) = max (real (flush left)) (real (flush right)) := by
  have comparison := less_iff left right hl hr
  unfold value
  split
  · rename_i h
    exact (max_eq_right ((comparison.mp h).le)).symm
  · rename_i h
    exact (max_eq_left (le_of_not_gt (fun lt => h (comparison.mpr lt)))).symm

theorem bound (left right : Float32) (cap : ℝ)
    (hl : |real left| ≤ cap) (hr : |real right| ≤ cap) : |real (value left right)| ≤ cap := by
  rcases selected left right with h | h <;> rw [h] <;> assumption

def fold (values : List Float32) (initial : Float32) : Float32 := values.foldl value initial

theorem fold_finite (values : List Float32) (initial : Float32)
    (hi : initial.isFinite = true) (hv : ∀ x ∈ values, x.isFinite = true) : (fold values initial).isFinite = true := by
  induction values generalizing initial with
  | nil => exact hi
  | cons x rest ih => exact ih (value initial x) (finite initial x hi (hv x (by simp))) (fun v h => hv v (by simp [h]))

theorem fold_selected (values : List Float32) (initial : Float32) : fold values initial = initial ∨ fold values initial ∈ values := by
  induction values generalizing initial with
  | nil => exact Or.inl rfl
  | cons x rest ih =>
    change fold rest (value initial x) = initial ∨ fold rest (value initial x) ∈ x::rest
    rcases ih (value initial x) with he | hm
    · rw [he]
      rcases selected initial x with hi | hx
      · exact Or.inl hi
      · exact Or.inr (by simp [hx])
    · exact Or.inr (List.mem_cons_of_mem x hm)

theorem fold_dominates (values : List Float32) (initial : Float32)
    (hi : initial.isFinite = true) (hv : ∀ x ∈ values, x.isFinite = true) :
    real (flush initial) ≤ real (flush (fold values initial)) ∧
      ∀ x ∈ values, real (flush x) ≤ real (flush (fold values initial)) := by
  induction values generalizing initial with
  | nil => exact ⟨le_refl _, by simp⟩
  | cons x rest ih =>
    have hx := hv x (by simp)
    have h := ih (value initial x) (finite initial x hi hx) (fun v h => hv v (by simp [h]))
    have he := real_value initial x hi hx
    refine ⟨(le_max_left _ _).trans (he ▸ h.1), ?_⟩
    intro v hv
    rcases List.mem_cons.mp hv with heq | hm
    · subst v
      exact (le_max_right _ _).trans (he ▸ h.1)
    · exact h.2 v hm

-- A fresh value above the finite minimum sentinel ensures the result is
-- a real input word. Its bound does not have to include that sentinel.
theorem fold_bound_after_value (values : List Float32) (initial : Float32) (cap : ℝ)
    (hi : initial.isFinite = true) (hv : ∀ x ∈ values, x.isFinite = true ∧ |real x| ≤ cap)
    (fresh : ∃ x ∈ values, real (flush initial) < real (flush x)) : |real (fold values initial)| ≤ cap := by
  rcases fold_selected values initial with he | hm
  · obtain ⟨x, hx, hlt⟩ := fresh
    have h := (fold_dominates values initial hi (fun x hx => (hv x hx).1)).2 x hx
    rw [he] at h
    exact False.elim (not_lt_of_ge h hlt)
  · exact (hv _ hm).2

def tree (input : Fin n → Float32) : Reduction.Tree n → Float32
  | .leaf i => input i
  | .add left right => value (tree input left) (tree input right)
theorem tree_finite (input : Fin n → Float32) (t : Reduction.Tree n) (hi : ∀ i, (input i).isFinite = true) :
    (tree input t).isFinite = true := by
  induction t with
  | leaf i => exact hi i
  | add left right il ir => exact finite _ _ il ir

theorem tree_spec (input : Fin n → Float32) (t : Reduction.Tree n) (hi : ∀ i, (input i).isFinite = true) :
    (∃ i ∈ Reduction.leaves t, tree input t = input i) ∧
      ∀ i ∈ Reduction.leaves t, real (flush (input i)) ≤ real (flush (tree input t)) := by
  induction t with
  | leaf i =>
    refine ⟨⟨i, by simp [Reduction.leaves], rfl⟩, ?_⟩
    intro j hj
    have he : j = i := List.mem_singleton.mp hj
    subst j
    exact le_refl _
  | add left right il ir =>
    have he := real_value (tree input left) (tree input right) (tree_finite input left hi) (tree_finite input right hi)
    refine ⟨?_, ?_⟩
    · rcases selected (tree input left) (tree input right) with hl | hr
      · obtain ⟨i, hm, hv⟩ := il.1
        exact ⟨i, List.mem_append_left _ hm, hl.trans hv⟩
      · obtain ⟨i, hm, hv⟩ := ir.1
        exact ⟨i, List.mem_append_right _ hm, hr.trans hv⟩
    · intro i hm
      change real (flush (input i)) ≤ real (flush (value (tree input left) (tree input right)))

      rw [he]
      rcases List.mem_append.mp hm with hl | hr
      · exact (il.2 i hl).trans (le_max_left _ _)
      · exact (ir.2 i hr).trans (le_max_right _ _)

end Inference.Contracts.Mlx.Maximum
