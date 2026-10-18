import host.load.RuntimeVectorReadyBatch
import host.load.RuntimeInitialConcatGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

noncomputable def concatReceiver : Nat := match ConcatInventoryCases.Source336.sourceThis with
  | .obj a => a
  | _ => 0

theorem source_concat_receiver : ConcatInventoryCases.Source336.sourceThis = .obj concatReceiver := by host_kernel_rfl

theorem ready_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (readyNotes notes caller).runtime.control = callNote (.obj ConcatInventoryCases.Source336.address) (.obj concatReceiver)
      ((ConcatFamilyHost.arguments ConcatInventoryCases.Source336.out ConcatInventoryCases.Source336.vec
        ConcatInventoryCases.Source336.stream ConcatInventoryCases.Source336.axisValue).map FixedArgument.role) := by
  host_kernel_rfl

theorem ready_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (readyNotes notes caller).buffers.owners ConcatInventoryCases.Source336.out = some (handleSlotNotes 0) := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
