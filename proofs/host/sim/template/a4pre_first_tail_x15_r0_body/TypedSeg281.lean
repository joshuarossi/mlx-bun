import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H29
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK951
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg281 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 951).getD 0) PRE_first_tail_x15_r0_body.s951 PRE_first_tail_x15_r0_body.S951 = some (PRE_first_tail_x15_r0_body.s952, PRE_first_tail_x15_r0_body.S952) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK951 bytes) rows)
end Host.Load.Run.Tpl
