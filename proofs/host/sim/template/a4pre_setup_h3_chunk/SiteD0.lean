import host.sim.template.a4pre_setup_h3_chunk.Site0
import host.sim.template.a4pre_setup_h3_chunk.SiteC0
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 0 of chain `PRE_setup_h3_chunk`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_setup_h3_chunk.cderived0 : PRE_setup_h3_chunk.nr0.map (fun r => nth? PRE_setup_h3_chunk.st0.S4.tab r) =
  []
kernel_rfl PRE_setup_h3_chunk.cnrLo0 : PRE_setup_h3_chunk.nr0.all (Nat.ble 10) = true
kernel_rfl PRE_setup_h3_chunk.cwsDisj0 : PRE_setup_h3_chunk.cws0.all (fun c => !PRE_setup_h3_chunk.ws0.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_setup_h3_chunk.cthetaZ0 : Nat → SymE := Conv.compactθZ PRE_setup_h3_chunk.cws0 PRE_setup_h3_chunk.crs0 PRE_setup_h3_chunk.ws0

end Host.Load.Run.Tpl
