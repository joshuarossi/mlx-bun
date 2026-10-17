import kernels.quantization.AffineInputMagnitude
import contracts.mlx.MaddMagnitude
import contracts.mlx.AdditionMagnitude

namespace Inference.Kernels.Quantization.AffineDot4Magnitude
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

def shift (i : Fin 4) : Fin 13 := ⟨4*i.val, by have := i.isLt; omega⟩
def prepared (divide : Float32 → Float32 → Float32) (x : Fin 4 → BF) (i : Fin 4) : Float32 :=
  AffineInput.prepare divide (x i) (shift i)

theorem mask_eq (w : BitVec 16) (i : Fin 4) :
    AffineDot.mask4 w i = AffinePacking.field4 w i * 2^(shift i).val := by
  have hm : 15*2^(4*i.val) < 65536 := by fin_cases i <;> decide
  simp only [AffineDot.mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt hm, shift]
  simpa only [AffinePacking.field4, show 2^4-1=15 from rfl, show (2 : Nat)^4=16 from rfl] using
    AffinePacking.shifted_mask w.toNat 4 (4*i.val)

theorem prepared_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 4 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512) (i : Fin 4) :
    (prepared divide x i).isFinite = true ∧ |real (prepared divide x i)| ≤ 512 := by
  have h := AffineScaledBounds.prepare_range divide division (x i) (shift i) 9 (by decide) (by decide)
    ⟨(hx i).1, by norm_num; exact (hx i).2⟩
  refine ⟨h.1, h.2.trans ?_⟩
  have hs := zpow_le_zpow_right₀ (by norm_num : (1 : ℝ) ≤ 2)
    (by have := (shift i).isLt; omega : (9 : Int)-((shift i).val : Int) ≤ 9)
  norm_num at hs
  exact hs

theorem coefficient_bound (w : BitVec 16) (i : Fin 4) : |real (AffineLift.value (AffineDot.mask4 w i))| ≤ 61440 := by
  rw [mask_eq, AffineLift.field_exact ⟨AffinePacking.field4 w i, AffinePacking.field4_bound w i⟩ (shift i),
    abs_of_nonneg (by positivity)]
  have fc : (AffinePacking.field4 w i : ℝ) ≤ 15 := by
    have := AffinePacking.field4_bound w i
    exact_mod_cast (by omega : AffinePacking.field4 w i ≤ 15)
  have sc : (shift i).val ≤ 12 := by have := (shift i).isLt; omega
  have h := mul_le_mul fc (pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) sc)
    (by positivity : (0 : ℝ) ≤ 2^(shift i).val) (by norm_num : (0 : ℝ) ≤ 15)
  norm_num at h
  exact h

theorem product_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 4 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (w : BitVec 16) (i : Fin 4) :
    |real (prepared divide x i)| * |real (AffineLift.value (AffineDot.mask4 w i))| ≤
      31*|Model.toReal (x i)|+(2 : ℝ)^(-100 : Int) := by
  have h := AffineInputMagnitude.lifted_product divide division (x i)
    ⟨AffinePacking.field4 w i, AffinePacking.field4_bound w i⟩ (shift i) (hx i).1 ((hx i).2.trans (by norm_num))
  have fc : (AffinePacking.field4 w i : ℝ) ≤ 15 := by
    have := AffinePacking.field4_bound w i
    exact_mod_cast (by omega : AffinePacking.field4 w i ≤ 15)
  have scaled := mul_le_mul_of_nonneg_right fc (abs_nonneg (Model.toReal (x i)))
  rw [mask_eq]
  change |real (AffineInput.prepare divide (x i) (shift i))| * _ ≤ _
  norm_num at h ⊢
  nlinarith only [h, fc, scaled, abs_nonneg (Model.toReal (x i))]

theorem source_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 4 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (contracted : Bool) (w : BitVec 16) (acc : Float32)
    (hf : Arithmetic.Finite (AffineDot.bind4 w (prepared divide x) acc) (AffineDot.expression4 contracted)) :
    |real (AffineDot.source4 contracted w (prepared divide x) acc)| ≤
      (1+(2 : ℝ)^(-20 : Int))*|real acc|+33*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-44 : Int) := by
  let input := AffineDot.bind4 w (prepared divide x) acc
  let a := fun i : Fin 4 => Expr.input i.val
  let b := fun i : Fin 4 => Expr.input (4+i.val)
  let next := fun i : Fin 3 => (⟨i.val+1, by have := i.isLt; omega⟩ : Fin 4)
  let mass := fun i : Fin 4 => 31*|Model.toReal (x i)|+(2 : ℝ)^(-100 : Int)
  let first := Expr.mul (a 0) (b 0)
  let groupExpr := (List.finRange 3).foldl (fun tail i => madd contracted (a (next i)) (b (next i)) tail) first
  have expressionEq : AffineDot.expression4 contracted = .add (.input 8) groupExpr := by
    simp only [groupExpr, show List.finRange 3 = [0, 1, 2] from by decide +kernel,
      List.foldl_cons, List.foldl_nil]
    rfl
  rw [expressionEq] at hf
  have firstFinite := (ArithmeticDependencies.fold_finite input contracted (fun i => a (next i))
    (fun i => b (next i)) (List.finRange 3) first hf.2.1).1
  have aRead (i : Fin 4) : evaluate input (a i) = prepared divide x i := by
    simp only [a, evaluate, input, AffineDot.bind4, dite_eq_left i.isLt]
  have bRead (i : Fin 4) : evaluate input (b i) = AffineLift.value (AffineDot.mask4 w i) := by
    have := i.isLt
    simp [b, evaluate, input, AffineDot.bind4, show ¬4+i.val < 4 by omega, show 4+i.val < 8 by omega]
  have operands (i : Fin 4) : |real (evaluate input (a i))|+|real (evaluate input (b i))| ≤ (2 : ℝ)^62+2 := by
    rw [aRead, bRead]
    have h := add_le_add (prepared_bound divide division x hx i).2 (coefficient_bound w i)
    norm_num at h ⊢
    linarith only [h]
  have products (i : Fin 4) : |real (evaluate input (a i))| * |real (evaluate input (b i))| ≤ mass i := by
    rw [aRead, bRead]
    exact product_bound divide division x hx w i
  have initial : |real (evaluate input first)| ≤ mass 0 := by
    have raw := firstFinite.2.2
    change (FlushToZero.flush (evaluate input (a 0))*FlushToZero.flush (evaluate input (b 0))).isFinite = true at raw
    rw [aRead, bRead, mask_eq] at raw
    have h := AffineInputMagnitude.rounded_product divide division (x 0)
      ⟨AffinePacking.field4 w 0, AffinePacking.field4_bound w 0⟩ (shift 0) (hx 0).1 (hx 0).2 raw
    change |real (FlushToZero.mul (evaluate input (a 0)) (evaluate input (b 0)))| ≤ _
    rw [aRead, bRead, mask_eq]
    exact h
  have group := MaddMagnitude.fold_bound input contracted (fun i => a (next i)) (fun i => b (next i))
    (fun i => mass (next i)) (List.finRange 3) first (mass 0) 0 (by simp) hf.2.1
    (fun i => operands (next i)) (fun i => products (next i)) (by dsimp [mass]; positivity)
    (by simpa using initial)
  have massEq : mass 0+((List.finRange 3).map (fun i => mass (next i))).sum =
      31*(∑ i, |Model.toReal (x i)|)+4*(2 : ℝ)^(-100 : Int) := by
    simp [mass, next, show List.finRange 3 = [0, 1, 2] from by decide +kernel, Fin.sum_univ_succ]
    ring
  rw [massEq] at group
  have groupBound : |real (evaluate input groupExpr)| ≤ 32*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-45 : Int) := by
    change |real (evaluate input groupExpr)| ≤ _ at group
    norm_num only [List.length_finRange, Nat.zero_add, Nat.cast_ofNat] at group
    have mn : 0 ≤ ∑ i, |Model.toReal (x i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
    norm_num at group ⊢
    linarith only [group, mn]
  have sumBound := AdditionMagnitude.addition (evaluate input (.input 8)) (evaluate input groupExpr)
    (finite_evaluate input _ hf.1) (finite_evaluate input _ hf.2.1) hf.2.2
  have accRead : evaluate input (.input 8) = acc := by simp [evaluate, input, AffineDot.bind4]
  rw [accRead] at sumBound
  rw [← AffineDot.execution4, expressionEq]
  change |real (FlushToZero.add acc (evaluate input groupExpr))| ≤ _
  have mn : 0 ≤ ∑ i, |Model.toReal (x i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  norm_num at groupBound sumBound ⊢
  linarith only [groupBound, sumBound, mn, abs_nonneg (real acc)]

theorem tile_dot (p : AffineTile.Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (hf : AffineTile.DotFinite4 p x w) :
    |real (AffineTile.dot4 p x w)| ≤ 34*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-40 : Int) := by
  let mass := fun c : Fin 4 => ∑ i, |Model.toReal (x (AffineInput.index4 c i))|
  have step (c : Fin 4) (acc : Float32) (valid : AffineTile.valid4 p x w c acc) :
      |real (AffineTile.step4 p x w c acc)| ≤
        (1+(2 : ℝ)^(-20 : Int))*|real acc|+33*mass c+(2 : ℝ)^(-44 : Int) :=
    source_bound p.divide division (fun i => x (AffineInput.index4 c i))
      (fun i => hx (AffineInput.index4 c i)) p.contracted (w c) acc valid
  have valid := hf.arithmetic
  simp only [show List.finRange 4 = [0, 1, 2, 3] from by decide +kernel, FoldFinite] at valid
  have h0 := step 0 0 valid.1
  have h1 := step 1 _ valid.2.1
  have h2 := step 2 _ valid.2.2.1
  have h3 := step 3 _ valid.2.2.2.1
  have whole := AffineTile.input_coverage4 (fun i => |Model.toReal (x i)|)
  change (∑ c, mass c) = ∑ i, |Model.toReal (x i)| at whole
  have sumFour : (∑ c, mass c) = mass 0+mass 1+mass 2+mass 3 := by
    simp [Fin.sum_univ_succ]
    ring
  rw [sumFour] at whole
  have nonnegative (c : Fin 4) : 0 ≤ mass c := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  simp only [AffineTile.dot4, show List.finRange 4 = [0, 1, 2, 3] from by decide +kernel,
    List.foldl_cons, List.foldl_nil]
  norm_num [FlushedIdentities.zero_real] at h0 h1 h2 h3 ⊢
  linarith only [h0, h1, h2, h3, whole, nonnegative 0, nonnegative 1, nonnegative 2, nonnegative 3]

end Inference.Kernels.Quantization.AffineDot4Magnitude
