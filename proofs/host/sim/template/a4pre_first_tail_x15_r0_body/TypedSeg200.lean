import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK740
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK741
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg200 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 740).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 741).getD 0)) PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.S740 = some (PRE_first_tail_x15_r0_body.s742, PRE_first_tail_x15_r0_body.S742) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 740).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 741).getD 0) PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.s741 PRE_first_tail_x15_r0_body.s742 PRE_first_tail_x15_r0_body.S740 PRE_first_tail_x15_r0_body.S741 PRE_first_tail_x15_r0_body.S742 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK740 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK741 bytes) rows)
end Host.Load.Run.Tpl
