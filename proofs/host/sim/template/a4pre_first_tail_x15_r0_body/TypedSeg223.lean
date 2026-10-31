import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK826
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK827
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg223 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 826).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 827).getD 0)) PRE_first_tail_x15_r0_body.s826 PRE_first_tail_x15_r0_body.S826 = some (PRE_first_tail_x15_r0_body.s828, PRE_first_tail_x15_r0_body.S828) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 826).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 827).getD 0) PRE_first_tail_x15_r0_body.s826 PRE_first_tail_x15_r0_body.s827 PRE_first_tail_x15_r0_body.s828 PRE_first_tail_x15_r0_body.S826 PRE_first_tail_x15_r0_body.S827 PRE_first_tail_x15_r0_body.S828 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK826 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK827 bytes) rows)
end Host.Load.Run.Tpl
