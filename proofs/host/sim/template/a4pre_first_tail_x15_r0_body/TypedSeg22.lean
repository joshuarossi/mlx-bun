import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK79
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK80
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg22 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 79).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 80).getD 0)) PRE_first_tail_x15_r0_body.s79 PRE_first_tail_x15_r0_body.S79 = some (PRE_first_tail_x15_r0_body.s81, PRE_first_tail_x15_r0_body.S81) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 79).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 80).getD 0) PRE_first_tail_x15_r0_body.s79 PRE_first_tail_x15_r0_body.s80 PRE_first_tail_x15_r0_body.s81 PRE_first_tail_x15_r0_body.S79 PRE_first_tail_x15_r0_body.S80 PRE_first_tail_x15_r0_body.S81 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK79 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK80 bytes) rows)
end Host.Load.Run.Tpl
