import host.sim.template.a4pre_first_tail_x15_r0_body.Site134
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC134
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 134 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived134 : PRE_first_tail_x15_r0_body.nr134.map (fun r => nth? PRE_first_tail_x15_r0_body.st134.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo134 : PRE_first_tail_x15_r0_body.nr134.all (Nat.ble 5782) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj134 : PRE_first_tail_x15_r0_body.cws134.all (fun c => !PRE_first_tail_x15_r0_body.ws134.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ134 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws134 PRE_first_tail_x15_r0_body.crs134 PRE_first_tail_x15_r0_body.ws134

end Host.Load.Run.Tpl
