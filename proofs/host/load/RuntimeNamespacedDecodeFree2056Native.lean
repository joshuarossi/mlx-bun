import host.load.RuntimeCompiledArgumentEntryFree
import host.mlx.NativeArrayFreeFrontend
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_retained_arrayFree P.F, CompiledArgumentEntry.At2056.s0 using
  (CompiledArgumentEntry.At2056.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to CompiledArgumentEntry.At2057.s0 using
  (CompiledArgumentEntry.At2057.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Free2056

theorem free2056_selected : Free2056.handle = 25732 := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let count := saved.messages.toList.length
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit
      "theorem wrong_disposed_handle : Free2056.handle = 29372 := by host_kernel_rfl"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
  for message in (← get).messages.toList.drop count do
    if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
  set saved
  unless rejected do throwError "native disposal negative did not reject the preceding call's handle in the kernel"
end Host.Load.Run.Full.Ordinary.NamespacedDecode
