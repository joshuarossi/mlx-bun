import host.sim.template.a4dec_clearFill.Site2
import host.sim.template.a4dec_clearFill.SiteC2
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 2 of chain `DEC_clearFill`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl DEC_clearFill.cderived2 : DEC_clearFill.nr2.map (fun r => nth? DEC_clearFill.st2.S2.tab r) =
  []
kernel_rfl DEC_clearFill.cnrLo2 : DEC_clearFill.nr2.all (Nat.ble 290) = true
kernel_rfl DEC_clearFill.cwsDisj2 : DEC_clearFill.cws2.all (fun c => !DEC_clearFill.ws2.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def DEC_clearFill.cthetaZ2 : Nat → SymE := Conv.compactθZ DEC_clearFill.cws2 DEC_clearFill.crs2 DEC_clearFill.ws2

end Host.Load.Run.Tpl
