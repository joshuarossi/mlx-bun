import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1350
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg399 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1350).getD 0) PRE_first_tail_x15_r0_body.s1350 PRE_first_tail_x15_r0_body.S1350 = some (PRE_first_tail_x15_r0_body.s1351, PRE_first_tail_x15_r0_body.S1351) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1350 bytes) rows)
end Host.Load.Run.Tpl
