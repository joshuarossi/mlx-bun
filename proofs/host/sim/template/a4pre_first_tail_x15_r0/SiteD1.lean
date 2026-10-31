import host.sim.template.a4pre_first_tail_x15_r0.Site1
import host.sim.template.a4pre_first_tail_x15_r0.SiteC1
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 1 of chain `PRE_first_tail_x15_r0`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0.cderived1 : PRE_first_tail_x15_r0.nr1.map (fun r => nth? PRE_first_tail_x15_r0.st1.S2.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0)))))]
kernel_rfl PRE_first_tail_x15_r0.cnrLo1 : PRE_first_tail_x15_r0.nr1.all (Nat.ble 14) = true
kernel_rfl PRE_first_tail_x15_r0.cwsDisj1 : PRE_first_tail_x15_r0.cws1.all (fun c => !PRE_first_tail_x15_r0.ws1.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0.cthetaZ1 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0.cws1 PRE_first_tail_x15_r0.crs1 PRE_first_tail_x15_r0.ws1

end Host.Load.Run.Tpl
