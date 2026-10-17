import kernels.sampling.LogSumExpBlockRanges
import kernels.attention.SdpaMerge
import contracts.mlx.ArithmeticFoldBounds

namespace Inference.Kernels.Sampling.LogSumExpMergeRanges
open Contracts.Mlx Contracts.Mlx.Numerics LogSumExpBlockRanges
open Attention.SdpaUpdate (Platform exponential ExponentFinite)
open Arithmetic ArithmeticBounds NonnegativeArithmetic ArithmeticFold

def maximum (states : Fin 32 → State) (tree : Reduction.Tree 32) : Float32 :=
  Maximum.tree (fun i => (states i).maximum) tree
def bind (p : Platform) (states : Fin 32 → State) (shift : Float32) : Nat → Float32 :=
  Attention.SdpaMerge.operands (fun i => (states i).normalizer) (fun i => exponential p (states i).maximum shift)
def lane (i : Fin 32) : Expr := .mul (.input i.val) (.input (32+i.val))
def expression (tree : Reduction.Tree 32) : Expr := reduceExpr lane tree
def merge (p : Platform) (states : Fin 32 → State) (maxTree sumTree : Reduction.Tree 32) : State :=
  ⟨maximum states maxTree, evaluate (bind p states (maximum states maxTree)) (expression sumTree)⟩

theorem execution (p : Platform) (states : Fin 32 → State) (maxTree sumTree : Reduction.Tree 32) :
    (merge p states maxTree sumTree).normalizer =
      FlushedReduction.evaluate (fun i => FlushToZero.mul (states i).normalizer
        (exponential p (states i).maximum (maximum states maxTree))) sumTree := by
  unfold merge expression
  dsimp only
  rw [evaluate_reduce]
  apply congrArg (fun input => FlushedReduction.evaluate input sumTree)
  funext i
  simp only [lane, evaluate, bind, Attention.SdpaMerge.operands_left, Attention.SdpaMerge.operands_right]

def inputCap (count i : Nat) : Float32 := if i < 32 then LogSumExpAccumulator.cap count else 1

theorem certificate (count : Nat) (size : 32*count < 16777216) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Certificate (inputCap count) (expression tree) (LogSumExpAccumulator.cap (32*count)) := by
  have hc := LogSumExpAccumulator.cap_range count (by omega)
  have leaves (i : Fin 32) : Certificate (inputCap count) (lane i) (LogSumExpAccumulator.cap count) := by
    have a := Certificate.input (inputCap := inputCap count) i.val
    have b := Certificate.input (inputCap := inputCap count) (32+i.val)
    simp only [inputCap, i.isLt, show ¬32+i.val < 32 from by omega, ite_true, ite_false] at a b
    exact .mul a b _ hc.1 (by rw [real_one, mul_one])
  have hl : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
  have h := ArithmeticFoldBounds.reduction (inputCap count) lane count 0 (by decide) (by decide) leaves tree
    (by rw [hl]; exact size)
  simpa only [expression, hl, LogSumExpAccumulator.cap] using h

theorem positive_tree (input : Nat → Float32) (tree : Reduction.Tree 32)
    (h : ∀ i, Nonnegative input (lane i)) : Nonnegative input (expression tree) := by
  induction tree with
  | leaf i => exact h i
  | add a b ia ib => exact .add ia ib

theorem lower_tree (input : Nat → Float32) (tree : Reduction.Tree 32)
    (h : ∀ i, Nonnegative input (lane i)) (witness : Fin 32)
    (member : witness ∈ Reduction.leaves tree) (hw : LowerOne input (lane witness)) :
    LowerOne input (expression tree) := by
  induction tree with
  | leaf i =>
    have eq : witness = i := List.mem_singleton.mp member
    subst i
    exact hw
  | add a b ia ib =>
    rcases List.mem_append.mp member with ha | hb
    · exact .addLeft (ia ha) (positive_tree input b h)
    · exact .addRight (positive_tree input a h) (ib hb)

structure Trace (p : Platform) (states : Fin 32 → State) (maxTree sumTree : Reduction.Tree 32) : Prop where
  factors : ∀ i, ExponentFinite p (states i).maximum (maximum states maxTree)
  arithmetic : Arithmetic.Finite (bind p states (maximum states maxTree)) (expression sumTree)

theorem ranges (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (states : Fin 32 → State) (count : Nat) (size : 32*count < 16777216)
    (hs : ∀ i, Bounds (states i) count) (maxTree sumTree : Reduction.Tree 32)
    (maxCovered : (Reduction.leaves maxTree).Perm (List.finRange 32))
    (sumCovered : (Reduction.leaves sumTree).Perm (List.finRange 32)) :
    Trace p states maxTree sumTree ∧ Bounds (merge p states maxTree sumTree) (32*count) := by
  let shift := maximum states maxTree
  have mf : shift.isFinite = true := Maximum.tree_finite _ _ (fun i => (hs i).maximumFinite)
  have ms := Maximum.tree_spec (fun i => (states i).maximum) maxTree (fun i => (hs i).maximumFinite)
  obtain ⟨witness, member, selected⟩ := ms.1
  have mb : |real shift| ≤ (2 : ℝ)^(23 : Nat) := by
    change |real (Maximum.tree (fun i => (states i).maximum) maxTree)| ≤ _
    rw [selected]
    exact (hs witness).maximumBound
  have factors i := LogSumExpExponentRanges.ordered_flushed p primitive (states i).maximum shift
    (hs i).maximumFinite mf ((hs i).maximumBound.trans (by norm_num)) (mb.trans (by norm_num))
    (ms.2 i (maxCovered.mem_iff.mpr (List.mem_finRange i)))
  have hi : ∀ i, (bind p states shift i).isFinite = true ∧
      |real (bind p states shift i)| ≤ real (inputCap count i) := by
    intro i
    unfold bind Attention.SdpaMerge.operands inputCap
    split
    · rename_i h
      have hn : 0 ≤ real (states ⟨i, h⟩).normalizer := by linarith [(hs ⟨i, h⟩).lower]
      rw [(LogSumExpAccumulator.cap_range count (by omega)).2, abs_of_nonneg hn]
      exact ⟨(hs _).normalizerFinite, (hs _).upper⟩
    · rw [real_one, abs_of_nonneg (factors _).2.1]
      exact ⟨(factors _).1.exponential, (factors _).2.2⟩
  have positive (i : Fin 32) : Nonnegative (bind p states shift) (lane i) := by
    apply Nonnegative.mul
    · apply Nonnegative.input
      simp only [bind, Attention.SdpaMerge.operands_left]
      linarith [(hs i).lower]
    · apply Nonnegative.input
      simp only [bind, Attention.SdpaMerge.operands_right]
      exact (factors i).2.1
  have lower : LowerOne (bind p states shift) (lane witness) := by
    apply LowerOne.mulRightOne
    · apply LowerOne.input
      simpa only [bind, Attention.SdpaMerge.operands_left] using (hs witness).lower
    · simp only [evaluate, bind, Attention.SdpaMerge.operands_right]
      change real (exponential p (states witness).maximum (Maximum.tree (fun i => (states i).maximum) maxTree)) = 1
      rw [selected]
      exact (Attention.SdpaExponentRanges.diagonal p primitive _ (hs witness).maximumFinite).2
  have hr := ArithmeticBounds.sound _ _ hi (certificate count size sumTree sumCovered)
  have hl := lower_one _ _ (lower_tree _ sumTree positive witness
    (sumCovered.mem_iff.mpr (List.mem_finRange witness)) lower) hr.1
  exact ⟨⟨fun i => (factors i).1, hr.1⟩, ⟨mf, mb, finite_evaluate _ _ hr.1, hl,
    (le_abs_self _).trans (hr.2.trans_eq (LogSumExpAccumulator.cap_range (32*count) size).2)⟩⟩

end Inference.Kernels.Sampling.LogSumExpMergeRanges
