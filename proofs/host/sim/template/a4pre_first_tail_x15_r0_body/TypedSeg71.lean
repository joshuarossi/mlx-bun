import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK240
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg71 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 240).getD 0) PRE_first_tail_x15_r0_body.s240 PRE_first_tail_x15_r0_body.S240 = some (PRE_first_tail_x15_r0_body.s241, PRE_first_tail_x15_r0_body.S241) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK240 bytes) rows)
end Host.Load.Run.Tpl
