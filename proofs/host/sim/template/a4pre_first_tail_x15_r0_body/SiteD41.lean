import host.sim.template.a4pre_first_tail_x15_r0_body.Site41
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC41
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 41 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived41 : PRE_first_tail_x15_r0_body.nr41.map (fun r => nth? PRE_first_tail_x15_r0_body.st41.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo41 : PRE_first_tail_x15_r0_body.nr41.all (Nat.ble 1807) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj41 : PRE_first_tail_x15_r0_body.cws41.all (fun c => !PRE_first_tail_x15_r0_body.ws41.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ41 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws41 PRE_first_tail_x15_r0_body.crs41 PRE_first_tail_x15_r0_body.ws41

end Host.Load.Run.Tpl
