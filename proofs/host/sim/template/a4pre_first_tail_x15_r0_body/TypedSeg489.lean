import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1813
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1814
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg489 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1813).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1814).getD 0)) PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.S1813 = some (PRE_first_tail_x15_r0_body.s1815, PRE_first_tail_x15_r0_body.S1815) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1813).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1814).getD 0) PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.s1814 PRE_first_tail_x15_r0_body.s1815 PRE_first_tail_x15_r0_body.S1813 PRE_first_tail_x15_r0_body.S1814 PRE_first_tail_x15_r0_body.S1815 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1813 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1814 bytes) rows)
end Host.Load.Run.Tpl
