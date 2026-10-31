import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.template.a4pre_first_tail_x15_r0.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0.k40 from PRE_first_tail_x15_r0.s40 to PRE_first_tail_x15_r0.s41 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB13 ((nth? PRE_first_tail_x15_r0.ks 40).getD 0) PRE_first_tail_x15_r0.s40 PRE_first_tail_x15_r0.S40 = some (PRE_first_tail_x15_r0.s41, PRE_first_tail_x15_r0.S41)
end Host.Load.Run.Tpl
