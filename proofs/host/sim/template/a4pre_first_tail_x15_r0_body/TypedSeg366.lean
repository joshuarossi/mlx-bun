import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1357
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1358
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg366 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1357).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1358).getD 0)) PRE_first_tail_x15_r0_body.s1357 PRE_first_tail_x15_r0_body.S1357 = some (PRE_first_tail_x15_r0_body.s1359, PRE_first_tail_x15_r0_body.S1359) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1357).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1358).getD 0) PRE_first_tail_x15_r0_body.s1357 PRE_first_tail_x15_r0_body.s1358 PRE_first_tail_x15_r0_body.s1359 PRE_first_tail_x15_r0_body.S1357 PRE_first_tail_x15_r0_body.S1358 PRE_first_tail_x15_r0_body.S1359 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1357 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1358 bytes) rows)
end Host.Load.Run.Tpl
