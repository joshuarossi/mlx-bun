import host.sim.template.a4pre_first_tail_x15_r0_body.Site174
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC174
import host.sim.conv.CallPieces
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 174 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived174 : PRE_first_tail_x15_r0_body.nr174.map (fun r => nth? PRE_first_tail_x15_r0_body.st174.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo174 : PRE_first_tail_x15_r0_body.nr174.all (Nat.ble 7523) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj174 : PRE_first_tail_x15_r0_body.cws174.all (fun c => !PRE_first_tail_x15_r0_body.ws174.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ174 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws174 PRE_first_tail_x15_r0_body.crs174 PRE_first_tail_x15_r0_body.ws174

end Host.Load.Run.Tpl
