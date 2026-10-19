import host.ts.renameOrdinary.RankOriginInitializedConvolutionCleanup

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.RankOrigin.ConvolutionDisposalFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def inputNotes := InitializedConvolutionCleanup.resultNotes
noncomputable def headNote (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputNotes notes caller).runtime.stack.headD (.atom Nat 0)
noncomputable def tailNotes (notes : RetainedNotes) (caller : List Annotated.Tree) :=
  (inputNotes notes caller).runtime.stack.tail

/-- These are the annotations reached by initialization and the 99-step
convolution cleanup, before storing the disposed flag. -/
theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = returnNote (.bool true) := by
  host_kernel_rfl

theorem current_stack (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.stack = headNote notes caller :: tailNotes notes caller := by
  host_kernel_rfl

theorem current_handle (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).privates.owners PostConvCleanup.DisposedStore.sourceAddress =
      some ⟨4852,chars!"handle",.handle 29372⟩ := by
  host_kernel_rfl

theorem current_receiver (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.cells.cells 3126879 = some (.obj 3126703) := by
  host_kernel_rfl

theorem different_name : nameEq chars!"handle" PostConvCleanup.DisposedStore.sourceName = false := by
  host_kernel_rfl

theorem source_server : PostConvCleanup.DisposedStore.initialServer =
    numberServer (PostConvCleanup.Region.S99.substitute LoopVariables.oracleVariables) := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.ConvolutionDisposalFacts
