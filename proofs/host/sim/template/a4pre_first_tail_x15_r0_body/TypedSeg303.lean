import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1123
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1124
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg303 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1123).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1124).getD 0)) PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.S1123 = some (PRE_first_tail_x15_r0_body.s1125, PRE_first_tail_x15_r0_body.S1125) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1123).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1124).getD 0) PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.s1124 PRE_first_tail_x15_r0_body.s1125 PRE_first_tail_x15_r0_body.S1123 PRE_first_tail_x15_r0_body.S1124 PRE_first_tail_x15_r0_body.S1125 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1123 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1124 bytes) rows)
end Host.Load.Run.Tpl
