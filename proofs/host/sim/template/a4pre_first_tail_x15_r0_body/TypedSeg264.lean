import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK979
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK980
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg264 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 979).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 980).getD 0)) PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.S979 = some (PRE_first_tail_x15_r0_body.s981, PRE_first_tail_x15_r0_body.S981) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 979).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 980).getD 0) PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.s980 PRE_first_tail_x15_r0_body.s981 PRE_first_tail_x15_r0_body.S979 PRE_first_tail_x15_r0_body.S980 PRE_first_tail_x15_r0_body.S981 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK979 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK980 bytes) rows)
end Host.Load.Run.Tpl
