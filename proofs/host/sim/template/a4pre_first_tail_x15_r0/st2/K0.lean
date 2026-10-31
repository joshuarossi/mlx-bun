import host.sim.template.a4pre_first_tail_x15_r0.st2.H0
import host.sim.template.a4pre_first_tail_x15_r0.st2.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk PRE_first_tail_x15_r0.st2 PRE_first_tail_x15_r0.st2.okL 0
kernel_rfl PRE_first_tail_x15_r0.st2.last : interpS (step PRE_first_tail_x15_r0.st2.F PRE_first_tail_x15_r0.st2.s1).run PRE_first_tail_x15_r0.st2.S1 = some (PRE_first_tail_x15_r0.st2.s2, PRE_first_tail_x15_r0.st2.S2)
end Host.Load.Run.Tpl
