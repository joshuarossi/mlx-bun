import host.sim.template.a4pre_first_tail_x15_r0_suffix.Site0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteC0
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `PRE_first_tail_x15_r0_suffix`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_suffix.cderived0 : PRE_first_tail_x15_r0_suffix.nr0.map (fun r => nth? PRE_first_tail_x15_r0_suffix.st0.S5.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_suffix.cnrLo0 : PRE_first_tail_x15_r0_suffix.nr0.all (Nat.ble 8226) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cwsDisj0 : PRE_first_tail_x15_r0_suffix.cws0.all (fun c => !PRE_first_tail_x15_r0_suffix.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_suffix.cthetaZ0 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_suffix.cws0 PRE_first_tail_x15_r0_suffix.crs0 PRE_first_tail_x15_r0_suffix.ws0

end Host.Load.Run.Tpl
