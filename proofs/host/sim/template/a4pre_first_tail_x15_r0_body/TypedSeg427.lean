import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1583
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1584
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg427 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1583).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1584).getD 0)) PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.S1583 = some (PRE_first_tail_x15_r0_body.s1585, PRE_first_tail_x15_r0_body.S1585) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1583).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1584).getD 0) PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.s1584 PRE_first_tail_x15_r0_body.s1585 PRE_first_tail_x15_r0_body.S1583 PRE_first_tail_x15_r0_body.S1584 PRE_first_tail_x15_r0_body.S1585 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1583 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1584 bytes) rows)
end Host.Load.Run.Tpl
