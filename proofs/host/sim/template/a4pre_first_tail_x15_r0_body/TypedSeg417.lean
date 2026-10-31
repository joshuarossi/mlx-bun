import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1545
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1546
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg417 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1545).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1546).getD 0)) PRE_first_tail_x15_r0_body.s1545 PRE_first_tail_x15_r0_body.S1545 = some (PRE_first_tail_x15_r0_body.s1547, PRE_first_tail_x15_r0_body.S1547) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1545).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1546).getD 0) PRE_first_tail_x15_r0_body.s1545 PRE_first_tail_x15_r0_body.s1546 PRE_first_tail_x15_r0_body.s1547 PRE_first_tail_x15_r0_body.S1545 PRE_first_tail_x15_r0_body.S1546 PRE_first_tail_x15_r0_body.S1547 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1545 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1546 bytes) rows)
end Host.Load.Run.Tpl
