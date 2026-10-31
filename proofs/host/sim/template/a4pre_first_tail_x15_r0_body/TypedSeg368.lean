import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1364
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1365
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg368 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1364).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1365).getD 0)) PRE_first_tail_x15_r0_body.s1364 PRE_first_tail_x15_r0_body.S1364 = some (PRE_first_tail_x15_r0_body.s1366, PRE_first_tail_x15_r0_body.S1366) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1364).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1365).getD 0) PRE_first_tail_x15_r0_body.s1364 PRE_first_tail_x15_r0_body.s1365 PRE_first_tail_x15_r0_body.s1366 PRE_first_tail_x15_r0_body.S1364 PRE_first_tail_x15_r0_body.S1365 PRE_first_tail_x15_r0_body.S1366 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1364 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1365 bytes) rows)
end Host.Load.Run.Tpl
