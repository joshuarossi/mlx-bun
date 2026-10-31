import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK222
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK223
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg60 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 222).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 223).getD 0)) PRE_first_tail_x15_r0_body.s222 PRE_first_tail_x15_r0_body.S222 = some (PRE_first_tail_x15_r0_body.s224, PRE_first_tail_x15_r0_body.S224) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 222).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 223).getD 0) PRE_first_tail_x15_r0_body.s222 PRE_first_tail_x15_r0_body.s223 PRE_first_tail_x15_r0_body.s224 PRE_first_tail_x15_r0_body.S222 PRE_first_tail_x15_r0_body.S223 PRE_first_tail_x15_r0_body.S224 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK222 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK223 bytes) rows)
end Host.Load.Run.Tpl
