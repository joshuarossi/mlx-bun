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

-- A NaN lane, quiet or signaling, makes the sum the default NaN 0x7fc00000,
-- as the M1 Max probe observes; NaN inputs need no separate clause.
theorem nan_witness :
    (evaluate (fun i : Fin 32 => if i.val=7 then Float32.ofBits 0xffc00001 else Float32.ofBits 0x3f800000)
      Reduction.orderedTree).toBits = 0x7fc00000 ∧
    (evaluate (fun i : Fin 32 => if i.val=31 then Float32.ofBits 0x7fa00001 else Float32.ofBits 0xff7fffff)
      Reduction.orderedTree).toBits = 0x7fc00000 := by decide +kernel

end Inference.Contracts.Mlx.FlushedReduction
