import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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
boot_rfl PRE_first_tail_x15_r0_body.stepA227 from PRE_first_tail_x15_r0_body.s840 to PRE_first_tail_x15_r0_body.s841 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s840).run PRE_first_tail_x15_r0_body.S840 = some (PRE_first_tail_x15_r0_body.s841, PRE_first_tail_x15_r0_body.S841)
boot_rfl PRE_first_tail_x15_r0_body.patchB227 from PRE_first_tail_x15_r0_body.s841 to PRE_first_tail_x15_r0_body.s842 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s841).run PRE_first_tail_x15_r0_body.S841 = some (PRE_first_tail_x15_r0_body.s842, PRE_first_tail_x15_r0_body.S842)
boot_rfl PRE_first_tail_x15_r0_body.k842 from PRE_first_tail_x15_r0_body.s842 to PRE_first_tail_x15_r0_body.s843 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB227 ((nth? PRE_first_tail_x15_r0_body.ks 842).getD 0) PRE_first_tail_x15_r0_body.s842 PRE_first_tail_x15_r0_body.S842 = some (PRE_first_tail_x15_r0_body.s843, PRE_first_tail_x15_r0_body.S843)
boot_rfl PRE_first_tail_x15_r0_body.stepA228 from PRE_first_tail_x15_r0_body.s843 to PRE_first_tail_x15_r0_body.s844 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s843).run PRE_first_tail_x15_r0_body.S843 = some (PRE_first_tail_x15_r0_body.s844, PRE_first_tail_x15_r0_body.S844)
end Host.Load.Run.Tpl
