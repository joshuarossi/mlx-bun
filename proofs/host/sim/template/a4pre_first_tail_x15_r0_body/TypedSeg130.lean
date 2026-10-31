import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK481
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK482
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg130 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 481).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 482).getD 0)) PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.S481 = some (PRE_first_tail_x15_r0_body.s483, PRE_first_tail_x15_r0_body.S483) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 481).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 482).getD 0) PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.s482 PRE_first_tail_x15_r0_body.s483 PRE_first_tail_x15_r0_body.S481 PRE_first_tail_x15_r0_body.S482 PRE_first_tail_x15_r0_body.S483 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK481 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK482 bytes) rows)
end Host.Load.Run.Tpl
