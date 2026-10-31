import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK99
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg27 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 99).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 100).getD 0)) PRE_first_tail_x15_r0_body.s99 PRE_first_tail_x15_r0_body.S99 = some (PRE_first_tail_x15_r0_body.s101, PRE_first_tail_x15_r0_body.S101) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 99).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 100).getD 0) PRE_first_tail_x15_r0_body.s99 PRE_first_tail_x15_r0_body.s100 PRE_first_tail_x15_r0_body.s101 PRE_first_tail_x15_r0_body.S99 PRE_first_tail_x15_r0_body.S100 PRE_first_tail_x15_r0_body.S101 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK99 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK100 bytes) rows)
end Host.Load.Run.Tpl
