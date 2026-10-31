import host.sim.template.a4dec_ord.Site2
import host.sim.template.a4dec_ord.SiteC2
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 2 of chain `DEC_ord`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl DEC_ord.cderived2 : DEC_ord.nr2.map (fun r => nth? DEC_ord.st2.S2.tab r) =
  []
kernel_rfl DEC_ord.cnrLo2 : DEC_ord.nr2.all (Nat.ble 354) = true
kernel_rfl DEC_ord.cwsDisj2 : DEC_ord.cws2.all (fun c => !DEC_ord.ws2.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def DEC_ord.cthetaZ2 : Nat → SymE := Conv.compactθZ DEC_ord.cws2 DEC_ord.crs2 DEC_ord.ws2

end Host.Load.Run.Tpl
