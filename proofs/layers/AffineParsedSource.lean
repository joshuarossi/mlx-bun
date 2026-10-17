import layers.AffineParsedSource3
import layers.AffineParsedSource4

namespace Inference.Layers.AffineParsedSource
open Contracts.Mlx AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps blocks : Nat} {p : Projection steps (4*(blocks*16))}
  {input : Fin (steps*512) → ArrayStorage.BF}

-- The written custom row-wrapper route supports both checkpoint bit widths.
-- Installing that route in a native descriptor remains a separate contract.
def Certificate (execution : AffineMemory.Execution p input) (before : Nat → Float32) : Prop :=
  match p with
  | .bits3 _ => AffineParsedSource3.Certificate execution before
  | .bits4 _ => AffineParsedSource4.Certificate execution before

def value (execution : AffineMemory.Execution p input) (row : Fin (4*(blocks*16))) : ArrayStorage.BF :=
  match p with
  | .bits3 _ => AffineParsedSource3.value execution row
  | .bits4 _ => AffineParsedSource4.value execution row

theorem checked (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (hsteps : steps≤15) (limit : blocks≤3880) (finite : p.Finite input) : Certificate execution before := by
  cases p with
  | bits3 p => exact AffineParsedSource3.checked execution before hsteps limit finite
  | bits4 p => exact AffineParsedSource4.checked execution before hsteps limit finite

theorem readback (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate execution before) (row : Fin (4*(blocks*16))) :
    value execution row=p.forward input row := by
  cases p with
  | bits3 p => exact source.readback row
  | bits4 p => exact source.readback row

theorem same_buffer (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate execution before) (row : Fin (4*(blocks*16))) :
    value execution row=execution.outputBuffer.read row := by
  rw [ArrayStorage.BFBuffer.read_correct,execution.output_eq]
  exact readback execution before source row

theorem readback_error (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate execution before) (target error : Fin (steps*512) → ℝ)
    (inputBound : ∀ i, |Model.toReal (input i)-target i|≤error i)
    (finite : p.Finite input) (row : Fin (4*(blocks*16))) :
    |Model.toReal (value execution row)-p.target target row|≤p.budget input target error row := by
  rw [readback execution before source row]
  exact p.forward_error input target error inputBound finite row

end Inference.Layers.AffineParsedSource
