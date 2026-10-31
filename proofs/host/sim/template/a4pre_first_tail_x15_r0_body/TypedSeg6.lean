import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK21
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg6 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 21).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 22).getD 0)) PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.S21 = some (PRE_first_tail_x15_r0_body.s23, PRE_first_tail_x15_r0_body.S23) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 21).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 22).getD 0) PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.s22 PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.S21 PRE_first_tail_x15_r0_body.S22 PRE_first_tail_x15_r0_body.S23 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK21 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK22 bytes) rows)
end Host.Load.Run.Tpl
