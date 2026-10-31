import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1804
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1805
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg487 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1804).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1805).getD 0)) PRE_first_tail_x15_r0_body.s1804 PRE_first_tail_x15_r0_body.S1804 = some (PRE_first_tail_x15_r0_body.s1806, PRE_first_tail_x15_r0_body.S1806) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1804).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1805).getD 0) PRE_first_tail_x15_r0_body.s1804 PRE_first_tail_x15_r0_body.s1805 PRE_first_tail_x15_r0_body.s1806 PRE_first_tail_x15_r0_body.S1804 PRE_first_tail_x15_r0_body.S1805 PRE_first_tail_x15_r0_body.S1806 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1804 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1805 bytes) rows)
end Host.Load.Run.Tpl
