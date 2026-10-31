import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK999
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1000
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg270 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 999).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1000).getD 0)) PRE_first_tail_x15_r0_body.s999 PRE_first_tail_x15_r0_body.S999 = some (PRE_first_tail_x15_r0_body.s1001, PRE_first_tail_x15_r0_body.S1001) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 999).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1000).getD 0) PRE_first_tail_x15_r0_body.s999 PRE_first_tail_x15_r0_body.s1000 PRE_first_tail_x15_r0_body.s1001 PRE_first_tail_x15_r0_body.S999 PRE_first_tail_x15_r0_body.S1000 PRE_first_tail_x15_r0_body.S1001 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK999 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1000 bytes) rows)
end Host.Load.Run.Tpl
