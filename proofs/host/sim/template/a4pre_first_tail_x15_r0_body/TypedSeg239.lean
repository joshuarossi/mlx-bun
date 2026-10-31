import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK884
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK885
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg239 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 884).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 885).getD 0)) PRE_first_tail_x15_r0_body.s884 PRE_first_tail_x15_r0_body.S884 = some (PRE_first_tail_x15_r0_body.s886, PRE_first_tail_x15_r0_body.S886) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 884).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 885).getD 0) PRE_first_tail_x15_r0_body.s884 PRE_first_tail_x15_r0_body.s885 PRE_first_tail_x15_r0_body.s886 PRE_first_tail_x15_r0_body.S884 PRE_first_tail_x15_r0_body.S885 PRE_first_tail_x15_r0_body.S886 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK884 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK885 bytes) rows)
end Host.Load.Run.Tpl
