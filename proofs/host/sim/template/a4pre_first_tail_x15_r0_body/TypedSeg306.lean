import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1134
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1135
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg306 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1134).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1135).getD 0)) PRE_first_tail_x15_r0_body.s1134 PRE_first_tail_x15_r0_body.S1134 = some (PRE_first_tail_x15_r0_body.s1136, PRE_first_tail_x15_r0_body.S1136) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1134).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1135).getD 0) PRE_first_tail_x15_r0_body.s1134 PRE_first_tail_x15_r0_body.s1135 PRE_first_tail_x15_r0_body.s1136 PRE_first_tail_x15_r0_body.S1134 PRE_first_tail_x15_r0_body.S1135 PRE_first_tail_x15_r0_body.S1136 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1134 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1135 bytes) rows)
end Host.Load.Run.Tpl
