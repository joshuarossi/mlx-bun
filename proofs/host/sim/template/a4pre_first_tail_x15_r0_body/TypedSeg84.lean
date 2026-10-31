import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK309
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK310
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg84 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 309).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 310).getD 0)) PRE_first_tail_x15_r0_body.s309 PRE_first_tail_x15_r0_body.S309 = some (PRE_first_tail_x15_r0_body.s311, PRE_first_tail_x15_r0_body.S311) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 309).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 310).getD 0) PRE_first_tail_x15_r0_body.s309 PRE_first_tail_x15_r0_body.s310 PRE_first_tail_x15_r0_body.s311 PRE_first_tail_x15_r0_body.S309 PRE_first_tail_x15_r0_body.S310 PRE_first_tail_x15_r0_body.S311 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK309 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK310 bytes) rows)
end Host.Load.Run.Tpl
