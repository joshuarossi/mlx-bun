import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1127
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1128
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg304 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1127).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1128).getD 0)) PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.S1127 = some (PRE_first_tail_x15_r0_body.s1129, PRE_first_tail_x15_r0_body.S1129) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1127).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1128).getD 0) PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.s1128 PRE_first_tail_x15_r0_body.s1129 PRE_first_tail_x15_r0_body.S1127 PRE_first_tail_x15_r0_body.S1128 PRE_first_tail_x15_r0_body.S1129 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1127 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1128 bytes) rows)
end Host.Load.Run.Tpl
