import host.mlx.NativeQuantizedFrontend
import host.mlx.OrdinaryQuantizedStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.QuantizedSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_quantized P.F, QuantizedStates.entry.1 using QuantizedStates.entry.2
  to QuantizedStates.after.1 using QuantizedStates.after.2 as Source8309

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source8309.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for required in [`closedX,`closedW,`closedSc,`closedBi,`groupSchema,`bitsSchema] do
      unless names.contains required do throwError "quantized transport: missing current occurrence schema"
    for forbidden in [`targetGeometry,`sourceGeometry,`targetRun,`targetMode,`targetShape,`targetDtype] do
      if names.contains forbidden then throwError "quantized transport retained a future metadata/run premise"

/-- error: host_retained_quantized: expected source call -/
#guard_msgs in
host_retained_quantized P.F, Source8309.output using QuantizedStates.after.2
  to Source8309.output using QuantizedStates.after.2 as RejectReturn

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source8309.input"),
      ("WrongResult","{Source8309.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_quantized P.F, Source8309.input using QuantizedStates.entry.2 to ({endpoint}) using QuantizedStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect quantized endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.QuantizedSource
