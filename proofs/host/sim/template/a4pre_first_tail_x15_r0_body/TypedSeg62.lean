import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK231
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK232
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg62 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 231).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 232).getD 0)) PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.S231 = some (PRE_first_tail_x15_r0_body.s233, PRE_first_tail_x15_r0_body.S233) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 231).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 232).getD 0) PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.s232 PRE_first_tail_x15_r0_body.s233 PRE_first_tail_x15_r0_body.S231 PRE_first_tail_x15_r0_body.S232 PRE_first_tail_x15_r0_body.S233 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK231 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK232 bytes) rows)
end Host.Load.Run.Tpl
