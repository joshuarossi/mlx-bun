import host.load.RuntimeNamespacedDecodeCuts1438
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 112 do
    let part := min 4 ((i-1)/25)
    let offset := i-1-part*25
    for tag in ["s","S"] do
      let source := if i == 0 then pre ++ `At1438 ++ Name.mkSimple s!"{tag}0" else
        pre ++ Name.mkSimple s!"From{1439+part*25}" ++ Name.mkSimple s!"{tag}{offset}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region1438 ++ Name.mkSimple s!"{tag}{i}") (mkConst source)
host_source_linear_plan_subst P.F, Region1438 from 0 plan_steps 111
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Plan1438
end Host.Load.Run.Full.Ordinary.NamespacedDecode
