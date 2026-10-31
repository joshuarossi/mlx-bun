import host.sim.template.a4pre_first_tail_x15_r0_body.MicroK1140_19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

sim_flat_boot_finish PRE_first_tail_x15_r0_body.microK1140_20 PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB337 from PRE_first_tail_x15_r0_body.microK1140_19.s1, PRE_first_tail_x15_r0_body.microK1140_19.S1 steps 91 ending PRE_first_tail_x15_r0_body.s1141, PRE_first_tail_x15_r0_body.S1141

end Host.Load.Run.Tpl
