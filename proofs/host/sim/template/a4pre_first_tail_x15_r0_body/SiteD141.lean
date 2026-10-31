import host.sim.template.a4pre_first_tail_x15_r0_body.Site141
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC141
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 141 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived141 : PRE_first_tail_x15_r0_body.nr141.map (fun r => nth? PRE_first_tail_x15_r0_body.st141.S2.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo141 : PRE_first_tail_x15_r0_body.nr141.all (Nat.ble 6117) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj141 : PRE_first_tail_x15_r0_body.cws141.all (fun c => !PRE_first_tail_x15_r0_body.ws141.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ141 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws141 PRE_first_tail_x15_r0_body.crs141 PRE_first_tail_x15_r0_body.ws141

end Host.Load.Run.Tpl
