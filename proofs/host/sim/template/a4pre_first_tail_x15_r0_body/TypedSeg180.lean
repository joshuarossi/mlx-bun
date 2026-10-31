import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK667
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK668
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg180 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) (((nth? PRE_first_tail_x15_r0_body.ks 667).getD 0) + ((nth? PRE_first_tail_x15_r0_body.ks 668).getD 0)) PRE_first_tail_x15_r0_body.s667 PRE_first_tail_x15_r0_body.S667 = some (PRE_first_tail_x15_r0_body.s669, PRE_first_tail_x15_r0_body.S669) :=
  runOk_trans PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 667).getD 0) ((nth? PRE_first_tail_x15_r0_body.ks 668).getD 0) PRE_first_tail_x15_r0_body.s667 PRE_first_tail_x15_r0_body.s668 PRE_first_tail_x15_r0_body.s669 PRE_first_tail_x15_r0_body.S667 PRE_first_tail_x15_r0_body.S668 PRE_first_tail_x15_r0_body.S669 ((congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK667 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK668 bytes) rows)
end Host.Load.Run.Tpl
