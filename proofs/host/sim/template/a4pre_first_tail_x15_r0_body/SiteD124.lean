import host.sim.template.a4pre_first_tail_x15_r0_body.Site124
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC124
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 124 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived124 : PRE_first_tail_x15_r0_body.nr124.map (fun r => nth? PRE_first_tail_x15_r0_body.st124.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo124 : PRE_first_tail_x15_r0_body.nr124.all (Nat.ble 5381) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj124 : PRE_first_tail_x15_r0_body.cws124.all (fun c => !PRE_first_tail_x15_r0_body.ws124.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ124 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws124 PRE_first_tail_x15_r0_body.crs124 PRE_first_tail_x15_r0_body.ws124

end Host.Load.Run.Tpl
