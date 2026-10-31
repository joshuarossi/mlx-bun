import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK539
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK540
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg146 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 539).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 540).getD 0)) PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.S539 = some (PRE_first_tail_x15_r0_body.s541, PRE_first_tail_x15_r0_body.S541) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 539).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 540).getD 0) PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.s540 PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.S539 PRE_first_tail_x15_r0_body.S540 PRE_first_tail_x15_r0_body.S541 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK539 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK540 bytes) rows)
end Host.Load.Run.Tpl
