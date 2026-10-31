import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK207
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK208
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg56 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 207).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 208).getD 0)) PRE_first_tail_x15_r0_body.s207 PRE_first_tail_x15_r0_body.S207 = some (PRE_first_tail_x15_r0_body.s209, PRE_first_tail_x15_r0_body.S209) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 207).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 208).getD 0) PRE_first_tail_x15_r0_body.s207 PRE_first_tail_x15_r0_body.s208 PRE_first_tail_x15_r0_body.s209 PRE_first_tail_x15_r0_body.S207 PRE_first_tail_x15_r0_body.S208 PRE_first_tail_x15_r0_body.S209 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK207 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK208 bytes) rows)
end Host.Load.Run.Tpl
