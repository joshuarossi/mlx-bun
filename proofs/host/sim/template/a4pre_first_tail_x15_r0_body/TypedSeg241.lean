import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK893
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK894
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg241 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 893).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 894).getD 0)) PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.S893 = some (PRE_first_tail_x15_r0_body.s895, PRE_first_tail_x15_r0_body.S895) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 893).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 894).getD 0) PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.s895 PRE_first_tail_x15_r0_body.S893 PRE_first_tail_x15_r0_body.S894 PRE_first_tail_x15_r0_body.S895 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK893 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK894 bytes) rows)
end Host.Load.Run.Tpl
