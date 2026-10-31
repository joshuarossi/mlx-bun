import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1229
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1230
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg332 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1229).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1230).getD 0)) PRE_first_tail_x15_r0_body.s1229 PRE_first_tail_x15_r0_body.S1229 = some (PRE_first_tail_x15_r0_body.s1231, PRE_first_tail_x15_r0_body.S1231) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1229).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1230).getD 0) PRE_first_tail_x15_r0_body.s1229 PRE_first_tail_x15_r0_body.s1230 PRE_first_tail_x15_r0_body.s1231 PRE_first_tail_x15_r0_body.S1229 PRE_first_tail_x15_r0_body.S1230 PRE_first_tail_x15_r0_body.S1231 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1229 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1230 bytes) rows)
end Host.Load.Run.Tpl
