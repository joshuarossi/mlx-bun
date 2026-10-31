import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H55
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1775
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1776
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg479 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1775).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1776).getD 0)) PRE_first_tail_x15_r0_body.s1775 PRE_first_tail_x15_r0_body.S1775 = some (PRE_first_tail_x15_r0_body.s1777, PRE_first_tail_x15_r0_body.S1777) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1775).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1776).getD 0) PRE_first_tail_x15_r0_body.s1775 PRE_first_tail_x15_r0_body.s1776 PRE_first_tail_x15_r0_body.s1777 PRE_first_tail_x15_r0_body.S1775 PRE_first_tail_x15_r0_body.S1776 PRE_first_tail_x15_r0_body.S1777 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1775 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1776 bytes) rows)
end Host.Load.Run.Tpl
