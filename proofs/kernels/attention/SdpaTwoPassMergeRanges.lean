import kernels.attention.SdpaTwoPassMerge

namespace Inference.Kernels.Attention.SdpaTwoPassMergeRanges
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic SdpaUpdate SdpaTwoPassMerge
open scoped BigOperators

theorem component_ranges (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (numerator : Bool) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (supported : blocks ≤ 1024)
    (hs : ∀ i, (SdpaMerge.component (states i) numerator).isFinite = true ∧
      |real (SdpaMerge.component (states i) numerator)| ≤ (2 : ℝ)^exponent)
    (he : ∀ i, (exponential p.scalar (states i).shift shift).isFinite = true ∧
      |real (exponential p.scalar (states i).shift shift)| ≤ 1) :
    Arithmetic.Finite (SdpaTwoPassMerge.bind p states shift numerator) (expression blocks contracted p.reduction.tree) ∧
      |real (source p contracted states shift numerator)| ≤ 1024*(2 : ℝ)^exponent := by
  have h := SdpaTwoPassReduction.ranges (SdpaTwoPassMerge.bind p states shift numerator) contracted
    (fun i : Fin blocks => .input i.val) (fun i => .input (blocks+i.val)) exponent lo hi
    (fun i => by simpa only [Arithmetic.Finite, Arithmetic.evaluate, SdpaTwoPassMerge.bind, operands_left] using he i)
    (fun i => by simpa only [Arithmetic.Finite, Arithmetic.evaluate, SdpaTwoPassMerge.bind, operands_right] using hs i)
    supported p.reduction.tree p.reduction.coverage
  change Arithmetic.Finite _ (expression blocks contracted p.reduction.tree) ∧
    |real (evaluate _ (expression blocks contracted p.reduction.tree))| ≤ _ at h
  rwa [execution] at h

theorem component_error (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (numerator : Bool) (supported : blocks ≤ 1024)
    (bound : ∀ i, |real (exponential p.scalar (states i).shift shift)|+
      |real (SdpaMerge.component (states i) numerator)| ≤ (2 : ℝ)^(62 : Nat)+2)
    (hf : Arithmetic.Finite (SdpaTwoPassMerge.bind p states shift numerator) (expression blocks contracted p.reduction.tree)) :
    |real (source p contracted states shift numerator)-
      (∑ i, real (exponential p.scalar (states i).shift shift)*real (SdpaMerge.component (states i) numerator))| ≤
      (2 : ℝ)^(-16 : Int)*(∑ i, |real (exponential p.scalar (states i).shift shift)| *
        |real (SdpaMerge.component (states i) numerator)|)+(2 : ℝ)^(-22 : Int) := by
  have h := SdpaTwoPassReduction.error (SdpaTwoPassMerge.bind p states shift numerator) contracted
    (fun i : Fin blocks => .input i.val) (fun i => .input (blocks+i.val))
    (fun i => by simpa only [evaluate, SdpaTwoPassMerge.bind, operands_left, operands_right] using bound i)
    supported p.reduction.tree p.reduction.coverage hf
  change |real (evaluate _ (expression blocks contracted p.reduction.tree))-_| ≤ _ at h
  rw [execution] at h
  simpa only [WeightedFold.term, evaluate, SdpaTwoPassMerge.bind, operands_left, operands_right, abs_mul] using h

theorem denominator_lower (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State)
    (shift : Float32) (hf : SdpaTwoPassMerge.Finite p contracted states shift)
    (hd : ∀ i, 0 ≤ real (states i).denominator)
    (he : ∀ i, 0 ≤ real (exponential p.scalar (states i).shift shift))
    (witness : Fin blocks) (hw : 1 ≤ real (states witness).denominator)
    (hwexp : real (exponential p.scalar (states witness).shift shift) = 1) :
    1 ≤ real (forward p contracted states shift).denominator := by
  let input := SdpaTwoPassMerge.bind p states shift false
  let a : Fin blocks → Expr := fun i => .input i.val
  let b : Fin blocks → Expr := fun i => .input (blocks+i.val)
  have ha (i : Fin blocks) : NonnegativeArithmetic.Nonnegative input (a i) :=
    .input i.val (by simpa only [input, SdpaTwoPassMerge.bind, operands_left] using he i)
  have hb (i : Fin blocks) : NonnegativeArithmetic.Nonnegative input (b i) :=
    .input (blocks+i.val) (by simpa only [input, SdpaTwoPassMerge.bind, operands_right, SdpaMerge.component, Bool.false_eq_true, ite_false] using hd i)
  let lanes := SdpaTwoPassReduction.lane contracted a b
  have hn (thread : Fin 32) : NonnegativeArithmetic.Nonnegative input (lanes thread) :=
    WeightedFold.ordered_nonnegative input contracted a b ha hb (SdpaLayout.keys blocks thread)
  let owner : Fin 32 := ⟨witness.val%32, by omega⟩
  have member : witness ∈ SdpaLayout.keys blocks owner := (SdpaLayout.keys_mem blocks owner witness).mpr rfl
  have one : NonnegativeArithmetic.LowerOne input (lanes owner) :=
    WeightedFold.ordered_lower_one input contracted a b ha hb (SdpaLayout.keys blocks owner) witness member
      (by simpa only [a, evaluate, input, SdpaTwoPassMerge.bind, operands_left] using hwexp)
      (.input (blocks+witness.val) (by simpa only [input, SdpaTwoPassMerge.bind, operands_right,
        SdpaMerge.component, Bool.false_eq_true, ite_false] using hw))
  have certificate := NonnegativeArithmetic.reduction_lower_one input lanes hn p.reduction.tree owner
    (p.reduction.coverage.mem_iff.mpr (List.mem_finRange owner)) one
  have lower := NonnegativeArithmetic.lower_one input _ certificate (hf.arithmetic false)
  change 1 ≤ real (evaluate (SdpaTwoPassMerge.bind p states shift false) (expression blocks contracted p.reduction.tree)) at lower
  rwa [execution] at lower

theorem ranges (p : SdpaMerge.Platform) (contracted : Bool) (states : Fin blocks → State) (shift : Float32)
    (supported : blocks ≤ 1024)
    (hd : ∀ i, (states i).denominator.isFinite = true ∧
      0 ≤ real (states i).denominator ∧ real (states i).denominator ≤ 8192)
    (hn : ∀ i, (states i).numerator.isFinite = true ∧
      |real (states i).numerator| ≤ (2 : ℝ)^(26 : Nat)*real (states i).denominator)
    (he : ∀ i, ExponentFinite p.scalar (states i).shift shift ∧
      0 ≤ real (exponential p.scalar (states i).shift shift) ∧ real (exponential p.scalar (states i).shift shift) ≤ 1)
    (witness : Fin blocks) (hw : 1 ≤ real (states witness).denominator)
    (hwexp : real (exponential p.scalar (states witness).shift shift) = 1) :
    SdpaTwoPassMerge.Finite p contracted states shift ∧
      (1 ≤ real (forward p contracted states shift).denominator ∧
        real (forward p contracted states shift).denominator ≤ (2 : ℝ)^(23 : Nat)) ∧
      |real (forward p contracted states shift).numerator| ≤
        (2 : ℝ)^(27 : Nat)*real (forward p contracted states shift).denominator := by
  have exponent (i : Fin blocks) : (exponential p.scalar (states i).shift shift).isFinite = true ∧
      |real (exponential p.scalar (states i).shift shift)| ≤ 1 :=
    ⟨(he i).1.exponential, by rw [abs_of_nonneg (he i).2.1]; exact (he i).2.2⟩
  have numeratorBound (i : Fin blocks) : |real (states i).numerator| ≤ (2 : ℝ)^(39 : Nat) := by
    have h := mul_le_mul_of_nonneg_left (hd i).2.2 (by positivity : (0 : ℝ) ≤ 2^26)
    exact (hn i).2.trans (by norm_num at h ⊢; exact h)
  have denominator := component_ranges p contracted states shift false 13 (by decide) (by decide) supported
    (fun i => ⟨(hd i).1, by
      change |real (states i).denominator| ≤ (2 : ℝ)^(13 : Int)
      rw [abs_of_nonneg (hd i).2.1]
      simpa only [show (2 : ℝ)^(13 : Int) = 8192 from by norm_num] using (hd i).2.2⟩) exponent
  have numerator := component_ranges p contracted states shift true 39 (by decide) (by decide) supported
    (fun i => ⟨(hn i).1, by simpa only [SdpaMerge.component, ite_true, zpow_ofNat] using numeratorBound i⟩) exponent
  have finite : SdpaTwoPassMerge.Finite p contracted states shift := ⟨fun i => (he i).1, fun n => by
    cases n; exact denominator.1; exact numerator.1⟩
  have lower := denominator_lower p contracted states shift finite (fun i => (hd i).2.1)
    (fun i => (he i).2.1) witness hw hwexp
  have denError := component_error p contracted states shift false supported (fun i => by
    change |real (exponential p.scalar (states i).shift shift)|+|real (states i).denominator| ≤ _
    rw [abs_of_nonneg (hd i).2.1]
    have d := (hd i).2.2
    have e := (exponent i).2
    norm_num
    linarith only [d, e]) denominator.1
  have numError := component_error p contracted states shift true supported (fun i => by
    change |real (exponential p.scalar (states i).shift shift)|+|real (states i).numerator| ≤ _
    have n := numeratorBound i
    have e := (exponent i).2
    norm_num at n ⊢
    linarith only [n, e]) numerator.1
  simp only [SdpaMerge.component, Bool.false_eq_true, ite_false] at denError
  simp only [SdpaMerge.component, ite_true] at numError
  simp_rw [abs_of_nonneg (hd _).2.1, abs_of_nonneg (he _).2.1] at denError
  simp_rw [abs_of_nonneg (he _).2.1] at numError
  let denMass := ∑ i : Fin blocks, real (exponential p.scalar (states i).shift shift)*real (states i).denominator
  let numMass := ∑ i : Fin blocks, real (exponential p.scalar (states i).shift shift)*|real (states i).numerator|
  have massBound : numMass ≤ (2 : ℝ)^(26 : Nat)*denMass := by
    unfold numMass denMass
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum (fun i _ => by
      simpa only [mul_left_comm] using mul_le_mul_of_nonneg_left (hn i).2 (he i).2.1)
  have massLower : 1 ≤ denMass := by
    have single := Finset.single_le_sum (s := Finset.univ)
      (fun i _ => mul_nonneg (he i).2.1 (hd i).2.1) (Finset.mem_univ witness)
    rw [hwexp, one_mul] at single
    exact hw.trans single
  have ideal : |∑ i : Fin blocks, real (exponential p.scalar (states i).shift shift)*real (states i).numerator| ≤ numMass := by
    have h := Finset.abs_sum_le_sum_abs
      (fun i => real (exponential p.scalar (states i).shift shift)*real (states i).numerator) Finset.univ
    simpa only [numMass, abs_mul, abs_of_nonneg (he _).2.1] using h
  have absolute := NormalizedCastBounds.absolute_of_error _ _ _ numError
  have denLower := (abs_le.mp denError).1
  have scaled := mul_le_mul_of_nonneg_left denLower (by positivity : (0 : ℝ) ≤ 2^27)
  refine ⟨finite, ⟨lower, ?_⟩, ?_⟩
  · have h := (le_abs_self _).trans denominator.2
    norm_num at h ⊢
    exact h
  · change |real (source p contracted states shift true)| ≤ (2 : ℝ)^(27 : Nat)*real (source p contracted states shift false)
    change |real (source p contracted states shift true)| ≤
      |∑ i : Fin blocks, real (exponential p.scalar (states i).shift shift)*real (states i).numerator|+
        ((2 : ℝ)^(-16 : Int)*numMass+(2 : ℝ)^(-22 : Int)) at absolute
    change _ ≤ (2 : ℝ)^(27 : Nat)*(real (source p contracted states shift false)-denMass) at scaled
    norm_num at absolute scaled massBound ⊢
    linarith only [absolute, ideal, scaled, massBound, massLower]

end Inference.Kernels.Attention.SdpaTwoPassMergeRanges
