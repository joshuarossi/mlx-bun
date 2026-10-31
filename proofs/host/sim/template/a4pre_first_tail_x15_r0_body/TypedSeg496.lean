import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H57
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1841
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1842
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg496 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1841).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1842).getD 0)) PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.S1841 = some (PRE_first_tail_x15_r0_body.s1843, PRE_first_tail_x15_r0_body.S1843) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1841).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1842).getD 0) PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.s1842 PRE_first_tail_x15_r0_body.s1843 PRE_first_tail_x15_r0_body.S1841 PRE_first_tail_x15_r0_body.S1842 PRE_first_tail_x15_r0_body.S1843 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1841 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1842 bytes) rows)
end Host.Load.Run.Tpl
