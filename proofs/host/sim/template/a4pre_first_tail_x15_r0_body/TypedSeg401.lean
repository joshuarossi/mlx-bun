import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1487
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1488
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg401 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1487).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1488).getD 0)) PRE_first_tail_x15_r0_body.s1487 PRE_first_tail_x15_r0_body.S1487 = some (PRE_first_tail_x15_r0_body.s1489, PRE_first_tail_x15_r0_body.S1489) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1487).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1488).getD 0) PRE_first_tail_x15_r0_body.s1487 PRE_first_tail_x15_r0_body.s1488 PRE_first_tail_x15_r0_body.s1489 PRE_first_tail_x15_r0_body.S1487 PRE_first_tail_x15_r0_body.S1488 PRE_first_tail_x15_r0_body.S1489 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1487 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1488 bytes) rows)
end Host.Load.Run.Tpl
