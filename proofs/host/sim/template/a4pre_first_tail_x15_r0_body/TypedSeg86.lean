import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK318
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK319
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg86 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 318).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 319).getD 0)) PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.S318 = some (PRE_first_tail_x15_r0_body.s320, PRE_first_tail_x15_r0_body.S320) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 318).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 319).getD 0) PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.s319 PRE_first_tail_x15_r0_body.s320 PRE_first_tail_x15_r0_body.S318 PRE_first_tail_x15_r0_body.S319 PRE_first_tail_x15_r0_body.S320 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK318 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK319 bytes) rows)
end Host.Load.Run.Tpl
