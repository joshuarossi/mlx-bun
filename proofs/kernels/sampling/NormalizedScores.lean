import kernels.sampling.ArgmaxPairs
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Kernels.Sampling.NormalizedScores
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- The BF16 route subtracts the row's logsumexp, stores a BF16 normalized
-- score, and widens that score for pair comparison. This preserves
-- rounding-created ties instead of silently selecting from raw logits.
def stored (logit normalizer : BF) : BF := BFloat16Arithmetic.sub logit normalizer
def value (logit normalizer : BF) : Float32 := BFloat16.widen (stored logit normalizer)
noncomputable def budget (logit normalizer : BF) (inputError : ℝ) : ℝ :=
  BFloat16Arithmetic.subBudget logit normalizer + inputError

private def cap : BF := BFloat16DyadicBounds.ceiling 1 25
private theorem cap_range : Model.isFinite cap = true ∧ Model.toReal cap = (2 : ℝ)^(25 : Nat) := by
  simpa only [cap, Nat.cast_one, one_mul, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 1 25 (by decide) (by decide) (by decide)

theorem raw_finite (logit normalizer : BF)
    (hl : Model.isFinite logit = true ∧ |Model.toReal logit| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat)) :
    Model.isFinite (Model.sub (BFloat16Arithmetic.flush logit) (BFloat16Arithmetic.flush normalizer)) = true := by
  apply Model.isFinite_sub_of_abs_toReal_sub_le_posMaxFinite _ _ (by decide)
    (BFloat16Arithmetic.finite_flush _ hl.1) (BFloat16Arithmetic.finite_flush _ hn.1)
  apply ((abs_sub _ _).trans (add_le_add (BFloat16Arithmetic.flush_abs_le logit)
    (BFloat16Arithmetic.flush_abs_le normalizer))).trans
  apply le_trans _ (BFloat16Bounds.ceiling_max cap cap_range.1)
  rw [cap_range.2]
  linarith [hl.2, hn.2]

theorem ranges (logit normalizer : BF)
    (hl : Model.isFinite logit = true ∧ |Model.toReal logit| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat)) :
    (value logit normalizer).isFinite = true ∧ |real (value logit normalizer)| ≤ (2 : ℝ)^(25 : Nat) := by
  have hf := raw_finite logit normalizer hl hn
  have hs : Model.isFinite (stored logit normalizer) = true := BFloat16Arithmetic.finite_flush _ hf
  refine ⟨BFloat16.widen_finite _ hs, ?_⟩
  rw [value, BFloat16.widen_real _ hs]
  apply (BFloat16Arithmetic.flush_abs_le _).trans
  rw [Model.toReal_sub_eq_roundAt _ _ (by decide)
    (BFloat16Arithmetic.finite_flush _ hl.1) (BFloat16Arithmetic.finite_flush _ hn.1) hf]
  rw [← cap_range.2]
  apply BFloat16Bounds.rounded_bound cap cap_range.1
  apply ((abs_sub _ _).trans (add_le_add (BFloat16Arithmetic.flush_abs_le logit)
    (BFloat16Arithmetic.flush_abs_le normalizer))).trans
  rw [cap_range.2]
  linarith [hl.2, hn.2]

theorem accuracy (logit normalizer : BF)
    (hl : Model.isFinite logit = true ∧ |Model.toReal logit| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat))
    (target inputError : ℝ) (he : |Model.toReal logit-target| ≤ inputError) :
    |real (value logit normalizer) - (target-Model.toReal normalizer)| ≤ budget logit normalizer inputError := by
  have hf := raw_finite logit normalizer hl hn
  have hs : Model.isFinite (stored logit normalizer) = true := BFloat16Arithmetic.finite_flush _ hf
  have hr := BFloat16Arithmetic.sub_error logit normalizer hl.1 hn.1 hf
  rw [value, BFloat16.widen_real _ hs]
  calc
    _ = |(Model.toReal (stored logit normalizer) - (Model.toReal logit-Model.toReal normalizer)) +
        (Model.toReal logit-target)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hr he)

def candidates (logits : Fin n → BF) (normalizer : BF) (i : Fin n) : ArgmaxPairs.Candidate :=
  ⟨some (value (logits i) normalizer), i.val⟩
def select (logits : Fin n → BF) (normalizer : BF) (tree : Reduction.Tree n) : Nat :=
  (ArgmaxPairs.tree (candidates logits normalizer) tree).index

theorem candidates_finite (logits : Fin n → BF) (normalizer : BF)
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat)) :
    ∀ i, ArgmaxPairs.Finite (candidates logits normalizer i) := by
  intro i x hx
  have he : value (logits i) normalizer = x := Option.some.inj hx
  rw [← he]
  exact (ranges _ _ (hl i) hn).1

theorem select_correct (logits : Fin n → BF) (normalizer : BF) (t : Reduction.Tree n)
    (coverage : (Reduction.leaves t).Perm (List.finRange n))
    (hl : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (hn : Model.isFinite normalizer = true ∧ |Model.toReal normalizer| ≤ (2 : ℝ)^(24 : Nat)) :
    ∃ selected : Fin n, select logits normalizer t = selected.val ∧
      (∀ i, real (value (logits i) normalizer) ≤ real (value (logits selected) normalizer)) ∧
      (∀ i, real (value (logits selected) normalizer) = real (value (logits i) normalizer) → selected.val ≤ i.val) := by
  have hf := candidates_finite logits normalizer hl hn
  have h := Argmax.tree_complete (fun i => ArgmaxPairs.semantic (candidates logits normalizer i)) t coverage
  rw [← ArgmaxPairs.tree_semantic _ t hf] at h
  obtain ⟨selected, he⟩ := h.1
  refine ⟨selected, congrArg (fun x => x.index) he, ?_, ?_⟩
  · intro i
    have hi := (h.2 i).1
    rw [he] at hi
    simpa only [candidates, ArgmaxPairs.semantic, WithBot.coe_le_coe] using hi
  · intro i equal
    have hi := h.2 i
    rw [he] at hi
    exact hi.2 (by simpa only [candidates, ArgmaxPairs.semantic, WithBot.coe_eq_coe] using equal)

end Inference.Kernels.Sampling.NormalizedScores
