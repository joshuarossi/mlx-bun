import host.load.RuntimeCompiledArgumentEntryPlan
import host.ts.RenameRetainedTypedHandleStoreStep
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_typed_handle_store P.F, Region.s155 using (Region.S155.substitute LoopVariables.oracleVariables)
  to Region.s156 using (Region.S156.substitute LoopVariables.oracleVariables) with 3 as TypedHandleStore155

theorem typed_store_first_index : TypedHandleStore155.index = 0 := by host_kernel_rfl
theorem typed_store_source_handle : TypedHandleStore155.handle = 29375 := by host_kernel_rfl
theorem typed_store_count_is_three : TypedHandleStore155.count = 3 := by host_kernel_rfl
theorem typed_store_buffer_is_allocation : TypedHandleStore155.buffer = Region.s106.next := by host_kernel_rfl
theorem typed_store_view_is_allocation : TypedHandleStore155.owner = Region.s106.next+1 := by host_kernel_rfl
theorem typed_store_buffer_length : len TypedHandleStore155.bytes = 24 := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  for (label,command) in [
      ("WrongTypedStoreCount", "host_retained_typed_handle_store P.F, Region.s155 using (Region.S155.substitute LoopVariables.oracleVariables) to Region.s156 using (Region.S156.substitute LoopVariables.oracleVariables) with 2 as WrongTypedStoreCount"),
      ("WrongTypedStoreEndpoint", "host_retained_typed_handle_store P.F, Region.s155 using (Region.S155.substitute LoopVariables.oracleVariables) to Region.s157 using (Region.S157.substitute LoopVariables.oracleVariables) with 3 as WrongTypedStoreEndpoint"),
      ("WrongTypedStoreOperand", "host_retained_typed_handle_store P.F, (Region.s155.go (.ret (.big (Int.ofNat 29376)))) using (Region.S155.substitute LoopVariables.oracleVariables) to Region.s156 using (Region.S156.substitute LoopVariables.oracleVariables) with 3 as WrongTypedStoreOperand")] do
    let messageCount := saved.messages.toList.length
    let mut rendered := ""
    try
      Parametric.Driver.emit command
    catch exception => rendered := rendered ++ (← exception.toMessageData.toString)
    for message in (← get).messages.toList.drop messageCount do
      rendered := rendered ++ "\n" ++ (← message.data.toString)
    for tag in [`input,`owner,`source_control,`source_kind,`source_output,`source_run,`retained_transport] do
      if (← getEnv).contains ((← getCurrNamespace) ++ Name.mkSimple label ++ tag) then
        throwError "typed handle store rejection leaked a partial declaration: {label}.{tag}"
    set saved
    unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
      throwError "typed handle store negative was not rejected by the kernel: {label}: {rendered}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
