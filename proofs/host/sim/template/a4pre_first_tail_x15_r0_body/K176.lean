import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.stepA209 from PRE_first_tail_x15_r0_body.s704 to PRE_first_tail_x15_r0_body.s705 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s704).run PRE_first_tail_x15_r0_body.S704 = some (PRE_first_tail_x15_r0_body.s705, PRE_first_tail_x15_r0_body.S705)
boot_rfl PRE_first_tail_x15_r0_body.k707 from PRE_first_tail_x15_r0_body.s707 to PRE_first_tail_x15_r0_body.s708 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB209 ((nth? PRE_first_tail_x15_r0_body.ks 707).getD 0) PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.S707 = some (PRE_first_tail_x15_r0_body.s708, PRE_first_tail_x15_r0_body.S708)
end Host.Load.Run.Tpl
