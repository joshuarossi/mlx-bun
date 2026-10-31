import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK437
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK438
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg118 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 437).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 438).getD 0)) PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.S437 = some (PRE_first_tail_x15_r0_body.s439, PRE_first_tail_x15_r0_body.S439) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 437).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 438).getD 0) PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.s438 PRE_first_tail_x15_r0_body.s439 PRE_first_tail_x15_r0_body.S437 PRE_first_tail_x15_r0_body.S438 PRE_first_tail_x15_r0_body.S439 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK437 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK438 bytes) rows)
end Host.Load.Run.Tpl
