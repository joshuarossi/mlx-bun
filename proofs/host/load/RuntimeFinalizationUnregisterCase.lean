import host.load.RuntimeNamespacedDecodeCuts1550
import host.ts.RenameRuntimeDriverUnregister
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.Unregister1666
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_unregister P.F, From1650.s16 using (From1650.S16.substitute LoopVariables.oracleVariables)
  to From1650.s17 using (From1650.S17.substitute LoopVariables.oracleVariables) as Selected

theorem actual_call : Selected.input.ctl = .call (.obj 186) (.obj 4851) [.obj 3126787] := by host_kernel_rfl
theorem actual_result : Selected.output.ctl = .ret (.bool false) := by host_kernel_rfl
theorem heap_preserved : Selected.output.heap = Selected.input.heap := by host_kernel_rfl
theorem native_preserved : Selected.output.ffi = Selected.input.ffi := by host_kernel_rfl
theorem counter_preserved : Selected.output.next = Selected.input.next := by host_kernel_rfl

host_retained_theorem entry := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (target : St P.F.S)
    (inst : Inst ν₀ Selected.initialServer C₀)
    (related : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Selected.input target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Selected.input target) => by
  host_retained_chain P.F, [Selected.retained_transport] using related, inventory, inst
host_assert_retained_schema entry, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema entry, 2

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_result : Selected.output.ctl = .ret .undef := by host_kernel_rfl",
      "theorem wrong_success : Selected.output.ctl = .ret (.bool true) := by host_kernel_rfl",
      "theorem wrong_builtin : Selected.sourceObject.kind = .fn (.native (.fn .finRegister) Selected.sourceData) := by host_kernel_rfl",
      "host_retained_unregister P.F, From1650.s16 using (From1650.S16.substitute LoopVariables.oracleVariables) to From1650.s18 using (From1650.S18.substitute LoopVariables.oracleVariables) as WrongEndpoint"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "unregister negative did not reach the intended kernel rejection: {claim}"
end Host.Load.Run.Full.Ordinary.NamespacedDecode.Unregister1666
