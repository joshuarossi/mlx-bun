import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H55
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1784
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1785
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg481 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1784).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1785).getD 0)) PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.S1784 = some (PRE_first_tail_x15_r0_body.s1786, PRE_first_tail_x15_r0_body.S1786) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1784).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1785).getD 0) PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.s1785 PRE_first_tail_x15_r0_body.s1786 PRE_first_tail_x15_r0_body.S1784 PRE_first_tail_x15_r0_body.S1785 PRE_first_tail_x15_r0_body.S1786 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1784 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1785 bytes) rows)
end Host.Load.Run.Tpl
