import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK136
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK137
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg37 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 136).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 137).getD 0)) PRE_first_tail_x15_r0_body.s136 PRE_first_tail_x15_r0_body.S136 = some (PRE_first_tail_x15_r0_body.s138, PRE_first_tail_x15_r0_body.S138) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 136).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 137).getD 0) PRE_first_tail_x15_r0_body.s136 PRE_first_tail_x15_r0_body.s137 PRE_first_tail_x15_r0_body.s138 PRE_first_tail_x15_r0_body.S136 PRE_first_tail_x15_r0_body.S137 PRE_first_tail_x15_r0_body.S138 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK136 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK137 bytes) rows)
end Host.Load.Run.Tpl
