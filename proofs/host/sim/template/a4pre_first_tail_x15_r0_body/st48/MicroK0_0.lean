import host.sim.template.a4pre_first_tail_x15_r0_body.st48.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.Ok
import host.sim.template.FlatMicro
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_first_tail_x15_r0_body.st48.microFuel0 : nth? PRE_first_tail_x15_r0_body.st48.ks 0 = some 10000

sim_flat_boot_candidate PRE_first_tail_x15_r0_body.st48.microK0_0 PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL from PRE_first_tail_x15_r0_body.st48.s0, PRE_first_tail_x15_r0_body.st48.S0 steps 512

end Host.Load.Run.Tpl
