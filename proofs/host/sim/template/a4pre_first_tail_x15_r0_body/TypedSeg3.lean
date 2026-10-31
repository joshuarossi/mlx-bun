import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg3 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 9).getD 0) PRE_first_tail_x15_r0_body.s9 PRE_first_tail_x15_r0_body.S9 = some (PRE_first_tail_x15_r0_body.s10, PRE_first_tail_x15_r0_body.S10) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK9 bytes) rows)
end Host.Load.Run.Tpl
