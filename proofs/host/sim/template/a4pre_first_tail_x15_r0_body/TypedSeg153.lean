import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK567
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK568
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg153 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 567).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 568).getD 0)) PRE_first_tail_x15_r0_body.s567 PRE_first_tail_x15_r0_body.S567 = some (PRE_first_tail_x15_r0_body.s569, PRE_first_tail_x15_r0_body.S569) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 567).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 568).getD 0) PRE_first_tail_x15_r0_body.s567 PRE_first_tail_x15_r0_body.s568 PRE_first_tail_x15_r0_body.s569 PRE_first_tail_x15_r0_body.S567 PRE_first_tail_x15_r0_body.S568 PRE_first_tail_x15_r0_body.S569 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK567 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK568 bytes) rows)
end Host.Load.Run.Tpl
