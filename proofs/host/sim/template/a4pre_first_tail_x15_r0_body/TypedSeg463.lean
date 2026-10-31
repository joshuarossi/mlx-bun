import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1567
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg463 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1567).getD 0) PRE_first_tail_x15_r0_body.s1567 PRE_first_tail_x15_r0_body.S1567 = some (PRE_first_tail_x15_r0_body.s1568, PRE_first_tail_x15_r0_body.S1568) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1567 bytes) rows)
end Host.Load.Run.Tpl
