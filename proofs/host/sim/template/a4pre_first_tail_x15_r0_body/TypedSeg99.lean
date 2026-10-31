import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK366
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK367
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg99 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 366).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 367).getD 0)) PRE_first_tail_x15_r0_body.s366 PRE_first_tail_x15_r0_body.S366 = some (PRE_first_tail_x15_r0_body.s368, PRE_first_tail_x15_r0_body.S368) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 366).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 367).getD 0) PRE_first_tail_x15_r0_body.s366 PRE_first_tail_x15_r0_body.s367 PRE_first_tail_x15_r0_body.s368 PRE_first_tail_x15_r0_body.S366 PRE_first_tail_x15_r0_body.S367 PRE_first_tail_x15_r0_body.S368 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK366 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK367 bytes) rows)
end Host.Load.Run.Tpl
