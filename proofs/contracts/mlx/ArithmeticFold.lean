import contracts.mlx.Arithmetic
import contracts.mlx.FlushedReduction

namespace Inference.Contracts.Mlx.ArithmeticFold
open Numerics Arithmetic
open scoped BigOperators

-- A compile-time contraction choice; never a runtime dispatch condition.
def madd (contracted : Bool) (a b acc : Expr) : Expr :=
  if contracted then .fma a b acc else .add acc (.mul a b)
def maddFloat (contracted : Bool) (a b acc : Float32) : Float32 :=
  if contracted then FlushToZero.fma a b acc else FlushToZero.add acc (FlushToZero.mul a b)

theorem evaluate_madd (input : Nat → Float32) (contracted : Bool) (a b acc : Expr) :
    evaluate input (madd contracted a b acc) = maddFloat contracted (evaluate input a) (evaluate input b) (evaluate input acc) := by
  cases contracted <;> rfl

theorem ideal_madd (input : Nat → ℝ) (contracted : Bool) (a b acc : Expr) :
    ideal input (madd contracted a b acc) = ideal input acc + ideal input a * ideal input b := by
  cases contracted <;> simp [madd, ideal, add_comm]

-- `a * b + acc` with the product on the left: contracted, the left product is
-- fused (the compiler contracts `x * y + z` before `z + x * y`).
def maddLeft (contracted : Bool) (a b acc : Expr) : Expr :=
  if contracted then .fma a b acc else .add (.mul a b) acc
def maddLeftFloat (contracted : Bool) (a b acc : Float32) : Float32 :=
  if contracted then FlushToZero.fma a b acc else FlushToZero.add (FlushToZero.mul a b) acc

theorem evaluate_maddLeft (input : Nat → Float32) (contracted : Bool) (a b acc : Expr) :
    evaluate input (maddLeft contracted a b acc) =
      maddLeftFloat contracted (evaluate input a) (evaluate input b) (evaluate input acc) := by
  cases contracted <;> rfl

theorem ideal_maddLeft (input : Nat → ℝ) (contracted : Bool) (a b acc : Expr) :
    ideal input (maddLeft contracted a b acc) = ideal input acc + ideal input a * ideal input b := by
  cases contracted <;> simp [maddLeft, ideal, add_comm]

-- Contracted, `maddLeft` is `madd`; uncontracted, `a * b + c * d` is `madd` on the right product.
theorem maddLeft_true (a b acc : Expr) : maddLeft true a b acc = madd true a b acc := rfl
theorem maddLeft_false (a b c d : Expr) : maddLeft false a b (.mul c d) = madd false c d (.mul a b) := rfl

-- A fold whose sites each have their own contraction choice.
theorem evaluate_sites (input : Nat → Float32) (contracted : α → Bool) (a b : α → Expr) (indices : List α) (acc : Expr) :
    evaluate input (indices.foldl (fun acc i => madd (contracted i) (a i) (b i) acc) acc) =
      indices.foldl (fun acc i => maddFloat (contracted i) (evaluate input (a i)) (evaluate input (b i)) acc)
        (evaluate input acc) := by
  induction indices generalizing acc with
  | nil => rfl
  | cons i rest ih => simp only [List.foldl_cons, ih, evaluate_madd]

theorem ideal_sites (input : Nat → ℝ) (contracted : α → Bool) (a b : α → Expr) (indices : List α) (acc : Expr) :
    ideal input (indices.foldl (fun acc i => madd (contracted i) (a i) (b i) acc) acc) =
      ideal input acc + (indices.map (fun i => ideal input (a i) * ideal input (b i))).sum := by
  induction indices generalizing acc with
  | nil => simp
  | cons i rest ih => simp only [List.foldl_cons, ih, ideal_madd, List.map_cons, List.sum_cons]; ring

theorem evaluate_fold (input : Nat → Float32) (contracted : Bool) (a b : α → Expr) (indices : List α) (acc : Expr) :
    evaluate input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc) =
      indices.foldl (fun acc i => maddFloat contracted (evaluate input (a i)) (evaluate input (b i)) acc) (evaluate input acc) :=
  evaluate_sites input (fun _ => contracted) a b indices acc

theorem ideal_fold (input : Nat → ℝ) (contracted : Bool) (a b : α → Expr) (indices : List α) (acc : Expr) :
    ideal input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc) =
      ideal input acc + (indices.map (fun i => ideal input (a i) * ideal input (b i))).sum :=
  ideal_sites input (fun _ => contracted) a b indices acc

def reduceExpr (lanes : Fin n → Expr) : Reduction.Tree n → Expr
  | .leaf i => lanes i
  | .add a b => .add (reduceExpr lanes a) (reduceExpr lanes b)

theorem evaluate_reduce (input : Nat → Float32) (lanes : Fin n → Expr) (tree : Reduction.Tree n) :
    evaluate input (reduceExpr lanes tree) = FlushedReduction.evaluate (fun i => evaluate input (lanes i)) tree := by
  induction tree with
  | leaf i => rfl
  | add a b ia ib => simp only [reduceExpr, evaluate, FlushedReduction.evaluate, ia, ib]

theorem ideal_reduce (input : Nat → ℝ) (lanes : Fin n → Expr) (tree : Reduction.Tree n) :
    ideal input (reduceExpr lanes tree) = Reduction.ideal (fun i => ideal input (lanes i)) tree := by
  induction tree with
  | leaf i => rfl
  | add a b ia ib => simp only [reduceExpr, ideal, Reduction.ideal, ia, ib]

-- Loop composition records only range obligations on states actually visited.
-- The step theorem is supplied by a checked kernel proof, not a platform axiom.
def FoldFinite (step : α → Float32 → Float32) (valid : α → Float32 → Prop) : List α → Float32 → Prop
  | [], _ => True
  | i :: rest, acc => valid i acc ∧ FoldFinite step valid rest (step i acc)

noncomputable def errorFold (step : α → Float32 → Float32) (contribution : α → ℝ)
    (cost : α → Float32 → ℝ → ℝ → ℝ) : List α → Float32 → ℝ → ℝ → ℝ
  | [], _, _, error => error
  | i :: rest, acc, target, error =>
    errorFold step contribution cost rest (step i acc) (target + contribution i) (cost i acc target error)

theorem fold_error (step : α → Float32 → Float32) (contribution : α → ℝ)
    (cost : α → Float32 → ℝ → ℝ → ℝ) (valid : α → Float32 → Prop)
    (hstep : ∀ i acc target error, valid i acc → |real acc - target| ≤ error →
      |real (step i acc) - (target + contribution i)| ≤ cost i acc target error)
    (indices : List α) (acc : Float32) (target error : ℝ)
    (hf : FoldFinite step valid indices acc) (hi : |real acc - target| ≤ error) :
    |real (indices.foldl (fun a i => step i a) acc) - (target + (indices.map contribution).sum)| ≤
      errorFold step contribution cost indices acc target error := by
  induction indices generalizing acc target error with
  | nil => simpa [errorFold] using hi
  | cons i rest ih =>
    have h := ih (step i acc) (target + contribution i) (cost i acc target error) hf.2 (hstep i acc target error hf.1 hi)
    simpa only [List.foldl_cons, List.map_cons, List.sum_cons, errorFold, add_assoc] using h

end Inference.Contracts.Mlx.ArithmeticFold
