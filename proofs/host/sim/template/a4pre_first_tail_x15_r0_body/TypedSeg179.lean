import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK663
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK664
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg179 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 663).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 664).getD 0)) PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.S663 = some (PRE_first_tail_x15_r0_body.s665, PRE_first_tail_x15_r0_body.S665) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 663).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 664).getD 0) PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.s664 PRE_first_tail_x15_r0_body.s665 PRE_first_tail_x15_r0_body.S663 PRE_first_tail_x15_r0_body.S664 PRE_first_tail_x15_r0_body.S665 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK663 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK664 bytes) rows)
end Host.Load.Run.Tpl
