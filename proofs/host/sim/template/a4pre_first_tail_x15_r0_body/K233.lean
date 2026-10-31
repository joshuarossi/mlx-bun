import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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
boot_rfl PRE_first_tail_x15_r0_body.stepA252 from PRE_first_tail_x15_r0_body.s932 to PRE_first_tail_x15_r0_body.s933 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s932).run PRE_first_tail_x15_r0_body.S932 = some (PRE_first_tail_x15_r0_body.s933, PRE_first_tail_x15_r0_body.S933)
boot_rfl PRE_first_tail_x15_r0_body.patchB252 from PRE_first_tail_x15_r0_body.s933 to PRE_first_tail_x15_r0_body.s934 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s933).run PRE_first_tail_x15_r0_body.S933 = some (PRE_first_tail_x15_r0_body.s934, PRE_first_tail_x15_r0_body.S934)
boot_rfl PRE_first_tail_x15_r0_body.k934 from PRE_first_tail_x15_r0_body.s934 to PRE_first_tail_x15_r0_body.s935 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB252 ((nth? PRE_first_tail_x15_r0_body.ks 934).getD 0) PRE_first_tail_x15_r0_body.s934 PRE_first_tail_x15_r0_body.S934 = some (PRE_first_tail_x15_r0_body.s935, PRE_first_tail_x15_r0_body.S935)
boot_rfl PRE_first_tail_x15_r0_body.stepA253 from PRE_first_tail_x15_r0_body.s935 to PRE_first_tail_x15_r0_body.s936 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s935).run PRE_first_tail_x15_r0_body.S935 = some (PRE_first_tail_x15_r0_body.s936, PRE_first_tail_x15_r0_body.S936)
end Host.Load.Run.Tpl
