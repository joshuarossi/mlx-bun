import host.sim.template.a4pre_first_tail_x15_r0_body.Site40
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC40
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 40 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived40 : PRE_first_tail_x15_r0_body.nr40.map (fun r => nth? PRE_first_tail_x15_r0_body.st40.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo40 : PRE_first_tail_x15_r0_body.nr40.all (Nat.ble 1790) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj40 : PRE_first_tail_x15_r0_body.cws40.all (fun c => !PRE_first_tail_x15_r0_body.ws40.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ40 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws40 PRE_first_tail_x15_r0_body.crs40 PRE_first_tail_x15_r0_body.ws40

end Host.Load.Run.Tpl
