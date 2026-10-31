import host.sim.template.a4pre_first_tail_x15_r0.Site0
import host.sim.template.a4pre_first_tail_x15_r0.SiteC0
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `PRE_first_tail_x15_r0`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0.cderived0 : PRE_first_tail_x15_r0.nr0.map (fun r => nth? PRE_first_tail_x15_r0.st0.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0.cnrLo0 : PRE_first_tail_x15_r0.nr0.all (Nat.ble 10) = true
kernel_rfl PRE_first_tail_x15_r0.cwsDisj0 : PRE_first_tail_x15_r0.cws0.all (fun c => !PRE_first_tail_x15_r0.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0.cthetaZ0 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0.cws0 PRE_first_tail_x15_r0.crs0 PRE_first_tail_x15_r0.ws0

end Host.Load.Run.Tpl
