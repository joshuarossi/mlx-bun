import state.ConvolutionStorage
import contracts.mlx.CopyShape

namespace Inference.State.ConvolutionLayout
open Contracts.Mlx

-- B=S=1, K=4, D=10240. The two concat views and the materialized
-- three-row tail collapse to one dimension, selecting gg1 / gg1_dynamic.
theorem history_copy_shape : CopyShape.collapse (2^31-1)
    [⟨1, 30720, 40960⟩, ⟨3, 10240, 10240⟩, ⟨10240, 1, 1⟩]=[⟨30720, 1, 1⟩] := by decide +kernel

theorem input_copy_shape : CopyShape.collapse (2^31-1)
    [⟨1, 10240, 40960⟩, ⟨1, 10240, 10240⟩, ⟨10240, 1, 1⟩]=[⟨10240, 1, 1⟩] := by decide +kernel

theorem tail_copy_shape : CopyShape.collapse (2^31-1)
    [⟨1, 40960, 30720⟩, ⟨3, 10240, 10240⟩, ⟨10240, 1, 1⟩]=[⟨30720, 1, 1⟩] := by decide +kernel

-- materializeCopy supplies the int32 start 0 on axis 0 of the existing
-- slice view. Its dynamic-offset kernel accumulates one signed-64 product.
def dynamicOffset : BitVec 64 := (0 : BitVec 64)+(0 : BitVec 32).signExtend 64*(40960 : BitVec 64)

theorem dynamic_offset_zero : dynamicOffset=0 := by decide +kernel
theorem dynamic_offset_signed : dynamicOffset.toInt=0 := by decide +kernel

theorem tail_view (row : Fin 3) (channel : Fin 10240) :
    2*10240+2*(ConvolutionStorage.index row channel).val=
      2*(ConvolutionStorage.index (rows := 4) ⟨row.val+1, by have := row.isLt; omega⟩ channel).val := by
  dsimp [ConvolutionStorage.index]
  omega

theorem tail_bounds (i : Fin 30720) : 20480+2*i.val+2 ≤ 81920 ∧
    (CopyIndices.elem2 i.val 0 1 0).toInt=Int.ofNat i.val := by
  have hi := i.isLt
  constructor
  · omega
  · simpa only [Nat.mul_one] using Copy1D.signed_index i.val 1 (by omega) (by decide) (by omega)

theorem concat_bounds (i : Fin 30720) (j : Fin 10240) :
    2*i.val+2 ≤ 61440 ∧ 61440+2*j.val+2 ≤ 81920 ∧ i.val ≠ 30720+j.val := by
  have := i.isLt; have := j.isLt
  omega

end Inference.State.ConvolutionLayout
