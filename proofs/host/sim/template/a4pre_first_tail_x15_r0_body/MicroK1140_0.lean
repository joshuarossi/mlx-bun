import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.template.FlatMicro
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_first_tail_x15_r0_body.microFuel1140 : nth? PRE_first_tail_x15_r0_body.ks 1140 = some 5211

sim_flat_boot_candidate PRE_first_tail_x15_r0_body.microK1140_0 PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB337 from PRE_first_tail_x15_r0_body.s1140, PRE_first_tail_x15_r0_body.S1140 steps 256

end Host.Load.Run.Tpl
