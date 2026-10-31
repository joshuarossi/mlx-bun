import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H53
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1709
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1710
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg461 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 1709).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 1710).getD 0)) PRE_first_tail_x15_r0_body.s1709 PRE_first_tail_x15_r0_body.S1709 = some (PRE_first_tail_x15_r0_body.s1711, PRE_first_tail_x15_r0_body.S1711) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1709).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 1710).getD 0) PRE_first_tail_x15_r0_body.s1709 PRE_first_tail_x15_r0_body.s1710 PRE_first_tail_x15_r0_body.s1711 PRE_first_tail_x15_r0_body.S1709 PRE_first_tail_x15_r0_body.S1710 PRE_first_tail_x15_r0_body.S1711 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1709 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1710 bytes) rows)
end Host.Load.Run.Tpl
