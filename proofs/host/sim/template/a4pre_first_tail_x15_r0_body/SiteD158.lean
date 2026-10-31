import host.sim.template.a4pre_first_tail_x15_r0_body.Site158
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC158
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 158 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived158 : PRE_first_tail_x15_r0_body.nr158.map (fun r => nth? PRE_first_tail_x15_r0_body.st158.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo158 : PRE_first_tail_x15_r0_body.nr158.all (Nat.ble 6808) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj158 : PRE_first_tail_x15_r0_body.cws158.all (fun c => !PRE_first_tail_x15_r0_body.ws158.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ158 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws158 PRE_first_tail_x15_r0_body.crs158 PRE_first_tail_x15_r0_body.ws158

end Host.Load.Run.Tpl
