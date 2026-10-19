import host.mlx.NativeShapelessFrontend
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Load.Run.Full.Ordinary
open Host.Mlx.Ffi

host_retained_shapeless P.F, P.RestStream.micro0.micro36.s86 using
  (P.RestStream.micro0.micro36.S86.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro36.s87 using
  (P.RestStream.micro0.micro36.S87.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Shapeless3686

theorem source_callee : Shapeless3686.input.ctl = .call (.obj 4782) (.obj 4817)
    [.ptr (.js 3127055) 0,.big (Int.ofNat 18194),.big (Int.ofNat 29382)] := by host_kernel_rfl

theorem source_arity : (match Shapeless3686.input.ctl with
    | .call _ _ arguments => arguments
    | _ => []).length = 3 := by host_kernel_rfl

theorem source_closure : Shapeless3686.input.ffi.mlx.obj? 18194 =
    some (.clo (.compiled 281474976715599 ShapelessHost.payload true [ShapelessCall.trace])) := by host_kernel_rfl

theorem source_vector : Shapeless3686.input.ffi.mlx.obj? 29382 = some (.vec ShapelessCall.inputs) := by host_kernel_rfl

theorem source_output_slot : Shapeless3686.input.heap.get 3127055 = some (.obj ShapelessHost.bufferObject) := by host_kernel_rfl

theorem source_output_handle : ShapelessHost.bufferObject.kind =
    .buf (Host.Ts.cellParts .u64 (.big (Int.ofNat 29383)) 8 0) := ShapelessHost.source_buffer_kind

theorem source_endpoint : Shapeless3686.input = P.RestStream.micro0.micro36.s86 := by host_kernel_rfl

theorem result_endpoint : Shapeless3686.output = P.RestStream.micro0.micro36.s87 := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let reject (claim marker : String) (tag : Name) : CommandElabM Unit := do
    let saved ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    let mut detail := ""
    try
      Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      detail := (← exception.toMessageData.toString)
      if (detail.splitOn marker).length > 1 then rejected := true
    for message in (← get).messages.toList.drop count do
      let text ← message.data.toString
      detail := detail ++ text
      if (text.splitOn marker).length > 1 then rejected := true
    set saved
    unless rejected do
      throwError "shapeless replay negative did not reach its intended kernel rejection ({marker}): {detail}"
    let root := `Host.Load.Run.Full.Ordinary.NamespacedDecode ++ tag
    for suffix in [`F, `input, `output, `initialServer, `nextServer, `source_run, `source_step, `retained_transport] do
      if (← getEnv).contains (root ++ suffix) then
        throwError m!"shapeless replay negative leaked {root ++ suffix}"
  reject "host_retained_shapeless P.F, P.RestStream.micro0.micro36.s86 using (P.RestStream.micro0.micro36.S86.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) to P.RestStream.micro0.micro36.s87 using ({P.RestStream.micro0.micro36.S87.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables with tab := []}) as WrongNumberTable"
    "(kernel) application type mismatch" `WrongNumberTable
  reject "host_retained_shapeless P.F, P.RestStream.micro0.micro36.s86 using (P.RestStream.micro0.micro36.S86.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) to P.RestStream.micro0.micro36.s86 using (P.RestStream.micro0.micro36.S87.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as WrongEndpoint"
    "(kernel) declaration type mismatch" `WrongEndpoint
end Host.Load.Run.Full.Ordinary.NamespacedDecode
