import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.stepA178 from PRE_first_tail_x15_r0_body.s656 to PRE_first_tail_x15_r0_body.s657 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s656).run PRE_first_tail_x15_r0_body.S656 = some (PRE_first_tail_x15_r0_body.s657, PRE_first_tail_x15_r0_body.S657)
boot_rfl PRE_first_tail_x15_r0_body.k659 from PRE_first_tail_x15_r0_body.s659 to PRE_first_tail_x15_r0_body.s660 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB178 ((nth? PRE_first_tail_x15_r0_body.ks 659).getD 0) PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.S659 = some (PRE_first_tail_x15_r0_body.s660, PRE_first_tail_x15_r0_body.S660)
end Host.Load.Run.Tpl
