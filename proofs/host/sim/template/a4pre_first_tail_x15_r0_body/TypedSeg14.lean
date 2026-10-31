import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK50
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK51
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg14 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 50).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 51).getD 0)) PRE_first_tail_x15_r0_body.s50 PRE_first_tail_x15_r0_body.S50 = some (PRE_first_tail_x15_r0_body.s52, PRE_first_tail_x15_r0_body.S52) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 50).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 51).getD 0) PRE_first_tail_x15_r0_body.s50 PRE_first_tail_x15_r0_body.s51 PRE_first_tail_x15_r0_body.s52 PRE_first_tail_x15_r0_body.S50 PRE_first_tail_x15_r0_body.S51 PRE_first_tail_x15_r0_body.S52 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK50 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK51 bytes) rows)
end Host.Load.Run.Tpl
