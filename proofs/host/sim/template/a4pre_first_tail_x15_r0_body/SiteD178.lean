import host.sim.template.a4pre_first_tail_x15_r0_body.Site178
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC178
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 178 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived178 : PRE_first_tail_x15_r0_body.nr178.map (fun r => nth? PRE_first_tail_x15_r0_body.st178.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo178 : PRE_first_tail_x15_r0_body.nr178.all (Nat.ble 7688) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj178 : PRE_first_tail_x15_r0_body.cws178.all (fun c => !PRE_first_tail_x15_r0_body.ws178.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ178 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws178 PRE_first_tail_x15_r0_body.crs178 PRE_first_tail_x15_r0_body.ws178

end Host.Load.Run.Tpl
