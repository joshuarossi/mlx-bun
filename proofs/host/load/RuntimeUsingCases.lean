import host.load.RuntimeNamespacedDecodeRegion1100
import host.ts.RenameRetainedUsingFrontend
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.UsingCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
noncomputable def input : St LSt := NamespacedDecode.Region1100.s63
noncomputable def output : St LSt := NamespacedDecode.Region1100.s64
host_retained_using Host.Load.ffi, input using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables)
  to output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables) as Source1163

theorem actual_source_path : Source1163.sourceAddress = 3126785 ∧ Source1163.sourceMethod = 4883 ∧ Source1163.scopeIndex = 1 := ⟨rfl,rfl,rfl⟩
theorem heap_and_native_frame : output.heap = input.heap ∧ output.ffi = input.ffi ∧ output.next = input.next := ⟨rfl,rfl,rfl⟩

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source1163.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (←Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetLookup,`targetMethod,`targetScope,`targetRun,`postInventory] do
      if names.contains forbidden then throwError "using: future target premise remained"

/-- error: host_retained_using: expected source return -/
#guard_msgs in
host_retained_using Host.Load.ffi, output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables)
  to output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables) as RejectBinding

noncomputable def notUsing : St LSt := {input with stack := .s (.decl .const Source1163.sourcePattern Source1163.sourceRest Source1163.sourceEnv)::Source1163.sourceTail}
/-- error: host_retained_using: expected using declaration -/
#guard_msgs in
host_retained_using Host.Load.ffi, notUsing using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables)
  to output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables) as RejectConst

noncomputable def missingScope : St LSt := {input with stack := [.s (.decl .using Source1163.sourcePattern Source1163.sourceRest Source1163.sourceEnv)]}
/-- error: host_retained_using: no nearest scope -/
#guard_msgs in
host_retained_using Host.Load.ffi, missingScope using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables)
  to output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables) as RejectScope

noncomputable def accessorDispose : St LSt := input.setObj Source1163.path1Address
  {Source1163.path1Object with props := [(.sym symDispose,.acc .undef .undef false)]}
/-- error: host_retained_using: expected source data disposal method -/
#guard_msgs in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_using Host.Load.ffi, accessorDispose using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables) to output using (NamespacedDecode.Region1100.S64.substitute LoopVariables.oracleVariables) as RejectAccessor"
  finally Lean.setEnv saved

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_using Host.Load.ffi, input using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables) to input using (NamespacedDecode.Region1100.S63.substitute LoopVariables.oracleVariables) as RejectEndpoint"
  finally Lean.setEnv saved
end Host.Load.Run.Full.Ordinary.UsingCases
