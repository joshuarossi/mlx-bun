import kernels.copy.KvRowDispatchGeometry
import kernels.attention.MlxAttentionGateCopyMemory

namespace Inference.Kernels.Attention.MlxAttentionGateReshapeHost
open Copy.KvRowDispatchGeometry
set_option maxRecDepth 10000

-- Reviewed metadata translation of prepare_reshape after its nonempty,
-- non-row-contiguous, nonscalar branches. Native descriptors remain explicit.
structure Prepared where
  copyNecessary : Bool
  outputStrides : List Nat
  deriving DecidableEq, Repr

def prepareLoop : List Nat → List Nat → List Nat → Nat → List Nat → Prepared
  | [],_,_,_,output => ⟨false,output⟩
  | extent::rest,shape,strides,j,output =>
    if j<shape.length ∧ (shape[j]?.getD 0)%extent=0 then
      let next := (shape[j]?.getD 0)/extent
      let updated := shape.modify j (fun _ => next)
      prepareLoop rest updated strides (j+if next=1 then 1 else 0)
        (output++[next*(strides[j]?.getD 0)])
    else if extent=1 then
      prepareLoop rest shape strides j (output++[output.getLast?.getD 0])
    else ⟨true,output⟩

def prepare (size ndim : Nat) (rowContiguous : Bool) (shape strides outputShape outputStrides : List Nat) : Prepared :=
  if size=0 ∨ rowContiguous then ⟨false,outputStrides⟩
  else if ndim=0 then ⟨false,List.replicate outputShape.length 0⟩
  else prepareLoop outputShape shape strides 0 []

-- The singleton axes vanish, but the 256-wide gate halves cannot merge
-- through the 512-element interleaved projection head stride.
def gateAxes : List Axis := [⟨1,12288,6144⟩,⟨1,12288,6144⟩,⟨24,512,256⟩,⟨256,1,1⟩]

theorem collapsed : collapse gateAxes (2^31-1)=[⟨24,512,256⟩,⟨256,1,1⟩] := by decide +kernel

theorem copy_necessary : prepare 6144 4 false [24,256] [512,1] [1,1,6144] [6144,6144,1]=
    ⟨true,[12288,12288]⟩ := by decide +kernel

theorem selected_grid : grid [⟨24,512,256⟩,⟨256,1,1⟩]=⟨256,24,1⟩ := by decide +kernel

theorem no_contiguous_flatten : ¬(1*256=512) := by decide

end Inference.Kernels.Attention.MlxAttentionGateReshapeHost
