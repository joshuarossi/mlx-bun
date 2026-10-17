import kernels.attention.SdpaMergeRanges
import contracts.mlx.WeightedReductionRelative
import contracts.mlx.NonnegativeArithmetic

namespace Inference.Kernels.Attention.SdpaMergeRelative
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaMerge
open scoped BigOperators

theorem component_error (p : SdpaMerge.Platform) (states : Fin 32 → State) (shift : Float32) (numerator : Bool)
    (hf : Arithmetic.Finite (SdpaMerge.bind p states shift numerator) (expression p.reduction.tree))
    (bound : ∀ i, |real (component (states i) numerator)|+
      |real (exponential p.scalar (states i).shift shift)| ≤ (2 : ℝ)^(62 : Nat)+2) :
    |real (source p states shift numerator)-
      (∑ i : Fin 32, real (component (states i) numerator)*real (exponential p.scalar (states i).shift shift))| ≤
      34*(2 : ℝ)^(-24 : Int)*(∑ i : Fin 32, |real (component (states i) numerator)| *
        |real (exponential p.scalar (states i).shift shift)|)+(2 : ℝ)^(-56 : Int) := by
  have h := WeightedReductionRelative.error (SdpaMerge.bind p states shift numerator)
    (fun i : Fin 32 => .input i.val) (fun i : Fin 32 => .input (32+i.val)) p.reduction.tree p.reduction.coverage hf
    (fun i => by simpa only [Arithmetic.evaluate, SdpaMerge.bind, operands_left, operands_right] using bound i)
  change |real (Arithmetic.evaluate (SdpaMerge.bind p states shift numerator) (expression p.reduction.tree))-_|
    ≤ _ at h
  rw [execution] at h
  simpa only [Arithmetic.evaluate, SdpaMerge.bind, operands_left, operands_right] using h

theorem denominator_lower (p : SdpaMerge.Platform) (states : Fin 32 → State) (shift : Float32)
    (hf : SdpaMerge.Finite p states shift)
    (hd : ∀ i, 0 ≤ real (states i).denominator)
    (he : ∀ i, 0 ≤ real (exponential p.scalar (states i).shift shift))
    (witness : Fin 32) (hw : 1 ≤ real (states witness).denominator)
    (hwexp : real (exponential p.scalar (states witness).shift shift) = 1) :
    1 ≤ real (forward p states shift).denominator := by
  let input := SdpaMerge.bind p states shift false
  have leafFinite (i : Fin 32) : Arithmetic.Finite input (.mul (.input i.val) (.input (32+i.val))) :=
    ArithmeticDependencies.reduce_finite input _ p.reduction.tree (hf.arithmetic false) i
      (p.reduction.coverage.mem_iff.mpr (List.mem_finRange i))
  have nonnegative (i : Fin 32) : 0 ≤ real (Arithmetic.evaluate input (.mul (.input i.val) (.input (32+i.val)))) := by
    apply NonnegativeArithmetic.nonnegative input _ ?_ (leafFinite i)
    exact .mul (.input i.val (by simpa only [input, SdpaMerge.bind, operands_left, component, Bool.false_eq_true, ite_false] using hd i))
      (.input (32+i.val) (by simpa only [input, SdpaMerge.bind, operands_right] using he i))
  have selected : 1 ≤ real (Arithmetic.evaluate input (.mul (.input witness.val) (.input (32+witness.val)))) := by
    apply NonnegativeArithmetic.lower_one input _ ?_ (leafFinite witness)
    exact .mulRightOne
      (.input witness.val (by simpa only [input, SdpaMerge.bind, operands_left, component, Bool.false_eq_true, ite_false] using hw))
      (by simpa only [Arithmetic.evaluate, input, SdpaMerge.bind, operands_right] using hwexp)
  have h := SdpaMergeRanges.reduce_lower_one input p.reduction.tree (hf.arithmetic false) nonnegative witness
    (p.reduction.coverage.mem_iff.mpr (List.mem_finRange witness)) selected
  rw [show input = SdpaMerge.bind p states shift false from rfl, execution] at h
  exact h

theorem ranges (p : SdpaMerge.Platform) (states : Fin 32 → State) (shift : Float32)
    (hd : ∀ i, (states i).denominator.isFinite = true ∧
      0 ≤ real (states i).denominator ∧ real (states i).denominator ≤ 8192)
    (hn : ∀ i, (states i).numerator.isFinite = true ∧
      |real (states i).numerator| ≤ (2 : ℝ)^(25 : Nat)*real (states i).denominator)
    (he : ∀ i, ExponentFinite p.scalar (states i).shift shift ∧
      0 ≤ real (exponential p.scalar (states i).shift shift) ∧ real (exponential p.scalar (states i).shift shift) ≤ 1)
    (witness : Fin 32) (hw : 1 ≤ real (states witness).denominator)
    (hwexp : real (exponential p.scalar (states witness).shift shift) = 1) :
    SdpaMerge.Finite p states shift ∧
      (1 ≤ real (forward p states shift).denominator ∧ real (forward p states shift).denominator ≤ (2 : ℝ)^(18 : Nat)) ∧
      |real (forward p states shift).numerator| ≤ (2 : ℝ)^(26 : Nat)*real (forward p states shift).denominator := by
  have exponent (i : Fin 32) : (exponential p.scalar (states i).shift shift).isFinite = true ∧
      |real (exponential p.scalar (states i).shift shift)| ≤ 1 :=
    ⟨(he i).1.exponential, by rw [abs_of_nonneg (he i).2.1]; exact (he i).2.2⟩
  have numeratorBound (i : Fin 32) : |real (states i).numerator| ≤ (2 : ℝ)^(38 : Nat) := by
    have h := mul_le_mul_of_nonneg_left (hd i).2.2 (by positivity : (0 : ℝ) ≤ 2^25)
    exact (hn i).2.trans (by norm_num at h ⊢; exact h)
  have denominator := SdpaMergeRanges.component_ranges p states shift false 13 (by decide) (by decide)
    (fun i => ⟨(hd i).1, by
      change |real (states i).denominator| ≤ (2 : ℝ)^(13 : Int)
      rw [abs_of_nonneg (hd i).2.1]
      simpa only [show (2 : ℝ)^(13 : Int) = 8192 from by norm_num] using (hd i).2.2⟩) exponent
  have numerator := SdpaMergeRanges.component_ranges p states shift true 38 (by decide) (by decide)
    (fun i => ⟨(hn i).1, by simpa only [component, ite_true, zpow_ofNat] using numeratorBound i⟩) exponent
  have finite : SdpaMerge.Finite p states shift := ⟨fun i => (he i).1, fun n => by
    cases n; exact denominator.1; exact numerator.1⟩
  have lower := denominator_lower p states shift finite (fun i => (hd i).2.1) (fun i => (he i).2.1) witness hw hwexp
  have denError := component_error p states shift false denominator.1 (fun i => by
    change |real (states i).denominator|+|real (exponential p.scalar (states i).shift shift)| ≤ _
    rw [abs_of_nonneg (hd i).2.1]
    have d := (hd i).2.2
    have e := (exponent i).2
    norm_num
    linarith only [d, e])
  have numError := component_error p states shift true numerator.1 (fun i => by
    change |real (states i).numerator|+|real (exponential p.scalar (states i).shift shift)| ≤ _
    have n := numeratorBound i
    have e := (exponent i).2
    norm_num at n ⊢
    linarith only [n, e])
  simp only [component, Bool.false_eq_true, ite_false] at denError
  simp only [component, ite_true] at numError
  simp_rw [abs_of_nonneg (hd _).2.1, abs_of_nonneg (he _).2.1] at denError
  simp_rw [abs_of_nonneg (he _).2.1] at numError
  let denMass := ∑ i : Fin 32, real (states i).denominator*real (exponential p.scalar (states i).shift shift)
  let numMass := ∑ i : Fin 32, |real (states i).numerator| * real (exponential p.scalar (states i).shift shift)
  have massBound : numMass ≤ (2 : ℝ)^(25 : Nat)*denMass := by
    unfold numMass denMass
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum (fun i _ => by
      simpa only [mul_assoc] using mul_le_mul_of_nonneg_right (hn i).2 (he i).2.1)
  have massLower : 1 ≤ denMass := by
    have single := Finset.single_le_sum (s := Finset.univ)
      (fun i _ => mul_nonneg (hd i).2.1 (he i).2.1) (Finset.mem_univ witness)
    rw [hwexp, mul_one] at single
    exact hw.trans single
  have ideal : |∑ i : Fin 32, real (states i).numerator*real (exponential p.scalar (states i).shift shift)| ≤ numMass := by
    have h := Finset.abs_sum_le_sum_abs
      (fun i => real (states i).numerator*real (exponential p.scalar (states i).shift shift)) Finset.univ
    simpa only [numMass, abs_mul, abs_of_nonneg (he _).2.1] using h
  have absolute := NormalizedCastBounds.absolute_of_error _ _ _ numError
  have denLower := (abs_le.mp denError).1
  have scaled := mul_le_mul_of_nonneg_left denLower (by positivity : (0 : ℝ) ≤ 2^26)
  refine ⟨finite, ⟨lower, ?_⟩, ?_⟩
  · have h := (le_abs_self _).trans denominator.2
    norm_num at h ⊢
    exact h
  · change |real (source p states shift true)| ≤ (2 : ℝ)^(26 : Nat)*real (source p states shift false)
    change |real (source p states shift true)| ≤
      |∑ i : Fin 32, real (states i).numerator*real (exponential p.scalar (states i).shift shift)|+
        (34*(2 : ℝ)^(-24 : Int)*numMass+(2 : ℝ)^(-56 : Int)) at absolute
    change _ ≤ (2 : ℝ)^(26 : Nat)*(real (source p states shift false)-denMass) at scaled
    norm_num at absolute scaled massBound ⊢
    linarith only [absolute, ideal, scaled, massBound, massLower]

end Inference.Kernels.Attention.SdpaMergeRelative
