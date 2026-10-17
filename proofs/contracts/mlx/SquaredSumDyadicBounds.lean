import contracts.mlx.SquaredSumBounds
import contracts.mlx.DyadicBounds

namespace Inference.Contracts.Mlx.SquaredSumDyadicBounds
open Numerics SquaredSum
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem range (input : Fin n → Float32) (exponent : Int)
    (lo : -149 ≤ exponent+exponent) (hi : exponent+exponent ≤ 100)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^exponent)
    (expr : Expr n) (size : (indices expr).length < 16777216) :
    Finite input expr ∧ |real (evaluate input expr)| ≤ ((indices expr).length : ℝ) * (2 : ℝ)^(exponent+exponent) := by
  have hp (i : Fin n) : |real (input i)| * |real (input i)| ≤ (2 : ℝ)^(exponent+exponent) := by
    rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    exact mul_le_mul (hx i).2 (hx i).2 (abs_nonneg _) (zpow_nonneg (by norm_num) _)
  induction expr with
  | zero =>
    have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
    exact ⟨True.intro, by simp [evaluate, indices, hz]⟩
  | square i =>
    have hc := DyadicBounds.ceiling_range 1 (exponent+exponent) (by decide) lo hi
    have h := NativeMultiplication.range (input i) (input i) (DyadicBounds.ceiling 1 (exponent+exponent))
      (hx i).1 (hx i).1 hc.1 (by simpa only [hc.2, Nat.cast_one, one_mul] using hp i)
    exact ⟨h.1, by simpa only [evaluate, indices, List.length_singleton, hc.2] using h.2⟩
  | fmaSquare i acc ih =>
    have ha := ih (by simp only [indices, List.length_cons] at size; omega)
    have hc := DyadicBounds.ceiling_range ((indices (.fmaSquare i acc)).length) (exponent+exponent) size lo hi
    have h := NativeFma.range (input i) (input i) (evaluate input acc)
      (DyadicBounds.ceiling ((indices (.fmaSquare i acc)).length) (exponent+exponent))
      (hx i).1 (hx i).1 (finite_evaluate _ _ ha.1) hc.1
      (by rw [hc.2]; calc
          _ ≤ (2 : ℝ)^(exponent+exponent) + ((indices acc).length : ℝ) * (2 : ℝ)^(exponent+exponent) := add_le_add (hp i) ha.2
          _ = _ := by simp only [indices, List.length_cons, Nat.cast_add, Nat.cast_one]; ring)
    exact ⟨⟨ha.1, (hx i).1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩
  | add a b ia ib =>
    have hs : (indices a).length + (indices b).length < 16777216 := by simpa only [indices, List.length_append] using size
    have ha := ia (by omega)
    have hb := ib (by omega)
    have hc := DyadicBounds.ceiling_range ((indices (.add a b)).length) (exponent+exponent) size lo hi
    have h := Float32Bounds.add_range (evaluate input a) (evaluate input b)
      (DyadicBounds.ceiling ((indices (.add a b)).length) (exponent+exponent))
      (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1) hc.1
      (by rw [hc.2]; calc
          _ ≤ ((indices a).length : ℝ) * (2 : ℝ)^(exponent+exponent) +
            ((indices b).length : ℝ) * (2 : ℝ)^(exponent+exponent) := add_le_add ha.2 hb.2
          _ = _ := by simp only [indices, List.length_append, Nat.cast_add]; ring)
    exact ⟨⟨ha.1, hb.1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩

theorem covered_range (input : Fin n → Float32) (exponent : Int)
    (lo : -149 ≤ exponent+exponent) (hi : exponent+exponent ≤ 100)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^exponent)
    (expr : Expr n) (coverage : (indices expr).Perm (List.finRange n)) (size : n < 16777216) :
    Finite input expr ∧ 0 ≤ real (evaluate input expr) ∧ real (evaluate input expr) ≤ (n : ℝ) * (2 : ℝ)^(exponent+exponent) := by
  have hl : (indices expr).length = n := by simpa only [List.length_finRange] using coverage.length_eq
  have h := range input exponent lo hi hx expr (by omega)
  exact ⟨h.1, nonnegative input expr h.1, (le_abs_self _).trans (by simpa only [hl] using h.2)⟩

theorem range_wide (input : Fin n → Float32) (exponent : Int)
    (lo : -149 ≤ exponent+exponent) (hi : exponent+exponent ≤ 112)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^exponent)
    (expr : Expr n) (size : (indices expr).length ≤ 16384) :
    Finite input expr ∧ |real (evaluate input expr)| ≤ ((indices expr).length : ℝ) * (2 : ℝ)^(exponent+exponent) := by
  have hp (i : Fin n) : |real (input i)| * |real (input i)| ≤ (2 : ℝ)^(exponent+exponent) := by
    rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    exact mul_le_mul (hx i).2 (hx i).2 (abs_nonneg _) (zpow_nonneg (by norm_num) _)
  induction expr with
  | zero =>
    have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
    exact ⟨True.intro, by simp [evaluate, indices, hz]⟩
  | square i =>
    have hc := DyadicBounds.ceiling_range_wide 1 (exponent+exponent) (by decide) lo hi
    have h := NativeMultiplication.range (input i) (input i) (DyadicBounds.ceiling 1 (exponent+exponent))
      (hx i).1 (hx i).1 hc.1 (by simpa only [hc.2, Nat.cast_one, one_mul] using hp i)
    exact ⟨h.1, by simpa only [evaluate, indices, List.length_singleton, hc.2] using h.2⟩
  | fmaSquare i acc ih =>
    have ha := ih (by simp only [indices, List.length_cons] at size; omega)
    have hc := DyadicBounds.ceiling_range_wide ((indices (.fmaSquare i acc)).length) (exponent+exponent) size lo hi
    have h := NativeFma.range (input i) (input i) (evaluate input acc)
      (DyadicBounds.ceiling ((indices (.fmaSquare i acc)).length) (exponent+exponent))
      (hx i).1 (hx i).1 (finite_evaluate _ _ ha.1) hc.1
      (by rw [hc.2]; calc
          _ ≤ (2 : ℝ)^(exponent+exponent) + ((indices acc).length : ℝ) * (2 : ℝ)^(exponent+exponent) := add_le_add (hp i) ha.2
          _ = _ := by simp only [indices, List.length_cons, Nat.cast_add, Nat.cast_one]; ring)
    exact ⟨⟨ha.1, (hx i).1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩
  | add a b ia ib =>
    have hs : (indices a).length + (indices b).length ≤ 16384 := by simpa only [indices, List.length_append] using size
    have ha := ia (by omega)
    have hb := ib (by omega)
    have hc := DyadicBounds.ceiling_range_wide ((indices (.add a b)).length) (exponent+exponent) size lo hi
    have h := Float32Bounds.add_range (evaluate input a) (evaluate input b)
      (DyadicBounds.ceiling ((indices (.add a b)).length) (exponent+exponent))
      (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1) hc.1
      (by rw [hc.2]; calc
          _ ≤ ((indices a).length : ℝ) * (2 : ℝ)^(exponent+exponent) +
            ((indices b).length : ℝ) * (2 : ℝ)^(exponent+exponent) := add_le_add ha.2 hb.2
          _ = _ := by simp only [indices, List.length_append, Nat.cast_add]; ring)
    exact ⟨⟨ha.1, hb.1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩

theorem covered_range_wide (input : Fin n → Float32) (exponent : Int)
    (lo : -149 ≤ exponent+exponent) (hi : exponent+exponent ≤ 112)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^exponent)
    (expr : Expr n) (coverage : (indices expr).Perm (List.finRange n)) (size : n ≤ 16384) :
    Finite input expr ∧ 0 ≤ real (evaluate input expr) ∧ real (evaluate input expr) ≤ (n : ℝ) * (2 : ℝ)^(exponent+exponent) := by
  have hl : (indices expr).length = n := by simpa only [List.length_finRange] using coverage.length_eq
  have h := range_wide input exponent lo hi hx expr (by omega)
  exact ⟨h.1, nonnegative input expr h.1, (le_abs_self _).trans (by simpa only [hl] using h.2)⟩

theorem flush_lower (floor x : Float32) (normal : FlushToZero.threshold < real floor) (bound : real floor ≤ real x) :
    real floor ≤ real (FlushToZero.flush x) := by
  have hp : 0 < real x := lt_of_lt_of_le (lt_trans FlushToZero.threshold_pos normal) bound
  rw [FlushToZero.flush_eq_of_threshold_lt x (by rw [abs_of_pos hp]; exact normal.trans_le bound)]
  exact bound

theorem round_lower (floor : Float32) (finite : floor.isFinite = true) (x : ℝ) (bound : real floor ≤ x) :
    real floor ≤ Model.roundAt FloatFormat.binary32 x := by
  have h := Model.roundAt_mono FloatFormat.binary32 bound
  have he : Model.roundAt FloatFormat.binary32 (real floor) = real floor :=
    Model.roundAt_toReal_eq (model floor) (by rw [finite_model]; exact finite)
  rwa [he] at h

-- A positive normal representable lower bound on one square survives every
-- addition and FMA above it. This avoids multiplying a rounding loss by the
-- reduction depth when bounding an RMS denominator from below.
theorem lower (input : Fin n → Float32) (hx : ∀ i, (input i).isFinite = true)
    (expr : Expr n) (finite : Finite input expr) (i : Fin n) (member : i ∈ indices expr)
    (floor : Float32) (hf : floor.isFinite = true) (normal : FlushToZero.threshold < real floor)
    (bound : real floor ≤ real (FlushToZero.flush (input i)) * real (FlushToZero.flush (input i))) :
    real floor ≤ real (evaluate input expr) := by
  induction expr with
  | zero => simp only [indices, List.not_mem_nil] at member
  | square j =>
    have he : i = j := by simpa only [indices, List.mem_singleton] using member
    subst j
    apply FlushToZero.flushExact_lower (FlushToZero.exact_mul _ _) _ (Numerics.mul_real _ _ finite) _ normal
    rw [Numerics.mul_real _ _ finite]
    exact round_lower floor hf _ bound
  | fmaSquare j acc ih =>
    have hr := Numerics.fma_real _ _ _ (FlushToZero.finite_flush _ (hx j))
      (FlushToZero.finite_flush _ (hx j)) (FlushToZero.finite_flush _ (finite_evaluate _ _ finite.1)) finite.2.2
    apply FlushToZero.flushExact_lower (FlushToZero.exact_fma _ _ _ (FlushToZero.finite_flush_model _ (hx j)) (FlushToZero.finite_flush_model _ (hx j))
      (FlushToZero.finite_flush_model _ (finite_evaluate _ _ finite.1))) _ hr _ normal
    rw [hr]
    apply round_lower floor hf

    rcases (show i = j ∨ i ∈ indices acc from by simpa only [indices, List.mem_cons] using member) with he | hm
    · subst j
      exact bound.trans (le_add_of_nonneg_right (FlushToZero.flush_nonnegative _ (nonnegative _ _ finite.1)))
    · have ha := flush_lower floor (evaluate input acc) normal (ih finite.1 hm)
      exact ha.trans (le_add_of_nonneg_left (mul_self_nonneg _))
  | add a b ia ib =>
    apply flush_lower floor _ normal
    rw [Numerics.add_real _ _ (FlushToZero.finite_flush _ (finite_evaluate _ _ finite.1))
      (FlushToZero.finite_flush _ (finite_evaluate _ _ finite.2.1)) finite.2.2]
    apply round_lower floor hf
    rcases (show i ∈ indices a ∨ i ∈ indices b from by simpa only [indices, List.mem_append] using member) with ha | hb
    · exact (flush_lower floor _ normal (ia finite.1 ha)).trans
        (le_add_of_nonneg_right (FlushToZero.flush_nonnegative _ (nonnegative _ _ finite.2.1)))
    · exact (flush_lower floor _ normal (ib finite.2.1 hb)).trans
        (le_add_of_nonneg_left (FlushToZero.flush_nonnegative _ (nonnegative _ _ finite.1)))

end Inference.Contracts.Mlx.SquaredSumDyadicBounds
