import host.mlx.OrdinaryConvCut
import host.mlx.OrdinaryArrayFreeCut
import host.ts.RenameRuntimeDerivedCuts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
host_derive_source_cuts P.F, Ordinary.ConvCall.output using P.RestStream.micro0.micro18.S57 steps 25 as From1857
host_derive_source_cuts P.F, From1857.s25 using From1857.S25 steps 25 as From1882
host_derive_source_cuts P.F, From1882.s25 using From1882.S25 steps 25 as From1907
host_derive_source_cuts P.F, From1907.s25 using From1907.S25 steps 25 as From1932
host_derive_source_cuts P.F, From1932.s25 using From1932.S25 steps 21 as From1957

theorem source_origin : From1857.s0 = Ordinary.ConvCall.output := by host_kernel_rfl
theorem source_server : From1857.S0 = P.RestStream.micro0.micro18.S57 := by host_kernel_rfl
theorem native_unchanged : From1957.s21.ffi = From1857.s0.ffi := by host_kernel_rfl
theorem endpoint_state : From1957.s21 = Ordinary.ArrayFreeCall.input := by host_kernel_rfl
theorem endpoint_free : From1957.s21.ctl = .call (.obj 4633) (.obj 4817) [.big (Int.ofNat 29372)] := by
  host_kernel_rfl
theorem endpoint_symbol : Ordinary.ArrayFreeCall.caps = [.str chars!"mlx_array_free",.obj 4259,.str Ordinary.ArrayFreeCall.returns] := by
  host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_freed_handle : From1957.s21.ctl = .call (.obj 4633) (.obj 4817) [.big (Int.ofNat 29373)] := by host_kernel_rfl",
      "theorem wrong_conv_handle : From1957.s21.ctl = .call (.obj 4633) (.obj 4817) [.big (Int.ofNat 29375)] := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "convolution-cleanup negative did not reach the intended kernel rejection: {claim}"

end Host.Load.Run.Full.Ordinary.PostConvCleanup
