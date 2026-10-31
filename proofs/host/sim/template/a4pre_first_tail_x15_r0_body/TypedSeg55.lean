import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK203
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK204
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg55 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 203).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 204).getD 0)) PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.S203 = some (PRE_first_tail_x15_r0_body.s205, PRE_first_tail_x15_r0_body.S205) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 203).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 204).getD 0) PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.s204 PRE_first_tail_x15_r0_body.s205 PRE_first_tail_x15_r0_body.S203 PRE_first_tail_x15_r0_body.S204 PRE_first_tail_x15_r0_body.S205 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK203 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK204 bytes) rows)
end Host.Load.Run.Tpl
