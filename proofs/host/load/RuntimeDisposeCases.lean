import host.load.RuntimePostConcatCleanupCuts
import host.load.RuntimeCompiledArgumentEntryCuts2057
import host.ts.RenameRetainedDisposeFrontend
import host.ts.RenameRetainedDisposeFacts
import host.ts.RenameRetainedChain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.DisposeCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_dispose P.F, PostConcatCleanup.Region.s41 using PostConcatCleanup.Region.S41
  to CompiledArgumentEntry.From2057.s3 using CompiledArgumentEntry.From2057.S3 as Source2020

host_assert_retained_schema Source2020.retained_transport, 40

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema Source2020.retained_transport, 41

theorem actual_call : Source2020.method = 4882 ∧ Source2020.owner = 2978923 ∧ Source2020.arrayHandle = 25732 := by
  exact ⟨rfl,rfl,rfl⟩

theorem actual_entry_false :
    findPriv Source2020.brand Dispose.flag Source2020.ownerObject.priv = some (.data (.bool false) true Source2020.flagEnumerable) := by
  host_kernel_rfl

theorem actual_exit_true :
    ∃ object, Source2020.output.heap.get Source2020.owner = some (.obj object) ∧
      findPriv Source2020.brand Dispose.flag object.priv = some (.data (.bool true) true Source2020.flagEnumerable) := by
  refine ⟨(match Source2020.output.obj? Source2020.owner with | some object => object | none => Source2020.ownerObject),?_,?_⟩ <;>
    host_kernel_rfl

theorem caller_restored : Source2020.output.stack = Source2020.input.stack := by host_kernel_rfl

theorem real_closure_allocations : Source2020.output.next = Source2020.input.next+2 := by host_kernel_rfl

theorem result_undefined : Source2020.output.ctl = .ret .undef := by host_kernel_rfl

open Lean Elab Command Meta in
run_cmd do
  let saved : Command.State ←get
  let base := (←getCurrNamespace) ++ `RejectedEndpoint
  let mut rejected := false
  let f ← `(term| P.F)
  let source ← `(term| PostConcatCleanup.Region.s41)
  let server ← `(term| PostConcatCleanup.Region.S41)
  let wrong ← `(term| PostConcatCleanup.Region.s77)
  let wrongServer ← `(term| PostConcatCleanup.Region.S77)
  try
    Host.Ts.Owned.Annotated.Driver.elaborateDispose f.raw source.raw server.raw wrong.raw wrongServer.raw (mkIdent `RejectedEndpoint)
  catch exception =>
    rejected := ((←exception.toMessageData.toString).splitOn "kernel").length > 1
  unless rejected do throwError "dispose: wrong endpoint did not reach kernel rejection"
  let leaked := (←getEnv).constants.foldStage2 (fun names name _ =>
    if base.isPrefixOf name then name::names else names) ([] : List Lean.Name)
  unless leaked.isEmpty do throwError "dispose: failed frontend leaked declarations: {leaked}"
  unless (←get).messages.toList.length == saved.messages.toList.length do
    throwError "dispose: failed frontend leaked messages"

open Lean Elab Command in
run_cmd do
  let saved : Command.State ←get
  let count := saved.messages.toList.length
  let mut rendered := ""
  try
    Parametric.Driver.emit "theorem RejectedCount (C : CSrv) : runC P.F 39 Source2020.input C = some (Source2020.output,C) := by host_kernel_rfl"
  catch exception =>
    rendered := (←exception.toMessageData.toString)
  for message in (←get).messages.toList.drop count do
    rendered := rendered ++ "\n" ++ (←message.data.toString)
  set saved
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError "dispose: wrong original-transition count did not reach kernel rejection: {rendered}"

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ←Lean.getConstInfo ``Source2020.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    for binder in binders do
      let name := (←Lean.Meta.getFVarLocalDecl binder).userName
      if [`targetRun,`futureState,`postInventory,`targetLookup,`reachedNative,`targetObject].contains name then
        throwError "dispose: future target premise remained: {name}"
end Host.Load.Run.Full.Ordinary.DisposeCases
