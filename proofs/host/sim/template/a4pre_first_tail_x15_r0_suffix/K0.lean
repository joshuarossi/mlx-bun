import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_suffix.k0 from PRE_first_tail_x15_r0_suffix.s0 to PRE_first_tail_x15_r0_suffix.s1 : runOk PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.okB0 ((nth? PRE_first_tail_x15_r0_suffix.ks 0).getD 0) PRE_first_tail_x15_r0_suffix.s0 PRE_first_tail_x15_r0_suffix.S0 = some (PRE_first_tail_x15_r0_suffix.s1, PRE_first_tail_x15_r0_suffix.S1)
boot_rfl PRE_first_tail_x15_r0_suffix.stepA1 from PRE_first_tail_x15_r0_suffix.s1 to PRE_first_tail_x15_r0_suffix.s2 : interpS (step PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.s1).run PRE_first_tail_x15_r0_suffix.S1 = some (PRE_first_tail_x15_r0_suffix.s2, PRE_first_tail_x15_r0_suffix.S2)
end Host.Load.Run.Tpl
