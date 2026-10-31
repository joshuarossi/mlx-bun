import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK337
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK338
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg91 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 337).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 338).getD 0)) PRE_first_tail_x15_r0_body.s337 PRE_first_tail_x15_r0_body.S337 = some (PRE_first_tail_x15_r0_body.s339, PRE_first_tail_x15_r0_body.S339) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 337).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 338).getD 0) PRE_first_tail_x15_r0_body.s337 PRE_first_tail_x15_r0_body.s338 PRE_first_tail_x15_r0_body.s339 PRE_first_tail_x15_r0_body.S337 PRE_first_tail_x15_r0_body.S338 PRE_first_tail_x15_r0_body.S339 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK337 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK338 bytes) rows)
end Host.Load.Run.Tpl
