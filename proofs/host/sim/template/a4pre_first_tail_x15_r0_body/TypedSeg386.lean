import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1430
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1431
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg386 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1430).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1431).getD 0)) PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.S1430 = some (PRE_first_tail_x15_r0_body.s1432, PRE_first_tail_x15_r0_body.S1432) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1430).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1431).getD 0) PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.s1431 PRE_first_tail_x15_r0_body.s1432 PRE_first_tail_x15_r0_body.S1430 PRE_first_tail_x15_r0_body.S1431 PRE_first_tail_x15_r0_body.S1432 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1430 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1431 bytes) rows)
end Host.Load.Run.Tpl
