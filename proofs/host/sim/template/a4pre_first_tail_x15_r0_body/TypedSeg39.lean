import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK145
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK146
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg39 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 145).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 146).getD 0)) PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.S145 = some (PRE_first_tail_x15_r0_body.s147, PRE_first_tail_x15_r0_body.S147) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 145).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 146).getD 0) PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.s146 PRE_first_tail_x15_r0_body.s147 PRE_first_tail_x15_r0_body.S145 PRE_first_tail_x15_r0_body.S146 PRE_first_tail_x15_r0_body.S147 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK145 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK146 bytes) rows)
end Host.Load.Run.Tpl
