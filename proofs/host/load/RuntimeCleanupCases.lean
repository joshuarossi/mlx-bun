import host.load.RuntimeCleanupCuts1600
import host.ts.RenameRetainedCleanupFrontend
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CleanupCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
noncomputable def input : St LSt := CleanupSource.From1625.s7
noncomputable def output : St LSt := CleanupSource.From1625.s8
host_retained_cleanup Host.Load.ffi, input using (CleanupSource.From1625.S7.substitute LoopVariables.oracleVariables)
  to output using (CleanupSource.From1625.S8.substitute LoopVariables.oracleVariables) as Source1632

theorem actual_resource_pair : Source1632.sourceResource = .obj 3126785 ∧ Source1632.sourceMethod = .obj 4883 ∧ Source1632.sourceRest = [] := ⟨rfl,rfl,rfl⟩
theorem actual_pending_return : Source1632.sourcePending = .abrupt (.ret (.obj 3126840)) := rfl
theorem actual_dispose_call : output.ctl = .call (.obj 4883) (.obj 3126785) [] := rfl
theorem unchanged_heap_native : output.heap = input.heap ∧ output.ffi = input.ffi ∧ output.next = input.next := ⟨rfl,rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ←Lean.getConstInfo ``Source1632.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (←Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetResource,`targetMethod,`targetScope,`targetRun,`targetCompletion,`postInventory] do
      if names.contains forbidden then throwError "cleanup: future target premise remained"

noncomputable def emptyScope : St LSt := {input with stack := .s (.scope [])::Source1632.sourceFrames}
/-- error: host_retained_cleanup: expected nonempty scope -/
#guard_msgs in
host_retained_cleanup Host.Load.ffi, emptyScope using (CleanupSource.From1625.S7.substitute LoopVariables.oracleVariables)
  to output using (CleanupSource.From1625.S8.substitute LoopVariables.oracleVariables) as RejectEmpty

noncomputable def throwingDisposer : St LSt := {input with ctl := .abr (.throw (.obj 3126840)),stack := .s (.dispose [] Source1632.sourcePending)::Source1632.sourceFrames}
/-- error: host_retained_cleanup: throwing disposer requires separate error rule -/
#guard_msgs in
host_retained_cleanup Host.Load.ffi, throwingDisposer using (CleanupSource.From1625.S7.substitute LoopVariables.oracleVariables)
  to output using (CleanupSource.From1625.S8.substitute LoopVariables.oracleVariables) as RejectThrow

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_cleanup Host.Load.ffi, input using (CleanupSource.From1625.S7.substitute LoopVariables.oracleVariables) to input using (CleanupSource.From1625.S7.substitute LoopVariables.oracleVariables) as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.CleanupCases
