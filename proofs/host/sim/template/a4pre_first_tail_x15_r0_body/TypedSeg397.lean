import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1472
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1473
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg397 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1472).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1473).getD 0)) PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.S1472 = some (PRE_first_tail_x15_r0_body.s1474, PRE_first_tail_x15_r0_body.S1474) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1472).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1473).getD 0) PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.s1473 PRE_first_tail_x15_r0_body.s1474 PRE_first_tail_x15_r0_body.S1472 PRE_first_tail_x15_r0_body.S1473 PRE_first_tail_x15_r0_body.S1474 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1472 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1473 bytes) rows)
end Host.Load.Run.Tpl
