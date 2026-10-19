import host.load.RuntimePostConvCleanupCuts
import host.load.RuntimeBlockPlan
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  for i in List.range 122 do
    let part := i / 25
    let offset := i - part * 25
    let chunk := match part with
      | 0 => `From1857
      | 1 => `From1882
      | 2 => `From1907
      | 3 => `From1932
      | _ => `From1957
    for tag in ["s", "S"] do
      let source := pre ++ chunk ++ Name.mkSimple s!"{tag}{offset}"
      Host.Ts.Owned.Parametric.Driver.addData (pre ++ `Region ++ Name.mkSimple s!"{tag}{i}") (mkConst source)
open Lean Elab Command in
run_cmd do
  for i in List.range 122 do
    Host.Ts.Owned.Parametric.Driver.emit s!"theorem Region.native_{i} : Region.s{i}.ffi = Region.s0.ffi := by host_kernel_rfl"
host_source_linear_plan_subst P.F, Region from 0 plan_steps 121
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Plan
end Host.Load.Run.Full.Ordinary.PostConvCleanup
