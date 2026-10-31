import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK525
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg155 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 525).getD 0) PRE_first_tail_x15_r0_body.s525 PRE_first_tail_x15_r0_body.S525 = some (PRE_first_tail_x15_r0_body.s526, PRE_first_tail_x15_r0_body.S526) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK525 bytes) rows)
end Host.Load.Run.Tpl
