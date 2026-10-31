import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.k816 from PRE_first_tail_x15_r0_body.s816 to PRE_first_tail_x15_r0_body.s817 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB220 ((nth? PRE_first_tail_x15_r0_body.ks 816).getD 0) PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.S816 = some (PRE_first_tail_x15_r0_body.s817, PRE_first_tail_x15_r0_body.S817)
boot_rfl PRE_first_tail_x15_r0_body.stepA221 from PRE_first_tail_x15_r0_body.s817 to PRE_first_tail_x15_r0_body.s818 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s817).run PRE_first_tail_x15_r0_body.S817 = some (PRE_first_tail_x15_r0_body.s818, PRE_first_tail_x15_r0_body.S818)
boot_rfl PRE_first_tail_x15_r0_body.patchB221 from PRE_first_tail_x15_r0_body.s818 to PRE_first_tail_x15_r0_body.s819 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s818).run PRE_first_tail_x15_r0_body.S818 = some (PRE_first_tail_x15_r0_body.s819, PRE_first_tail_x15_r0_body.S819)
boot_rfl PRE_first_tail_x15_r0_body.k819 from PRE_first_tail_x15_r0_body.s819 to PRE_first_tail_x15_r0_body.s820 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB221 ((nth? PRE_first_tail_x15_r0_body.ks 819).getD 0) PRE_first_tail_x15_r0_body.s819 PRE_first_tail_x15_r0_body.S819 = some (PRE_first_tail_x15_r0_body.s820, PRE_first_tail_x15_r0_body.S820)
end Host.Load.Run.Tpl
