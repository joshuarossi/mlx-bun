import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1019
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1020
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg275 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1019).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1020).getD 0)) PRE_first_tail_x15_r0_body.s1019 PRE_first_tail_x15_r0_body.S1019 = some (PRE_first_tail_x15_r0_body.s1021, PRE_first_tail_x15_r0_body.S1021) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1019).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1020).getD 0) PRE_first_tail_x15_r0_body.s1019 PRE_first_tail_x15_r0_body.s1020 PRE_first_tail_x15_r0_body.s1021 PRE_first_tail_x15_r0_body.S1019 PRE_first_tail_x15_r0_body.S1020 PRE_first_tail_x15_r0_body.S1021 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1019 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1020 bytes) rows)
end Host.Load.Run.Tpl
