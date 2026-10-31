import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1027
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1028
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg277 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1027).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1028).getD 0)) PRE_first_tail_x15_r0_body.s1027 PRE_first_tail_x15_r0_body.S1027 = some (PRE_first_tail_x15_r0_body.s1029, PRE_first_tail_x15_r0_body.S1029) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1027).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1028).getD 0) PRE_first_tail_x15_r0_body.s1027 PRE_first_tail_x15_r0_body.s1028 PRE_first_tail_x15_r0_body.s1029 PRE_first_tail_x15_r0_body.S1027 PRE_first_tail_x15_r0_body.S1028 PRE_first_tail_x15_r0_body.S1029 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1027 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1028 bytes) rows)
end Host.Load.Run.Tpl
