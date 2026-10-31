import host.sim.template.a4pre_first_tail_x15_r0.Site2
import host.sim.template.a4pre_first_tail_x15_r0.SiteC2
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 2 of chain `PRE_first_tail_x15_r0`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0.cderived2 : PRE_first_tail_x15_r0.nr2.map (fun r => nth? PRE_first_tail_x15_r0.st2.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0.cnrLo2 : PRE_first_tail_x15_r0.nr2.all (Nat.ble 18) = true
kernel_rfl PRE_first_tail_x15_r0.cwsDisj2 : PRE_first_tail_x15_r0.cws2.all (fun c => !PRE_first_tail_x15_r0.ws2.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0.cthetaZ2 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0.cws2 PRE_first_tail_x15_r0.crs2 PRE_first_tail_x15_r0.ws2

end Host.Load.Run.Tpl
