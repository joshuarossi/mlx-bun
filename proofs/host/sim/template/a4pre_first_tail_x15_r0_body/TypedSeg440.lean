import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1489
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg440 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1489).getD 0) PRE_first_tail_x15_r0_body.s1489 PRE_first_tail_x15_r0_body.S1489 = some (PRE_first_tail_x15_r0_body.s1490, PRE_first_tail_x15_r0_body.S1490) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1489 bytes) rows)
end Host.Load.Run.Tpl
