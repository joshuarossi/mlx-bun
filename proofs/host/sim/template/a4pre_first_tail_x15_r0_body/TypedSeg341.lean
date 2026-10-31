import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1266
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1267
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg341 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1266).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1267).getD 0)) PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.S1266 = some (PRE_first_tail_x15_r0_body.s1268, PRE_first_tail_x15_r0_body.S1268) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1266).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1267).getD 0) PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.s1267 PRE_first_tail_x15_r0_body.s1268 PRE_first_tail_x15_r0_body.S1266 PRE_first_tail_x15_r0_body.S1267 PRE_first_tail_x15_r0_body.S1268 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1266 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1267 bytes) rows)
end Host.Load.Run.Tpl
