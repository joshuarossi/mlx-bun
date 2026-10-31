import host.sim.template.a4pre_first_tail_x15_r0_body.Site37
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC37
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 37 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived37 : PRE_first_tail_x15_r0_body.nr37.map (fun r => nth? PRE_first_tail_x15_r0_body.st37.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo37 : PRE_first_tail_x15_r0_body.nr37.all (Nat.ble 1661) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj37 : PRE_first_tail_x15_r0_body.cws37.all (fun c => !PRE_first_tail_x15_r0_body.ws37.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ37 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws37 PRE_first_tail_x15_r0_body.crs37 PRE_first_tail_x15_r0_body.ws37

end Host.Load.Run.Tpl
