import contracts.mlx.IntegerBounds
import contracts.mlx.NativeFma
import contracts.mlx.SquaredSum

namespace Inference.Contracts.Mlx.SquaredSumBounds
open Numerics SquaredSum

-- Independent of reduction order and contraction: with |x| ≤ 1, each
-- subtree is bounded by its number of squared terms. That integer is an
-- exactly representable ceiling, so rounding cannot break the invariant.
theorem unit_range (input : Fin n → Float32)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ 1)
    (expr : Expr n) (size : (indices expr).length < 16777216) :
    Finite input expr ∧ |real (evaluate input expr)| ≤ ((indices expr).length : ℝ) := by
  induction expr with
  | zero =>
    have hz : real (0 : Float32) = 0 := by
      rw [real_unpack]; exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    exact ⟨True.intro, by simp [evaluate, indices, hz]⟩
  | square i =>
    have hp : |real (input i)| * |real (input i)| ≤ 1 := by
      simpa using mul_le_mul (hi i).2 (hi i).2 (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
    have h := NativeMultiplication.range (input i) (input i) 1 (hi i).1 (hi i).1 (by decide +kernel)
      (by simpa only [real_one] using hp)
    exact ⟨h.1, by simpa [evaluate, indices, real_one] using h.2⟩
  | fmaSquare i acc ih =>
    have hs : (indices acc).length < 16777216 := by
      simp only [indices, List.length_cons] at size
      omega
    have ha := ih hs
    have hc := IntegerBounds.natural ((indices (.fmaSquare i acc)).length) size
    have hp : |real (input i)| * |real (input i)| ≤ 1 := by
      simpa using mul_le_mul (hi i).2 (hi i).2 (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
    have h := NativeFma.range (input i) (input i) (evaluate input acc)
      (Float32.ofInt ((indices (.fmaSquare i acc)).length)) (hi i).1 (hi i).1 (finite_evaluate _ _ ha.1) hc.1
      (by rw [hc.2]; simpa [indices, Nat.cast_add, add_comm] using add_le_add hp ha.2)
    exact ⟨⟨ha.1, (hi i).1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩
  | add a b ia ib =>
    have hs : (indices a).length + (indices b).length < 16777216 := by simpa only [indices, List.length_append] using size
    have ha := ia (by omega)
    have hb := ib (by omega)
    have hc := IntegerBounds.natural ((indices (.add a b)).length) size
    have h := Float32Bounds.add_range (evaluate input a) (evaluate input b)
      (Float32.ofInt ((indices (.add a b)).length)) (finite_evaluate _ _ ha.1) (finite_evaluate _ _ hb.1) hc.1
      (by rw [hc.2]; simpa only [indices, List.length_append, Nat.cast_add] using add_le_add ha.2 hb.2)
    exact ⟨⟨ha.1, hb.1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩

theorem covered_range (input : Fin n → Float32)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ 1)
    (expr : Expr n) (coverage : (indices expr).Perm (List.finRange n)) (hn : n < 16777216) :
    Finite input expr ∧ 0 ≤ real (evaluate input expr) ∧ real (evaluate input expr) ≤ (n : ℝ) := by
  have hl : (indices expr).length = n := by simpa using coverage.length_eq
  have h := unit_range input hi expr (by omega)
  exact ⟨h.1, nonnegative input expr h.1, (le_abs_self _).trans (by simpa only [hl] using h.2)⟩

end Inference.Contracts.Mlx.SquaredSumBounds
