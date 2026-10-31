import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK682
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK683
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg184 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 682).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 683).getD 0)) PRE_first_tail_x15_r0_body.s682 PRE_first_tail_x15_r0_body.S682 = some (PRE_first_tail_x15_r0_body.s684, PRE_first_tail_x15_r0_body.S684) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 682).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 683).getD 0) PRE_first_tail_x15_r0_body.s682 PRE_first_tail_x15_r0_body.s683 PRE_first_tail_x15_r0_body.s684 PRE_first_tail_x15_r0_body.S682 PRE_first_tail_x15_r0_body.S683 PRE_first_tail_x15_r0_body.S684 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK682 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK683 bytes) rows)
end Host.Load.Run.Tpl
