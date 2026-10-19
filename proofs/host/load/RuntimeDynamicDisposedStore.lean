import host.load.RuntimeNamespacedDecodePlan1550
import host.ts.RenameRuntimeDriverPrivateOther
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_private_store_other P.F, Region1550.s105 using (Region1550.S105.substitute LoopVariables.oracleVariables)
  to Region1550.s106 using (Region1550.S106.substitute LoopVariables.oracleVariables) as DisposedStore

namespace DisposedStore

def handleAt (s : St P.F.S) : Option Val :=
  (s.obj? 3126785).bind fun object =>
    match findPriv 4852 chars!"handle" object.priv with
    | some (.data value _ _) => some value
    | _ => none

theorem source_flag : sourceName = chars!"disposed" := by host_kernel_rfl
theorem source_value : sourceValue = .bool true := by host_kernel_rfl
theorem source_owner : sourceAddress = 3126785 := by host_kernel_rfl
theorem handle_before : handleAt input = some (.big 29373) := by host_kernel_rfl
theorem handle_after : handleAt output = some (.big 29373) := by host_kernel_rfl
theorem native_preserved : output.ffi = input.ffi := by host_kernel_rfl
theorem counter_preserved : output.next = input.next := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_flag : sourceName = chars!\"handle\" := by host_kernel_rfl",
      "theorem wrong_handle : handleAt output = some (.big 29374) := by host_kernel_rfl",
      "theorem wrong_value : sourceValue = .bool false := by host_kernel_rfl",
      "host_retained_private_store_other P.F, Region1550.s105 using (Region1550.S105.substitute LoopVariables.oracleVariables) to Region1550.s107 using (Region1550.S107.substitute LoopVariables.oracleVariables) as WrongEndpoint"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "disposed-store negative did not reach the intended kernel rejection: {claim}"
end DisposedStore
end Host.Load.Run.Full.Ordinary.NamespacedDecode
