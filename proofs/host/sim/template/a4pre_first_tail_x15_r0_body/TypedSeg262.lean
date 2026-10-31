import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK970
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK971
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg262 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 970).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 971).getD 0)) PRE_first_tail_x15_r0_body.s970 PRE_first_tail_x15_r0_body.S970 = some (PRE_first_tail_x15_r0_body.s972, PRE_first_tail_x15_r0_body.S972) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 970).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 971).getD 0) PRE_first_tail_x15_r0_body.s970 PRE_first_tail_x15_r0_body.s971 PRE_first_tail_x15_r0_body.s972 PRE_first_tail_x15_r0_body.S970 PRE_first_tail_x15_r0_body.S971 PRE_first_tail_x15_r0_body.S972 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK970 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK971 bytes) rows)
end Host.Load.Run.Tpl
