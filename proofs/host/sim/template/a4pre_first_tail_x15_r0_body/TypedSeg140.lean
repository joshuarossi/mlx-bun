import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK519
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK520
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg140 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 519).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 520).getD 0)) PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519 = some (PRE_first_tail_x15_r0_body.s521, PRE_first_tail_x15_r0_body.S521) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 519).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 520).getD 0) PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s520 PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.S519 PRE_first_tail_x15_r0_body.S520 PRE_first_tail_x15_r0_body.S521 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK519 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK520 bytes) rows)
end Host.Load.Run.Tpl
