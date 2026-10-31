import host.sim.template.a4pre_first_tail_x15_r0_body.Site164
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC164
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 164 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived164 : PRE_first_tail_x15_r0_body.nr164.map (fun r => nth? PRE_first_tail_x15_r0_body.st164.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo164 : PRE_first_tail_x15_r0_body.nr164.all (Nat.ble 7066) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj164 : PRE_first_tail_x15_r0_body.cws164.all (fun c => !PRE_first_tail_x15_r0_body.ws164.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ164 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws164 PRE_first_tail_x15_r0_body.crs164 PRE_first_tail_x15_r0_body.ws164

end Host.Load.Run.Tpl
