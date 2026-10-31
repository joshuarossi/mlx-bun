import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK596
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK597
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg161 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 596).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 597).getD 0)) PRE_first_tail_x15_r0_body.s596 PRE_first_tail_x15_r0_body.S596 = some (PRE_first_tail_x15_r0_body.s598, PRE_first_tail_x15_r0_body.S598) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 596).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 597).getD 0) PRE_first_tail_x15_r0_body.s596 PRE_first_tail_x15_r0_body.s597 PRE_first_tail_x15_r0_body.s598 PRE_first_tail_x15_r0_body.S596 PRE_first_tail_x15_r0_body.S597 PRE_first_tail_x15_r0_body.S598 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK596 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK597 bytes) rows)
end Host.Load.Run.Tpl
