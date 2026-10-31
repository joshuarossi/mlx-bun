import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK329
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK330
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg89 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 329).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 330).getD 0)) PRE_first_tail_x15_r0_body.s329 PRE_first_tail_x15_r0_body.S329 = some (PRE_first_tail_x15_r0_body.s331, PRE_first_tail_x15_r0_body.S331) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 329).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 330).getD 0) PRE_first_tail_x15_r0_body.s329 PRE_first_tail_x15_r0_body.s330 PRE_first_tail_x15_r0_body.s331 PRE_first_tail_x15_r0_body.S329 PRE_first_tail_x15_r0_body.S330 PRE_first_tail_x15_r0_body.S331 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK329 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK330 bytes) rows)
end Host.Load.Run.Tpl
