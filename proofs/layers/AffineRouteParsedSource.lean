import layers.AffineParsedSource3
import layers.AffineNativeParsedSource4

namespace Inference.Layers.AffineRouteParsedSource
open Contracts.Mlx AffineVerifyLinear
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {steps groups : Nat} {p : Projection steps (4*groups)}
  {input : Fin (steps*512) → ArrayStorage.BF}

-- One-row decode projections take their route from the stored bit width:
-- three-bit tensors run the custom complete-row wrapper, four-bit tensors run
-- MLX quantized_matmul's qmv_fast. Its host selection holds on every
-- architecture, so the four-bit branch is stated for all of them. The custom
-- route counts 64-row blocks; the native route counts 8-row blocks.
def Certificate (custom native : Nat) (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (hcustom : groups=custom*16) (hnative : groups=native*2) : Prop := by
  cases p with
  | bits3 q => subst hcustom; exact AffineParsedSource3.Certificate (blocks:=custom) execution before
  | bits4 q =>
    subst hnative
    exact ∀ generation size,AffineNativeParsedSource4.Certificate (blocks:=native) execution generation size before

def value (execution : AffineMemory.Execution p input) (row : Fin (4*groups)) : ArrayStorage.BF :=
  match p with
  | .bits3 _ => Model.ofBits (HalfMemory.load execution.kernel.stores.memory (execution.kernel.base+2*row.val))
  | .bits4 _ => Model.ofBits (HalfMemory.load execution.kernel.stores.memory (execution.kernel.base+2*row.val))

theorem checked {custom native : Nat} (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (hsteps : steps≤15) (customLimit : custom≤3880) (nativeLimit : native≤31040) (finite : p.Finite input)
    (hcustom : groups=custom*16) (hnative : groups=native*2) :
    Certificate custom native execution before hcustom hnative := by
  cases p with
  | bits3 q =>
    subst hcustom
    exact AffineParsedSource3.checked execution before hsteps customLimit finite
  | bits4 q =>
    subst hnative
    exact fun generation size =>
      AffineNativeParsedSource4.checked execution generation size before hsteps nativeLimit finite

theorem readback {custom native : Nat} {hcustom : groups=custom*16} {hnative : groups=native*2}
    (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate custom native execution before hcustom hnative) (row : Fin (4*groups)) :
    value execution row=p.forward input row := by
  cases p with
  | bits3 q =>
    subst hcustom
    exact AffineParsedSource3.Certificate.readback source row
  | bits4 q =>
    subst hnative
    exact AffineNativeParsedSource4.Certificate.readback (source 0 'd') row

theorem same_buffer {custom native : Nat} {hcustom : groups=custom*16} {hnative : groups=native*2}
    (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate custom native execution before hcustom hnative) (row : Fin (4*groups)) :
    value execution row=execution.outputBuffer.read row := by
  rw [ArrayStorage.BFBuffer.read_correct,execution.output_eq]
  exact readback execution before source row

theorem readback_error {custom native : Nat} {hcustom : groups=custom*16} {hnative : groups=native*2}
    (execution : AffineMemory.Execution p input) (before : Nat → Float32)
    (source : Certificate custom native execution before hcustom hnative) (target error : Fin (steps*512) → ℝ)
    (inputBound : ∀ i, |Model.toReal (input i)-target i|≤error i)
    (finite : p.Finite input) (row : Fin (4*groups)) :
    |Model.toReal (value execution row)-p.target target row|≤p.budget input target error row := by
  rw [readback execution before source row]
  exact p.forward_error input target error inputBound finite row

end Inference.Layers.AffineRouteParsedSource
