import kernels.attention.SdpaMerge
import contracts.mlx.ArithmeticFoldBounds
import contracts.mlx.FlushedIdentities
import contracts.mlx.SquaredSumDyadicBounds

namespace Inference.Kernels.Attention.SdpaMergeRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaMerge ArithmeticBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def inputCap (exponent : Int) (i : Nat) : Float32 :=
  if i < 32 then DyadicBounds.ceiling 1 exponent else 1

theorem certificate (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (tree : Reduction.Tree 32) (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Certificate (inputCap exponent) (expression tree) (DyadicBounds.ceiling 32 exponent) := by
  have cap := DyadicBounds.ceiling_range 1 exponent (by decide) lo hi
  have lanes (i : Fin 32) : Certificate (inputCap exponent)
      (.mul (.input i.val) (.input (32+i.val))) (DyadicBounds.ceiling 1 exponent) := by
    have a := Certificate.input (inputCap := inputCap exponent) i.val
    have b := Certificate.input (inputCap := inputCap exponent) (32+i.val)
    simp only [inputCap, i.isLt, show ¬32+i.val < 32 from by omega, ite_true, ite_false] at a b
    exact .mul a b _ cap.1 (by rw [real_one, mul_one])
  have hl : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
  have h := ArithmeticFoldBounds.reduction (inputCap exponent)
    (fun i : Fin 32 => .mul (.input i.val) (.input (32+i.val))) 1 exponent lo hi lanes tree
    (by rw [hl]; decide)
  simpa only [expression, hl, Nat.mul_one] using h

theorem component_ranges (p : SdpaMerge.Platform) (states : Fin 32 → State) (shift : Float32)
    (numerator : Bool) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hs : ∀ i, (component (states i) numerator).isFinite = true ∧
      |real (component (states i) numerator)| ≤ (2 : ℝ)^exponent)
    (he : ∀ i, (exponential p.scalar (states i).shift shift).isFinite = true ∧
      |real (exponential p.scalar (states i).shift shift)| ≤ 1) :
    Arithmetic.Finite (SdpaMerge.bind p states shift numerator) (expression p.reduction.tree) ∧
      |real (source p states shift numerator)| ≤ 32*(2 : ℝ)^exponent := by
  have cap := DyadicBounds.ceiling_range 1 exponent (by decide) lo hi
  have hb : ∀ i, (SdpaMerge.bind p states shift numerator i).isFinite = true ∧
      |real (SdpaMerge.bind p states shift numerator i)| ≤ real (inputCap exponent i) := by
    intro i
    unfold SdpaMerge.bind operands inputCap
    split
    · simpa only [cap.2, Nat.cast_one, one_mul] using hs _
    · simpa only [real_one] using he _
  have h := ArithmeticBounds.sound _ (inputCap exponent) hb (certificate exponent lo hi p.reduction.tree p.reduction.coverage)
  refine ⟨h.1, ?_⟩
  rw [execution] at h
  have hc := DyadicBounds.ceiling_range 32 exponent (by decide) lo hi
  exact h.2.trans_eq hc.2

theorem reduce_nonnegative (input : Nat → Float32) (tree : Reduction.Tree 32)
    (hf : Arithmetic.Finite input (expression tree))
    (hi : ∀ i : Fin 32, 0 ≤ real (Arithmetic.evaluate input (.mul (.input i.val) (.input (32+i.val))))) :
    0 ≤ real (Arithmetic.evaluate input (expression tree)) := by
  induction tree with
  | leaf i => exact hi i
  | add a b ia ib =>
    exact FlushToZero.add_nonnegative _ _ (Arithmetic.finite_evaluate _ _ hf.1)
      (Arithmetic.finite_evaluate _ _ hf.2.1) (ia hf.1) (ib hf.2.1) hf.2.2

theorem reduce_lower_one (input : Nat → Float32) (tree : Reduction.Tree 32)
    (hf : Arithmetic.Finite input (expression tree))
    (hi : ∀ i : Fin 32, 0 ≤ real (Arithmetic.evaluate input (.mul (.input i.val) (.input (32+i.val)))))
    (witness : Fin 32) (member : witness ∈ Reduction.leaves tree)
    (hw : 1 ≤ real (Arithmetic.evaluate input (.mul (.input witness.val) (.input (32+witness.val))))) :
    1 ≤ real (Arithmetic.evaluate input (expression tree)) := by
  have normal : FlushToZero.threshold < real (1 : Float32) := by rw [real_one]; norm_num [FlushToZero.threshold]
  induction tree with
  | leaf i =>
    have h : witness = i := by simpa only [Reduction.leaves, List.mem_singleton] using member
    subst i
    exact hw
  | add a b ia ib =>
    change 1 ≤ real (FlushToZero.add (Arithmetic.evaluate input (expression a)) (Arithmetic.evaluate input (expression b)))
    rw [← real_one]
    apply SquaredSumDyadicBounds.flush_lower 1 _ normal
    rw [Numerics.add_real (FlushToZero.flush (Arithmetic.evaluate input (expression a)))
      (FlushToZero.flush (Arithmetic.evaluate input (expression b)))
      (FlushToZero.finite_flush _ (Arithmetic.finite_evaluate _ _ hf.1))
      (FlushToZero.finite_flush _ (Arithmetic.finite_evaluate _ _ hf.2.1)) hf.2.2]
    apply SquaredSumDyadicBounds.round_lower 1 (by decide)
    rcases (show witness ∈ Reduction.leaves a ∨ witness ∈ Reduction.leaves b from
      by simpa only [Reduction.leaves, List.mem_append] using member) with ha | hb
    · have h := SquaredSumDyadicBounds.flush_lower 1 (Arithmetic.evaluate input (expression a)) normal (by rw [real_one]; exact ia hf.1 ha)
      have hn := FlushToZero.flush_nonnegative _ (reduce_nonnegative input b hf.2.1 hi)
      linarith
    · have h := SquaredSumDyadicBounds.flush_lower 1 (Arithmetic.evaluate input (expression b)) normal (by rw [real_one]; exact ib hf.2.1 hb)
      have hn := FlushToZero.flush_nonnegative _ (reduce_nonnegative input a hf.1 hi)
      linarith

theorem leaf_finite (input : Nat → Float32) (tree : Reduction.Tree 32)
    (hf : Arithmetic.Finite input (expression tree)) (i : Fin 32) (member : i ∈ Reduction.leaves tree) :
    (FlushToZero.flush (input i.val) * FlushToZero.flush (input (32+i.val))).isFinite = true := by
  induction tree with
  | leaf j =>
    have h : i = j := by simpa only [Reduction.leaves, List.mem_singleton] using member
    subst j
    exact hf.2.2
  | add a b ia ib =>
    rcases (show i ∈ Reduction.leaves a ∨ i ∈ Reduction.leaves b from
      by simpa only [Reduction.leaves, List.mem_append] using member) with ha | hb
    · exact ia hf.1 ha
    · exact ib hf.2.1 hb

theorem denominator_lower (p : SdpaMerge.Platform) (states : Fin 32 → State) (shift : Float32)
    (hf : SdpaMerge.Finite p states shift)
    (hd : ∀ i, 0 ≤ real (states i).denominator)
    (he : ∀ i, 0 ≤ real (exponential p.scalar (states i).shift shift))
    (witness : Fin 32) (hw : real (states witness).denominator = 1)
    (hwexp : real (exponential p.scalar (states witness).shift shift) = 1) :
    1 ≤ real (forward p states shift).denominator := by
  let input := SdpaMerge.bind p states shift false
  have leafFinite (i : Fin 32) :
      (FlushToZero.flush (states i).denominator * FlushToZero.flush (exponential p.scalar (states i).shift shift)).isFinite = true := by
    have h := leaf_finite (SdpaMerge.bind p states shift false) p.reduction.tree (hf.arithmetic false) i
      (p.reduction.coverage.mem_iff.mpr (List.mem_finRange i))
    simpa only [SdpaMerge.bind, operands_left, operands_right, component, Bool.false_eq_true, ite_false] using h
  have hpos (i : Fin 32) : 0 ≤ real (Arithmetic.evaluate input (.mul (.input i.val) (.input (32+i.val)))) := by
    change 0 ≤ real (FlushToZero.mul (SdpaMerge.bind p states shift false i.val) (SdpaMerge.bind p states shift false (32+i.val)))
    simp only [SdpaMerge.bind, operands_left, operands_right, component, Bool.false_eq_true, ite_false]
    exact FlushToZero.mul_nonnegative _ _ (mul_nonneg (FlushToZero.flush_nonnegative _ (hd i))
      (FlushToZero.flush_nonnegative _ (he i))) (leafFinite i)
  have hleaf : real (Arithmetic.evaluate input (.mul (.input witness.val) (.input (32+witness.val)))) = 1 := by
    change real (FlushToZero.mul (SdpaMerge.bind p states shift false witness.val) (SdpaMerge.bind p states shift false (32+witness.val))) = 1
    simp only [SdpaMerge.bind, operands_left, operands_right, component, Bool.false_eq_true, ite_false]
    exact FlushedIdentities.mul_one_one _ _ hw hwexp (leafFinite witness)
  have h := reduce_lower_one input p.reduction.tree (hf.arithmetic false) hpos witness
    (p.reduction.coverage.mem_iff.mpr (List.mem_finRange witness)) hleaf.ge
  rw [execution] at h
  exact h

end Inference.Kernels.Attention.SdpaMergeRanges
