import host.load.RuntimeNamespacedDecodeConvolutionNative
import host.ts.renameOrdinary.RankOriginInitializedCacheConvolutionCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.ConvolutionCallFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def inputNotes := RankOrigin.InitializedCacheConvolutionCall.resultNotes
private def sampleNotes : RetainedNotes :=
  ⟨⟨.atom Nat 0,[],Notes.empty⟩,PrivateNotes.empty,NativeCaptureNotes.empty,
    ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let emptyStack ← mkAppOptM ``List.nil #[some (mkConst ``Annotated.Tree)]
  let ready ← mkAppM ``inputNotes #[mkConst ``sampleNotes,emptyStack]
  let control ← mkAppM ``RuntimeNotes.control #[← mkAppM ``RetainedNotes.runtime #[ready]]
  let fields ← Parametric.Driver.field control ``Annotated.Tree.node 2 1
  let rec noteAt (values : Lean.Expr) (index : Nat) : TermElabM Lean.Expr := do
    match index with
    | 0 => Parametric.Driver.field values ``List.cons 3 1
    | n+1 => noteAt (← Parametric.Driver.field values ``List.cons 3 2) n
  let third ← noteAt fields 2
  let arguments ← Parametric.Driver.field third ``Annotated.Tree.node 2 1
  for (name,index) in [(`strideRole,3),(`paddingRole,4),(`dilationRole,5),(`groupsRole,6)] do
    let note ← noteAt arguments index
    let role ← Parametric.Driver.field note ``Annotated.Tree.value 1 0
    Parametric.Driver.addData ((← getCurrNamespace)++name) role

theorem stride_schema : ClosedLiteralNote strideRole := by rfl
theorem padding_schema : ClosedLiteralNote paddingRole := by rfl
theorem dilation_schema : ClosedLiteralNote dilationRole := by rfl
theorem groups_schema : ClosedLiteralNote groupsRole := by rfl

theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = callNote (.obj Conv1856.address) (.obj 4817)
      (ConvFamilyHost.convArgumentNotes Conv1856.out Conv1856.hx Conv1856.hy Conv1856.stream
        strideRole paddingRole dilationRole groupsRole) := by host_kernel_rfl

theorem output_selected (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).buffers.owners Conv1856.out = some (handleSlotNotes 0) := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NamespacedDecode.ConvolutionCallFacts
