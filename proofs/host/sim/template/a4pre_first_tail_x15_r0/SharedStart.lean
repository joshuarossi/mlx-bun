import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_setup_early_r0.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

kernel_rfl PRE_first_tail_x15_r0.call0_eq :
  PRE_first_tail_x15_r0.s4 = PRE_setup_early_r0.s4
kernel_rfl PRE_first_tail_x15_r0.call0_tab_eq :
  PRE_first_tail_x15_r0.S4.tab = PRE_setup_early_r0.S4.tab
kernel_rfl PRE_first_tail_x15_r0.chunk0_eq :
  PRE_first_tail_x15_r0.s6 = PRE_setup_early_r0.s6
kernel_rfl PRE_first_tail_x15_r0.chunk0_tab_eq :
  PRE_first_tail_x15_r0.S6.tab = PRE_setup_early_r0.S6.tab

end Host.Load.Run.Tpl
