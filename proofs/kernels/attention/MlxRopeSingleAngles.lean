import kernels.attention.MlxRopeSingleSyntax
import kernels.attention.RopeAngles

namespace Inference.Kernels.Attention.MlxRopeSingleAngles
open Contracts.Mlx MlxRopeSingleSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Host log2(base), int offset→float and scale binding remain explicit input
-- contracts. Division/exp2 and both fast trigonometric functions retain their
-- existing platform contracts. This evaluates exactly the parsed operation order.
def theta (_ : Angle) (p : RopeAngles.Platform) (x : RopeAngles.Inputs) (lane : Fin 32) : Float32 :=
  let d := p.divide (Float32.ofInt lane.val) (Float32.ofInt 32)
  let inv_freq := p.exp2 (FlushToZero.mul (-d) x.base)
  let L := FlushToZero.mul x.scale x.position
  FlushToZero.mul L inv_freq

def source (p : RopeAngles.Platform) (x : RopeAngles.Inputs) (lane : Fin 32) : Option Float32 := do
  let ast ←parseAngle sourceAngle
  pure (theta ast p x lane)

theorem selected_theta (p : RopeAngles.Platform) (x : RopeAngles.Inputs) (lane : Fin 32) :
    source p x lane=some (RopeAngles.value p x lane) := by
  unfold source
  rw [parsed_angle]
  rfl

end Inference.Kernels.Attention.MlxRopeSingleAngles
