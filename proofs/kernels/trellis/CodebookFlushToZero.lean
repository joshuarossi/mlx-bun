import contracts.mlx.FlushToZero
import kernels.trellis.CodebookLoad

namespace Inference.Kernels.Trellis.CodebookFlushToZero
open Codebook Codebook.FloatingPoint
open Contracts.Mlx

set_option maxHeartbeats 0

-- The initializer's subtraction and multiplication, with flushing applied at
-- arithmetic inputs and outputs. No flushing is applied to bitcasts or loads.
def liftedFtz (y : Int) : Float32 :=
  FlushToZero.add (Float32.ofBits (0x4b000000 ||| UInt32.ofInt (y+510))) (-8389118)

def value (y : Int) : Float32 := FlushToZero.mul (liftedFtz y) reciprocal

theorem initialization_bits : ∀ i : Fin 1021,
    (value (i.val-510)).toBits = (lifted (i.val-510) * reciprocal).toBits := by decide +kernel

-- Thus the existing initialization and decoder accuracy theorems also apply
-- to this flushing initializer. This does not transfer projection arithmetic.
theorem initialization_correct (s : BitVec 32) :
    value (implementation s) = CodebookLoad.codeValue s := by
  have h := initialization_bits (stateIndex s)
  rw [stateIndex_value] at h
  exact Contracts.Mlx.M1Max.float_eq_of_bits_eq _ _ h

theorem decoder_correct (s : BitVec 32) :
    value (implementation s) = CodebookLoad.mathematicalCode s :=
  (initialization_correct s).trans (CodebookLoad.codeValue_correct s)

end Inference.Kernels.Trellis.CodebookFlushToZero
