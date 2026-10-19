import host.load.RuntimePostConvCleanupFrames
import host.ts.renameOrdinary.RankOriginInitializedCacheConvolution

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.ConvolutionCleanupFacts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open NamespacedDecode

noncomputable def inputNotes := InitializedCacheConvolution.resultNotes
def remainingCaller (caller : List Annotated.Tree) : List Annotated.Tree :=
  caller.tail.tail.tail.tail.tail.tail
private def sampleNotes : RetainedNotes :=
  ⟨⟨.atom Nat 0,[],Notes.empty⟩,PrivateNotes.empty,NativeCaptureNotes.empty,
    ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let empty ← mkAppOptM ``List.nil #[some (mkConst ``Annotated.Tree)]
  let ready ← mkAppM ``inputNotes #[mkConst ``sampleNotes,empty]
  let stack ← mkAppM ``RuntimeNotes.stack #[← mkAppM ``RetainedNotes.runtime #[ready]]
  let rec noteAt (xs : Lean.Expr) (i : Nat) : TermElabM Lean.Expr := do
    match i with
    | 0 => Parametric.Driver.field xs ``List.cons 3 1
    | n+1 => noteAt (← Parametric.Driver.field xs ``List.cons 3 2) n
  let frame ← noteAt stack 6
  let fields ← Parametric.Driver.field frame ``Annotated.Tree.node 2 1
  let argument ← noteAt fields 0
  let roles ← Parametric.Driver.field argument ``Annotated.Tree.node 2 1
  for (name,index) in [(`constructorRole,1),(`constructorThis,2)] do
    let role ← Parametric.Driver.field (← noteAt roles index) ``Annotated.Tree.value 1 0
    Parametric.Driver.addData ((← getCurrNamespace) ++ name) role

theorem source_entry : PostConvCleanup.Region.s0 = Conv1856.output := by host_kernel_rfl
theorem source_server : PostConvCleanup.Plan.Block0.initialServer = Conv1856.nextServer := by host_kernel_rfl
theorem current_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.control = returnNote nativeStatusRole := by host_kernel_rfl
theorem current_stack (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.stack =
      PostConvCleanup.resultFrames constructorRole constructorThis (remainingCaller caller) := by host_kernel_rfl
theorem current_slot (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).runtime.cells.cells 3126863 = some (.ptr (.js 3126867) 0) := by host_kernel_rfl
theorem current_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).buffers.owners 3126867 = some (handleSlotNotes 29375) := by host_kernel_rfl
theorem current_input_handle (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (inputNotes notes caller).privates.owners 3126703 = some ⟨4852,chars!"handle",.handle 29372⟩ := by
  host_kernel_rfl

theorem initial_live_grow (a : Nat) (alive : InitialRetained.live a) : InitializedCacheConvolution.live a := by
  unfold InitializedCacheConvolution.live InitializedCacheConvolutionCall.live InitializedCacheConvolutionCall.connectedLive
  unfold Plan1770.Block58.endLive Plan1770.Block37.endLive
  apply CellsLive.grow
  apply ClosureLive.grow
  apply CellsLive.grow
  apply ClosureLive.grow
  apply ClosureLive.grow
  apply Or.inl
  apply Or.inl
  apply Or.inl
  exact InitializedCacheConvolutionEntry.live_grow a alive

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_cleanup_source : PostConvCleanup.Region.s1 = Conv1856.output := by host_kernel_rfl",
      "theorem wrong_caller_tail (notes : RetainedNotes) (caller : List Annotated.Tree) : (inputNotes notes caller).runtime.stack = PostConvCleanup.resultFrames constructorRole constructorThis caller := by host_kernel_rfl"] do
    let saved : Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "initialized cleanup negative missed the intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.RankOrigin.ConvolutionCleanupFacts
