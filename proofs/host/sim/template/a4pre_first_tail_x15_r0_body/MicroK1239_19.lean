import host.sim.template.a4pre_first_tail_x15_r0_body.MicroK1239_18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

sim_flat_boot_finish PRE_first_tail_x15_r0_body.microK1239_19 PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB366 from PRE_first_tail_x15_r0_body.microK1239_18.s1, PRE_first_tail_x15_r0_body.microK1239_18.S1 steps 59 ending PRE_first_tail_x15_r0_body.s1240, PRE_first_tail_x15_r0_body.S1240

end Host.Load.Run.Tpl
