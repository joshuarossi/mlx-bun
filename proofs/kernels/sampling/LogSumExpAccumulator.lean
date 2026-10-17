import contracts.mlx.ArithmeticBounds
import contracts.mlx.NonnegativeArithmetic

namespace Inference.Kernels.Sampling.LogSumExpAccumulator
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticBounds NonnegativeArithmetic

def cap (n : Nat) : Float32 := DyadicBounds.ceiling n 0
theorem cap_range (n : Nat) (hn : n < 16777216) : (cap n).isFinite = true ∧ real (cap n) = n := by
  simpa only [cap, zpow_zero, mul_one] using DyadicBounds.ceiling_range n 0 hn (by decide) (by decide)

def bind (acc factor : Float32) (terms : Fin 4 → Float32) (i : Nat) : Float32 :=
  if i = 0 then acc else if i = 1 then factor else terms ⟨(i-2)%4, by omega⟩
def inputCap (count i : Nat) : Float32 := if i = 0 then cap count else 1
def headExpr (contracted : Bool) : Expr :=
  if contracted then .fma (.input 0) (.input 1) (.input 2)
  else .add (.mul (.input 0) (.input 1)) (.input 2)
def expression (contracted : Bool) : Expr :=
  .add (.add (.add (headExpr contracted) (.input 3)) (.input 4)) (.input 5)
def update (contracted : Bool) (acc factor : Float32) (terms : Fin 4 → Float32) : Float32 :=
  evaluate (bind acc factor terms) (expression contracted)

theorem execution (contracted : Bool) (acc factor : Float32) (terms : Fin 4 → Float32) :
    update contracted acc factor terms =
      FlushToZero.add (FlushToZero.add (FlushToZero.add
        (if contracted then FlushToZero.fma acc factor (terms 0)
          else FlushToZero.add (FlushToZero.mul acc factor) (terms 0)) (terms 1)) (terms 2)) (terms 3) := by
  cases contracted <;> rfl

theorem certificate (count : Nat) (size : count+4 < 16777216) (contracted : Bool) :
    Certificate (inputCap count) (expression contracted) (cap (count+4)) := by
  have hc := cap_range count (by omega)
  have h1 := cap_range (count+1) (by omega)
  have h2 := cap_range (count+2) (by omega)
  have h3 := cap_range (count+3) (by omega)
  have h4 := cap_range (count+4) size
  have ha : Certificate (inputCap count) (.input 0) (cap count) := .input 0
  have hf : Certificate (inputCap count) (.input 1) 1 := .input 1
  have ht (i : Nat) (hi : i ≠ 0) : Certificate (inputCap count) (.input i) 1 := by
    simpa only [inputCap, hi, ite_false] using Certificate.input (inputCap := inputCap count) i
  have hh : Certificate (inputCap count) (headExpr contracted) (cap (count+1)) := by
    cases contracted
    · exact .add (.mul ha hf _ hc.1 (by rw [real_one, mul_one])) (ht 2 (by decide)) _ h1.1
        (by rw [hc.2, h1.2, real_one]; push_cast; exact le_refl _)
    · exact .fma ha hf (ht 2 (by decide)) _ h1.1
        (by rw [hc.2, h1.2, real_one]; push_cast; ring_nf; exact le_refl _)
  have hh2 := Certificate.add hh (ht 3 (by decide)) (cap (count+2)) h2.1
    (by rw [h1.2, h2.2, real_one]; push_cast; linarith)
  have hh3 := Certificate.add hh2 (ht 4 (by decide)) (cap (count+3)) h3.1
    (by rw [h2.2, h3.2, real_one]; push_cast; linarith)
  exact .add hh3 (ht 5 (by decide)) _ h4.1
    (by rw [h3.2, h4.2, real_one]; push_cast; linarith)

theorem positive_expression (contracted : Bool) (input : Nat → Float32)
    (hi : ∀ i, 0 ≤ real (input i)) : Nonnegative input (expression contracted) := by
  have hh : Nonnegative input (headExpr contracted) := by
    cases contracted
    · exact .add (.mul (.input 0 (hi 0)) (.input 1 (hi 1))) (.input 2 (hi 2))
    · exact .fma (.input 0 (hi 0)) (.input 1 (hi 1)) (.input 2 (hi 2))
  exact .add (.add (.add hh (.input 3 (hi 3))) (.input 4 (hi 4))) (.input 5 (hi 5))

theorem lower_expression (contracted : Bool) (input : Nat → Float32)
    (hi : ∀ i, 0 ≤ real (input i))
    (witness : (1 ≤ real (input 0) ∧ real (input 1) = 1) ∨
      ∃ i : Fin 4, 1 ≤ real (input (i.val+2))) : LowerOne input (expression contracted) := by
  have nh : Nonnegative input (headExpr contracted) := by
    cases contracted
    · exact .add (.mul (.input 0 (hi 0)) (.input 1 (hi 1))) (.input 2 (hi 2))
    · exact .fma (.input 0 (hi 0)) (.input 1 (hi 1)) (.input 2 (hi 2))
  have extend (h : LowerOne input (headExpr contracted)) : LowerOne input (expression contracted) :=
    .addLeft (.addLeft (.addLeft h (.input 3 (hi 3))) (.input 4 (hi 4))) (.input 5 (hi 5))
  rcases witness with old | fresh
  · apply extend
    cases contracted
    · exact .addLeft (.mulRightOne (.input 0 old.1) old.2) (.input 2 (hi 2))
    · exact .fmaProduct (.input 0 old.1) old.2 (.input 2 (hi 2))
  · obtain ⟨i, hw⟩ := fresh
    fin_cases i
    · apply extend
      cases contracted
      · exact .addRight (.mul (.input 0 (hi 0)) (.input 1 (hi 1))) (.input 2 hw)
      · exact .fmaAddend (.input 0 (hi 0)) (.input 1 (hi 1)) (.input 2 hw)
    · exact .addLeft (.addLeft (.addRight nh (.input 3 hw)) (.input 4 (hi 4))) (.input 5 (hi 5))
    · exact .addLeft (.addRight (.add nh (.input 3 (hi 3))) (.input 4 hw)) (.input 5 (hi 5))
    · exact .addRight (.add (.add nh (.input 3 (hi 3))) (.input 4 (hi 4))) (.input 5 hw)

theorem ranges (count : Nat) (size : count+4 < 16777216) (contracted : Bool)
    (acc factor : Float32) (terms : Fin 4 → Float32)
    (ha : acc.isFinite = true ∧ 0 ≤ real acc ∧ real acc ≤ count)
    (hf : factor.isFinite = true ∧ 0 ≤ real factor ∧ real factor ≤ 1)
    (ht : ∀ i, (terms i).isFinite = true ∧ 0 ≤ real (terms i) ∧ real (terms i) ≤ 1) :
    Finite (bind acc factor terms) (expression contracted) ∧
      (update contracted acc factor terms).isFinite = true ∧
      0 ≤ real (update contracted acc factor terms) ∧ real (update contracted acc factor terms) ≤ count+4 ∧
      (((1 ≤ real acc ∧ real factor = 1) ∨ ∃ i, 1 ≤ real (terms i)) →
        1 ≤ real (update contracted acc factor terms)) := by
  have hi : ∀ i, (bind acc factor terms i).isFinite = true ∧
      |real (bind acc factor terms i)| ≤ real (inputCap count i) := by
    intro i
    unfold bind inputCap
    split
    · rw [(cap_range count (by omega)).2, abs_of_nonneg ha.2.1]
      exact ⟨ha.1, ha.2.2⟩
    · split
      · rw [real_one, abs_of_nonneg hf.2.1]
        exact ⟨hf.1, hf.2.2⟩
      · rw [real_one, abs_of_nonneg (ht _).2.1]
        exact ⟨(ht _).1, (ht _).2.2⟩
  have hn : ∀ i, 0 ≤ real (bind acc factor terms i) := by
    intro i
    unfold bind
    split
    · exact ha.2.1
    · split
      · exact hf.2.1
      · exact (ht _).2.1
  have h := ArithmeticBounds.sound _ _ hi (certificate count size contracted)
  refine ⟨h.1, finite_evaluate _ _ h.1, nonnegative _ _ (positive_expression contracted _ hn) h.1, ?_, ?_⟩
  · have hb := (le_abs_self _).trans h.2
    rw [(cap_range (count+4) size).2] at hb
    simpa only [Nat.cast_add, Nat.cast_ofNat, update] using hb
  · intro hw
    apply lower_one _ _ (lower_expression contracted _ hn ?_) h.1
    rcases hw with old | fresh
    · exact Or.inl old
    · obtain ⟨i, hi⟩ := fresh
      refine Or.inr ⟨i, ?_⟩
      simpa only [bind, show i.val+2 ≠ 0 from by omega, show i.val+2 ≠ 1 from by omega,
        ite_false, Nat.add_sub_cancel, Nat.mod_eq_of_lt i.isLt] using hi

theorem rescale (count : Nat) (size : count < 16777216) (acc factor : Float32)
    (ha : acc.isFinite = true ∧ 0 ≤ real acc ∧ real acc ≤ count)
    (hf : factor.isFinite = true ∧ 0 ≤ real factor ∧ real factor ≤ 1) :
    (FlushToZero.flush acc * FlushToZero.flush factor).isFinite = true ∧
      (FlushToZero.mul acc factor).isFinite = true ∧ 0 ≤ real (FlushToZero.mul acc factor) ∧
      real (FlushToZero.mul acc factor) ≤ count ∧
      (1 ≤ real acc → real factor = 1 → 1 ≤ real (FlushToZero.mul acc factor)) := by
  have hc := cap_range count size
  have h := NativeMultiplication.range acc factor (cap count) ha.1 hf.1 hc.1 (by
    rw [abs_of_nonneg ha.2.1, abs_of_nonneg hf.2.1, hc.2]
    exact (mul_le_mul ha.2.2 hf.2.2 hf.2.1 (by positivity)).trans_eq (mul_one _))
  refine ⟨h.1, FlushToZero.finite_flush _ h.1,
    FlushToZero.mul_nonnegative _ _ (mul_nonneg (FlushToZero.flush_nonnegative _ ha.2.1)
      (FlushToZero.flush_nonnegative _ hf.2.1)) h.1,
    (le_abs_self _).trans (h.2.trans_eq hc.2), ?_⟩
  intro low one
  let input : Nat → Float32 := fun i => if i = 0 then acc else factor
  exact lower_one input (.mul (.input 0) (.input 1))
    (.mulRightOne (.input 0 low) one) ⟨ha.1, hf.1, h.1⟩

end Inference.Kernels.Sampling.LogSumExpAccumulator
