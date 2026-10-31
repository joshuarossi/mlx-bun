import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK165
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK166
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg45 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 165).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 166).getD 0)) PRE_first_tail_x15_r0_body.s165 PRE_first_tail_x15_r0_body.S165 = some (PRE_first_tail_x15_r0_body.s167, PRE_first_tail_x15_r0_body.S167) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 165).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 166).getD 0) PRE_first_tail_x15_r0_body.s165 PRE_first_tail_x15_r0_body.s166 PRE_first_tail_x15_r0_body.s167 PRE_first_tail_x15_r0_body.S165 PRE_first_tail_x15_r0_body.S166 PRE_first_tail_x15_r0_body.S167 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK165 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK166 bytes) rows)
end Host.Load.Run.Tpl
