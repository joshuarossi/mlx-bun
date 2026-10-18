import host.load.RuntimeDriver
import host.mlx.NativeCachedFrontend
import host.mlx.NativeShapelessFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RuntimeNativeRegistryDispatchTest
open Lean Elab Command Meta

elab "host_registry_reject_test " _f:term ", " _s:term " using " _initial:term " to " _t:term " using " _next:term " as " name:ident : command => do
  liftTermElabM <| Host.Ts.Owned.Parametric.Driver.addData
    ((← getCurrNamespace) ++ name.getId ++ `rejectedLeak) (mkNatLit 1)
  throwError "deliberate source generator rejection"

elab "host_registry_incomplete_test " _f:term ", " _s:term " using " _initial:term " to " _t:term " using " _next:term " as " name:ident : command => do
  liftTermElabM <| Host.Ts.Owned.Parametric.Driver.addData
    ((← getCurrNamespace) ++ name.getId ++ `incompleteLeak) (mkNatLit 2)

host_register_native_source "mlx_closure_apply" => "host_registry_reject_test"
host_register_native_source "mlx_closure_apply" => "host_registry_incomplete_test"
host_register_native_source "mlx_closure_apply" => "host_retained_cached"
host_register_native_source "mlx_closure_apply" => "host_retained_shapeless"

host_source_step P.F, P.RestStream.micro0.micro23.s82 using P.RestStream.micro0.micro23.S82
  to P.RestStream.micro0.micro23.s83 using P.RestStream.micro0.micro23.S83 as Cached2382
host_source_step P.F, P.RestStream.micro0.micro36.s86 using P.RestStream.micro0.micro36.S86
  to P.RestStream.micro0.micro36.s87 using P.RestStream.micro0.micro36.S87 as Shapeless3686

run_cmd do
  let env ← getEnv
  let namespaceName ← getCurrNamespace
  for selected in [`Cached2382,`Shapeless3686] do
    unless env.contains (namespaceName ++ selected ++ `retained_transport) do
      throwError "registered native selection omitted the checked transport"
    for suffix in [`rejectedLeak,`incompleteLeak] do
      if env.contains (namespaceName ++ selected ++ suffix) then
        throwError "rejected native source candidate leaked a declaration"

run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  let mut diagnostic := "no exception"
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_source_step P.F, P.RestStream.micro0.micro36.s86 using P.RestStream.micro0.micro36.S86 to P.RestStream.micro0.micro36.s86 using P.RestStream.micro0.micro36.S86 as WrongEndpoint"
  catch exception =>
    diagnostic ← exception.toMessageData.toString
    rejected := (diagnostic.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
    diagnostic := diagnostic ++ "\n" ++ rendered
  set saved
  unless rejected do throwError "wrong registered native endpoint escaped kernel rejection: {diagnostic}"
  if (← getEnv).contains ((← getCurrNamespace) ++ `WrongEndpoint ++ `input) then
    throwError "failed registered native selection leaked source declarations"

end Host.Load.Run.Full.Ordinary.RuntimeNativeRegistryDispatchTest
