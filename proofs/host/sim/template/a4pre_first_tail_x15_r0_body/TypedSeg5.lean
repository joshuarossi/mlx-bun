import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK17
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg5 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 17).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 18).getD 0)) PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17 = some (PRE_first_tail_x15_r0_body.s19, PRE_first_tail_x15_r0_body.S19) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 17).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 18).getD 0) PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.s18 PRE_first_tail_x15_r0_body.s19 PRE_first_tail_x15_r0_body.S17 PRE_first_tail_x15_r0_body.S18 PRE_first_tail_x15_r0_body.S19 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK17 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK18 bytes) rows)
end Host.Load.Run.Tpl
