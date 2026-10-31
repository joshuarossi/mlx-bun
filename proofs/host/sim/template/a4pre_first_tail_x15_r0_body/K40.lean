import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.stepA48 from PRE_first_tail_x15_r0_body.s160 to PRE_first_tail_x15_r0_body.s161 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s160).run PRE_first_tail_x15_r0_body.S160 = some (PRE_first_tail_x15_r0_body.s161, PRE_first_tail_x15_r0_body.S161)
boot_rfl PRE_first_tail_x15_r0_body.patchB48 from PRE_first_tail_x15_r0_body.s161 to PRE_first_tail_x15_r0_body.s162 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s161).run PRE_first_tail_x15_r0_body.S161 = some (PRE_first_tail_x15_r0_body.s162, PRE_first_tail_x15_r0_body.S162)
boot_rfl PRE_first_tail_x15_r0_body.k162 from PRE_first_tail_x15_r0_body.s162 to PRE_first_tail_x15_r0_body.s163 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB48 ((nth? PRE_first_tail_x15_r0_body.ks 162).getD 0) PRE_first_tail_x15_r0_body.s162 PRE_first_tail_x15_r0_body.S162 = some (PRE_first_tail_x15_r0_body.s163, PRE_first_tail_x15_r0_body.S163)
boot_rfl PRE_first_tail_x15_r0_body.stepA49 from PRE_first_tail_x15_r0_body.s163 to PRE_first_tail_x15_r0_body.s164 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s163).run PRE_first_tail_x15_r0_body.S163 = some (PRE_first_tail_x15_r0_body.s164, PRE_first_tail_x15_r0_body.S164)
end Host.Load.Run.Tpl
