import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK559
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK560
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg151 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 559).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 560).getD 0)) PRE_first_tail_x15_r0_body.s559 PRE_first_tail_x15_r0_body.S559 = some (PRE_first_tail_x15_r0_body.s561, PRE_first_tail_x15_r0_body.S561) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 559).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 560).getD 0) PRE_first_tail_x15_r0_body.s559 PRE_first_tail_x15_r0_body.s560 PRE_first_tail_x15_r0_body.s561 PRE_first_tail_x15_r0_body.S559 PRE_first_tail_x15_r0_body.S560 PRE_first_tail_x15_r0_body.S561 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK559 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK560 bytes) rows)
end Host.Load.Run.Tpl
