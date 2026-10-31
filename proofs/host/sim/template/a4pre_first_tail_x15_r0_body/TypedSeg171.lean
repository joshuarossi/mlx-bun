import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H19
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK634
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK635
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg171 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 634).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 635).getD 0)) PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.S634 = some (PRE_first_tail_x15_r0_body.s636, PRE_first_tail_x15_r0_body.S636) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 634).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 635).getD 0) PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.s635 PRE_first_tail_x15_r0_body.s636 PRE_first_tail_x15_r0_body.S634 PRE_first_tail_x15_r0_body.S635 PRE_first_tail_x15_r0_body.S636 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK634 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK635 bytes) rows)
end Host.Load.Run.Tpl
