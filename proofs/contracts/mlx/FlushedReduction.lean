import contracts.mlx.Reduction
import contracts.mlx.FlushToZero

namespace Inference.Contracts.Mlx.FlushedReduction

-- One SIMD primitive contract shared by normalization, projections, and
-- recurrent updates. The binary tree records rounding order and coverage.
def evaluate (input : Fin n → Float32) : Reduction.Tree n → Float32
  | .leaf i => input i
  | .add a b => FlushToZero.add (evaluate input a) (evaluate input b)

structure SimdContract (reduce : (Fin 32 → Float32) → Float32) where
  tree : Reduction.Tree 32
  coverage : (Reduction.leaves tree).Perm (List.finRange 32)
  execution : ∀ input, reduce input = evaluate input tree

-- A mathematical witness that the primitive contract is satisfiable. It
-- does not identify the physical chip's reduction tree.
def orderedContract : SimdContract (fun input => evaluate input Reduction.orderedTree) :=
  ⟨Reduction.orderedTree, Reduction.ordered_coverage, fun _ => rfl⟩

theorem contract_satisfiable : Nonempty (SimdContract (fun input => evaluate input Reduction.orderedTree)) :=
  ⟨orderedContract⟩

end Inference.Contracts.Mlx.FlushedReduction
