import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H54
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1755
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1756
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg473 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1755).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1756).getD 0)) PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.S1755 = some (PRE_first_tail_x15_r0_body.s1757, PRE_first_tail_x15_r0_body.S1757) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1755).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1756).getD 0) PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.s1756 PRE_first_tail_x15_r0_body.s1757 PRE_first_tail_x15_r0_body.S1755 PRE_first_tail_x15_r0_body.S1756 PRE_first_tail_x15_r0_body.S1757 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1755 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1756 bytes) rows)
end Host.Load.Run.Tpl
