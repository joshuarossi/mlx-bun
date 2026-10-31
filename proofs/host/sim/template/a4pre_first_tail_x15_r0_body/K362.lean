import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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
boot_rfl PRE_first_tail_x15_r0_body.patchB391 from PRE_first_tail_x15_r0_body.s1448 to PRE_first_tail_x15_r0_body.s1449 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1448).run PRE_first_tail_x15_r0_body.S1448 = some (PRE_first_tail_x15_r0_body.s1449, PRE_first_tail_x15_r0_body.S1449)
boot_rfl PRE_first_tail_x15_r0_body.k1449 from PRE_first_tail_x15_r0_body.s1449 to PRE_first_tail_x15_r0_body.s1450 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB391 ((nth? PRE_first_tail_x15_r0_body.ks 1449).getD 0) PRE_first_tail_x15_r0_body.s1449 PRE_first_tail_x15_r0_body.S1449 = some (PRE_first_tail_x15_r0_body.s1450, PRE_first_tail_x15_r0_body.S1450)
boot_rfl PRE_first_tail_x15_r0_body.stepA392 from PRE_first_tail_x15_r0_body.s1450 to PRE_first_tail_x15_r0_body.s1451 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1450).run PRE_first_tail_x15_r0_body.S1450 = some (PRE_first_tail_x15_r0_body.s1451, PRE_first_tail_x15_r0_body.S1451)
boot_rfl PRE_first_tail_x15_r0_body.patchB392 from PRE_first_tail_x15_r0_body.s1451 to PRE_first_tail_x15_r0_body.s1452 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1451).run PRE_first_tail_x15_r0_body.S1451 = some (PRE_first_tail_x15_r0_body.s1452, PRE_first_tail_x15_r0_body.S1452)
end Host.Load.Run.Tpl
