import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK433
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK434
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg117 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 433).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 434).getD 0)) PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.S433 = some (PRE_first_tail_x15_r0_body.s435, PRE_first_tail_x15_r0_body.S435) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 433).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 434).getD 0) PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.s434 PRE_first_tail_x15_r0_body.s435 PRE_first_tail_x15_r0_body.S433 PRE_first_tail_x15_r0_body.S434 PRE_first_tail_x15_r0_body.S435 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK433 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK434 bytes) rows)
end Host.Load.Run.Tpl
