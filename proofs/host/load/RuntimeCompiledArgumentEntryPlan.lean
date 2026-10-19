import host.load.RuntimeCompiledArgumentEntryAnchor
import host.ts.RenameRouteDriver
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Lean Elab Command Meta
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  let wide := [2057, 2082, 2107, 2132, 2157, 2182, 2207, 2232, 2257]
  let near := [2282, 2287, 2292, 2297]
  let micro := `Host.Load.Run.Full.P.RestStream.micro0.micro23
  for i in List.range 280 do
    for tag in ["s", "S"] do
      let source :=
        if i < 225 then
          pre ++ Name.mkSimple s!"From{wide[i / 25]!}" ++ Name.mkSimple s!"{tag}{i % 25}"
        else if i < 243 then
          pre ++ Name.mkSimple s!"From{near[(i - 225) / 5]!}" ++ Name.mkSimple s!"{tag}{(i - 225) % 5}"
        else
          micro ++ Name.mkSimple s!"{tag}{i - 243}"
      unless (← getEnv).contains source do
        throwError s!"compiled argument region missing {source}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region ++ Name.mkSimple s!"{tag}{i}") (mkConst source)
end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
