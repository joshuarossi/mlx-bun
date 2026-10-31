import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H19
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK625
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK626
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg169 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 625).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 626).getD 0)) PRE_first_tail_x15_r0_body.s625 PRE_first_tail_x15_r0_body.S625 = some (PRE_first_tail_x15_r0_body.s627, PRE_first_tail_x15_r0_body.S627) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 625).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 626).getD 0) PRE_first_tail_x15_r0_body.s625 PRE_first_tail_x15_r0_body.s626 PRE_first_tail_x15_r0_body.s627 PRE_first_tail_x15_r0_body.S625 PRE_first_tail_x15_r0_body.S626 PRE_first_tail_x15_r0_body.S627 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK625 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK626 bytes) rows)
end Host.Load.Run.Tpl
