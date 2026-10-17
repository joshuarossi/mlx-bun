import contracts.mlx.ArithmeticFold

namespace Inference.Contracts.Mlx.ArithmeticDependencies
open Arithmetic ArithmeticFold

-- Range obligations for an executed expression already establish the ranges
-- of every operand it evaluates. Composition can reuse these proofs instead
-- of asking callers for duplicate assumptions about intermediate results.
theorem madd_finite (input : Nat → Float32) (contracted : Bool) (a b acc : Expr)
    (hf : Finite input (madd contracted a b acc)) : Finite input a ∧ Finite input b ∧ Finite input acc := by
  cases contracted with
  | false => exact ⟨hf.2.1.1, hf.2.1.2.1, hf.1⟩
  | true => exact ⟨hf.1, hf.2.1, hf.2.2.1⟩

theorem fold_finite (input : Nat → Float32) (contracted : Bool) (a b : α → Expr) (indices : List α) (acc : Expr)
    (hf : Finite input (indices.foldl (fun acc i => madd contracted (a i) (b i) acc) acc)) :
    Finite input acc ∧ ∀ i ∈ indices, Finite input (a i) ∧ Finite input (b i) := by
  induction indices generalizing acc with
  | nil => exact ⟨hf, by simp⟩
  | cons i rest ih =>
    have hr := ih (madd contracted (a i) (b i) acc) hf
    have hi := madd_finite input contracted (a i) (b i) acc hr.1
    refine ⟨hi.2.2, ?_⟩
    intro j hj
    rcases List.mem_cons.mp hj with rfl | hj
    · exact ⟨hi.1, hi.2.1⟩
    · exact hr.2 j hj

theorem reduce_finite (input : Nat → Float32) (lanes : Fin n → Expr) (tree : Reduction.Tree n)
    (hf : Finite input (reduceExpr lanes tree)) (i : Fin n) (hi : i ∈ Reduction.leaves tree) : Finite input (lanes i) := by
  induction tree with
  | leaf j =>
    have he : i = j := by simpa only [Reduction.leaves, List.mem_singleton] using hi
    subst i
    exact hf
  | add a b ha hb =>
    rcases List.mem_append.mp hi with hi | hi
    · exact ha hf.1 hi
    · exact hb hf.2.1 hi

end Inference.Contracts.Mlx.ArithmeticDependencies
