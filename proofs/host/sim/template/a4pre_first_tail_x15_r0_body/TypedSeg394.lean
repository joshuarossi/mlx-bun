import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1459
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1460
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg394 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1459).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1460).getD 0)) PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.S1459 = some (PRE_first_tail_x15_r0_body.s1461, PRE_first_tail_x15_r0_body.S1461) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1459).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1460).getD 0) PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.s1460 PRE_first_tail_x15_r0_body.s1461 PRE_first_tail_x15_r0_body.S1459 PRE_first_tail_x15_r0_body.S1460 PRE_first_tail_x15_r0_body.S1461 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1459 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1460 bytes) rows)
end Host.Load.Run.Tpl
