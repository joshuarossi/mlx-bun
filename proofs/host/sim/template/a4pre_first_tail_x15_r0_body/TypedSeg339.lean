import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1147
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg339 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1147).getD 0) PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.S1147 = some (PRE_first_tail_x15_r0_body.s1148, PRE_first_tail_x15_r0_body.S1148) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1147 bytes) rows)
end Host.Load.Run.Tpl
