import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1496
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1497
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg403 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1496).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1497).getD 0)) PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.S1496 = some (PRE_first_tail_x15_r0_body.s1498, PRE_first_tail_x15_r0_body.S1498) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1496).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1497).getD 0) PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.s1497 PRE_first_tail_x15_r0_body.s1498 PRE_first_tail_x15_r0_body.S1496 PRE_first_tail_x15_r0_body.S1497 PRE_first_tail_x15_r0_body.S1498 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1496 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1497 bytes) rows)
end Host.Load.Run.Tpl
