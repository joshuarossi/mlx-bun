import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1574
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1575
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg425 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1574).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1575).getD 0)) PRE_first_tail_x15_r0_body.s1574 PRE_first_tail_x15_r0_body.S1574 = some (PRE_first_tail_x15_r0_body.s1576, PRE_first_tail_x15_r0_body.S1576) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1574).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1575).getD 0) PRE_first_tail_x15_r0_body.s1574 PRE_first_tail_x15_r0_body.s1575 PRE_first_tail_x15_r0_body.s1576 PRE_first_tail_x15_r0_body.S1574 PRE_first_tail_x15_r0_body.S1575 PRE_first_tail_x15_r0_body.S1576 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1574 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1575 bytes) rows)
end Host.Load.Run.Tpl
