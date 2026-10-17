import contracts.mlx.FlushToZero
import contracts.mlx.Reduction

namespace Inference.Contracts.Mlx.SquaredSum
open Numerics

-- Both contracted (FMA) and uncontracted x*x+acc are represented. A compiler
-- schedule must supply the expression it executes and once-only coverage;
-- neither arithmetic associativity nor contraction is silently assumed.
inductive Expr (n : Nat) where
  | zero
  | square (i : Fin n)
  | fmaSquare (i : Fin n) (acc : Expr n)
  | add (left right : Expr n)

def indices : Expr n → List (Fin n)
  | .zero => []
  | .square i => [i]
  | .fmaSquare i a => i :: indices a
  | .add a b => indices a ++ indices b

def step (contracted : Bool) (acc : Expr n) (i : Fin n) : Expr n :=
  if contracted then .fmaSquare i acc else .add acc (.square i)

def accumulate (contracted : Bool) (columns : List (Fin n)) (acc : Expr n) : Expr n :=
  columns.foldl (step contracted) acc

theorem step_indices (contracted : Bool) (acc : Expr n) (i : Fin n) :
    (indices (step contracted acc i)).Perm (indices acc ++ [i]) := by
  cases contracted
  · exact List.Perm.refl _
  · change ([i] ++ indices acc).Perm (indices acc ++ [i])
    exact List.perm_append_comm

theorem accumulate_indices (contracted : Bool) (columns : List (Fin n)) (acc : Expr n) :
    (indices (accumulate contracted columns acc)).Perm (indices acc ++ columns) := by
  induction columns generalizing acc with
  | nil => simp [accumulate]
  | cons i rest ih =>
    have h := (ih (step contracted acc i)).trans ((step_indices contracted acc i).append_right rest)
    simpa only [accumulate, List.foldl_cons, List.append_assoc, List.singleton_append] using h

def reduceTree (input : Fin m → Expr n) : Reduction.Tree m → Expr n
  | .leaf i => input i
  | .add a b => .add (reduceTree input a) (reduceTree input b)

theorem reduceTree_indices (input : Fin m → Expr n) (tree : Reduction.Tree m) :
    indices (reduceTree input tree) = (Reduction.leaves tree).flatMap (fun i => indices (input i)) := by
  induction tree with
  | leaf i => simp [reduceTree, Reduction.leaves]
  | add a b ia ib => simp only [reduceTree, Reduction.leaves, indices, List.flatMap_append, ia, ib]

def evaluate (input : Fin n → Float32) : Expr n → Float32
  | .zero => 0
  | .square i => FlushToZero.mul (input i) (input i)
  | .fmaSquare i a => FlushToZero.fma (input i) (input i) (evaluate input a)
  | .add a b => FlushToZero.add (evaluate input a) (evaluate input b)

def arithmeticStep (contracted : Bool) (input : Fin n → Float32) (acc : Float32) (i : Fin n) : Float32 :=
  if contracted then FlushToZero.fma (input i) (input i) acc
  else FlushToZero.add acc (FlushToZero.mul (input i) (input i))

theorem evaluate_step (contracted : Bool) (input : Fin n → Float32) (acc : Expr n) (i : Fin n) :
    evaluate input (step contracted acc i) = arithmeticStep contracted input (evaluate input acc) i := by
  cases contracted <;> rfl

theorem evaluate_accumulate (contracted : Bool) (input : Fin n → Float32)
    (columns : List (Fin n)) (acc : Expr n) :
    evaluate input (accumulate contracted columns acc) =
      columns.foldl (arithmeticStep contracted input) (evaluate input acc) := by
  induction columns generalizing acc with
  | nil => rfl
  | cons i rest ih =>
    change evaluate input (accumulate contracted rest (step contracted acc i)) = _
    rw [ih, evaluate_step]
    rfl

noncomputable def ideal (input : Fin n → ℝ) : Expr n → ℝ
  | .zero => 0
  | .square i => input i ^ 2
  | .fmaSquare i a => input i ^ 2 + ideal input a
  | .add a b => ideal input a + ideal input b

def Finite (input : Fin n → Float32) : Expr n → Prop
  | .zero => True
  | .square i => (FlushToZero.flush (input i)*FlushToZero.flush (input i)).isFinite=true
  | .fmaSquare i a => Finite input a ∧ (input i).isFinite=true ∧
      (Float32.fma (FlushToZero.flush (input i)) (FlushToZero.flush (input i))
        (FlushToZero.flush (evaluate input a))).isFinite=true
  | .add a b => Finite input a ∧ Finite input b ∧
      (FlushToZero.flush (evaluate input a)+FlushToZero.flush (evaluate input b)).isFinite=true

noncomputable def budget (input : Fin n → Float32) : Expr n → ℝ
  | .zero => 0
  | .square i => FlushToZero.mulBudget (input i) (input i)
  | .fmaSquare i a => budget input a + FlushToZero.fmaBudget (input i) (input i) (evaluate input a)
  | .add a b => budget input a + budget input b + FlushToZero.addBudget (evaluate input a) (evaluate input b)

theorem finite_evaluate (input : Fin n → Float32) (expr : Expr n) (hf : Finite input expr) :
    (evaluate input expr).isFinite=true := by
  cases expr with
  | zero => change (0 : Float32).isFinite=true; decide
  | square => exact FlushToZero.finite_flush _ hf
  | fmaSquare => exact FlushToZero.finite_flush _ hf.2.2
  | add => exact FlushToZero.finite_flush _ hf.2.2

theorem nonnegative (input : Fin n → Float32) (expr : Expr n) (hf : Finite input expr) :
    0 ≤ real (evaluate input expr) := by
  induction expr with
  | zero =>
    change 0 ≤ real (0 : Float32)
    rw [real_unpack]
    exact le_of_eq (FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive).symm
  | square i => exact FlushToZero.mul_nonnegative _ _ (mul_self_nonneg _) hf
  | fmaSquare i a ia =>
    exact FlushToZero.fma_square_nonnegative _ _ hf.2.1 (finite_evaluate input a hf.1) (ia hf.1) hf.2.2
  | add a b ia ib =>
    exact FlushToZero.add_nonnegative _ _ (finite_evaluate input a hf.1) (finite_evaluate input b hf.2.1)
      (ia hf.1) (ib hf.2.1) hf.2.2

theorem error (input : Fin n → Float32) (expr : Expr n) (hf : Finite input expr) :
    |real (evaluate input expr)-ideal (fun i => real (input i)) expr| ≤ budget input expr := by
  induction expr with
  | zero =>
    have hz : real (0 : Float32)=0 := by
      rw [real_unpack]
      exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    simp only [evaluate, ideal, budget, hz, sub_zero, abs_zero, le_refl]
  | square i =>
    simpa only [evaluate, ideal, budget, pow_two, FlushToZero.mulBudget] using FlushToZero.mul_error (input i) (input i) hf
  | fmaSquare i a ia =>
    obtain ⟨ha, hi, ho⟩ := hf
    have ea := ia ha
    have en := FlushToZero.fma_error (input i) (input i) (evaluate input a) hi hi (finite_evaluate input a ha) ho
    change |real (FlushToZero.fma (input i) (input i) (evaluate input a))-
      (real (input i)*real (input i)+real (evaluate input a))| ≤ FlushToZero.fmaBudget (input i) (input i) (evaluate input a) at en
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (FlushToZero.fma (input i) (input i) (evaluate input a))-
          (real (input i)*real (input i)+real (evaluate input a))) +
          (real (evaluate input a)-ideal (fun j => real (input j)) a)| := by congr 1; ring
      _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add en ea); linarith
  | add a b ia ib =>
    obtain ⟨ha, hb, ho⟩ := hf
    have ea := ia ha
    have eb := ib hb
    have en := FlushToZero.add_error (evaluate input a) (evaluate input b)
      (finite_evaluate input a ha) (finite_evaluate input b hb) ho
    change |real (FlushToZero.add (evaluate input a) (evaluate input b))-
      (real (evaluate input a)+real (evaluate input b))| ≤ FlushToZero.addBudget (evaluate input a) (evaluate input b) at en
    simp only [evaluate, ideal, budget]
    calc
      _ = |(real (FlushToZero.add (evaluate input a) (evaluate input b))-
          (real (evaluate input a)+real (evaluate input b))) +
          ((real (evaluate input a)-ideal (fun j => real (input j)) a)+
          (real (evaluate input b)-ideal (fun j => real (input j)) b))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add en ((abs_add_le _ _).trans (add_le_add ea eb)))
        linarith

theorem ideal_indices (input : Fin n → ℝ) (expr : Expr n) :
    ideal input expr = ((indices expr).map (fun i => input i ^ 2)).sum := by
  induction expr with
  | zero => rfl
  | square i => simp [ideal, indices]
  | fmaSquare i a ia => simp [ideal, indices, ia]
  | add a b ia ib => simp [ideal, indices, ia, ib, List.map_append, List.sum_append]

theorem sum_error (input : Fin n → Float32) (expr : Expr n)
    (coverage : (indices expr).Perm (List.finRange n)) (hf : Finite input expr) :
    |real (evaluate input expr)-((List.finRange n).map (fun i => real (input i)^2)).sum| ≤ budget input expr := by
  have h := error input expr hf
  rw [ideal_indices, (coverage.map (fun i => real (input i)^2)).sum_eq] at h
  exact h

end Inference.Contracts.Mlx.SquaredSum
