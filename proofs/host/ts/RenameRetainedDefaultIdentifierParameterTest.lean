import host.load.RuntimeDefaultIdentifierParameterCases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned.Parametric
open Host.Ts.Owned.Annotated

private def defaultParameterTestNotes : RetainedNotes :=
  ⟨⟨.atom Nat 0,[],Notes.empty⟩,PrivateNotes.empty,NativeCaptureNotes.empty,
    ArrayNotes.empty,PublicNotes.empty,BufferNotes.empty⟩

theorem default_role_installed :
    (defaultIdentifierParameterNotes defaultParameterTestNotes pinnedFunction sourceRemainingParams []
      sourceEnv [] parameterAddress (.handle 2)).runtime.cells.cells parameterAddress =
      some (.handle 2) := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let checks := [
    ("wrong_fuel", "host_assert_retained_schema retained_entry, 5", "target run has the wrong step count"),
    ("wrong_endpoint", "theorem wrong_endpoint : defaultIdentifierParameterReached From1371.s9 parameterAddress sourceDefaultValue pinnedFunction sourceRemainingParams sourceArgs sourceEnv sourceCallerFrames = From1375.s3 := by host_kernel_rfl", "(kernel) declaration type mismatch, 'Host.Load.Run.Full.Ordinary.NamespacedDecode.wrong_endpoint' has type"),
    ("wrong_default_name", "theorem wrong_default_name : From1371.s9.stack = .k (.params pinnedFunction (.dflt (.id defaultName) (.id parameterName)::sourceRemainingParams) sourceArgs sourceEnv)::sourceCallerFrames := by host_kernel_rfl", "(kernel) declaration type mismatch, 'Host.Load.Run.Full.Ordinary.NamespacedDecode.wrong_default_name' has type"),
    ("wrong_default_cell", "theorem wrong_default_cell : From1371.s9.heap.get defaultAddress = some (.cell none) := by host_kernel_rfl", "(kernel) declaration type mismatch, 'Host.Load.Run.Full.Ordinary.NamespacedDecode.wrong_default_cell' has type"),
    ("wrong_written_default", "theorem wrong_written_default : defaultIdentifierParameterReached From1371.s9 parameterAddress .undef pinnedFunction sourceRemainingParams sourceArgs sourceEnv sourceCallerFrames = From1375.s4 := by host_kernel_rfl", "(kernel) declaration type mismatch, 'Host.Load.Run.Full.Ordinary.NamespacedDecode.wrong_written_default' has type"),
    ("swapped_value_role", "theorem swapped_value_role : (defaultIdentifierParameterNotes defaultParameterTestNotes pinnedFunction sourceRemainingParams [] sourceEnv [] parameterAddress (.handle 2)).runtime.cells.cells parameterAddress = some (.handle 3) := by host_kernel_rfl", "(kernel) declaration type mismatch, 'Host.Load.Run.Full.Ordinary.NamespacedDecode.swapped_value_role' has type")]
  for (label,claim,expected) in checks do
    let saved : Lean.Elab.Command.State ← get
    let previousMessages := (← get).messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      let message ← exception.toMessageData.toString
      rejected := !message.isEmpty && (message.splitOn expected).length > 1
    let freshMessages := (← get).messages.toList.drop previousMessages
    for message in freshMessages do
      let rendered ← message.data.toString
      if (rendered.splitOn expected).length > 1 then rejected := true
    set saved
    unless rejected do throwError "negative source check {label} was not rejected"

end Host.Load.Run.Full.Ordinary.NamespacedDecode
