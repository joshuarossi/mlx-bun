import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK289
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK290
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg78 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 289).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 290).getD 0)) PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.S289 = some (PRE_first_tail_x15_r0_body.s291, PRE_first_tail_x15_r0_body.S291) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 289).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 290).getD 0) PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.s290 PRE_first_tail_x15_r0_body.s291 PRE_first_tail_x15_r0_body.S289 PRE_first_tail_x15_r0_body.S290 PRE_first_tail_x15_r0_body.S291 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK289 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK290 bytes) rows)
end Host.Load.Run.Tpl
