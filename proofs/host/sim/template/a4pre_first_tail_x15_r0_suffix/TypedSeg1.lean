import host.sim.Chunk
import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_suffix.TypedK4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_suffix.bodyRunSeg1 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_suffix.F (PRE_first_tail_x15_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_suffix.ks 4).getD 0) PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.S4 = some (PRE_first_tail_x15_r0_suffix.s5, PRE_first_tail_x15_r0_suffix.S5) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_suffix.bodyK4 bytes) rows)
end Host.Load.Run.Tpl
