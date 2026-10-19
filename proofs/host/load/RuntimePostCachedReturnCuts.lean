import host.ts.RenameRuntimeDerivedCuts
import host.ts.RenameLoopVariableNamespace
import host.ts.RenameStateValuationRebase
import host.ts.renameOrdinary.NativeCallCutStates
import host.mlx.OrdinaryVectorResultStates
import host.mlx.NativeVectorFreeFrontend
import host.mlx.NativeVectorSizeFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated

/- Source 2383 is the state after the cached closure call. The next 64 original
steps reach source 2447. Two of them are native: vector free at 2408 and vector
size at 2428. Host derivation stops on each call; the retained adapters own it. -/

theorem vector_free_control :
    (P.RestStream.micro0.micro24.s8).ctl
      = .call (.obj 4710) (.obj 4817) [.big (Int.ofNat 29376)] := by
  host_kernel_rfl

theorem vector_size_control :
    (P.RestStream.micro0.micro24.s28).ctl
      = .call (.obj 4789) (.obj 4817) [.big (Int.ofNat 29377)] := by
  host_kernel_rfl

-- 2383 through the vector-free call state, without executing that call.
host_derive_source_cuts P.F, P.RestStream.micro0.micro23.s83 using P.RestStream.micro0.micro23.S83
  steps 25 as From2383

theorem free_state : From2383.s25 = P.RestStream.micro0.micro24.s8 := by host_kernel_rfl
theorem free_server : From2383.S25 = P.RestStream.micro0.micro24.S8 := by host_kernel_rfl

host_retained_vectorFree P.F, From2383.s25 using (From2383.S25.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro24.s9 using (P.RestStream.micro0.micro24.S9.substitute LoopVariables.oracleVariables)
  as VectorFree2408

theorem free_handle : VectorFree2408.handle = 29376 := by host_kernel_rfl
theorem free_callee : VectorFree2408.address = 4710 := by host_kernel_rfl
theorem free_receiver : VectorFree2408.sourceThis = .obj 4817 := by host_kernel_rfl
theorem free_output : VectorFree2408.output = P.RestStream.micro0.micro24.s9 := by host_kernel_rfl

-- 2409 through the vector-size call state, without executing that call.
host_derive_source_cuts P.F, P.RestStream.micro0.micro24.s9 using P.RestStream.micro0.micro24.S9
  steps 19 as From2409

theorem size_state : From2409.s19 = P.RestStream.micro0.micro24.s28 := by host_kernel_rfl
theorem size_server : From2409.S19 = P.RestStream.micro0.micro24.S28 := by host_kernel_rfl

host_retained_vectorSize P.F, From2409.s19 using (From2409.S19.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro24.s29 using (P.RestStream.micro0.micro24.S29.substitute LoopVariables.oracleVariables)
  as VectorSize2428

theorem size_handle : VectorSize2428.handle = 29377 := by host_kernel_rfl
theorem size_callee : VectorSize2428.address = 4789 := by host_kernel_rfl
theorem size_receiver : VectorSize2428.sourceThis = .obj 4817 := by host_kernel_rfl
theorem size_output : VectorSize2428.output = P.RestStream.micro0.micro24.s29 := by host_kernel_rfl

-- 2429 through the assigned endpoint. Source 2447 is not executed.
host_derive_source_cuts P.F, P.RestStream.micro0.micro24.s29 using P.RestStream.micro0.micro24.S29
  steps 18 as From2429

theorem endpoint_state : From2429.s18 = P.RestStream.micro0.micro24.s47 := by host_kernel_rfl
theorem endpoint_server : From2429.S18 = P.RestStream.micro0.micro24.S47 := by host_kernel_rfl

theorem namespaced_entry_server :
    numberServer ((From2383.S0).substitute LoopVariables.oracleVariables)
      = numberServer ((P.RestStream.micro0.micro23.S83).substitute LoopVariables.oracleVariables) := by
  host_kernel_rfl

theorem namespaced_endpoint_server :
    numberServer ((From2429.S18).substitute LoopVariables.oracleVariables)
      = numberServer ((P.RestStream.micro0.micro24.S47).substitute LoopVariables.oracleVariables) := by
  host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "host_derive_source_cuts P.F, P.RestStream.micro0.micro24.s8 using P.RestStream.micro0.micro24.S8 steps 1 as RejectNativeFree",
      "host_derive_source_cuts P.F, P.RestStream.micro0.micro24.s28 using P.RestStream.micro0.micro24.S28 steps 1 as RejectNativeSize",
      "host_retained_vectorFree P.F, From2383.s25 using (From2383.S25.substitute LoopVariables.oracleVariables) to P.RestStream.micro0.micro24.s10 using (P.RestStream.micro0.micro24.S10.substitute LoopVariables.oracleVariables) as WrongFreeEndpoint",
      "host_retained_vectorSize P.F, From2409.s19 using (From2409.S19.substitute LoopVariables.oracleVariables) to P.RestStream.micro0.micro24.s30 using (P.RestStream.micro0.micro24.S30.substitute LoopVariables.oracleVariables) as WrongSizeEndpoint"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    let mut seen := ""
    try
      Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      let text ← exception.toMessageData.toString
      seen := text
      rejected := (text.splitOn "(kernel) declaration type mismatch").length > 1
        || (text.splitOn "derived source cuts: original native symbol").length > 1
    for message in (← get).messages.toList.drop count do
      let text ← message.data.toString
      seen := seen ++ text
      if (text.splitOn "(kernel) declaration type mismatch").length > 1
          || (text.splitOn "derived source cuts: original native symbol").length > 1 then
        rejected := true
    set saved
    unless rejected do throwError "post-cached cut negative did not reach the intended rejection: {claim}\n{seen}"

end Host.Load.Run.Full.Ordinary.PostCachedReturn
