import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1171
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1172
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg316 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1171).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1172).getD 0)) PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.S1171 = some (PRE_first_tail_x15_r0_body.s1173, PRE_first_tail_x15_r0_body.S1173) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1171).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1172).getD 0) PRE_first_tail_x15_r0_body.s1171 PRE_first_tail_x15_r0_body.s1172 PRE_first_tail_x15_r0_body.s1173 PRE_first_tail_x15_r0_body.S1171 PRE_first_tail_x15_r0_body.S1172 PRE_first_tail_x15_r0_body.S1173 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1171 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1172 bytes) rows)
end Host.Load.Run.Tpl
