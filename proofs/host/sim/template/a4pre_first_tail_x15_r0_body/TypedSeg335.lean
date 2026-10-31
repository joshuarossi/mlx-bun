import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1242
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1243
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg335 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1242).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1243).getD 0)) PRE_first_tail_x15_r0_body.s1242 PRE_first_tail_x15_r0_body.S1242 = some (PRE_first_tail_x15_r0_body.s1244, PRE_first_tail_x15_r0_body.S1244) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1242).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1243).getD 0) PRE_first_tail_x15_r0_body.s1242 PRE_first_tail_x15_r0_body.s1243 PRE_first_tail_x15_r0_body.s1244 PRE_first_tail_x15_r0_body.S1242 PRE_first_tail_x15_r0_body.S1243 PRE_first_tail_x15_r0_body.S1244 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1242 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1243 bytes) rows)
end Host.Load.Run.Tpl
