import host.sim.template.a4pre_first_tail_x15_r0_body.st48.MicroK0_12a
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
sim_flat_boot_choose PRE_first_tail_x15_r0_body.st48.microK0_12_right PRE_first_tail_x15_r0_body.st48.F from PRE_first_tail_x15_r0_body.st48.microK0_12_left.s1, PRE_first_tail_x15_r0_body.st48.microK0_12_left.S1 steps 256
sim_flat_boot_check PRE_first_tail_x15_r0_body.st48.microK0_12_right PRE_first_tail_x15_r0_body.st48.F PRE_first_tail_x15_r0_body.st48.okL from PRE_first_tail_x15_r0_body.st48.microK0_12_left.s1, PRE_first_tail_x15_r0_body.st48.microK0_12_left.S1 steps 256
end Host.Load.Run.Tpl
