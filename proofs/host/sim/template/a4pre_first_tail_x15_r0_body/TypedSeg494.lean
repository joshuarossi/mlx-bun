import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H57
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1832
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1833
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg494 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1832).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1833).getD 0)) PRE_first_tail_x15_r0_body.s1832 PRE_first_tail_x15_r0_body.S1832 = some (PRE_first_tail_x15_r0_body.s1834, PRE_first_tail_x15_r0_body.S1834) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1832).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1833).getD 0) PRE_first_tail_x15_r0_body.s1832 PRE_first_tail_x15_r0_body.s1833 PRE_first_tail_x15_r0_body.s1834 PRE_first_tail_x15_r0_body.S1832 PRE_first_tail_x15_r0_body.S1833 PRE_first_tail_x15_r0_body.S1834 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1832 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1833 bytes) rows)
end Host.Load.Run.Tpl
