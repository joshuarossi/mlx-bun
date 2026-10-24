import kernels.quantization.AffineDot3Magnitude
import contracts.mlx.FlushedIdentities

namespace Inference.Kernels.Quantization.AffineDot3SourceMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold AffineDot AffineDot3Magnitude
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

theorem product_combine (a b r x s f : ℝ) (an : 0 ≤ a) (bn : 0 ≤ b) (xn : 0 ≤ x)
    (prepared : a*s ≤ 2*x+(2 : ℝ)^(-133 : Int))
    (mask : b*f ≤ 8*s) (cap : b ≤ 1024)
    (rounded : r ≤ (1+(2 : ℝ)^(-24 : Int))*f*a+(2 : ℝ)^(-110 : Int)) :
    b*r ≤ 17*x+(2 : ℝ)^(-99 : Int) := by
  have linked := mul_le_mul_of_nonneg_right mask an
  have result := mul_le_mul_of_nonneg_left rounded bn
  have noise := mul_le_mul_of_nonneg_right cap (by positivity : (0 : ℝ) ≤ 2^(-110 : Int))
  norm_num at prepared result noise ⊢
  nlinarith only [prepared, linked, result, noise, xn]

theorem mask_link (w : Fin 3 → BitVec 8) (i : Fin 10) :
    |real (AffineLift.value (mask3 w i))| * (if crossed3 i then (256 : ℝ) else 1) ≤
      8*(2 : ℝ)^(AffineTile.shift3 (coordinate3 i)).val := by
  have h := (AffineShiftedDotBounds.mask3_range w i).2
  fin_cases i <;> norm_num [AffineShiftedDotBounds.maskExponent3, crossed3, coordinate3,
    AffineTile.shift3, inputShift3] at h ⊢ <;> linarith only [h]

theorem left_read (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) (i : Fin 10) :
    evaluate (bind3 w scaled acc) (left3 i) = AffineLift.value (mask3 w i) := by
  have := i.isLt
  simp [left3, evaluate, bind3, show ¬8+i.val < 8 by omega, show 8+i.val < 18 by omega]

theorem right_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 8 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (w : Fin 3 → BitVec 8) (acc : Float32) (i : Fin 10)
    (hf : Arithmetic.Finite (bind3 w (prepared divide x) acc) (right3 i)) :
    |real (evaluate (bind3 w (prepared divide x) acc) (right3 i))| ≤
      (1+(2 : ℝ)^(-24 : Int))*(if crossed3 i then (256 : ℝ) else 1)*
        |real (prepared divide x (coordinate3 i))|+(2 : ℝ)^(-110 : Int) ∧
      |real (evaluate (bind3 w (prepared divide x) acc) (right3 i))| ≤ (2 : ℝ)^18 := by
  have prep := prepared_bound divide division x hx (coordinate3 i)
  by_cases cross : crossed3 i = true
  · simp only [right3, cross, ite_true, Arithmetic.Finite] at hf
    have raw : (FlushToZero.flush (prepared divide x (coordinate3 i))*FlushToZero.flush (256 : Float32)).isFinite = true := by
      simpa [evaluate, bind3, (coordinate3 i).isLt] using hf.2.2
    simpa [right3, cross, evaluate, bind3, (coordinate3 i).isLt] using
      crossed_bound (prepared divide x (coordinate3 i)) prep.2 raw
  · have read : evaluate (bind3 w (prepared divide x) acc) (right3 i) = prepared divide x (coordinate3 i) := by
      simp [right3, cross, evaluate, bind3, (coordinate3 i).isLt]
    rw [read, ite_eq_right cross]
    refine ⟨?_, prep.2.trans (by norm_num : (512 : ℝ) ≤ 2^18)⟩
    norm_num
    nlinarith only [abs_nonneg (real (prepared divide x (coordinate3 i)))]

theorem product_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 8 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (w : Fin 3 → BitVec 8) (acc : Float32) (i : Fin 10)
    (hf : Arithmetic.Finite (bind3 w (prepared divide x) acc) (right3 i)) :
    |real (evaluate (bind3 w (prepared divide x) acc) (left3 i))| *
      |real (evaluate (bind3 w (prepared divide x) acc) (right3 i))| ≤
        17*|Model.toReal (x (coordinate3 i))|+(2 : ℝ)^(-99 : Int) := by
  have prep := (AffineInputMagnitude.prepare divide division (x (coordinate3 i))
    (AffineTile.shift3 (coordinate3 i)) (hx _).1 ((hx _).2.trans (by norm_num))).2
  rw [left_read]
  exact product_combine _ _ _ _ _ _ (abs_nonneg _) (abs_nonneg _) (abs_nonneg _)
    prep (mask_link w i) (coefficient_bound w i) (right_bound divide division x hx w acc i hf).1

theorem coordinate_mass (f : Fin 8 → ℝ) (hn : ∀ i, 0 ≤ f i) :
    (∑ i : Fin 10, f (coordinate3 i)) ≤ 2*(∑ i, f i) := by
  have repeated : (∑ i : Fin 10, f (coordinate3 i)) = (∑ i, f i)+f 2+f 5 := by
    norm_num [Fin.sum_univ_succ, coordinate3]
    ring
  rw [repeated]
  have rest : f 2+f 5 ≤ ∑ i, f i := by
    norm_num [Fin.sum_univ_succ]
    linarith only [hn 0, hn 1, hn 3, hn 4, hn 6, hn 7]
  linarith only [rest]

-- The ten multiply/add terms are traversed in their source order. Two source
-- coordinates appear twice because their packed fields cross byte boundaries.
theorem source_bound (divide : Float32 → Float32 → Float32) (division : DivisionDirectedBounds.Contract divide)
    (x : Fin 8 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (contracted : Nat → Bool) (w : Fin 3 → BitVec 8) (acc : Float32)
    (hf : Arithmetic.Finite (bind3 w (prepared divide x) acc) (expression3 contracted)) :
    |real (source3 contracted w (prepared divide x) acc)| ≤
      (1+(2 : ℝ)^(-16 : Int))*|real acc|+35*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-45 : Int) := by
  let input := bind3 w (prepared divide x) acc
  let mass := fun i : Fin 10 => 17*|Model.toReal (x (coordinate3 i))|+(2 : ℝ)^(-99 : Int)
  have dependencies := ArithmeticDependencies.sites_finite input (fun i : Fin 10 => contracted i.val) left3 right3
    (List.finRange 10) (.input 19) hf
  have rightFinite (i : Fin 10) : Arithmetic.Finite input (right3 i) :=
    (dependencies.2 i (by simp)).2
  have operands (i : Fin 10) : |real (evaluate input (left3 i))|+|real (evaluate input (right3 i))| ≤ (2 : ℝ)^62+2 := by
    have h := add_le_add (coefficient_bound w i) (right_bound divide division x hx w acc i (rightFinite i)).2
    rw [show input = bind3 w (prepared divide x) acc from rfl, left_read]
    norm_num at h ⊢
    linarith only [h]
  have products (i : Fin 10) : |real (evaluate input (left3 i))| * |real (evaluate input (right3 i))| ≤ mass i :=
    product_bound divide division x hx w acc i (rightFinite i)
  have accRead : evaluate input (.input 19) = acc := by simp [evaluate, input, bind3]
  have result := MaddMagnitude.sites_bound input (fun i : Fin 10 => contracted i.val) left3 right3 mass
    (List.finRange 10) (.input 19) |real acc| 0 (by simp) hf operands products (abs_nonneg _) (by rw [accRead]; simp)
  have massEq : ((List.finRange 10).map mass).sum =
      17*(∑ i : Fin 10, |Model.toReal (x (coordinate3 i))|)+10*(2 : ℝ)^(-99 : Int) := by
    rw [← Fin.sum_univ_def]
    simp [mass, Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [massEq] at result
  have coverage := coordinate_mass (fun i => |Model.toReal (x i)|) (fun _ => abs_nonneg _)
  have mn : 0 ≤ ∑ i, |Model.toReal (x i)| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  change |real (evaluate input (expression3 contracted))| ≤ _ at result
  rw [execution3] at result
  norm_num only [List.length_finRange, Nat.zero_add, Nat.cast_ofNat] at result
  norm_num at result ⊢
  linarith only [result, coverage, mn, abs_nonneg (real acc)]

theorem tile_dot (p : AffineTile.Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512)
    (hf : AffineTile.DotFinite3 p x w) :
    |real (AffineTile.dot3 p x w)| ≤ 36*(∑ i, |Model.toReal (x i)|)+(2 : ℝ)^(-40 : Int) := by
  let mass := fun c : Fin 2 => ∑ i, |Model.toReal (x (AffineInput.index8 c i))|
  have step (c : Fin 2) (acc : Float32) (valid : AffineTile.valid3 p x w c acc) :
      |real (AffineTile.step3 p x w c acc)| ≤
        (1+(2 : ℝ)^(-16 : Int))*|real acc|+35*mass c+(2 : ℝ)^(-45 : Int) :=
    source_bound p.divide division (fun i => x (AffineInput.index8 c i))
      (fun i => hx (AffineInput.index8 c i)) p.contracted (w c) acc valid
  have valid := hf.arithmetic
  simp only [show List.finRange 2 = [0, 1] from by decide +kernel, FoldFinite] at valid
  have h0 := step 0 0 valid.1
  have h1 := step 1 _ valid.2.1
  have whole := AffineTile.input_coverage3 (fun i => |Model.toReal (x i)|)
  change (∑ c, mass c) = ∑ i, |Model.toReal (x i)| at whole
  have sumTwo : (∑ c, mass c) = mass 0+mass 1 := by simp [Fin.sum_univ_succ]
  rw [sumTwo] at whole
  have nonnegative (c : Fin 2) : 0 ≤ mass c := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  simp only [AffineTile.dot3, show List.finRange 2 = [0, 1] from by decide +kernel,
    List.foldl_cons, List.foldl_nil]
  norm_num [FlushedIdentities.zero_real] at h0 h1 ⊢
  linarith only [h0, h1, whole, nonnegative 0, nonnegative 1]

end Inference.Kernels.Quantization.AffineDot3SourceMagnitude
