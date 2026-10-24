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
    (contracted : Nat → Bool) (w : BitVec 16) (acc : Float32)
    (hf : Arithmetic.Finite (AffineDot.bind4 w (prepared divide x) acc) (AffineDot.expression4 contracted)) :
    |real (AffineDot.source4 contracted w (prepared divide x) acc)| ≤
      (1+(2 : ℝ)^(-20 : Int))*|real acc|+33*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-44 : Int) := by
  let input := AffineDot.bind4 w (prepared divide x) acc
  let a := fun i : Fin 4 => Expr.input i.val
  let b := fun i : Fin 4 => Expr.input (4+i.val)
  let mass := fun i : Fin 4 => 31*|Model.toReal (x i)|+(2 : ℝ)^(-100 : Int)
  let pair := maddLeft (contracted 0) (a 0) (b 0) (.mul (a 1) (b 1))
  let middle := madd (contracted 1) (a 2) (b 2) pair
  let groupExpr := madd (contracted 2) (a 3) (b 3) middle
  have expressionEq : AffineDot.expression4 contracted = .add (.input 8) groupExpr := rfl
  rw [expressionEq] at hf
  have middleFinite := (ArithmeticDependencies.madd_finite input _ _ _ _ hf.2.1).2.2
  have pairFinite := (ArithmeticDependencies.madd_finite input _ _ _ _ middleFinite).2.2
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
  have initial (i : Fin 4) (finite : Arithmetic.Finite input (.mul (a i) (b i))) :
      |real (evaluate input (.mul (a i) (b i)))| ≤ mass i := by
    have raw := finite.2.2
    change (FlushToZero.flush (evaluate input (a i))*FlushToZero.flush (evaluate input (b i))).isFinite = true at raw
    rw [aRead, bRead, mask_eq] at raw
    have h := AffineInputMagnitude.rounded_product divide division (x i)
      ⟨AffinePacking.field4 w i, AffinePacking.field4_bound w i⟩ (shift i) (hx i).1 (hx i).2 raw
    change |real (FlushToZero.mul (evaluate input (a i)) (evaluate input (b i)))| ≤ _
    rw [aRead, bRead, mask_eq]
    exact h
  have nonnegative (i : Fin 4) : 0 ≤ mass i := by dsimp [mass]; positivity
  -- Site 0 adds the first two products; either may be the accumulated operand.
  have pairBound (c : Bool) (finite : Arithmetic.Finite input (maddLeft c (a 0) (b 0) (.mul (a 1) (b 1)))) :
      |real (evaluate input (maddLeft c (a 0) (b 0) (.mul (a 1) (b 1))))| ≤
        (1+((0+1 : Nat) : ℝ)/1048576)*(mass 0+mass 1)+((0+1 : Nat) : ℝ)*(2 : ℝ)^(-50 : Int) := by
    cases c
    · rw [maddLeft_false] at finite ⊢
      rw [add_comm (mass 0)]
      exact MaddMagnitude.madd_bound input false (a 1) (b 1) _ finite (operands 1) (mass 1) (mass 0) 0 (by decide)
        (nonnegative 0) (products 1) (by simpa using initial 0 (ArithmeticDependencies.madd_finite input _ _ _ _ finite).2.2)
    · rw [maddLeft_true] at finite ⊢
      exact MaddMagnitude.madd_bound input true (a 0) (b 0) _ finite (operands 0) (mass 0) (mass 1) 0 (by decide)
        (nonnegative 1) (products 0) (by simpa using initial 1 (ArithmeticDependencies.madd_finite input _ _ _ _ finite).2.2)
  have middleBound := MaddMagnitude.madd_bound input (contracted 1) (a 2) (b 2) pair middleFinite (operands 2)
    (mass 2) (mass 0+mass 1) 1 (by decide) (add_nonneg (nonnegative 0) (nonnegative 1)) (products 2)
    (pairBound (contracted 0) pairFinite)
  have group := MaddMagnitude.madd_bound input (contracted 2) (a 3) (b 3) middle hf.2.1 (operands 3)
    (mass 3) (mass 2+(mass 0+mass 1)) 2 (by decide)
    (add_nonneg (nonnegative 2) (add_nonneg (nonnegative 0) (nonnegative 1))) (products 3) middleBound
  have massEq : mass 3+(mass 2+(mass 0+mass 1)) = 31*(∑ i, |Model.toReal (x i)|)+4*(2 : ℝ)^(-100 : Int) := by
    simp only [mass, Fin.sum_univ_four]
    ring
  rw [massEq] at group
  have groupBound : |real (evaluate input groupExpr)| ≤ 32*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-45 : Int) := by
    change |real (evaluate input groupExpr)| ≤ _ at group
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
