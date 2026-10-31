import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK674
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK675
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg182 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 674).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 675).getD 0)) PRE_first_tail_x15_r0_body.s674 PRE_first_tail_x15_r0_body.S674 = some (PRE_first_tail_x15_r0_body.s676, PRE_first_tail_x15_r0_body.S676) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 674).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 675).getD 0) PRE_first_tail_x15_r0_body.s674 PRE_first_tail_x15_r0_body.s675 PRE_first_tail_x15_r0_body.s676 PRE_first_tail_x15_r0_body.S674 PRE_first_tail_x15_r0_body.S675 PRE_first_tail_x15_r0_body.S676 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK674 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK675 bytes) rows)
end Host.Load.Run.Tpl
