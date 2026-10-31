import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedK1797
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.bodyRunSeg485 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1797).getD 0) PRE_first_tail_x15_r0_body.s1797 PRE_first_tail_x15_r0_body.S1797 = some (PRE_first_tail_x15_r0_body.s1798, PRE_first_tail_x15_r0_body.S1798) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.bodyK1797 bytes) rows)
end Host.Load.Run.Tpl
