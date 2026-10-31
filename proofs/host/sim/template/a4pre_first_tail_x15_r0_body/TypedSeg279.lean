import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1036
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1037
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg279 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1036).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1037).getD 0)) PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.S1036 = some (PRE_first_tail_x15_r0_body.s1038, PRE_first_tail_x15_r0_body.S1038) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1036).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1037).getD 0) PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.s1037 PRE_first_tail_x15_r0_body.s1038 PRE_first_tail_x15_r0_body.S1036 PRE_first_tail_x15_r0_body.S1037 PRE_first_tail_x15_r0_body.S1038 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1036 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1037 bytes) rows)
end Host.Load.Run.Tpl
