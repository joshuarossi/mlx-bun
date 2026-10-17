import contracts.mlx.SquaredSum
import contracts.mlx.RelativeRounding
import contracts.mlx.FlushedIdentities

namespace Inference.Contracts.Mlx.SquaredSumEnergyBounds
open Numerics SquaredSum

-- Count arithmetic rounding sites, including separate multiply/add when the
-- compiler does not contract. No reassociation of the source tree is used.
def sites : Expr n → Nat
  | .zero => 0
  | .square _ => 1
  | .fmaSquare _ a => sites a + 1
  | .add a b => sites a + sites b + 1

noncomputable def unit : ℝ := (2 : ℝ)^(-24 : Int)
noncomputable def tiny : ℝ := (2 : ℝ)^(-60 : Int)

theorem unit_nonnegative : 0 ≤ unit := by unfold unit; positivity
theorem unit_le_one : unit ≤ 1 := by norm_num [unit]
theorem tiny_nonnegative : 0 ≤ tiny := by unfold tiny; positivity

theorem ideal_nonnegative (input : Fin n → ℝ) (expr : Expr n) :
    0 ≤ ideal input expr := by
  induction expr with
  | zero => exact le_rfl
  | square i => exact sq_nonneg _
  | fmaSquare i a ih => exact add_nonneg (sq_nonneg _) ih
  | add a b ia ib => exact add_nonneg ia ib

-- Composition loses at most one additional unit of relative error per
-- arithmetic site, plus an absolute allowance for underflow and flushing.
theorem combine_lower (a b ea eb out ca cb : ℝ)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hca : 0 ≤ ca) (hcb : 0 ≤ cb)
    (hla : (1-ca*unit)*a-ca*tiny ≤ ea)
    (hlb : (1-cb*unit)*b-cb*tiny ≤ eb)
    (ho : (1-unit)*(ea+eb)-tiny ≤ out) :
    (1-(ca+cb+1)*unit)*(a+b)-(ca+cb+1)*tiny ≤ out := by
  have hu := unit_nonnegative
  have ht := tiny_nonnegative
  have hq : 0 ≤ 1-unit := sub_nonneg.mpr unit_le_one
  have gap : 0 ≤ unit*(cb*a+ca*b) + unit*unit*(ca*a+cb*b) + unit*(ca+cb)*tiny := by
    positivity
  calc
    _ ≤ (1-unit)*(((1-ca*unit)*a-ca*tiny)+((1-cb*unit)*b-cb*tiny))-tiny := by
      nlinarith only [gap]
    _ ≤ (1-unit)*(ea+eb)-tiny :=
      sub_le_sub_right (mul_le_mul_of_nonneg_left (add_le_add hla hlb) hq) _
    _ ≤ out := ho

theorem square_lower (x : Float32) (hx : |real x| ≤ (2 : ℝ)^56)
    (hf : (FlushToZero.flush x*FlushToZero.flush x).isFinite = true) :
    (1-unit)*real x^2-tiny ≤ real (FlushToZero.mul x x) := by
  have h := (abs_le.mp (RelativeRounding.multiplication x x hf)).1
  have ht : (2 : ℝ)^(-150 : Int) + FlushToZero.threshold*(1+|real x|+|real x|) ≤ tiny := by
    unfold FlushToZero.threshold tiny
    norm_num at *
    linarith
  rw [← pow_two, sq_abs] at h
  unfold unit
  nlinarith only [h, ht]

theorem fma_square_lower (x acc : Float32) (hx : x.isFinite = true)
    (ha : acc.isFinite = true) (hb : |real x| ≤ (2 : ℝ)^56) (hn : 0 ≤ real acc)
    (hf : (Float32.fma (FlushToZero.flush x) (FlushToZero.flush x)
      (FlushToZero.flush acc)).isFinite = true) :
    (1-unit)*(real x^2+real acc)-tiny ≤ real (FlushToZero.fma x x acc) := by
  have h := (abs_le.mp ((FlushToZero.fma_error x x acc hx hx ha hf).trans
    (RelativeRounding.fma_budget x x acc))).1
  have ht : (2 : ℝ)^(-150 : Int) + FlushToZero.threshold*(2+|real x|+|real x|) ≤ tiny := by
    unfold FlushToZero.threshold tiny
    norm_num at *
    linarith
  rw [← pow_two, sq_abs, abs_of_nonneg hn] at h
  unfold unit
  nlinarith only [h, ht]

theorem add_lower (a b : Float32) (ha : a.isFinite = true) (hb : b.isFinite = true)
    (hna : 0 ≤ real a) (hnb : 0 ≤ real b)
    (hf : (FlushToZero.flush a+FlushToZero.flush b).isFinite = true) :
    (1-unit)*(real a+real b)-tiny ≤ real (FlushToZero.add a b) := by
  have h := (abs_le.mp (RelativeRounding.addition a b ha hb hf)).1
  rw [abs_of_nonneg hna, abs_of_nonneg hnb] at h
  have ht : (2 : ℝ)^(-150 : Int)+3*FlushToZero.threshold ≤ tiny := by
    norm_num [FlushToZero.threshold, tiny]
  unfold unit
  nlinarith only [h, ht]

theorem lower (input : Fin n → Float32) (expr : Expr n)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56) (hf : Finite input expr) :
    (1-(sites expr : ℝ)*unit)*ideal (fun i => real (input i)) expr -
      (sites expr : ℝ)*tiny ≤ real (evaluate input expr) := by
  induction expr with
  | zero => simp [sites, ideal, evaluate, FlushedIdentities.zero_real]
  | square i => simpa [sites, ideal, evaluate] using square_lower (input i) (hx i) hf
  | fmaSquare i a ia =>
    have h := combine_lower (real (input i)^2) (ideal (fun j => real (input j)) a)
      (real (input i)^2) (real (evaluate input a)) _ 0 (sites a)
      (sq_nonneg _) (ideal_nonnegative _ a) (by positivity) (by positivity)
      (by simp) (ia hf.1)
      (fma_square_lower (input i) (evaluate input a) hf.2.1
        (finite_evaluate input a hf.1) (hx i) (nonnegative input a hf.1) hf.2.2)
    simpa [sites, ideal, evaluate, Nat.cast_add, Nat.cast_one] using h
  | add a b ia ib =>
    have h := combine_lower (ideal (fun i => real (input i)) a) (ideal (fun i => real (input i)) b)
      (real (evaluate input a)) (real (evaluate input b)) _ (sites a) (sites b)
      (ideal_nonnegative _ a) (ideal_nonnegative _ b) (by positivity) (by positivity)
      (ia hf.1) (ib hf.2.1)
      (add_lower _ _ (finite_evaluate input a hf.1) (finite_evaluate input b hf.2.1)
        (nonnegative input a hf.1) (nonnegative input b hf.2.1) hf.2.2)
    simpa [sites, ideal, evaluate, Nat.cast_add, Nat.cast_one] using h

theorem lower_bounded_sites (input : Fin n → Float32) (expr : Expr n)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56) (hf : Finite input expr)
    (hs : sites expr ≤ 16384) :
    (1023/1024 : ℝ)*ideal (fun i => real (input i)) expr - (2 : ℝ)^(-46 : Int) ≤
      real (evaluate input expr) := by
  have h := lower input expr hx hf
  have hn := ideal_nonnegative (fun i => real (input i)) expr
  have hc : (sites expr : ℝ) ≤ 16384 := by exact_mod_cast hs
  have hp := mul_le_mul_of_nonneg_right hc hn
  norm_num [unit, tiny] at h ⊢
  nlinarith only [h, hc, hp]

theorem sum_lower (input : Fin n → Float32) (expr : Expr n)
    (hx : ∀ i, |real (input i)| ≤ (2 : ℝ)^56) (hf : Finite input expr)
    (hs : sites expr ≤ 16384) (coverage : (indices expr).Perm (List.finRange n)) :
    (1023/1024 : ℝ)*((List.finRange n).map (fun i => real (input i)^2)).sum -
      (2 : ℝ)^(-46 : Int) ≤ real (evaluate input expr) := by
  have h := lower_bounded_sites input expr hx hf hs
  rwa [ideal_indices, (coverage.map (fun i => real (input i)^2)).sum_eq] at h

end Inference.Contracts.Mlx.SquaredSumEnergyBounds
