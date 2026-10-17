import contracts.mlx.RelativeRounding
import contracts.mlx.SquaredSumDyadicBounds

namespace Inference.Contracts.Mlx.SquaredSumRelativeBounds
open Numerics SquaredSum

-- Counts the magnitude-weighted rounding sites, including zero additions.
-- The selected 128-coordinate head schedule later bounds this static cost.
def cost : Expr n → Nat
  | .zero => 0
  | .square _ => 2
  | .fmaSquare _ a => cost a + (indices a).length + 2
  | .add a b => cost a + cost b + (indices a).length + (indices b).length + 1

noncomputable def scale (e : Int) : ℝ := (2 : ℝ)^(e+e)
noncomputable def unit (e : Int) : ℝ := (2 : ℝ)^(-24 : Int)*scale e

theorem square_scale (e : Int) : ((2 : ℝ)^e)^2 = scale e := by
  rw [pow_two, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
  rfl

theorem flush_allowance (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50) :
    (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(3+2*(2 : ℝ)^e) ≤ unit e := by
  have hc : (2 : ℝ)^e ≤ (2 : ℝ)^(50 : Int) := zpow_le_zpow_right₀ (by norm_num) hi
  have hs : (2 : ℝ)^(-20 : Int) ≤ scale e := zpow_le_zpow_right₀ (by norm_num) (by omega)
  calc
    _ ≤ (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(3+2*(2 : ℝ)^(50 : Int)) := by
      exact add_le_add (le_refl _) (mul_le_mul_of_nonneg_left (by linarith) FlushToZero.threshold_pos.le)
    _ ≤ (2 : ℝ)^(-24 : Int)*(2 : ℝ)^(-20 : Int) := by norm_num [FlushToZero.threshold]
    _ ≤ _ := mul_le_mul_of_nonneg_left hs (by positivity)

theorem square_budget (x : Float32) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (hx : |real x| ≤ (2 : ℝ)^e) : FlushToZero.mulBudget x x ≤ 2*unit e := by
  have h := RelativeRounding.multiplication_budget x x
  have hs : |real x| * |real x| ≤ scale e := by
    have h := mul_le_mul hx hx (abs_nonneg _) (by positivity)
    simpa only [← pow_two, square_scale] using h
  have hu := mul_le_mul_of_nonneg_left hs (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have ht := mul_le_mul_of_nonneg_left (show 1+|real x|+|real x| ≤ 3+2*(2 : ℝ)^e by linarith)
    FlushToZero.threshold_pos.le
  have hf := flush_allowance e lo hi
  unfold unit at *
  linarith

theorem fma_budget (x acc : Float32) (count : Nat) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (hx : |real x| ≤ (2 : ℝ)^e) (ha : |real acc| ≤ count*scale e) :
    FlushToZero.fmaBudget x x acc ≤ (count+2)*unit e := by
  have h := RelativeRounding.fma_budget x x acc
  have hs : |real x| * |real x| ≤ scale e := by
    have h := mul_le_mul hx hx (abs_nonneg _) (by positivity)
    simpa only [← pow_two, square_scale] using h
  have hu := mul_le_mul_of_nonneg_left (add_le_add hs ha) (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have ht := mul_le_mul_of_nonneg_left (show 2+|real x|+|real x| ≤ 3+2*(2 : ℝ)^e by linarith)
    FlushToZero.threshold_pos.le
  have hf := flush_allowance e lo hi
  unfold unit at *
  nlinarith

theorem add_budget (a b : Float32) (ca cb : Nat) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (ha : |real a| ≤ ca*scale e) (hb : |real b| ≤ cb*scale e) :
    FlushToZero.addBudget a b ≤ (ca+cb+1)*unit e := by
  have h := RelativeRounding.addition_budget a b
  have hu := mul_le_mul_of_nonneg_left (add_le_add ha hb) (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-24 : Int))
  have ht : 3*FlushToZero.threshold ≤ FlushToZero.threshold*(3+2*(2 : ℝ)^e) := by
    have hp : 0 ≤ (2 : ℝ)^e := by positivity
    nlinarith [FlushToZero.threshold_pos]
  have hf := flush_allowance e lo hi
  unfold unit at *
  nlinarith

theorem budget_bound (input : Fin n → Float32) (e : Int) (lo : -10 ≤ e) (hi : e ≤ 50)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^e)
    (expr : Expr n) (size : (indices expr).length ≤ 128) : budget input expr ≤ cost expr*unit e := by
  induction expr with
  | zero => simp only [budget, cost, Nat.cast_zero, zero_mul, le_refl]
  | square i => exact square_budget (input i) e lo hi (hx i).2
  | fmaSquare i a ih =>
    have sa : (indices a).length ≤ 128 := by simp only [indices, List.length_cons] at size; omega
    have ha := SquaredSumDyadicBounds.range input e (by omega) (by omega) hx a (by omega)
    have step := fma_budget (input i) (evaluate input a) (indices a).length e lo hi (hx i).2 ha.2
    have h := add_le_add (ih sa) step
    simpa only [budget, cost, Nat.cast_add, Nat.cast_ofNat, add_mul, add_assoc] using h
  | add a b ia ib =>
    have ss : (indices a).length+(indices b).length ≤ 128 := by simpa only [indices, List.length_append] using size
    have ha := SquaredSumDyadicBounds.range input e (by omega) (by omega) hx a (by omega)
    have hb := SquaredSumDyadicBounds.range input e (by omega) (by omega) hx b (by omega)
    have step := add_budget (evaluate input a) (evaluate input b) (indices a).length (indices b).length e lo hi ha.2 hb.2
    have h := add_le_add (add_le_add (ia (by omega)) (ib (by omega))) step
    simpa only [budget, cost, Nat.cast_add, Nat.cast_one, add_mul, add_assoc] using h

end Inference.Contracts.Mlx.SquaredSumRelativeBounds
