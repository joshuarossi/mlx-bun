import host.sim.template.a4pre_first_tail_x15_r0.SharedStart
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

kernel_rfl PRE_first_tail_x15_r0.nps1_eq :
  PRE_first_tail_x15_r0.s17 = PRE_setup_early_r0.s16
kernel_rfl PRE_first_tail_x15_r0.nps1_tab_eq :
  PRE_first_tail_x15_r0.S17.tab = PRE_setup_early_r0.S16.tab

end Host.Load.Run.Tpl
