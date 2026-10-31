import host.sim.template.a4dec_clear.Site0
import host.sim.template.a4dec_clear.SiteC0
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `DEC_clear`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl DEC_clear.cderived0 : DEC_clear.nr0.map (fun r => nth? DEC_clear.st0.S2.tab r) =
  []
kernel_rfl DEC_clear.cnrLo0 : DEC_clear.nr0.all (Nat.ble 123) = true
kernel_rfl DEC_clear.cwsDisj0 : DEC_clear.cws0.all (fun c => !DEC_clear.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def DEC_clear.cthetaZ0 : Nat → SymE := Conv.compactθZ DEC_clear.cws0 DEC_clear.crs0 DEC_clear.ws0

end Host.Load.Run.Tpl
