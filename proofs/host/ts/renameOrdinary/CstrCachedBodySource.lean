import host.ts.RenameRetainedCstrCachedFrontend
import host.ts.renameOrdinary.CstrCachedReturnCuts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CstrCachedBodySource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_cstr_cached_body P.F, CstrCachedStates.Body.s4 using CstrCachedStates.Body.S4
  to CstrCachedStates.Return.s4 using CstrCachedStates.Return.S4 as Source8279

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ← Lean.getConstInfo ``Source8279.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (← Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetLookup,`targetCache,`targetBuffer,`targetRun,`futureValue,`targetCaller] do
      if names.contains forbidden then throwError "cached cstr body retained a future target premise"

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source8279.input"),
      ("WrongResult","{Source8279.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_cstr_cached_body P.F, Source8279.input using CstrCachedStates.Body.S4 to ({endpoint}) using CstrCachedStates.Return.S4 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect cached cstr endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.CstrCachedBodySource
