import contracts.mlx.Reduction

namespace Inference.Contracts.Mlx.Argmax

-- Order-level specification for the shader's score/index pair reduction.
-- Its floating-point comparison refinement and launch coverage are separate
-- obligations. The score order may include a bottom value for -infinity.
structure Candidate (α : Type) where
  score : α
  index : Nat

variable {α : Type} [LinearOrder α]

def better (x y : Candidate α) : Bool :=
  decide (y.score < x.score ∨ (x.score = y.score ∧ x.index < y.index))
def choose (x y : Candidate α) : Candidate α := if better x y then x else y
def Dominates (x y : Candidate α) : Prop :=
  y.score ≤ x.score ∧ (x.score = y.score → x.index ≤ y.index)

theorem dominates_refl (x : Candidate α) : Dominates x x := ⟨le_refl _, fun _ => le_refl _⟩
theorem dominates_trans {x y z : Candidate α} (xy : Dominates x y) (yz : Dominates y z) : Dominates x z := by
  refine ⟨yz.1.trans xy.1, ?_⟩
  intro he
  have hxy : x.score = y.score := le_antisymm (he ▸ yz.1) xy.1
  have hyz : y.score = z.score := hxy.symm.trans he
  exact (xy.2 hxy).trans (yz.2 hyz)

theorem dominates_antisymm {x y : Candidate α} (xy : Dominates x y) (yx : Dominates y x) : x = y := by
  have hs := le_antisymm yx.1 xy.1
  have hi := Nat.le_antisymm (xy.2 hs) (yx.2 hs.symm)
  cases x
  cases y
  simp_all

theorem choose_member (x y : Candidate α) : choose x y = x ∨ choose x y = y := by
  unfold choose
  split <;> simp

theorem choose_dominates (x y : Candidate α) : Dominates (choose x y) x ∧ Dominates (choose x y) y := by
  unfold choose
  split
  · rename_i h
    have hb := of_decide_eq_true (show decide (_ ∨ _) = true from h)
    refine ⟨dominates_refl x, ?_⟩
    rcases hb with hlt | ⟨he, hi⟩
    · exact ⟨hlt.le, fun he => False.elim ((ne_of_gt hlt) he)⟩
    · exact ⟨he.ge, fun _ => hi.le⟩
  · rename_i h
    have hb : ¬(y.score < x.score ∨ (x.score = y.score ∧ x.index < y.index)) := by
      simpa only [better, decide_eq_true_eq] using h
    refine ⟨⟨le_of_not_gt (fun hlt => hb (Or.inl hlt)), ?_⟩, dominates_refl y⟩
    intro he
    exact le_of_not_gt (fun hi => hb (Or.inr ⟨he.symm, hi⟩))

theorem choose_comm (x y : Candidate α) : choose x y = choose y x := by
  apply dominates_antisymm
  · rcases choose_member y x with h | h <;> rw [h]
    · exact (choose_dominates x y).2
    · exact (choose_dominates x y).1
  · rcases choose_member x y with h | h <;> rw [h]
    · exact (choose_dominates y x).2
    · exact (choose_dominates y x).1

def scan (values : List (Candidate α)) (initial : Candidate α) : Candidate α :=
  values.foldl (fun best value => choose value best) initial

theorem scan_spec (values : List (Candidate α)) (initial : Candidate α) :
    (scan values initial = initial ∨ scan values initial ∈ values) ∧
      Dominates (scan values initial) initial ∧ ∀ value ∈ values, Dominates (scan values initial) value := by
  induction values generalizing initial with
  | nil => exact ⟨Or.inl rfl, dominates_refl initial, by simp⟩
  | cons value rest ih =>
    have h := ih (choose value initial)
    change (scan rest (choose value initial) = initial ∨ scan rest (choose value initial) ∈ value::rest) ∧ _
    refine ⟨?_, dominates_trans h.2.1 (choose_dominates value initial).2, ?_⟩
    · rcases h.1 with he | hm
      · rw [he]
        rcases choose_member value initial with hv | hi
        · exact Or.inr (by simp [hv])
        · exact Or.inl hi
      · exact Or.inr (List.mem_cons_of_mem value hm)
    · intro x hx
      rcases List.mem_cons.mp hx with he | hx
      · subst x
        exact dominates_trans h.2.1 (choose_dominates value initial).1
      · exact h.2.2 x hx

def tree (input : Fin n → Candidate α) : Reduction.Tree n → Candidate α
  | .leaf i => input i
  | .add left right => choose (tree input left) (tree input right)

theorem tree_spec (input : Fin n → Candidate α) (t : Reduction.Tree n) :
    (∃ i ∈ Reduction.leaves t, tree input t = input i) ∧
      ∀ i ∈ Reduction.leaves t, Dominates (tree input t) (input i) := by
  induction t with
  | leaf i =>
    refine ⟨⟨i, by simp [Reduction.leaves], rfl⟩, ?_⟩
    intro j hj
    have he : j = i := List.mem_singleton.mp hj
    subst j
    exact dominates_refl (input i)
  | add left right il ir =>
    refine ⟨?_, ?_⟩
    · rcases choose_member (tree input left) (tree input right) with hl | hr
      · obtain ⟨i, hi, he⟩ := il.1
        exact ⟨i, List.mem_append_left _ hi, hl.trans he⟩
      · obtain ⟨i, hi, he⟩ := ir.1
        exact ⟨i, List.mem_append_right _ hi, hr.trans he⟩
    · intro i hi
      rcases List.mem_append.mp hi with hl | hr
      · exact dominates_trans (choose_dominates _ _).1 (il.2 i hl)
      · exact dominates_trans (choose_dominates _ _).2 (ir.2 i hr)

theorem tree_complete (input : Fin n → Candidate α) (t : Reduction.Tree n)
    (coverage : (Reduction.leaves t).Perm (List.finRange n)) :
    (∃ i, tree input t = input i) ∧ ∀ i, Dominates (tree input t) (input i) := by
  have h := tree_spec input t
  exact ⟨let ⟨i, _, hi⟩ := h.1; ⟨i, hi⟩,
    fun i => h.2 i (coverage.mem_iff.mpr (by simp))⟩

-- An explicit decision contract for numerical accuracy: if the observed
-- winner's margin exceeds the two error bounds, rounding cannot change it.
theorem observed_margin (actual target error : Fin n → ℝ) (winner : Fin n)
    (approximation : ∀ i, |actual i-target i| ≤ error i)
    (margin : ∀ i, i ≠ winner → error winner + error i < actual winner-actual i) :
    ∀ i, i ≠ winner → target i < target winner := by
  intro i different
  have hw := abs_le.mp (approximation winner)
  have hi := abs_le.mp (approximation i)
  have hm := margin i different
  linarith

theorem target_margin (actual target error : Fin n → ℝ) (winner selected : Fin n)
    (approximation : ∀ i, |actual i-target i| ≤ error i)
    (maximum : ∀ i, actual i ≤ actual selected)
    (margin : ∀ i, i ≠ winner → target i + error i < target winner-error winner) : selected = winner := by
  by_contra different
  have hw := abs_le.mp (approximation winner)
  have hs := abs_le.mp (approximation selected)
  have hm := margin selected different
  have ho := maximum winner
  linarith

end Inference.Contracts.Mlx.Argmax
