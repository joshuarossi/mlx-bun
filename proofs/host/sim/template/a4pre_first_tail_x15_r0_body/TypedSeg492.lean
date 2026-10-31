import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H57
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1824
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1825
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg492 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1824).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1825).getD 0)) PRE_first_tail_x15_r0_body.s1824 PRE_first_tail_x15_r0_body.S1824 = some (PRE_first_tail_x15_r0_body.s1826, PRE_first_tail_x15_r0_body.S1826) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1824).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1825).getD 0) PRE_first_tail_x15_r0_body.s1824 PRE_first_tail_x15_r0_body.s1825 PRE_first_tail_x15_r0_body.s1826 PRE_first_tail_x15_r0_body.S1824 PRE_first_tail_x15_r0_body.S1825 PRE_first_tail_x15_r0_body.S1826 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1824 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1825 bytes) rows)
end Host.Load.Run.Tpl
