import host.sim.template.a4dec_fill.Site2
import host.sim.template.a4dec_fill.SiteC2
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 2 of chain `DEC_fill`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl DEC_fill.cderived2 : DEC_fill.nr2.map (fun r => nth? DEC_fill.st2.S2.tab r) =
  []
kernel_rfl DEC_fill.cnrLo2 : DEC_fill.nr2.all (Nat.ble 290) = true
kernel_rfl DEC_fill.cwsDisj2 : DEC_fill.cws2.all (fun c => !DEC_fill.ws2.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def DEC_fill.cthetaZ2 : Nat → SymE := Conv.compactθZ DEC_fill.cws2 DEC_fill.crs2 DEC_fill.ws2

end Host.Load.Run.Tpl
