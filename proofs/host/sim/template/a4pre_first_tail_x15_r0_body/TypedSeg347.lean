import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1286
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1287
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg347 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1286).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1287).getD 0)) PRE_first_tail_x15_r0_body.s1286 PRE_first_tail_x15_r0_body.S1286 = some (PRE_first_tail_x15_r0_body.s1288, PRE_first_tail_x15_r0_body.S1288) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1286).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1287).getD 0) PRE_first_tail_x15_r0_body.s1286 PRE_first_tail_x15_r0_body.s1287 PRE_first_tail_x15_r0_body.s1288 PRE_first_tail_x15_r0_body.S1286 PRE_first_tail_x15_r0_body.S1287 PRE_first_tail_x15_r0_body.S1288 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1286 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1287 bytes) rows)
end Host.Load.Run.Tpl
