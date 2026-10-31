import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H43
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1401
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1402
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg378 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1401).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1402).getD 0)) PRE_first_tail_x15_r0_body.s1401 PRE_first_tail_x15_r0_body.S1401 = some (PRE_first_tail_x15_r0_body.s1403, PRE_first_tail_x15_r0_body.S1403) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1401).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1402).getD 0) PRE_first_tail_x15_r0_body.s1401 PRE_first_tail_x15_r0_body.s1402 PRE_first_tail_x15_r0_body.s1403 PRE_first_tail_x15_r0_body.S1401 PRE_first_tail_x15_r0_body.S1402 PRE_first_tail_x15_r0_body.S1403 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1401 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1402 bytes) rows)
end Host.Load.Run.Tpl
