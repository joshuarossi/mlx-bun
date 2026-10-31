import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK409
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg121 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 409).getD 0) PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.S409 = some (PRE_first_tail_x15_r0_body.s410, PRE_first_tail_x15_r0_body.S410) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK409 bytes) rows)
end Host.Load.Run.Tpl
