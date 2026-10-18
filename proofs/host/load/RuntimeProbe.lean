import host.load.RuntimeDriver
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command

/-- Probe imported source snapshots. Temporary source facts and retained
transport theorems undergo normal synchronous checks, then are discarded.
This reports frontend readiness; it does not discharge entry annotations. -/
elab "host_source_probe " f:term ", " base:ident " from " start:num " probe_steps " limit:num : command => do
  let some fText := f.raw.reprint | throwError "host_source_probe: cannot print Ffi argument"
  let start := start.getNat
  let limit := limit.getNat
  let base := base.getId.toString
  let mut checked : Nat := 0
  let mut failure : Option (Nat × String) := none
  for index in List.range limit do
    let index := start+index
    let saved : Command.State ← get
    let probeName := "SourceProbe" ++ toString index
    let mut issue : Option String := none
    try
      Parametric.Driver.emit s!"host_source_step {fText}, {base}.s{index} using {base}.S{index} to {base}.s{index+1} using {base}.S{index+1} as {probeName}"
    catch exception => issue := some (← exception.toMessageData.toString)
    if (← get).messages.hasErrors && issue.isNone then
      for message in (← get).messages.toList do
        if message.severity == .error && issue.isNone then issue := some (← message.data.toString)
    let generated := (← getCurrNamespace) ++ Name.mkSimple probeName ++ `retained_transport
    if !(← getEnv).contains generated && issue.isNone then issue := some "no checked retained transport declaration was generated"
    set saved
    if let some reason := issue then
      failure := some (index,reason)
      break
    checked := checked+1
  match failure with
  | some (index,reason) => logInfo m!"Retained source probe: {checked} checked frontend instances; first unsupported source index {index}: {reason}"
  | none => logInfo m!"Retained source probe: all {checked} selected frontend instances checked; initial annotation premises remain to be discharged"

end Host.Ts.Owned.Annotated.Driver
