import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK107
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK108
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg29 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 107).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 108).getD 0)) PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.S107 = some (PRE_first_tail_x15_r0_body.s109, PRE_first_tail_x15_r0_body.S109) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 107).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 108).getD 0) PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.s108 PRE_first_tail_x15_r0_body.s109 PRE_first_tail_x15_r0_body.S107 PRE_first_tail_x15_r0_body.S108 PRE_first_tail_x15_r0_body.S109 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK107 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK108 bytes) rows)
end Host.Load.Run.Tpl
