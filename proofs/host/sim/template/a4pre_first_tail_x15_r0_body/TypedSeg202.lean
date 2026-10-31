import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK749
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK750
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg202 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 749).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 750).getD 0)) PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.S749 = some (PRE_first_tail_x15_r0_body.s751, PRE_first_tail_x15_r0_body.S751) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 749).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 750).getD 0) PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.s750 PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.S749 PRE_first_tail_x15_r0_body.S750 PRE_first_tail_x15_r0_body.S751 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK749 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK750 bytes) rows)
end Host.Load.Run.Tpl
