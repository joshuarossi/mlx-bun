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
boot_rfl PRE_first_tail_x15_r0_body.stepA275 from PRE_first_tail_x15_r0_body.s928 to PRE_first_tail_x15_r0_body.s929 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s928).run PRE_first_tail_x15_r0_body.S928 = some (PRE_first_tail_x15_r0_body.s929, PRE_first_tail_x15_r0_body.S929)
boot_rfl PRE_first_tail_x15_r0_body.patchB275 from PRE_first_tail_x15_r0_body.s929 to PRE_first_tail_x15_r0_body.s930 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s929).run PRE_first_tail_x15_r0_body.S929 = some (PRE_first_tail_x15_r0_body.s930, PRE_first_tail_x15_r0_body.S930)
boot_rfl PRE_first_tail_x15_r0_body.k930 from PRE_first_tail_x15_r0_body.s930 to PRE_first_tail_x15_r0_body.s931 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB275 ((nth? PRE_first_tail_x15_r0_body.ks 930).getD 0) PRE_first_tail_x15_r0_body.s930 PRE_first_tail_x15_r0_body.S930 = some (PRE_first_tail_x15_r0_body.s931, PRE_first_tail_x15_r0_body.S931)
boot_rfl PRE_first_tail_x15_r0_body.stepA276 from PRE_first_tail_x15_r0_body.s931 to PRE_first_tail_x15_r0_body.s932 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s931).run PRE_first_tail_x15_r0_body.S931 = some (PRE_first_tail_x15_r0_body.s932, PRE_first_tail_x15_r0_body.S932)
end Host.Load.Run.Tpl
