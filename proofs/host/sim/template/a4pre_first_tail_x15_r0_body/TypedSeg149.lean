import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK552
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK553
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg149 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 552).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 553).getD 0)) PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.S552 = some (PRE_first_tail_x15_r0_body.s554, PRE_first_tail_x15_r0_body.S554) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 552).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 553).getD 0) PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.s553 PRE_first_tail_x15_r0_body.s554 PRE_first_tail_x15_r0_body.S552 PRE_first_tail_x15_r0_body.S553 PRE_first_tail_x15_r0_body.S554 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK552 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK553 bytes) rows)
end Host.Load.Run.Tpl
