import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1114
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1115
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg301 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1114).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1115).getD 0)) PRE_first_tail_x15_r0_body.s1114 PRE_first_tail_x15_r0_body.S1114 = some (PRE_first_tail_x15_r0_body.s1116, PRE_first_tail_x15_r0_body.S1116) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1114).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1115).getD 0) PRE_first_tail_x15_r0_body.s1114 PRE_first_tail_x15_r0_body.s1115 PRE_first_tail_x15_r0_body.s1116 PRE_first_tail_x15_r0_body.S1114 PRE_first_tail_x15_r0_body.S1115 PRE_first_tail_x15_r0_body.S1116 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1114 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1115 bytes) rows)
end Host.Load.Run.Tpl
