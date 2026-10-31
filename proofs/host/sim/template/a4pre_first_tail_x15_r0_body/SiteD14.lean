import host.sim.template.a4pre_first_tail_x15_r0_body.Site14
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC14
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 14 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived14 : PRE_first_tail_x15_r0_body.nr14.map (fun r => nth? PRE_first_tail_x15_r0_body.st14.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo14 : PRE_first_tail_x15_r0_body.nr14.all (Nat.ble 652) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj14 : PRE_first_tail_x15_r0_body.cws14.all (fun c => !PRE_first_tail_x15_r0_body.ws14.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ14 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws14 PRE_first_tail_x15_r0_body.crs14 PRE_first_tail_x15_r0_body.ws14

end Host.Load.Run.Tpl
