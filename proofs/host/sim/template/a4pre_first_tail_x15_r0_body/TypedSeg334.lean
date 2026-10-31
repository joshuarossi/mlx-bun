import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1238
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1239
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg334 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1238).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1239).getD 0)) PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.S1238 = some (PRE_first_tail_x15_r0_body.s1240, PRE_first_tail_x15_r0_body.S1240) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1238).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1239).getD 0) PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.s1239 PRE_first_tail_x15_r0_body.s1240 PRE_first_tail_x15_r0_body.S1238 PRE_first_tail_x15_r0_body.S1239 PRE_first_tail_x15_r0_body.S1240 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1238 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1239 bytes) rows)
end Host.Load.Run.Tpl
