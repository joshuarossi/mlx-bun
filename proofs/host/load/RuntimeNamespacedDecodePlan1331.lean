import host.load.RuntimeNamespacedDecodeCuts1331
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 32 do
    let part := min 1 (i/25)
    let offset := i-part*25
    for tag in ["s","S"] do
      let source := pre ++ Name.mkSimple s!"From{1331+part*25}" ++ Name.mkSimple s!"{tag}{offset}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region1331 ++ Name.mkSimple s!"{tag}{i}") (mkConst source)
host_source_linear_plan_subst P.F, Region1331 from 0 plan_steps 31
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Plan1331
noncomputable def ShapeToDynamicSlice.rules := [``Meta1330.retained_transport] ++ Plan1331.rules
end Host.Load.Run.Full.Ordinary.NamespacedDecode
