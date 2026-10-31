import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.stepA14 from PRE_first_tail_x15_r0_body.s44 to PRE_first_tail_x15_r0_body.s45 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s44).run PRE_first_tail_x15_r0_body.S44 = some (PRE_first_tail_x15_r0_body.s45, PRE_first_tail_x15_r0_body.S45)
boot_rfl PRE_first_tail_x15_r0_body.patchB14 from PRE_first_tail_x15_r0_body.s45 to PRE_first_tail_x15_r0_body.s46 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s45).run PRE_first_tail_x15_r0_body.S45 = some (PRE_first_tail_x15_r0_body.s46, PRE_first_tail_x15_r0_body.S46)
boot_rfl PRE_first_tail_x15_r0_body.k46 from PRE_first_tail_x15_r0_body.s46 to PRE_first_tail_x15_r0_body.s47 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB14 ((nth? PRE_first_tail_x15_r0_body.ks 46).getD 0) PRE_first_tail_x15_r0_body.s46 PRE_first_tail_x15_r0_body.S46 = some (PRE_first_tail_x15_r0_body.s47, PRE_first_tail_x15_r0_body.S47)
boot_rfl PRE_first_tail_x15_r0_body.stepA15 from PRE_first_tail_x15_r0_body.s47 to PRE_first_tail_x15_r0_body.s48 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s47).run PRE_first_tail_x15_r0_body.S47 = some (PRE_first_tail_x15_r0_body.s48, PRE_first_tail_x15_r0_body.S48)
end Host.Load.Run.Tpl
