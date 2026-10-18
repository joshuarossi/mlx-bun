import host.mlx.NativeRmsFrontend
import host.mlx.OrdinaryRmsStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RmsSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_rms P.F, RmsStates.entry.1 using RmsStates.entry.2
  to RmsStates.after.1 using RmsStates.after.2 as Source16530

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source16530.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`closedInput,`closedWeight,`epsilonSchema] do
      unless names.contains required do throwError "RMS transport: missing current occurrence schema"
    for forbidden in [`targetGeometry,`sourceGeometry,`targetRun,`targetShape,`targetDtype,`float] do
      if names.contains forbidden then throwError "RMS transport retained a future metadata/run premise"

/-- error: host_retained_rms: expected source call -/
#guard_msgs in
host_retained_rms P.F, Source16530.output using RmsStates.after.2
  to Source16530.output using RmsStates.after.2 as RejectReturn

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source16530.input"),
      ("WrongResult","{Source16530.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_rms P.F, Source16530.input using RmsStates.entry.2 to ({endpoint}) using RmsStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect RMS endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RmsSource
