import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK806
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK807
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg217 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 806).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 807).getD 0)) PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.S806 = some (PRE_first_tail_x15_r0_body.s808, PRE_first_tail_x15_r0_body.S808) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 806).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 807).getD 0) PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.s807 PRE_first_tail_x15_r0_body.s808 PRE_first_tail_x15_r0_body.S806 PRE_first_tail_x15_r0_body.S807 PRE_first_tail_x15_r0_body.S808 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK806 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK807 bytes) rows)
end Host.Load.Run.Tpl
