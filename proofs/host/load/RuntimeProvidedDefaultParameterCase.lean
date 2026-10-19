import host.load.RuntimeNamespacedDecodeCuts1678
import host.load.RuntimeDefaultIdentifierParameterCuts
import host.ts.RenameRuntimeDriverProvidedDefault
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.Provided1712
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_provided_default P.F, From1703.s9 using (From1703.S9.substitute LoopVariables.oracleVariables)
  to From1703.s10 using (From1703.S10.substitute LoopVariables.oracleVariables) as Selected

theorem parameter_name : Selected.sourceName = chars!"stride" := by host_kernel_rfl
theorem actual_argument : nthD .undef Selected.sourceArgs 0 = .num (.lit (F64.ofNat 1)) := by host_kernel_rfl
theorem original_pattern : Selected.output.ctl =
    .bind (.dflt (.id Selected.sourceName) Selected.sourceDefault)
      (nthD .undef Selected.sourceArgs 0) Selected.sourceEnv .init .let_ := by host_kernel_rfl
theorem native_preserved : Selected.output.ffi = Selected.input.ffi := by host_kernel_rfl
theorem heap_preserved : Selected.output.heap = Selected.input.heap := by host_kernel_rfl
theorem counter_preserved : Selected.output.next = Selected.input.next := by host_kernel_rfl

host_retained_theorem entry := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (target : St P.F.S)
    (inst : Inst ν₀ Selected.initialServer C₀)
    (related : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Selected.input target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Selected.input target)
    (roles : List Annotated.Value) (tailNotes : List Annotated.Tree)
    (stackNotes : notes.runtime.stack = parameterFrameNote Selected.sourceFunction
      (.dflt (.id Selected.sourceName) Selected.sourceDefault::Selected.sourceParams) roles Selected.sourceEnv::tailNotes) => by
  host_retained_chain P.F, [Selected.retained_transport] using related, inventory, inst
host_assert_retained_schema entry, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema entry, 2

open Lean Elab Command in
run_cmd do
  for (claim,expected) in [
      ("theorem wrong_pattern : Selected.output.ctl = .bind (.id Selected.sourceName) (nthD .undef Selected.sourceArgs 0) Selected.sourceEnv .init .let_ := by host_kernel_rfl", "(kernel) declaration type mismatch"),
      ("theorem wrong_argument : nthD .undef Selected.sourceArgs 0 = .undef := by host_kernel_rfl", "(kernel) declaration type mismatch"),
      ("host_retained_provided_default P.F, From1703.s9 using (From1703.S9.substitute LoopVariables.oracleVariables) to From1703.s11 using (From1703.S11.substitute LoopVariables.oracleVariables) as WrongEndpoint", "(kernel) declaration type mismatch"),
      ("host_retained_provided_default P.F, From1371.s9 using (From1371.S9.substitute LoopVariables.oracleVariables) to From1375.s1 using (From1375.S1.substitute LoopVariables.oracleVariables) as MissingArgument", "host_retained_provided_default: source argument is undefined")] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn expected).length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn expected).length > 1 then rejected := true
    set saved
    unless rejected do throwError "provided-default negative did not reach its intended rejection: {claim}"
end Host.Load.Run.Full.Ordinary.NamespacedDecode.Provided1712
