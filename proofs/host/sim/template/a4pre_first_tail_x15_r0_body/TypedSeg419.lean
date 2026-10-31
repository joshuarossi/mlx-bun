import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1554
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1555
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg419 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1554).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1555).getD 0)) PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.S1554 = some (PRE_first_tail_x15_r0_body.s1556, PRE_first_tail_x15_r0_body.S1556) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1554).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1555).getD 0) PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.s1555 PRE_first_tail_x15_r0_body.s1556 PRE_first_tail_x15_r0_body.S1554 PRE_first_tail_x15_r0_body.S1555 PRE_first_tail_x15_r0_body.S1556 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1554 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1555 bytes) rows)
end Host.Load.Run.Tpl
