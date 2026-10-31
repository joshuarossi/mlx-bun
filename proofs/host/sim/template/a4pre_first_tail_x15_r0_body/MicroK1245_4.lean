import host.sim.template.a4pre_first_tail_x15_r0_body.MicroK1245_3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

sim_flat_boot_candidate PRE_first_tail_x15_r0_body.microK1245_4 PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB368 from PRE_first_tail_x15_r0_body.microK1245_3.s1, PRE_first_tail_x15_r0_body.microK1245_3.S1 steps 256

end Host.Load.Run.Tpl
