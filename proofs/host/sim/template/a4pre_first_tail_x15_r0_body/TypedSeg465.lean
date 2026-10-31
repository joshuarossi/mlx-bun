import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H54
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1726
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1727
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg465 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1726).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1727).getD 0)) PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.S1726 = some (PRE_first_tail_x15_r0_body.s1728, PRE_first_tail_x15_r0_body.S1728) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1726).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1727).getD 0) PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.s1727 PRE_first_tail_x15_r0_body.s1728 PRE_first_tail_x15_r0_body.S1726 PRE_first_tail_x15_r0_body.S1727 PRE_first_tail_x15_r0_body.S1728 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1726 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1727 bytes) rows)
end Host.Load.Run.Tpl
