import host.load.RuntimeCachedArrayEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedArrayEntry.Tests
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem source_forty_steps (C : CSrv) :
    runC P.F 40 P.RestStream.micro0.micro24.s47 C = some (P.RestStream.micro0.micro24.s87,C) := by
  host_kernel_rfl

theorem source_native_unchanged : P.RestStream.micro0.micro24.s87.ffi = P.RestStream.micro0.micro24.s47.ffi := by
  host_kernel_rfl

theorem source_address_growth : P.RestStream.micro0.micro24.s87.next = P.RestStream.micro0.micro24.s47.next+4 := by
  host_kernel_rfl

theorem final_control : P.RestStream.micro0.micro24.s87.ctl = .call (.obj 4630) (.obj 4817) [] := by
  host_kernel_rfl

theorem final_symbol : (P.RestStream.micro0.micro24.s87.obj? 4630).map (fun object =>
    match object.kind with
    | .fn (.native (.ffi .symbol) (.str symbol::_)) => symbol
    | _ => []) = some chars!"mlx_array_new" := by
  host_kernel_rfl

theorem count_cell_name : Rest.Block25.sourceName = chars!"n" := by host_kernel_rfl

theorem keeps_privates (notes : RetainedNotes) : (resultNotes notes).privates = notes.privates := by host_kernel_rfl
theorem keeps_captures (notes : RetainedNotes) : (resultNotes notes).captures = notes.captures := by host_kernel_rfl
theorem keeps_arrays (notes : RetainedNotes) : (resultNotes notes).arrays = notes.arrays := by host_kernel_rfl
theorem keeps_public_fields (notes : RetainedNotes) : (resultNotes notes).publicFields = notes.publicFields := by host_kernel_rfl
theorem derives_zero_buffer (notes : RetainedNotes) :
    (resultNotes notes).buffers.owners Region.s0.next = some (zeroByteNotes 8) := by
  host_kernel_rfl

host_assert_retained_schema retained_to_array_new, 40

open Lean Elab Command in
run_cmd do
  for (claim,expected) in [
      ("theorem wrong_final_state : From2477.Cut.s10 = P.RestStream.micro0.micro24.s86 := by host_kernel_rfl", "(kernel) declaration type mismatch"),
      ("theorem wrong_step_count (C : CSrv) : runC P.F 39 P.RestStream.micro0.micro24.s47 C = some (P.RestStream.micro0.micro24.s87,C) := by host_kernel_rfl", "(kernel) declaration type mismatch"),
      ("host_assert_retained_schema retained_to_array_new, 39", "retained batch schema: target run has the wrong step count"),
      ("theorem wrong_current_count : countLiteral = F64.ofNat 1 := by host_kernel_rfl", "(kernel) declaration type mismatch")] do
    let saved : Command.State ← get
    let count := saved.messages.toList.length
    let mut rendered := ""
    try Parametric.Driver.emit claim
    catch exception => rendered := rendered ++ (← exception.toMessageData.toString)
    for message in (← get).messages.toList.drop count do
      rendered := rendered ++ "\n" ++ (← message.data.toString)
    set saved
    unless (rendered.splitOn expected).length > 1 do
      throwError "cached entry negative missed its intended rejection: {claim}\n{rendered}"
  for tag in [`wrong_final_state,`wrong_step_count,`wrong_current_count] do
    if (← getEnv).contains ((← getCurrNamespace) ++ tag) then
      throwError "caught elaboration failure leaked a declaration: {tag}"
  logInfo "Cached-array negatives passed: endpoint, count, schema, current count; full command-state rollback."

end Host.Load.Run.Full.Ordinary.CachedArrayEntry.Tests
