import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK904
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK905
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg244 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 904).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 905).getD 0)) PRE_first_tail_x15_r0_body.s904 PRE_first_tail_x15_r0_body.S904 = some (PRE_first_tail_x15_r0_body.s906, PRE_first_tail_x15_r0_body.S906) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 904).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 905).getD 0) PRE_first_tail_x15_r0_body.s904 PRE_first_tail_x15_r0_body.s905 PRE_first_tail_x15_r0_body.s906 PRE_first_tail_x15_r0_body.S904 PRE_first_tail_x15_r0_body.S905 PRE_first_tail_x15_r0_body.S906 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK904 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK905 bytes) rows)
end Host.Load.Run.Tpl
