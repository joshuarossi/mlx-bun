import host.sim.template.a4pre_first_tail_x15_r0_body.MicroK1320_6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
sim_flat_boot_candidate PRE_first_tail_x15_r0_body.microK1320_7_left PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB390 from PRE_first_tail_x15_r0_body.microK1320_6.s1, PRE_first_tail_x15_r0_body.microK1320_6.S1 steps 128
end Host.Load.Run.Tpl
