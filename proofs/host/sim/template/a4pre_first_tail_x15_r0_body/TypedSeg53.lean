import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK194
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK195
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg53 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 194).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 195).getD 0)) PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.S194 = some (PRE_first_tail_x15_r0_body.s196, PRE_first_tail_x15_r0_body.S196) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 194).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 195).getD 0) PRE_first_tail_x15_r0_body.s194 PRE_first_tail_x15_r0_body.s195 PRE_first_tail_x15_r0_body.s196 PRE_first_tail_x15_r0_body.S194 PRE_first_tail_x15_r0_body.S195 PRE_first_tail_x15_r0_body.S196 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK194 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK195 bytes) rows)
end Host.Load.Run.Tpl
