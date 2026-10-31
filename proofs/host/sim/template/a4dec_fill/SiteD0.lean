import host.sim.template.a4dec_fill.Site0
import host.sim.template.a4dec_fill.SiteC0
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `DEC_fill`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl DEC_fill.cderived0 : DEC_fill.nr0.map (fun r => nth? DEC_fill.st0.S2.tab r) =
  []
kernel_rfl DEC_fill.cnrLo0 : DEC_fill.nr0.all (Nat.ble 123) = true
kernel_rfl DEC_fill.cwsDisj0 : DEC_fill.cws0.all (fun c => !DEC_fill.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def DEC_fill.cthetaZ0 : Nat → SymE := Conv.compactθZ DEC_fill.cws0 DEC_fill.crs0 DEC_fill.ws0

end Host.Load.Run.Tpl
