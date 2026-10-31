import host.sim.template.a4pre_first_tail_x15_r0_body.Site10
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC10
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 10 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived10 : PRE_first_tail_x15_r0_body.nr10.map (fun r => nth? PRE_first_tail_x15_r0_body.st10.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo10 : PRE_first_tail_x15_r0_body.nr10.all (Nat.ble 506) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj10 : PRE_first_tail_x15_r0_body.cws10.all (fun c => !PRE_first_tail_x15_r0_body.ws10.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ10 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws10 PRE_first_tail_x15_r0_body.crs10 PRE_first_tail_x15_r0_body.ws10

end Host.Load.Run.Tpl
