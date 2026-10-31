import host.sim.template.a4pre_first_tail_x15_r0_body.Site76
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC76
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 76 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived76 : PRE_first_tail_x15_r0_body.nr76.map (fun r => nth? PRE_first_tail_x15_r0_body.st76.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo76 : PRE_first_tail_x15_r0_body.nr76.all (Nat.ble 3329) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj76 : PRE_first_tail_x15_r0_body.cws76.all (fun c => !PRE_first_tail_x15_r0_body.ws76.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ76 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws76 PRE_first_tail_x15_r0_body.crs76 PRE_first_tail_x15_r0_body.ws76

end Host.Load.Run.Tpl
