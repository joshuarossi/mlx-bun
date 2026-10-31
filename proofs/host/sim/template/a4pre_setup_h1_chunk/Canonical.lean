import host.sim.template.a4pre_setup_h1_chunk.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_setup_h1_chunk.start_state : PRE_setup_h1_chunk.s0 = PRE_first_tail_x15_r0.s4
kernel_rfl PRE_setup_h1_chunk.start_tab : PRE_setup_h1_chunk.S0.tab = PRE_first_tail_x15_r0.S4.tab
kernel_rfl PRE_setup_h1_chunk.canonical_state : PRE_setup_h1_chunk.s2 = PRE_first_tail_x15_r0.s6.ret (.num (.lit (F64.ofNat 1024)))
kernel_rfl PRE_setup_h1_chunk.canonical_tab : PRE_setup_h1_chunk.S2.tab = PRE_first_tail_x15_r0.S6.tab

end Host.Load.Run.Tpl
