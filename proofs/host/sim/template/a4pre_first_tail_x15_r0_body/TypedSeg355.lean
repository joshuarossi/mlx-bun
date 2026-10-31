import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1315
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1316
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg355 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1315).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1316).getD 0)) PRE_first_tail_x15_r0_body.s1315 PRE_first_tail_x15_r0_body.S1315 = some (PRE_first_tail_x15_r0_body.s1317, PRE_first_tail_x15_r0_body.S1317) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1315).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1316).getD 0) PRE_first_tail_x15_r0_body.s1315 PRE_first_tail_x15_r0_body.s1316 PRE_first_tail_x15_r0_body.s1317 PRE_first_tail_x15_r0_body.S1315 PRE_first_tail_x15_r0_body.S1316 PRE_first_tail_x15_r0_body.S1317 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1315 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1316 bytes) rows)
end Host.Load.Run.Tpl
