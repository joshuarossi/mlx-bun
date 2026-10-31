import host.sim.template.a4pre_setup_early_r0.st0.H0
import host.sim.template.a4pre_setup_early_r0.st0.Ok
import host.sim.Chunk
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
sim_chunk PRE_setup_early_r0.st0 PRE_setup_early_r0.st0.okL 0
kernel_rfl PRE_setup_early_r0.st0.last : interpS (step PRE_setup_early_r0.st0.F PRE_setup_early_r0.st0.s1).run PRE_setup_early_r0.st0.S1 = some (PRE_setup_early_r0.st0.s2, PRE_setup_early_r0.st0.S2)
end Host.Load.Run.Tpl
