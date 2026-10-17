import kernels.quantization.AffineRow
import contracts.mlx.AdditionMagnitude

namespace Inference.Kernels.Quantization.AffineRowMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics AffineRow
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

theorem lane_only (steps : Nat) (lane : Fin 32) : AdditionMagnitude.Only (laneExpr steps lane) :=
  AdditionMagnitude.fold_only (fun i : Fin steps => .input (AffineLayout.chunkIndex i lane).val)
    (fun _ => True.intro) (List.finRange steps) .zero True.intro

theorem lane_sites (steps : Nat) (lane : Fin 32) : AdditionMagnitude.sites (laneExpr steps lane) = steps := by
  simpa only [laneExpr, AdditionMagnitude.sites, List.length_finRange, Nat.zero_add] using
    AdditionMagnitude.fold_sites (fun i : Fin steps => .input (AffineLayout.chunkIndex i lane).val)
      (fun _ => rfl) (List.finRange steps) .zero

theorem tree_only (lanes : Fin n → Arithmetic.Expr) (leaf : ∀ i, AdditionMagnitude.Only (lanes i))
    (tree : Reduction.Tree n) : AdditionMagnitude.Only (ArithmeticFold.reduceExpr lanes tree) := by
  induction tree with
  | leaf i => exact leaf i
  | add a b ia ib => exact ⟨ia, ib⟩

theorem tree_sites (lanes : Fin n → Arithmetic.Expr) (count : Nat)
    (leaf : ∀ i, AdditionMagnitude.sites (lanes i)=count) (tree : Reduction.Tree n) :
    AdditionMagnitude.sites (ArithmeticFold.reduceExpr lanes tree)+1 =
      (count+1)*(Reduction.leaves tree).length := by
  induction tree with
  | leaf i => simp [ArithmeticFold.reduceExpr, leaf, Reduction.leaves]
  | add a b ia ib =>
    simp only [ArithmeticFold.reduceExpr, AdditionMagnitude.sites, Reduction.leaves, List.length_append]
    nlinarith only [ia, ib]

theorem source_bound (p : Platform) (tiles : Fin steps → Fin 32 → Float32) (size : steps ≤ 32)
    (hf : Arithmetic.Finite (bind tiles) (AffineRow.expression steps p.reduction.tree)) :
    |real (source p tiles)| ≤ (17/16 : ℝ)*(∑ lane, ∑ step, |real (tiles step lane)|)+(2 : ℝ)^(-98 : Int) := by
  have only := tree_only (laneExpr steps) (lane_only steps) p.reduction.tree
  have hs := tree_sites (laneExpr steps) steps (lane_sites steps) p.reduction.tree
  have leaves : (Reduction.leaves p.reduction.tree).length = 32 := by
    simpa only [List.length_finRange] using p.reduction.coverage.length_eq
  rw [leaves] at hs
  change AdditionMagnitude.sites (AffineRow.expression steps p.reduction.tree)+1 = (steps+1)*32 at hs
  have sites : AdditionMagnitude.sites (AffineRow.expression steps p.reduction.tree) ≤ 1055 := by omega
  have h := AdditionMagnitude.expression (bind tiles) (AffineRow.expression steps p.reduction.tree)
    only hf (by omega)
  have massEq : (fun i => |real (bind tiles i)|) = bindReal (fun step lane => |real (tiles step lane)|) := by
    funext i
    unfold AffineRow.bind bindReal
    split
    · rfl
    · simp [FlushedIdentities.zero_real]
  rw [massEq, execution, AffineRow.ideal _ p.reduction.coverage] at h
  have count : (AdditionMagnitude.sites (AffineRow.expression steps p.reduction.tree) : ℝ) ≤ 1055 := by
    exact_mod_cast sites
  have mass : 0 ≤ ∑ lane, ∑ step, |real (tiles step lane)| :=
    Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => abs_nonneg _))
  have scaled := mul_le_mul_of_nonneg_right count mass
  norm_num at h ⊢
  nlinarith only [h, count, mass, scaled]

-- Final BF16 rounding is retained after the exact source lane order and
-- arbitrary covered SIMD reduction tree. Input tiles need not share a bound.
theorem output_bound (p : Platform) (tiles : Fin steps → Fin 32 → Float32) (size : steps ≤ 32)
    (hf : Arithmetic.Finite (bind tiles) (AffineRow.expression steps p.reduction.tree))
    (hb : Model.isFinite (output p tiles) = true) :
    |Model.toReal (output p tiles)| ≤ (9/8 : ℝ)*(∑ lane, ∑ step, |real (tiles step lane)|)+(2 : ℝ)^(-96 : Int) := by
  have sourceBound := source_bound p tiles size hf
  have sourceFinite := Arithmetic.finite_evaluate (bind tiles) (AffineRow.expression steps p.reduction.tree) hf
  rw [execution] at sourceFinite
  have error := (BFloat16.narrow_error (source p tiles) sourceFinite hb).trans
    (RelativeRounding.bfloat16_epsilon (real (source p tiles)))
  have h := NormalizedCastBounds.absolute_of_error _ _ _ error
  have mass : 0 ≤ ∑ lane, ∑ step, |real (tiles step lane)| :=
    Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => abs_nonneg _))
  change |Model.toReal (output p tiles)| ≤ _ at h
  norm_num at sourceBound h ⊢
  linarith only [sourceBound, h, mass]

end Inference.Kernels.Quantization.AffineRowMagnitude
