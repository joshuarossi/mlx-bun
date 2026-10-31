import host.sim.template.a4pre_first_tail_x15_r0_body.Site55
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC55
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 55 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived55 : PRE_first_tail_x15_r0_body.nr55.map (fun r => nth? PRE_first_tail_x15_r0_body.st55.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo55 : PRE_first_tail_x15_r0_body.nr55.all (Nat.ble 2432) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj55 : PRE_first_tail_x15_r0_body.cws55.all (fun c => !PRE_first_tail_x15_r0_body.ws55.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ55 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws55 PRE_first_tail_x15_r0_body.crs55 PRE_first_tail_x15_r0_body.ws55

end Host.Load.Run.Tpl
