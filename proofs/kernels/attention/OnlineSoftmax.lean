import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.List.Basic

namespace Inference.Kernels.Attention.OnlineSoftmax
noncomputable section

-- Exact mathematical invariant behind MLX's incremental and parallel SDPA.
-- The shift is allowed to be any real number. Consequently a floating-point
-- maximum can serve as the reference shift without assuming it is exact for
-- the ideal scores. It cancels from the final normalized attention value.
structure Summary where
  shift : ℝ
  denominator : ℝ
  numerator : ℝ

def denominator (score : α → ℝ) (indices : List α) (shift : ℝ) : ℝ :=
  (indices.map (fun i => Real.exp (score i - shift))).sum

def numerator (score value : α → ℝ) (indices : List α) (shift : ℝ) : ℝ :=
  (indices.map (fun i => Real.exp (score i - shift) * value i)).sum

def reference (score value : α → ℝ) (indices : List α) (shift : ℝ) : Summary :=
  ⟨shift, denominator score indices shift, numerator score value indices shift⟩

def rescale (s : Summary) (shift : ℝ) : Summary :=
  ⟨shift, Real.exp (s.shift - shift) * s.denominator, Real.exp (s.shift - shift) * s.numerator⟩

def append (s : Summary) (score value shift : ℝ) : Summary :=
  ⟨shift, s.denominator * Real.exp (s.shift - shift) + Real.exp (score - shift),
    s.numerator * Real.exp (s.shift - shift) + Real.exp (score - shift) * value⟩

def merge (a b : Summary) (shift : ℝ) : Summary :=
  ⟨shift, a.denominator * Real.exp (a.shift - shift) + b.denominator * Real.exp (b.shift - shift),
    a.numerator * Real.exp (a.shift - shift) + b.numerator * Real.exp (b.shift - shift)⟩

def normalized (s : Summary) : ℝ := s.numerator / s.denominator

def softmaxWeighted (score value : α → ℝ) (indices : List α) : ℝ :=
  (indices.map (fun i => Real.exp (score i) * value i)).sum / (indices.map (fun i => Real.exp (score i))).sum

theorem exponential_rescale (score oldShift newShift : ℝ) :
    Real.exp (oldShift - newShift) * Real.exp (score - oldShift) = Real.exp (score - newShift) := by
  rw [← Real.exp_add]
  congr 1
  ring

theorem denominator_rescale (score : α → ℝ) (indices : List α) (oldShift newShift : ℝ) :
    Real.exp (oldShift - newShift) * denominator score indices oldShift = denominator score indices newShift := by
  induction indices with
  | nil => simp [denominator]
  | cons i rest ih =>
    simp only [denominator, List.map_cons, List.sum_cons] at ih ⊢
    rw [mul_add, exponential_rescale, ih]

theorem numerator_rescale (score value : α → ℝ) (indices : List α) (oldShift newShift : ℝ) :
    Real.exp (oldShift - newShift) * numerator score value indices oldShift = numerator score value indices newShift := by
  induction indices with
  | nil => simp [numerator]
  | cons i rest ih =>
    simp only [numerator, List.map_cons, List.sum_cons] at ih ⊢
    rw [mul_add, ← mul_assoc, exponential_rescale, ih]

theorem rescale_correct (score value : α → ℝ) (indices : List α) (oldShift newShift : ℝ) :
    rescale (reference score value indices oldShift) newShift = reference score value indices newShift := by
  simp only [rescale, reference, denominator_rescale, numerator_rescale]

theorem append_correct (score value : α → ℝ) (indices : List α) (i : α) (oldShift newShift : ℝ) :
    append (reference score value indices oldShift) (score i) (value i) newShift =
      reference score value (indices ++ [i]) newShift := by
  have hd := denominator_rescale score indices oldShift newShift
  have hn := numerator_rescale score value indices oldShift newShift
  simp only [append, reference]
  congr 1
  · rw [mul_comm, hd]
    simp [denominator, List.map_append, List.sum_append]
  · rw [mul_comm, hn]
    simp [numerator, List.map_append, List.sum_append]

theorem merge_correct (score value : α → ℝ) (left right : List α) (leftShift rightShift shift : ℝ) :
    merge (reference score value left leftShift) (reference score value right rightShift) shift =
      reference score value (left ++ right) shift := by
  simp only [merge, reference]
  congr 1
  · rw [mul_comm (denominator _ _ _), denominator_rescale,
      mul_comm (denominator _ _ _), denominator_rescale]
    simp [denominator, List.map_append, List.sum_append]
  · rw [mul_comm (numerator _ _ _ _), numerator_rescale,
      mul_comm (numerator _ _ _ _), numerator_rescale]
    simp [numerator, List.map_append, List.sum_append]

-- Covers any choice of maximum or shift update and every input ordering.
-- The numerical proof will instantiate choose with the source's actual max.
def run (choose : ℝ → ℝ → ℝ) (score value : α → ℝ) (indices : List α) (initial : Summary) : Summary :=
  indices.foldl (fun s i => append s (score i) (value i) (choose s.shift (score i))) initial

theorem run_correct (choose : ℝ → ℝ → ℝ) (score value : α → ℝ) (indices processed : List α) (shift : ℝ) :
    run choose score value indices (reference score value processed shift) =
      reference score value (processed ++ indices) (run choose score value indices (reference score value processed shift)).shift := by
  induction indices generalizing processed shift with
  | nil => simp [run, reference]
  | cons i rest ih =>
    change run choose score value rest (append (reference score value processed shift) (score i) (value i) (choose shift (score i))) =
      reference score value (processed ++ i :: rest)
        (run choose score value rest (append (reference score value processed shift) (score i) (value i) (choose shift (score i)))).shift
    simp only [append_correct]
    simpa only [List.append_assoc, List.singleton_append] using ih (processed ++ [i]) (choose shift (score i))

theorem normalized_reference (score value : α → ℝ) (indices : List α) (shift : ℝ) :
    normalized (reference score value indices shift) = softmaxWeighted score value indices := by
  have hd := denominator_rescale score indices 0 shift
  have hn := numerator_rescale score value indices 0 shift
  simp only [normalized, reference, ← hd, ← hn]
  rw [mul_div_mul_left _ _ (Real.exp_ne_zero _)]
  simp [denominator, numerator, softmaxWeighted]

theorem run_softmax (choose : ℝ → ℝ → ℝ) (score value : α → ℝ) (indices : List α) (shift : ℝ) :
    normalized (run choose score value indices (reference score value [] shift)) = softmaxWeighted score value indices := by
  rw [run_correct]
  simp only [List.nil_append, normalized_reference]

theorem merge_softmax (score value : α → ℝ) (left right : List α) (leftShift rightShift shift : ℝ) :
    normalized (merge (reference score value left leftShift) (reference score value right rightShift) shift) =
      softmaxWeighted score value (left ++ right) := by rw [merge_correct, normalized_reference]

theorem denominator_nonnegative (score : α → ℝ) (indices : List α) (shift : ℝ) : 0 ≤ denominator score indices shift := by
  induction indices with
  | nil => simp [denominator]
  | cons i rest ih => simpa only [denominator, List.map_cons, List.sum_cons] using add_nonneg (Real.exp_pos _).le ih

theorem denominator_positive (score : α → ℝ) (indices : List α) (shift : ℝ) (hne : indices ≠ []) :
    0 < denominator score indices shift := by
  cases indices with
  | nil => exact False.elim (hne rfl)
  | cons i rest =>
    simpa only [denominator, List.map_cons, List.sum_cons] using add_pos_of_pos_of_nonneg (Real.exp_pos _) (denominator_nonnegative score rest shift)

-- Row partitions can be flattened in any order because this is a theorem
-- about real sums. It does not reassociate the source's rounded reductions.
theorem reference_permutation (score value : α → ℝ) (a b : List α) (hp : a.Perm b) (shift : ℝ) :
    reference score value a shift = reference score value b shift := by
  unfold reference denominator numerator
  rw [(hp.map _).sum_eq, (hp.map _).sum_eq]

end
end Inference.Kernels.Attention.OnlineSoftmax
